import PlayQueueUtils from "../../queue/PlayQueueUtils"
import NowPlayingStore from "../NowPlayingStore"
import { PersonalFMState, PlayControl } from "../user/playControl"

export class FeaturedPlayUtils {
  static async playPersonalizedList() {
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
}