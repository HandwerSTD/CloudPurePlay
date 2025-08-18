import { DjAPIUtils, PlayQueue } from "@handwer/api_adapter"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import playQueueUtils from "../../queue/PlayQueueUtils"
import NowPlayingStore from "../NowPlayingStore"
import { PlayControl } from "./playControl"

const TAG = '[podcastOp] '

export class podcastOp {
  static async djRadioToQueue(id: string, count: number, currentIndex: number = 0) {
    try {
      NowPlayingStore.isPlayerLoading = true
      // const lastPlayInfo = await AppStorage.get(StorageConstants.LAST_PLAYED_LIST) as PlayingPlayList
      // if(lastPlayInfo.id != -1 && lastPlayInfo.id == id && lastPlayInfo.count == count) {
      if (false) {
        PlayControl.playQueue(currentIndex)
      } else {
        let limit = 100
        const cleanQueue =
          async () => {
            await playQueueUtils.cleanQueue()
          };
        const addQueue =
          async (data: PlayQueue[]) => {
            await playQueueUtils.queueAddArray(data)
          };
        await DjAPIUtils.putDjRadioInQueue(id, limit, limit, currentIndex < 50 ? 0 : currentIndex - 25, true,
          // clean queue
          cleanQueue,
          // add queue
          addQueue
        )
        PlayControl.playQueue(currentIndex < 50 ? currentIndex : 25)
        await DjAPIUtils.putDjRadioInQueue(id, count, 400, limit, false, cleanQueue, addQueue)
      }
    } catch (e) {
      LogUtil.error(TAG, '' + e.message)
      ToastUtil.showToast('播放播客出错')
    } finally {
      // const playInfo: PlayingPlayList = {
      //   id: id,
      //   count: count
      // }
      // AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
      // AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
      NowPlayingStore.isPlayerLoading = false
    }
  }
}