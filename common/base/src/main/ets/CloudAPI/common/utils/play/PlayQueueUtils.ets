// 📁 common/utils/PlayQueueUtils.ts
import { EmitterUtil, LogUtil } from '@pura/harmony-utils'
import { EmitterConstants } from '../../constants/EmitterConstants'
import { StorageConstants } from '../../constants/StorageConstants'
import PreferencesUtils from '../data/PreferencesUtils'
import { PlayQueue } from '../../model/PlayQueue'
import { Song } from '../../entities/Song'
import playQueueStore from '../../../../store/playQueueStore'

const TAG = '[PlayQueueUtils] '
const pref = StorageConstants.QUEUE_PREF

class PlayQueueUtils {
  async init() {
    try {
      playQueueStore.currentQueueIndex = -1
      const gotQueue = await PreferencesUtils.getPreferenceValue<Array<PlayQueue>>(pref, 'queue', playQueueStore.queue)
      const circleMode = await PreferencesUtils.getPreferenceValue<number>(pref, 'cycleMode', 0)
      playQueueStore.queue = gotQueue
      playQueueStore.cycleMode = circleMode
    } catch (e) {
      LogUtil.error(TAG, '初始化播放列表 init playqueue error: ' + e.message())
    }
  }

  private async syncQueueToStorage() {
    try {
      await PreferencesUtils.putPreferenceValue(pref, 'queue', playQueueStore.queue)
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
      await PreferencesUtils.putPreferenceValue(pref, 'queue', playQueueStore.queue)
      EmitterUtil.post(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {})
    } catch (e) {
      LogUtil.error(TAG, 'Error while queueAddArray: ' + e.message)
    }
  }

  async queueDelete(index: number) {
    try {
      playQueueStore.queue.splice(index, 1)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', playQueueStore.queue)
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
    await PreferencesUtils.putPreferenceValue(pref, 'queue', playQueueStore.queue)
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
