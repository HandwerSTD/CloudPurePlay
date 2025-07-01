import { Song } from "../CloudAPI/common/entities/Song"
import { PlayerStatus } from "../CloudAPI/common/model/Enum"

@ObservedV2
class PlayerStore {
  @Trace nowPlayingSong?: Song
  @Trace playTime: number = 0
  @Trace picUrl: string = ''
  @Trace currentLyric: string = ''
  @Trace currentLyricIndex: number = -1
  @Trace _status: PlayerStatus = PlayerStatus.STOPPED
  @Trace playMode: string = 'loop'
  @Trace isPersonalFm: boolean = false
  @Trace personalFmMode: number = 0


  get status(): PlayerStatus {
    return this._status
  }

  set status(newStatus: PlayerStatus) {
    this._status = newStatus
  }

  get isPlaying(): boolean {
    return this._status !== PlayerStatus.STOPPED
  }

  get isPaused(): boolean {
    return this._status === PlayerStatus.PAUSED
  }

  get isPlayerLoading(): boolean {
    return this._status === PlayerStatus.LOADING
  }
}

export default new PlayerStore()