import { LyricStyle, LyricStyle_INITIAL, PLAYMODE, Song, Song_INITIAL } from '@handwer/cloud_api'
import { SpecialPlayMode as SpecialPlayMode } from './user/playControl'

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

  @Trace specialPlayMode: SpecialPlayMode = -1

  get isPersonalFM(): boolean {
    return this.specialPlayMode === SpecialPlayMode.PERSONAL_FM_DEFAULT
    || this.specialPlayMode === SpecialPlayMode.PERSONAL_FM_FAMILIAR
    || this.specialPlayMode === SpecialPlayMode.PERSONAL_FM_EXPLORE
  }
  get isHeartMode(): boolean {
    return this.specialPlayMode === SpecialPlayMode.HEART_MODE
  }
  get isDailyListMode(): boolean {
    return this.specialPlayMode === SpecialPlayMode.DAILY_LIST
  }
  get personalFmMode() {
    return this.specialPlayMode
  }
}

export default new NowPlayingStore()