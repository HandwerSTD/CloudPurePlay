import { CycleMode, PlayList, PlayListSong, PLAYMODE, PlayQueue, Song } from '@handwer/api_adapter'
import { EmitterUtil, LogUtil } from '@pura/harmony-utils'
import { PlayControl } from '../../../exports'
import { playQueueStore, playQueueKV } from './PlayQueueStore'

const TAG = '[PlayQueueUtils] '

enum SCQueueKV {
  queue = 0,
  cycleMode = 1,
  currentIndex = 2,
}

class PlayQueueUtils {
  get queue() {
    return playQueueStore.queue
  }
  get currentQueueIndex() {
    return playQueueStore.currentQueueIndex
  }

  async init() {
    try {
      playQueueKV.init()
      playQueueStore.currentQueueIndex = playQueueKV.get(SCQueueKV.currentIndex) ?? -1
      const gotQueue = playQueueKV.get<Array<PlayQueue>>(SCQueueKV.queue) ?? playQueueStore.queue
      const circleMode = playQueueKV.get<number>(SCQueueKV.cycleMode) ?? 0
      playQueueStore.queue = gotQueue
      playQueueStore.cycleMode = circleMode
    } catch (e) {
      LogUtil.error(TAG, '初始化播放列表 init playqueue error: ' + e.message())
    }
  }

  private async syncQueueToStorage() {
    try {
      playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
      playQueueKV.put(SCQueueKV.cycleMode, playQueueStore.cycleMode)
      playQueueKV.put(SCQueueKV.currentIndex, playQueueStore.currentQueueIndex)
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

  async queueDelete(index: number, goToFront: boolean = false) {
    try {
      if (index === playQueueStore.currentQueueIndex) {
        await PlayControl.playNext()
      }
      playQueueStore.queue.splice(index, 1)
      playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
      if (index < playQueueStore.currentQueueIndex) {
        this.setIndex(playQueueStore.currentQueueIndex - 1)
      } else {
        if (goToFront) this.setIndex(0)
      }
    } catch (e) {
      LogUtil.error(TAG, '删除失败 delete queue element error: ' + e.message())
    }
  }

  async cleanQueue() {
    playQueueStore.queue = []
    playQueueStore.currentQueueIndex = -1
    playQueueKV.put(SCQueueKV.queue, playQueueStore.queue)
    playQueueKV.put(SCQueueKV.currentIndex, playQueueStore.currentQueueIndex)
  }

  async setIndex(index: number) {
    playQueueStore.currentQueueIndex = index
    playQueueKV.put(SCQueueKV.currentIndex, playQueueStore.currentQueueIndex)
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

  getQueueLength(): number {
    return playQueueStore.getQueueLength()
  }

  getQueueElement(index: number): PlayQueue {
    return playQueueStore.getQueueElement(index)
  }

  getQueue(): Array<PlayQueue> {
    return this.queue
  }

  getCurrentSong(): Song {
    return playQueueStore.getCurrentSong()
  }

  peekNextSong(): PlayQueue | undefined {
    if (playQueueStore.currentQueueIndex < playQueueStore.queue.length - 1) {
      return this.getQueueElement(this.currentQueueIndex+1)
    }
    return undefined
  }

  changeCycleMode(mode?: CycleMode) {
    playQueueStore.cycleMode = mode ?? (playQueueStore.cycleMode + 1) % 4
    playQueueKV.put(SCQueueKV.cycleMode, playQueueStore.cycleMode)
  }

  makeQueueByPlaylist(list: PlayListSong[]) {
    let queue: PlayQueue[] = list.map((item): PlayQueue => ({
      playmode: PLAYMODE.PLAYLIST,
      song: {
        id: item.id,
        name: item.name,
        artists: item.ar,
        album: item.al,
        duration: item.dt,
        fee: item.fee,
        alias: []
      },
      fileName: '',
      picUrl: item.al.picUrl
    }))
    return queue
  }
}

const playQueueUtils = new PlayQueueUtils()
export default playQueueUtils
