import { SongAPIUtils } from "@handwer/cloud_api"
import { UserManager } from "../../../Network/UserManager"
import UserStore from "../../../Network/UserStore"
import PlayQueueUtils from "../../queue/PlayQueueUtils"
import NowPlayingStore from "../NowPlayingStore"
import { PersonalFMState, PlayControl } from "../user/playControl"

export class FeaturedPlayUtils {
  static async playPersonalizedFM() {
    const nps = NowPlayingStore
    if(!nps.isPlayerLoading) {
      nps.isPlayerLoading = true
      try {
        // AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, true)
        nps.isPersonalFMState = PersonalFMState.DEFAULT
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
  static async playHeartMode() {
    const nps = NowPlayingStore
    const user = UserStore
    if(UserManager.isLogged) {
      if(!nps.isPlayerLoading) {
        try {
          nps.isPlayerLoading = true
          // ToastUtil.showToast('开始播放心动歌单')
          await SongAPIUtils.setHeartMode(PlayQueueUtils.getCurrentSong().id, user.userPlaylists[0].id,
            (): Promise<void> => {
              return PlayQueueUtils.cleanQueue();
            },
            (queue): Promise<void> => {
              return PlayQueueUtils.queueAddArray(queue);
            })
          await PlayControl.playQueue(0)
        } catch (e) {
          // ToastUtil.showToast('获取心动歌单失败: ' + e.message)
        } finally {
          setTimeout(() => {
            nps.isPlayerLoading = false
          }, 1000)
        }
      } else {
        // ToastUtil.showToast('正在加载, 请稍后')
      }
    } else {
      // ToastUtil.showToast('请登录后再试')
    }
  }
}