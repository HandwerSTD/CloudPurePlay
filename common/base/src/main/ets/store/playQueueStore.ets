import { Song, Song_INITIAL } from "../CloudAPI/common/entities/Song"
import { PlayQueue } from "../CloudAPI/common/model/PlayQueue"

@ObservedV2
class PlayQueueStore {
  @Trace queue: Array<PlayQueue> = []
  @Trace currentQueueIndex: number = -1
  @Trace cycleMode: number = 0

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

export default new PlayQueueStore()
