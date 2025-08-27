import {
  CycleMode,
  PlayConstants, Song, SongAPIUtils, SongPlayResult, Song_INITIAL } from "@handwer/api_adapter"
import { EmitterUtil, FileUtil, LogUtil, RandomUtil, ToastUtil } from "@pura/harmony-utils"
import { FileUtils } from "../../../../utils/FileUtil"
import LyricUtils from "../../lyric/LyricUtils"
import AudioCacheUtils from "../system/AudioCacheUtils"
import AVPlayerUtils from "../system/AVPlayerUtils"
import AVSessionUtils from "../system/AVSessionUtils"
import { SongLike } from "./songLike"
import { fileIo } from "@kit.CoreFileKit"
import PlayQueueUtils from "../../queue/PlayQueueUtils"
import NowPlayingStore from "../NowPlayingStore"
import { playQueueStore } from "../../queue/PlayQueueStore"
import { UserManager } from "../../../Network/UserManager"
import Settings, { PreferenceUtils } from "../../../Preferences/PreferenceUtils"
import { SCPref } from "../../../../constants/PreferenceConstants"
import { Logger, DeviceCollaborationUtils, GlobalStore } from "../../../../../../../Index"
import { SCEmitter } from "../../../../exports"
import { SongConvertUtils } from "../../convert"
import { RetryUtil } from "../../../../utils/CommonUtil"


const TAG = '[playerControl] '

export enum SpecialPlayMode {
  DISABLED = -1,
  PERSONAL_FM_DEFAULT = 0,
  PERSONAL_FM_FAMILIAR = 1,
  PERSONAL_FM_EXPLORE = 2,
  HEART_MODE = 3,
  DAILY_LIST = 4
}

const playControlKV = new PreferenceUtils('PlayControl')

// 播放重试管理器
export class PlayRetryManager {
  private static retryCount: Map<string, number> = new Map()
  private static maxRetries: number = 2 // 最大重试次数（第1次播放 + 1次重试）
  
  /**
   * 记录播放失败
   * @param songId 歌曲ID
   * @returns 当前重试次数
   */
  static recordFailure(songId: string): number {
    const currentCount = PlayRetryManager.retryCount.get(songId) || 0
    const newCount = currentCount + 1
    PlayRetryManager.retryCount.set(songId, newCount)
    Logger.debug(TAG, `歌曲 ${songId} 播放失败，重试次数: ${newCount}`)
    return newCount
  }
  
  /**
   * 检查是否应该重试
   * @param songId 歌曲ID
   * @returns 是否应该重试
   */
  static shouldRetry(songId: string): boolean {
    const count = PlayRetryManager.retryCount.get(songId) || 0
    return count < PlayRetryManager.maxRetries
  }
  
  /**
   * 清除重试记录
   * @param songId 歌曲ID
   */
  static clearRetry(songId: string): void {
    PlayRetryManager.retryCount.delete(songId)
    Logger.debug(TAG, `清除歌曲 ${songId} 的重试记录`)
  }
  
  /**
   * 播放成功时清除重试记录
   * @param songId 歌曲ID
   */
  static onPlaySuccess(songId: string): void {
    PlayRetryManager.clearRetry(songId)
  }
  
  /**
   * 获取最大重试次数（供UI显示使用）
   */
  static getMaxRetries(): number {
    return PlayRetryManager.maxRetries
  }
}

let shouldPauseOnStart: boolean = false

export class PlayControl {
  static async init() {
    const store = NowPlayingStore;
    const kv = playControlKV;
    kv.init()
    store.currentSong = kv.get('CurrentSong') ?? store.currentSong
    store.currentArtists = kv.get('CurrentArtists') ?? store.currentArtists
    store.currentPic = kv.get('CurrentImage') ?? store.currentPic
    store.playMode = kv.get('PlayMode') ?? store.playMode
    store.specialPlayMode = kv.get('isPersonalFMState') ?? store.specialPlayMode
    Logger.debug(TAG, `load store info = ${JSON.stringify(store)}`)
    await AVPlayerUtils.init()
    if (store.currentSong !== Song_INITIAL) {
      store.isPlaying = true
      store.isPaused = true
      const playOnStart = Settings.get<boolean>(SCPref.autoPlayOnLaunch) ?? false
      if (!playOnStart) shouldPauseOnStart = true
      await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode)
    }
  }
  static async playMusicByUrl(song: Song, isLogged: boolean, picUrl: string = '', mode: number = 1) {
    const songId = song.id
    try {
      let artists = SongConvertUtils.getArtists(song.artists)
      await PlayControl.setPlayData(mode, song, artists)
      await AVPlayerUtils.reset()
      const isAccessible = SongAPIUtils.checkMusic(song.id).then(() => {
        if(!isAccessible) {
          ToastUtil.showToast('当前歌曲仅支持试听或无版权')
        }
      })
      SongLike.isThisSongLiked(song.id)
      let localPath: string = ''
      let tempArtists: string = artists
      const songNameLength = (typeof song.name === 'string' ? song.name.length : 0)
      if(songNameLength + artists.length >= 103) {
        try { tempArtists = artists.slice(0, 100 - songNameLength) }
        catch (e) { artists = '未知' }
      }
      if(!picUrl) {
        picUrl = await SongAPIUtils.getSongPicUrl(song)
      }
      await PlayControl.setPicUrl(picUrl)
      await PlayControl.saveCurrentSongInfo(mode, song, artists, picUrl)
      await LyricUtils.setLyric(song)

      if (shouldPauseOnStart) {
        NowPlayingStore.isPaused = true
        return;
      } // 设置完 metadata 就走，不动 AVSession

      await AVSessionUtils.setDefaultMetadata(song, artists)
      await AVSessionUtils.activate()
      await AVSessionUtils.bufferingState(0)

      await AVSessionUtils.setMetadata(song, artists, picUrl)

      localPath = await FileUtils.accessLocalFile(SongConvertUtils.sanitizeFileName(`${tempArtists} - ${song.name}`))

      if(localPath != '') { // 是否存在本地文件
        NowPlayingStore.isLocalFile = true
        await AVPlayerUtils.setUrl(localPath)
      } else {
        const quality: number | undefined = Settings.get(SCPref.audioQuality)
        const songPlay: SongPlayResult = await SongAPIUtils.getSongUrl(song.id, quality ? PlayConstants.QUALITY[quality] : "standard", isLogged)
        NowPlayingStore.isLocalFile = false
        let proxyUrl = await AudioCacheUtils.getProxyUrl(songPlay.data[0].url)
        Logger.debug(TAG, `playMusicByUrl got final data, set url = ${proxyUrl ?? songPlay.data[0].url}`)
        await AVPlayerUtils.setUrl(proxyUrl ?? songPlay.data[0].url)
      }
      
      // 播放成功，清除重试记录
      PlayRetryManager.onPlaySuccess(songId)
      DeviceCollaborationUtils.setCanMissionContinue(GlobalStore.contextFaker!)
    } catch (e) {
      LogUtil.error(TAG, '播放出错: ' + e)
      await PlayControl.handlePlaybackError(songId, song, isLogged, picUrl, mode)
    }
  }

  /**
   * 处理播放错误，支持重试机制
   * @param songId 歌曲ID
   * @param song 歌曲信息
   * @param isLogged 是否登录
   * @param picUrl 图片URL
   * @param mode 播放模式
   */
  static async handlePlaybackError(songId: string, song: Song, isLogged: boolean, picUrl: string, mode: number) {
    const retryCount = PlayRetryManager.recordFailure(songId)
    
    if (PlayRetryManager.shouldRetry(songId)) {
      Logger.debug(TAG, `开始重试播放歌曲 ${song.name}，第 ${retryCount} 次重试`)
      ToastUtil.showToast(`播放失败，正在重试... (${retryCount}/${PlayRetryManager.getMaxRetries()})`)
      
      // 使用 RetryUtil 进行重试，延迟1秒后重试
      try {
        await RetryUtil.retryWithResult(1, async () => {
          await PlayControl.playMusicByUrl(song, isLogged, picUrl, mode)
        }, 1000)
      } catch (retryError) {
        // 重试也失败了，记录并继续处理
        LogUtil.error(TAG, `重试播放失败: ${retryError}`)
      }
    } else {
      // 达到最大重试次数，暂停播放
      Logger.debug(TAG, `歌曲 ${song.name} 达到最大重试次数，暂停播放`)
      ToastUtil.showToast(`播放失败次数过多，已暂停播放`)
      PlayRetryManager.clearRetry(songId)
      
      // 暂停播放而不是跳到下一首
      await PlayControl.pauseMusic()
      NowPlayingStore.isPlaying = true
      NowPlayingStore.isPaused = true
    }
  }

  static async playMusicWithFile(song: Song, fileName: string) {
    const songId = song.id
    try {
      NowPlayingStore.isLiked = true
      const filesDir = FileUtils.getFilesDir()
      const fileUrl = filesDir + `/${fileName}`
      let file = await fileIo.open(fileUrl)
      let fdPath = 'fd://' + file.fd
      const metadata = await SongConvertUtils.fetchMetadata(fileUrl)
      const artistsString = SongConvertUtils.getArtists(song.artists)
      if(metadata) {
        song.duration = (metadata.duration) ? parseInt(metadata.duration) : 0
      }
      if(FileUtil.accessSync(fileUrl)) {
        await PlayControl.setPlayData(0, song, artistsString, fileName)
        await AVPlayerUtils.reset()
        let picUrl = song.id !== "0" ? `file://${filesDir}/pic/${song.id}.jpg` : ''
        await PlayControl.setPicUrl(picUrl)
        // Lyric
        if(song.id != "0") {
          let lyricString = await LyricUtils.readLyric(song.id.toString())
          LyricUtils.setLyricString(lyricString)
        } else {
          LyricUtils.setLyricString('')
        }
        NowPlayingStore.currentLyricIndex = 0
        EmitterUtil.post(SCEmitter.LyricUpdate, 'Lyric Updated')
        // AVSession
        await AVSessionUtils.setMetadata(song, artistsString, picUrl)
        await AVSessionUtils.activate()
        await AVSessionUtils.bufferingState(0)
        await PlayControl.saveCurrentSongInfo(0, song, artistsString, picUrl)
        await AVPlayerUtils.setUrl(fdPath)
        
        // 播放成功，清除重试记录
        PlayRetryManager.onPlaySuccess(songId)
      } else {
        ToastUtil.showToast('未找到文件')
        await PlayControl.handleLocalFileError(songId, song, fileName)
      }
    } catch (e) {
      LogUtil.error(TAG, '播放本地文件 PlayMusicWithFile 出错: ' + JSON.stringify(e))
      await PlayControl.handleLocalFileError(songId, song, fileName)
    }
  }

  /**
   * 处理本地文件播放错误
   * @param songId 歌曲ID
   * @param song 歌曲信息
   * @param fileName 文件名
   */
  static async handleLocalFileError(songId: string, song: Song, fileName: string) {
    const retryCount = PlayRetryManager.recordFailure(songId)
    
    if (PlayRetryManager.shouldRetry(songId)) {
      Logger.debug(TAG, `开始重试播放本地文件 ${fileName}，第 ${retryCount} 次重试`)
      ToastUtil.showToast(`本地文件播放失败，正在重试... (${retryCount}/${PlayRetryManager.getMaxRetries()})`)
      
      try {
        await RetryUtil.retryWithResult(1, async () => {
          await PlayControl.playMusicWithFile(song, fileName)
        }, 1000)
      } catch (retryError) {
        LogUtil.error(TAG, `重试播放本地文件失败: ${retryError}`)
      }
    } else {
      Logger.debug(TAG, `本地文件 ${fileName} 达到最大重试次数，暂停播放`)
      ToastUtil.showToast(`本地文件播放失败次数过多，已暂停播放`)
      PlayRetryManager.clearRetry(songId)
      
      await PlayControl.pauseMusic()
      NowPlayingStore.isPlaying = false
      NowPlayingStore.isPaused = true
    }
  }

  static async stopMusic() {
    AVPlayerUtils.stop().then(() => {
      NowPlayingStore.isPlaying = false
      AVPlayerUtils.release()
    })
  }

  static async pauseMusic() {
    AVPlayerUtils.pause()
    NowPlayingStore.isPaused = true
  }

  static async resumeMusic() {
    if (shouldPauseOnStart) {
      shouldPauseOnStart = false
      const store = NowPlayingStore
      await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode)
    }
    AVPlayerUtils.play()
    NowPlayingStore.isPaused = false
  }

  static seekMusic(time: number) {
    AVPlayerUtils.seek(time)
  }

  static async playQueue(index: number) {
    const queue = PlayQueueUtils.queue
    const playqueue = queue[index]
    PlayQueueUtils.setIndex(index)
    if(playqueue.playmode == 0) { // Play with file
      PlayControl.playMusicWithFile(playqueue.song as Song, playqueue.fileName)
    } else { // Play with url
      const isLogged: boolean | undefined = UserManager.isLogged
      PlayControl.playMusicByUrl(playqueue.song, isLogged ? true : false, playqueue.picUrl, playqueue.playmode)
    }
  }

  static async playPre() {
    let isLogged: boolean | undefined = UserManager.isLogged
    let cycleMode = await PlayControl.getCycleMode()
    if(PlayQueueUtils.pre()) {
      const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
      if(res.playmode == 0) {
        PlayControl.playMusicWithFile(res.song as Song, res.fileName)
      } else {
        PlayControl.playMusicByUrl(res.song, isLogged ? isLogged : false, res.picUrl, res.playmode)
      }
    } else {
      if(cycleMode == 2) { PlayControl.playQueue(PlayQueueUtils.getQueueLength() - 1) }
      else { ToastUtil.showToast('没有上一首了~') }
    }
  }

  static async playNext() {
    const isPersonalFm = NowPlayingStore.isPersonalFM
    if(isPersonalFm && !(PlayQueueUtils.currentQueueIndex < PlayQueueUtils.queue.length - 1)) {
      const personalFmMode = NowPlayingStore.personalFmMode
      let nextSong = await SongAPIUtils.getPersonalFmSong(personalFmMode)
      let artists = SongConvertUtils.getArtists(nextSong.artists)
      PlayQueueUtils.queueAdd(1, nextSong, artists, '')
      PlayControl.playQueue(PlayQueueUtils.currentQueueIndex + 1)
      return
    }
    let isLogged:boolean | undefined = UserManager.isLogged
    let cycleMode = await PlayControl.getCycleMode()
    if(cycleMode == CycleMode.random) {
      let queueLength = PlayQueueUtils.getQueueLength()
      let randomIndex = RandomUtil.getRandomInt(0, queueLength - 1)
      PlayControl.playQueue(randomIndex)
    }
    // 存在下一首歌曲
    else if(PlayQueueUtils.next()) {
      const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
      if(res.playmode == 0) {
        PlayControl.playMusicWithFile(res.song as Song, res.fileName)
      } else {
        Logger.debug(TAG, `playNext triggered playMusicByUrl`)
        PlayControl.playMusicByUrl(res.song, isLogged ?? false, res.picUrl, res.playmode)
      }
    } else {
      if(cycleMode == 2) { PlayControl.playQueue(0) }
      else {
        AVPlayerUtils.stop()
        ToastUtil.showToast('没有下一首了~')
      }
    }
  }

  static async completeDo() {
    const isPersonalFm = NowPlayingStore.isPersonalFM
    if(isPersonalFm && !(PlayQueueUtils.currentQueueIndex < PlayQueueUtils.queue.length - 1)) {
      const personalFmMode = NowPlayingStore.personalFmMode
      let nextSong = await SongAPIUtils.getPersonalFmSong(personalFmMode)
      let artists = SongConvertUtils.getArtists(nextSong.artists)
      PlayQueueUtils.queueAdd(1, nextSong, artists, '')
      PlayControl.playQueue(PlayQueueUtils.currentQueueIndex + 1)
      return
    }

    let cycleMode = await PlayControl.getCycleMode()
    // 顺序播放 & 顺序循环
    if(cycleMode == 0 || cycleMode == 2) {
      PlayControl.playNext()
    }
    // 单曲循环
    else if(cycleMode == 1) {
      let currentQueueIndex = PlayQueueUtils.currentQueueIndex
      PlayControl.playQueue(currentQueueIndex)
    }
    // 随机播放
    else if(cycleMode == 3) {
      let queueLength = PlayQueueUtils.getQueueLength()
      let randomIndex = RandomUtil.getRandomInt(0, queueLength - 1)
      PlayControl.playQueue(randomIndex)
    }
  }

  static async changeCycleMode(mode: number) {
    playQueueStore.cycleMode = mode
    const isPaused = NowPlayingStore.isPaused
    PlayQueueUtils.changeCycleMode(mode)
    if(isPaused) AVSessionUtils.pauseState(await PlayControl.getPlayTime())
    else AVSessionUtils.playState(await PlayControl.getPlayTime())
  }

  static async getCycleMode(): Promise<number> {
    const mode: number | undefined = playQueueStore.cycleMode
    if(mode) {
      return mode
    } else return 0
  }

  static async getPlayTime(): Promise<number> {
    let resTime = 0
    let elapsedTime:number | undefined = NowPlayingStore.playTime
    if(elapsedTime) {
      resTime = elapsedTime
    }
    return resTime
  }

  static async setPlayData(mode: number, song: Song, artists: string, fileName: string = '') {
    NowPlayingStore.isPlaying = true
    NowPlayingStore.isPaused = false
    NowPlayingStore.playMode = mode
    NowPlayingStore.fileName = fileName
    NowPlayingStore.currentSong = song
    NowPlayingStore.currentArtists = artists
    NowPlayingStore.playTime = 0
  }

  static async setPicUrl(picUrl: string) {
    NowPlayingStore.currentPic = picUrl
  }

  static async saveCurrentSongInfo(playMode: number, song: Song, artists: string, imgUrl: string | ResourceStr) {
    Logger.debug(TAG, `triggered to save current song: song = ${JSON.stringify(song)}`)
    playControlKV.put('PlayMode', playMode)
    playControlKV.put('CurrentSong', song)
    playControlKV.put('CurrentArtists', artists)
    playControlKV.put('CurrentImage', imgUrl)
    playControlKV.put('CurrentQueueIndex', PlayQueueUtils.currentQueueIndex)
    playControlKV.put('isPersonalFMState', NowPlayingStore.specialPlayMode)
  }
  static async clearCurrentSong() {
    await PlayControl.stopMusic()
    await PlayControl.saveCurrentSongInfo(0, Song_INITIAL, '','');
  }
}