import { PlayQueue, Song } from '@handwer/cloud_api'
import { EmitterUtil, LogUtil } from '@pura/harmony-utils'
import { playQueueStore, playQueueKV } from './PlayQueueStore'

const TAG = '[PlayQueueUtils] '

enum SCQueueKV {
  queue = 0,
  cycleMode = 1,
}

class PlayQueueUtils {
  async init() {
    try {
      playQueueKV.init()
      playQueueStore.currentQueueIndex = -1
      const gotQueue = playQueueKV.get<Array<PlayQueue>>(SCQueueKV.queue) ?? playQueueStore.queue
      const circleMode = playQueueKV.get<number>(SCQueueKV.cycleMode) ?? 0
      playQueueStore.queue = gotQueue
      playQueueStore.cycleMode = circleMode // 可选：挂载额外字段，或转存入 App 初始化逻辑
    } catch (e) {
      LogUtil.error(TAG, '初始化播放列表 init playqueue error: ' + e.message())
    }
  }

  private async syncQueueToStorage() {
    try {
      playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
    } catch (e) {
      LogUtil.error(TAG, 'Error while syncQueueToStorage: ' + e.message)
    }
  }

  async queueAdd(playmode: number, song: Song, artists: string = '', fileName: string = '', picUrl: string = '') {
    try {
      playQueueStore.queue.splice(playQueueStore.currentQueueIndex + 1, 0, {
        playmode,
        song,
        fileName,
        picUrl
      })
      await this.syncQueueToStorage()
    } catch (e) {
      LogUtil.error(TAG, '添加失败 add queue element error: ' + e.message())
    }
  }

  async queueAddArray(queue: PlayQueue[]) {
    try {
      playQueueStore.queue = playQueueStore.queue.concat(queue)
      playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
      // EmitterUtil.post(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {})
    } catch (e) {
      LogUtil.error(TAG, 'Error while queueAddArray: ' + e.message)
    }
  }

  async queueDelete(index: number) {
    try {
      playQueueStore.queue.splice(index, 1)
      playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
      if (index < playQueueStore.currentQueueIndex) {
        this.setIndex(playQueueStore.currentQueueIndex - 1)
      }
    } catch (e) {
      LogUtil.error(TAG, '删除失败 delete queue element error: ' + e.message())
    }
  }

  async cleanQueue() {
    playQueueStore.queue = []
    playQueueStore.currentQueueIndex = -1
    playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
  }

  async setIndex(index: number) {
    playQueueStore.currentQueueIndex = index
  }

  pre(): boolean {
    if (playQueueStore.currentQueueIndex > 0) {
      this.setIndex(playQueueStore.currentQueueIndex - 1)
      return true
    }
    return false
  }

  next(): boolean {
    if (playQueueStore.currentQueueIndex < playQueueStore.queue.length - 1) {
      this.setIndex(playQueueStore.currentQueueIndex + 1)
      return true
    }
    return false
  }
}

const playQueueUtils = new PlayQueueUtils()
export default playQueueUtils
