import { PlayQueue, SongAPIUtils } from "@handwer/cloud_api"
import { DialogHelper } from "@pura/harmony-dialog"
import { LogUtil } from "@pura/harmony-utils"
import { Logger } from "../../../../exports"
import { UserManager } from "../../../Network/UserManager"
import UserStore from "../../../Network/UserStore"
import PlayQueueUtils from "../../queue/PlayQueueUtils"
import NowPlayingStore from "../NowPlayingStore"
import { SpecialPlayMode, PlayControl } from "../user/playControl"

const TAG = '[FeaturedPlayUtils]'

export class FeaturedPlayUtils {
  static async playPersonalizedFM() {
    const nps = NowPlayingStore
    if(!nps.isPlayerLoading) {
      nps.isPlayerLoading = true
      try {
        // AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, true)
        nps.specialPlayMode = SpecialPlayMode.PERSONAL_FM_DEFAULT
        await PlayQueueUtils.cleanQueue()
        // ToastUtil.showToast('开始播放私人FM')
        await PlayControl.playNext()
      } catch (e) {
        // ToastUtil.showToast('获取私人FM曲目失败')
      } finally {
        setTimeout(() => {
          nps.isPlayerLoading = false
        }, 1000)
      }
    } else {
      // ToastUtil.showToast('正在加载, 请稍后')
    }
  }
  static async playHeartMode(showToastCallback: (icon: ResourceStr, msg: ResourceStr) => void) {
    const nps = NowPlayingStore
    const user = UserStore
    if(UserManager.isLogged) {
      if(!nps.isPlayerLoading) {
        try {
          nps.isPlayerLoading = true
          showToastCallback($r('sys.symbol.opticaldisc_badge_heart'), $r('app.string.start_playing_heart_mode'))

          await SongAPIUtils.setHeartMode(PlayQueueUtils.getCurrentSong().id, user.userPlaylists[0].id,
            (): Promise<void> => {
              return PlayQueueUtils.cleanQueue();
            },
            (queue): Promise<void> => {
              return PlayQueueUtils.queueAddArray(queue);
            })
          Logger.debug(TAG, `set heart mode completed`)
          await PlayControl.playQueue(0)
          nps.specialPlayMode = SpecialPlayMode.HEART_MODE
        } catch (e) {
          showToastCallback($r('sys.symbol.opticaldisc_badge_heart'), $r('app.string.start_playing_heart_mode_failed'))
          Logger.error(TAG, `play heart mode failed: ${JSON.stringify(e)}`)
        } finally {
          setTimeout(() => {
            nps.isPlayerLoading = false
          }, 1000)
        }
      } else {
      }
    } else {
      showToastCallback($r('sys.symbol.person_head_on_circle'), $r('app.string.try_after_login'))
    }
  }
  static async playDailySongs(showToastCallback: (icon: ResourceStr, msg: ResourceStr) => void, todayIcon: ResourceStr) {
    const loadSongs = async () => {
      try {
        let result = await SongAPIUtils.getDailySongs()
        if(result.length < 3) { result = await SongAPIUtils.getDailySongs(false) }
        return result
      } catch (e) {
        LogUtil.error(TAG, 'Error fetching songs: ', e)
        return
      } finally {
      }
    }

    const id = DialogHelper.showLoadingDialog()

    const list = await loadSongs()

    DialogHelper.closeDialog(id)

    const playSong = async (songIndex: number) => {
      if (!list) {
        showToastCallback(todayIcon, $r('app.string.start_playing_daily_songs_failed'))
        return
      }
      try {
        let queue: PlayQueue[] = list.map((item): PlayQueue => ({
          playmode: 2,
          song: item.song,
          fileName: '',
          picUrl: item.picUrl
        }))
        await PlayQueueUtils.cleanQueue()
        await PlayQueueUtils.queueAddArray(queue)
        PlayControl.playQueue(songIndex)
        showToastCallback(todayIcon, $r('app.string.start_playing_daily_songs'))
        NowPlayingStore.specialPlayMode = SpecialPlayMode.DAILY_LIST
      } catch (e) {
        showToastCallback(todayIcon, $r('app.string.start_playing_daily_songs_failed'))
      }
    }
    await playSong(0)
  }
}