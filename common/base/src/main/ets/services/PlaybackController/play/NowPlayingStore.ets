import { LyricStyle, LyricStyle_INITIAL, PLAYMODE, Song, Song_INITIAL } from '@handwer/cloud_api'
import { PersonalFMState } from './user/playControl'

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

  @Trace isPersonalFMState: PersonalFMState = -1

  get isPersonalFM(): boolean {
    return this.isPersonalFMState !== PersonalFMState.DISABLED
  }
  get personalFmMode() {
    return this.isPersonalFMState
  }
}

export default new NowPlayingStore()