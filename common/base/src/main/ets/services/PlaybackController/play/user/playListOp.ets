import { PlayListSong, PlayQueue, PlayingPlayList, PlayListAPIUtils, Song } from "@handwer/api_adapter"
import { EmitterUtil, LogUtil, ToastUtil } from "@pura/harmony-utils"
import { SCEmitter } from "../../../../constants/CommonConstants"
import { UserManager } from "../../../Network/UserManager"
import UserStore from "../../../Network/UserStore"
import { SongConvertUtils } from "../../convert"
import PlayQueueUtils from "../../queue/PlayQueueUtils"
import { PlayControl } from "./playControl"

const TAG = '[playListOp] '

export interface PlaylistContentUpdateInfo {
  pid: number,
  songId: number,
  songInfo: PlayListSong,
  operation: 'add' | 'del' | undefined
}

export class PlayListOp {
  static async playListToQueue(playlist: PlayListSong[], index: number) {
    try {
      if(playlist.length === 0) return
      let queue: PlayQueue[] = playlist.map((item): PlayQueue => ({
        playmode: 2,
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
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      PlayControl.playQueue(index)
    } catch (e) {
      ToastUtil.showToast('播放失败: ' + e.message)
      LogUtil.error(TAG, 'playlist to queue error: ' + e.stack)
    }
  }

  static cleanLastPlayInfo() {
    const playInfo: PlayingPlayList = {
      id: -1,
      count: -1
    }
    // AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
  }

  static async addSongToPlaylist(playlistId: number, song: Song): Promise<boolean> {
    const result = await PlayListAPIUtils.PlayListOperation('add', playlistId, song.id)
    if (result) {
      // notify
      EmitterUtil.post(SCEmitter.PlaylistContentUpdate, {
        pid: playlistId,
        songId: song.id,
        songInfo: SongConvertUtils.NormalSong2PlaylistSong(song)
      } as PlaylistContentUpdateInfo)
      // add count
      const res = UserStore.userPlaylists.find((val) => val.id === playlistId)
      if (res) {
        res.playCount++;
      }
      UserManager.fetchUserPlaylists()
      return true
    } else return false
  }
}