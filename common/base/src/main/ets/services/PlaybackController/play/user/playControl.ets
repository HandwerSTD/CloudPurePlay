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
import NowPlayingStore from "../NowPlayingStore.ets"
import { playQueueStore } from "../../queue/PlayQueueStore"
import { UserManager } from "../../../Network/UserManager"
import Settings, { PreferenceUtils } from "../../../Preferences/PreferenceUtils"
import { SCPref } from "../../../../constants/PreferenceConstants"
import { Logger } from "../../../../../../../Index"
import { SCEmitter } from "../../../../exports"
import { SongConvertUtils } from "../../convert"


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
      await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode)
    }
  }
  static async playMusicByUrl(song: Song, isLogged: boolean, picUrl: string = '', mode: number = 1) {
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
      if(song.name.length + artists.length >= 103) {
        try { tempArtists = artists.slice(0, 100 - song.name.length) }
        catch (e) { artists = '未知' }
      }
      await AVSessionUtils.setDefaultMetadata(song, artists)
      await AVSessionUtils.activate()
      await AVSessionUtils.bufferingState(0)

      if(!picUrl) {
        picUrl = await SongAPIUtils.getSongPicUrl(song)
      }
      await PlayControl.setPicUrl(picUrl)
      await PlayControl.saveCurrentSongInfo(mode, song, artists, picUrl)
      await LyricUtils.setLyric(song)
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
    } catch (e) {
      LogUtil.error(TAG, '播放出错: ' + e)
      await PlayControl.playNext()
    }
  }

  static async playMusicWithFile(song: Song, fileName: string) {
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
      } else {
        ToastUtil.showToast('未找到文件')
        PlayControl.playNext()
      }
    } catch (e) {
      LogUtil.error(TAG, '播放本地文件 PlayMusicWithFile 出错: ' + JSON.stringify(e))
      PlayControl.playNext()
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