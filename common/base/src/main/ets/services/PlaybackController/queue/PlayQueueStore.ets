import { CycleMode, PlayQueue, Song, Song_INITIAL } from "@handwer/api_adapter"
import { PreferenceUtils } from "../../Preferences/PreferenceUtils"

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
}

const playQueueStore =  new PlayQueueStore()

const playQueueKV = new PreferenceUtils()

export { playQueueStore, playQueueKV }