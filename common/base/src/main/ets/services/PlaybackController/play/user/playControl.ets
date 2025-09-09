import {
  APIConfigUtils,
  CycleMode,
  InstanceSwitcher,
  PlayConstants,
  PLAYMODE,
  Song, SongAPIUtils, SongPlayResult, Song_INITIAL,
  INSTANCE_TYPE,
  CustomAPIConfig,
  NavidromeRequestContext,
  Cloud_RequestContext,
  RealIP_INITIAL } from "@handwer/api_adapter"
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
import { SCEmitter, UserStore } from "../../../../exports"
import { SongConvertUtils } from "../../convert"
import { RetryUtil } from "../../../../utils/CommonUtil"
import { url } from "@kit.ArkTS"


const TAG = '[playerControl] '

export enum PlaySourceDataType {
  DISABLED = -1,
  PERSONAL_FM_DEFAULT = 0,
  PERSONAL_FM_FAMILIAR = 1,
  PERSONAL_FM_EXPLORE = 2,
  HEART_MODE = 3,
  DAILY_LIST = 4,
  PLAY_LIST = 5,
  ALBUM = 6,
  OUTER = 7
}

@ObservedV2
export class PlaySourceData {
  @Trace PlaySourceDataType: PlaySourceDataType = -1
  @Trace PlaySourceDataId: string = ''

  constructor(type: PlaySourceDataType, id: string) {
    this.PlaySourceDataType = type
    this.PlaySourceDataId = id
  }

  static get PERSONAL_FM() {
    return new PlaySourceData(PlaySourceDataType.PERSONAL_FM_DEFAULT, '')
  }
  static get HEART_MODE() {
    return new PlaySourceData(PlaySourceDataType.HEART_MODE, '')
  }
  static get DAILY_LIST() {
    return new PlaySourceData(PlaySourceDataType.DAILY_LIST, '')
  }
  static get DISABLED() {
    return new PlaySourceData(-1, '')
  }
}

const playControlKV = new PreferenceUtils('PlayControl')

// 临时API上下文管理器
class TemporaryAPIContext {
  private static originalInstanceType: INSTANCE_TYPE | null = null
  private static originalRequestContext: Object | null = null
  private static isActive: boolean = false
  
  /**
   * 设置临时API上下文
   * @param customAPI 自定义API配置
   */
  static async setupTemporary(customAPI: CustomAPIConfig): Promise<void> {
    if (TemporaryAPIContext.isActive) {
      Logger.warn(TAG, '临时API上下文已激活，跳过重复设置')
      return
    }
    
    try {
      // 保存当前配置
      TemporaryAPIContext.originalInstanceType = InstanceSwitcher.InstanceType
      TemporaryAPIContext.originalRequestContext = APIConfigUtils.NowRequestContext
      
      // 切换到自定义API
      InstanceSwitcher.InstanceType = customAPI.apiType as INSTANCE_TYPE
      
      // 根据API类型设置对应的请求上下文
      if (customAPI.apiType === INSTANCE_TYPE.NAVIDROME) {
        const navidromeContext: NavidromeRequestContext = {
          baseUrl: customAPI.apiAddr,
          username: customAPI.apiUserName,
          password: customAPI.apiPasswd
        }
        APIConfigUtils.loadRequestContext(navidromeContext)
      } else if (customAPI.apiType === INSTANCE_TYPE.CLOUD) {
        const cloudContext: Cloud_RequestContext = {
          baseUrl: customAPI.apiAddr,
          cookie: { 
            cookie: customAPI.apiPasswd,
            customCookie: ''
          },
          realIp: {
            toggle: false,
            realIp: '116.25.146.177'
          }
        }
        APIConfigUtils.loadRequestContext(cloudContext)
      }
      
      TemporaryAPIContext.isActive = true
      Logger.debug(TAG, `临时API上下文已设置: ${customAPI.apiAddr}`)
    } catch (error) {
      Logger.error(TAG, `设置临时API上下文失败: ${error}`)
      throw Error(error)
    }
  }
  
  /**
   * 恢复原始配置
   */
  static async restore(): Promise<void> {
    if (!TemporaryAPIContext.isActive) {
      return
    }
    
    try {
      if (TemporaryAPIContext.originalInstanceType !== null) {
        InstanceSwitcher.InstanceType = TemporaryAPIContext.originalInstanceType
      }
      
      if (TemporaryAPIContext.originalRequestContext) {
        APIConfigUtils.loadRequestContext(TemporaryAPIContext.originalRequestContext)
      }
      
      TemporaryAPIContext.isActive = false
      TemporaryAPIContext.originalInstanceType = null
      TemporaryAPIContext.originalRequestContext = null
      
      Logger.debug(TAG, '临时API上下文已恢复')
    } catch (error) {
      Logger.error(TAG, `恢复API上下文失败: ${error}`)
    }
  }
  
  /**
   * 检查是否正在使用临时API上下文
   */
  static get isUsingTemporary(): boolean {
    return TemporaryAPIContext.isActive
  }
}

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
    store.nowPlayingSource = kv.get('nowPlayingSource') ?? store.nowPlayingSource
    Logger.debug(TAG, `load store info = ${JSON.stringify(store)}`)
    await AVPlayerUtils.init()
    if (store.currentSong !== Song_INITIAL) {
      store.isPlaying = true
      store.isPaused = true
      const playOnStart = Settings.get<boolean>(SCPref.autoPlayOnLaunch) ?? false
      if (!playOnStart) shouldPauseOnStart = true
      await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode, !playOnStart)
    }
  }
  static async playMusicByUrl(song: Song, isLogged: boolean, picUrl: string = '', mode: number = 1, pauseOnStart: boolean = false) {
    const songId = song.id
    let usingCustomAPI = false
    
    try {
      // 检查是否需要使用自定义API
      if (song.customAPI) {
        Logger.debug(TAG, `检测到自定义API配置，切换API上下文: ${song.customAPI.apiAddr}`)
        await TemporaryAPIContext.setupTemporary(song.customAPI)
        usingCustomAPI = true
      }
      
      let artists = SongConvertUtils.getArtists(song.artists)
      await PlayControl.setPlayData(mode, song, artists)
      await AVPlayerUtils.reset()
      
      const isAccessible = SongAPIUtils.checkMusic(song.id).then(() => {
        if(!isAccessible) {
          ToastUtil.showToast('当前歌曲仅支持试听或无版权')
        }
      })
      if (!song.customAPI) {
        SongLike.isThisSongLiked(song.id)
      } else {
        NowPlayingStore.isLiked = false
      }
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

      if (pauseOnStart) {
        NowPlayingStore.isPaused = true
        return;
        // 设置完 metadata 就走，不动 AVSession
      } else {
        shouldPauseOnStart = false
        // 不是首次播放了，可以关掉正常进行了
      }

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
        Logger.debug(TAG, `playMusicByUrl got final data, set url`)
        await AVPlayerUtils.setUrl(proxyUrl ?? songPlay.data[0].url)
      }
      
      // 播放成功，清除重试记录
      PlayRetryManager.onPlaySuccess(songId)
      DeviceCollaborationUtils.setCanMissionContinue(GlobalStore.contextFaker!)
      if (usingCustomAPI) {
        NowPlayingStore.nowPlayingSource = new PlaySourceData(PlaySourceDataType.OUTER, song.id)
      } else {
        if (NowPlayingStore.nowPlayingSource.PlaySourceDataType === PlaySourceDataType.OUTER) {
          NowPlayingStore.nowPlayingSource = new PlaySourceData(PlaySourceDataType.DISABLED, song.id)
        }
      }
    } catch (e) {
      LogUtil.error(TAG, '播放出错: ' + e)
      await PlayControl.handlePlaybackError(songId, song, isLogged, picUrl, mode)
    } finally {
      // 确保在任何情况下都恢复原始配置
      if (usingCustomAPI) {
        await TemporaryAPIContext.restore()
      }
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
      NowPlayingStore.isPaused = false
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

  static async seekMusic(time: number) {
    if (shouldPauseOnStart) {
      shouldPauseOnStart = false
      const store = NowPlayingStore
      await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode)
      setTimeout(() => {
        AVPlayerUtils.seek(time)
      }, 300)
    } else {
      await AVPlayerUtils.seek(time)
    }
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
        if (NowPlayingStore.playTime >= NowPlayingStore.currentSong.duration) {
          // 和启动暂停播放一致的逻辑
          shouldPauseOnStart = true;
          const store = NowPlayingStore
          await PlayControl.playMusicByUrl(store.currentSong, UserManager.isLogged, store.currentPic as string, store.playMode, true)
          NowPlayingStore.isPaused = true
          AVSessionUtils.pauseState(0)
        }
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
    playControlKV.put('nowPlayingSource', NowPlayingStore.nowPlayingSource)
  }
  static async clearCurrentSong() {
    await PlayControl.stopMusic()
    await PlayControl.setPlayData(0, Song_INITIAL, '')
    NowPlayingStore.isPlaying = false
    await PlayControl.saveCurrentSongInfo(0, Song_INITIAL, '','');
    await AVSessionUtils.destroy()
  }

  static generateShareLink() {
    const song = JSON.parse(JSON.stringify(NowPlayingStore.currentSong)) as Song
    const config = APIConfigUtils.requestConfig
    song.customAPI = {
      apiType: InstanceSwitcher.InstanceType,
      apiAddr: config.apiAddr,
      apiUserName: config.apiUser,
      apiPasswd: config.apiPasswd
    }
    const data = encodeURIComponent(JSON.stringify(song))
    return `cloudpureplay://shareSong/share?type=plain&songName=${encodeURIComponent(song.name)}&data=${data}`
  }

  static async playSongFromShareLink(link: string): Promise<[boolean, string]> {
    try {
      const u = url.URL.parseURL(link)
      const type = u.params.get('type')
      const data = JSON.parse(u.params.get('data') ?? '{}') as Song
      
      if (type === 'plain' && data.customAPI) {
        Logger.debug(TAG, `从分享链接播放歌曲: ${data.name}，使用自定义API: ${data.customAPI.apiAddr}`)
        
        // 直接调用 playMusicByUrl，它会自动处理 customAPI
        await PlayQueueUtils.queueAdd(PLAYMODE.SINGLE, data, SongConvertUtils.getArtists(data.artists), '', data.album.picUrl)
        await PlayControl.playNext()
        
        return [true, '播放成功']
      } else {
        return [false, '无效的分享链接或缺少API配置']
      }
    } catch (error) {
      Logger.error(TAG, `播放分享歌曲失败: ${error}`)
      return [false, `播放失败: ${error}`]
    }
  }
}