import { Song, Song_INITIAL } from "@handwer/api_adapter";
import { avSession } from "@kit.AVSessionKit";
import { LogUtil } from "@pura/harmony-utils";
import LyricUtils from "../../lyric/LyricUtils";
import NowPlayingStore from "../NowPlayingStore";
import { playQueueStore } from '../../queue/PlayQueueStore'
import { PlayControl } from "../user/playControl";
import { SongLike } from "../user/songLike";
import PlayQueueUtils from "../../queue/PlayQueueUtils";

/**
 * AVSession 播控中心工具类
 */
const TAG = '[AVSessionUtils] '

class AVSessionUtils {
  private instance: avSession.AVSession | null = null
  private isActivating = false
  private cycleMode: number = 0
  private currentSong: Song = Song_INITIAL
  private currentArtists: string = ''
  private currentPic: string | ResourceStr  = ''
  private lyric: string = ''
  private controller: avSession.AVSessionController | null = null

  private async getInstance(): Promise<avSession.AVSession> {
    if(!this.instance) {
      this.instance = await this.createSession()
    }
    return this.instance
  }

  async getController(): Promise<avSession.AVSessionController> {
    if(!this.controller) {
      const instance = await this.getInstance()
      this.controller = await instance.getController()
    }
    return this.controller
  }

  async createSession(): Promise<avSession.AVSession> {
    let session = await avSession.createAVSession(getContext(), 'cloudmusic', 'audio')
    try {
      let cycleMode: number = playQueueStore.cycleMode
      this.cycleMode = cycleMode

      session.on('play', () => {
        PlayControl.resumeMusic()
      });
      session.on('pause', () => {
        PlayControl.pauseMusic()
      });
      session.on('playNext', () => {
        PlayControl.playNext()
      });
      session.on('playPrevious', () => {
        PlayControl.playPre()
      });
      session.on('seek', (time) => {
        PlayControl.seekMusic(time)
      });
      session.on('toggleFavorite', (isFavor) => {
        SongLike.likeThisSong().then(async () => {
          (await this.getInstance()).setAVPlaybackState({ isFavorite: this.isFavorite() })
        })
      })
      session.on('setLoopMode', (loopMode) => {
        // if(loopMode == 0) { PlayQueueUtils.changeCycleMode(1) }
        // else if(loopMode == 1) { changeCycleMode(2) }
        // else if(loopMode == 2) { changeCycleMode(3) }
        // else { changeCycleMode(0) }
        PlayQueueUtils.changeCycleMode((loopMode + 1) % 4)
      })

      this.controller = await session.getController()

    } catch (e) {
      LogUtil.error(TAG, '创建session失败 / create session error: ' + JSON.stringify(e))
    } finally {
      return session
    }
  }

  async sendControlCommand(command: avSession.AVControlCommand) {
    const controller = await this.getController()
    controller.sendControlCommand(command, () => {})
  }

  async setDefaultMetadata(song: Song, artists: string) {
    this.currentSong = song
    this.currentArtists = artists
    let instance = await this.getInstance()
    instance.setAVMetadata({
      assetId: `${song.id}`,
      title: song.name,
      artist: artists,
      duration: song.duration
    })
  }

  /**
   * 设置媒体信息
   * @param song
   * @param artists
   * @param picUrl
   */
  async setMetadata(song: Song, artists: string, picUrl: string) {
    this.currentSong = song
    this.currentArtists = artists
    this.currentPic = picUrl
    this.lyric = LyricUtils.lyric.lrc.lyric

    let metadata: avSession.AVMetadata = {
      assetId: `${song.id}`,
      title: song.name,
      mediaImage: picUrl.startsWith('http') ? `${picUrl}?param=256y256` : picUrl,
      artist: artists != 'null' ? artists : '未知',
      duration: song.duration,
      lyric: this.lyric
    };

    const instance = await this.getInstance()
    instance.setAVMetadata(metadata)
    let controller = await instance.getController()
  }

  /**
   * 启用
   */
  async activate() {
    if (this.isActivating) return // 防止重复调用
    try {
      const instance = await this.getInstance()
      await instance.activate()
      this.isActivating = true
    } catch (e) {
      LogUtil.error(TAG, 'Error while activating: ' + e)
      this.isActivating = false
    }
  }

  /**
   * 停用
   */
  async deactivate() {
    if (this.isActivating) return // 等待激活完成
    try {
      const instance = await this.getInstance()
      await instance.activate()
      this.isActivating = false
    } catch (e) {
      LogUtil.error(TAG, 'Error while deactivating' + e)
    }
  }

  private isFavorite(): boolean {
    const is: boolean = NowPlayingStore.isLiked
    return is
  }

  /**
   * 设置为播放状态
   */
  async playState(time: number) {
    let loopMode = await getLoopMode()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };

    (await this.getInstance()).setAVPlaybackState(playbackState)
  }

  /**
   * 设置为暂停状态
   */
  async pauseState(time: number) {
    let loopMode = await getLoopMode()
    let pausedState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };
    (await this.getInstance()).setAVPlaybackState(pausedState);
  }

  /**
   * 设置为缓冲状态
   */
  async bufferingState(time: number) {
    let loopMode = await getLoopMode()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_BUFFERING,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime(),
      }
    };
    (await this.getInstance()).setAVPlaybackState(playbackState)
  }
}

async function getLoopMode(): Promise<number> {
  return playQueueStore.cycleMode
}

const avSessionUtils = new AVSessionUtils()
export default avSessionUtils as AVSessionUtils