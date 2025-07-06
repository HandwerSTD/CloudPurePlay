import { PlayList, PlayListAPIUtils, Song, SongAPIUtils } from "@handwer/cloud_api"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { UserManager } from "../../../Network/UserManager"
import UserStore from "../../../Network/UserStore"
import NowPlayingStore from "../NowPlayingStore"

const TAG = '[songLike] '

export class SongLike {
  /**
   * 判断当前歌曲是否被喜欢
   * @param sid
   */
  static async isThisSongLiked(sid: number) {
    let isLiked: boolean = false
    try {
      let likeList = UserStore.likeList
      isLiked = likeList.has(sid.toString())
    } catch (e) {
      LogUtil.error(TAG, 'isThisSongLiked Error: ' + e.message)
    } finally {
      NowPlayingStore.isLiked = isLiked
    }
  }

  /**
   * 喜欢当前歌曲
   */
  static async likeThisSong() {
    try {
      let isLogged: boolean = UserManager.isLogged
      let isLiked: boolean = NowPlayingStore.isLiked
      if (!isLogged) {
        return
      } else if(!isLiked) { // 未喜欢
        let currentSong = NowPlayingStore.currentSong
        const result = await SongAPIUtils.likeMusic(currentSong.id)
        NowPlayingStore.isLiked = isLiked
        SongAPIUtils.getLikeList()
        ToastUtil.showToast(result ? '已收藏至【我喜欢的音乐】' : '收藏失败')
      } else { // 已喜欢
        let currentSong = NowPlayingStore.currentSong
        let userPlayLists = UserStore.userPlaylists
        const result = await PlayListAPIUtils.PlayListOperation('del', userPlayLists[0].id, currentSong.id)
        NowPlayingStore.isLiked = isLiked
        SongAPIUtils.getLikeList()
        ToastUtil.showToast(result ? '取消喜欢当前歌曲' : '取消喜欢失败')
      }
    } catch (e) {
      LogUtil.error(TAG, 'likeThisSong Error: ' + e.message)
    }
  }
}
