import { LyricStyle, LyricStyle_INITIAL, PLAYMODE, Song, Song_INITIAL } from '@handwer/api_adapter'
import { PlaySourceData, PlaySourceDataType } from './user/playControl'
interface ExportableNowPlayingStore {
  isPlayerLoading: boolean

  currentSong: Song
  currentArtists: string
  currentPic: ResourceStr
  isLiked: boolean

  playTime: number
  isPlaying: boolean
  isPaused: boolean

  currentLyric: string
  currentLyricIndex: number
  lyricStyle: LyricStyle
  mixWithOthers: boolean

  playMode: PLAYMODE
  fileName: string
  isLocalFile: boolean

  PlaySourceData: PlaySourceData
}

@ObservedV2
class NowPlayingStore {
  @Trace isPlayerLoading: boolean = false

  @Trace currentSong: Song = Song_INITIAL
  @Trace currentArtists: string = ''
  @Trace currentPic: ResourceStr  = ''
  @Trace isLiked: boolean = false

  @Trace playTime: number = 0
  @Trace isPlaying: boolean = false
  @Trace isPaused: boolean = false

  @Trace currentLyric: string = ''
  @Trace currentLyricIndex: number = 0
  @Trace lyricStyle: LyricStyle = LyricStyle_INITIAL
  @Trace mixWithOthers: boolean = false

  @Trace playMode: PLAYMODE = 0
  @Trace fileName: string = ''
  @Trace isLocalFile: boolean = false

  @Trace nowPlayingSource: PlaySourceData = new PlaySourceData(-1, '')

  get isPersonalFM(): boolean {
    return this.nowPlayingSource.PlaySourceDataType === PlaySourceDataType.PERSONAL_FM_DEFAULT
  }
  get isHeartMode(): boolean {
    return this.nowPlayingSource.PlaySourceDataType === PlaySourceDataType.HEART_MODE
  }
  get isDailyListMode(): boolean {
    return this.nowPlayingSource.PlaySourceDataType === PlaySourceDataType.DAILY_LIST
  }
  get personalFmMode() {
    return this.nowPlayingSource.PlaySourceDataType
  }
  get isPlayingOuter(): boolean {
    return this.nowPlayingSource.PlaySourceDataType === PlaySourceDataType.OUTER
  }

  /** 转换为可导出的对象 */
  toExportable(): ExportableNowPlayingStore {
    return {
      isPlayerLoading: this.isPlayerLoading,
      currentSong: this.currentSong,
      currentArtists: this.currentArtists,
      currentPic: this.currentPic,
      isLiked: this.isLiked,

      playTime: this.playTime,
      isPlaying: this.isPlaying,
      isPaused: this.isPaused,

      currentLyric: this.currentLyric,
      currentLyricIndex: this.currentLyricIndex,
      lyricStyle: this.lyricStyle,
      mixWithOthers: this.mixWithOthers,

      playMode: this.playMode,
      fileName: this.fileName,
      isLocalFile: this.isLocalFile,

      PlaySourceData: this.nowPlayingSource,
    }
  }

  /** 从导出的对象恢复到当前单例 */
  fromExportable(data: ExportableNowPlayingStore): void {
    this.isPlayerLoading = data.isPlayerLoading ?? false

    this.currentSong = data.currentSong ?? Song_INITIAL
    this.currentArtists = data.currentArtists ?? ''
    this.currentPic = data.currentPic ?? ''
    this.isLiked = data.isLiked ?? false

    this.playTime = data.playTime ?? 0
    this.isPlaying = data.isPlaying ?? false
    this.isPaused = data.isPaused ?? false

    this.currentLyric = data.currentLyric ?? ''
    this.currentLyricIndex = data.currentLyricIndex ?? 0
    this.lyricStyle = data.lyricStyle ?? LyricStyle_INITIAL
    this.mixWithOthers = data.mixWithOthers ?? false

    this.playMode = data.playMode ?? 0
    this.fileName = data.fileName ?? ''
    this.isLocalFile = data.isLocalFile ?? false

    this.nowPlayingSource = data.PlaySourceData ?? new PlaySourceData(-1, '')
  }
}


export default new NowPlayingStore()