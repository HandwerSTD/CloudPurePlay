import { CycleMode, PlayQueue, Song, Song_INITIAL } from "@handwer/api_adapter"
import { PreferenceUtils } from "../../Preferences/PreferenceUtils"

interface ExportablePlayQueueStore {
  queue: Array<PlayQueue>
  currentQueueIndex: number
  cycleMode: CycleMode
}

@ObservedV2
class PlayQueueStore {
  @Trace queue: Array<PlayQueue> = []
  @Trace currentQueueIndex: number = -1
  @Trace cycleMode: CycleMode = 0

  getQueueLength(): number {
    return this.queue.length
  }

  getQueueElement(index: number): PlayQueue {
    return this.queue[index]
  }

  getQueue(): Array<PlayQueue> {
    return this.queue
  }

  getCurrentSong(): Song {
    try {
      const item = this.queue[this.currentQueueIndex]
      if (item?.playmode !== 0) return item.song
    } catch {}
    return Song_INITIAL
  }

  /** 转换为可导出的普通对象 */
  toExportable(): ExportablePlayQueueStore {
    return {
      queue: this.queue,
      currentQueueIndex: this.currentQueueIndex,
      cycleMode: this.cycleMode,
    }
  }

  /** 从可导出的对象恢复 */
  fromExportable(data: ExportablePlayQueueStore) {
    const store = this
    store.queue = data.queue ?? []
    store.currentQueueIndex = data.currentQueueIndex ?? -1
    store.cycleMode = data.cycleMode ?? 0
  }
}

const playQueueStore =  new PlayQueueStore()

const playQueueKV = new PreferenceUtils()

export { playQueueStore, playQueueKV }