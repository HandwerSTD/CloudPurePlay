import { PlayList, PlayListAPIUtils, Song, SongAPIUtils } from "@handwer/api_adapter"
import { EmitterUtil, LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlaylistContentUpdateInfo, SCEmitter, ShowToastCallback, SongConvertUtils } from "../../../../exports"
import { UserManager } from "../../../Network/UserManager"
import UserStore from "../../../Network/UserStore"
import NowPlayingStore from "../NowPlayingStore"

const TAG = '[songLike] '

export class SongLike {
  static isSongLiked(sid: number) {
    if (sid === 0) return false;
    let isLiked: boolean = false
    try {
      let likeList = Array.from(UserStore.likeList)
      isLiked = JSON.stringify(likeList).includes(sid.toString())
    } catch (e) {
      LogUtil.error(TAG, 'isThisSongLiked Error: ' + e.message)
    }
    return isLiked;
  }

  /**
   * 判断当前歌曲是否被喜欢
   * @param sid
   */
  static isThisSongLiked(sid: number) {
    let isLiked: boolean = false
    try {
      let likeList = Array.from(UserStore.likeList)
      isLiked = JSON.stringify(likeList).includes(sid.toString())
    } catch (e) {
      LogUtil.error(TAG, 'isThisSongLiked Error: ' + e.message)
    } finally {
      NowPlayingStore.isLiked = isLiked
      LogUtil.debug(TAG, `the song is liked: ${isLiked}`)
    }
  }

  /**
   * 喜欢当前歌曲，并触发歌单刷新
   */
  static async likeThisSong(toastCallback?: ShowToastCallback) {
    const store = UserStore
    try {
      let isLogged: boolean = UserManager.isLogged
      let isLiked: boolean = NowPlayingStore.isLiked
      if (!isLogged) {
        return
      } else if(!isLiked) { // 未喜欢
        let currentSong = NowPlayingStore.currentSong
        const result = await SongAPIUtils.likeMusic(currentSong.id)
        NowPlayingStore.isLiked = !isLiked
        // 喜欢列表
        await SongAPIUtils.getLikeList(UserStore.user, (val) => {
          if (val) store.likeList = new Set(val)
          UserManager.persistLikeList()
        })
        toastCallback?.($r('sys.symbol.heart_fill'), result ? '已收藏至【我喜欢的音乐】' : '收藏失败')
      } else { // 已喜欢
        let currentSong = NowPlayingStore.currentSong
        let userPlayLists = UserStore.userPlaylists
        const result = await PlayListAPIUtils.PlayListOperation('del', userPlayLists[0].id, currentSong.id)
        NowPlayingStore.isLiked = !isLiked
        // 喜欢列表
        await SongAPIUtils.getLikeList(UserStore.user, (val) => {
          store.likeList = new Set(val ?? store.likeList)
          UserManager.persistLikeList()
        })
        toastCallback?.($r('sys.symbol.heart'), result ? '取消喜欢当前歌曲' : '取消喜欢失败')
      }
      EmitterUtil.post(SCEmitter.PlaylistContentUpdate, {
        pid: UserStore.userPlaylists[0].id,
        songId: NowPlayingStore.currentSong.id,
        songInfo: SongConvertUtils.NormalSong2PlaylistSong(NowPlayingStore.currentSong),
        operation: !isLiked ? 'add' : 'del' // 曾经未喜欢，就是加歌曲
      } as PlaylistContentUpdateInfo)
    } catch (e) {
      LogUtil.error(TAG, 'likeThisSong Error: ' + e.message)
      toastCallback?.($r('sys.symbol.heart_slash'), '修改红心失败')
    } finally {
      UserManager.fetchUserPlaylists()
    }
  }


  /**
   * 从歌单页面喜欢当前歌曲，不触发歌单刷新
   */
  static async likeSong(sid: number, toastCallback?: ShowToastCallback) {
    const store = UserStore
    try {
      let isLogged: boolean = UserManager.isLogged
      let isLiked: boolean = SongLike.isSongLiked(sid)
      if (!isLogged) {
        return
      } else if(!isLiked) { // 未喜欢
        const result = await SongAPIUtils.likeMusic(sid)
        // 喜欢列表
        await SongAPIUtils.getLikeList(UserStore.user, (val) => {
          if (val) store.likeList = new Set(val)
          UserManager.persistLikeList()
        })
        toastCallback?.($r('sys.symbol.heart_fill'), result ? '已收藏至【我喜欢的音乐】' : '收藏失败')
      } else { // 已喜欢
        let currentSong = NowPlayingStore.currentSong
        let userPlayLists = UserStore.userPlaylists
        const result = await PlayListAPIUtils.PlayListOperation('del', userPlayLists[0].id, sid)
        // 喜欢列表
        await SongAPIUtils.getLikeList(UserStore.user, (val) => {
          store.likeList = new Set(val ?? store.likeList)
          UserManager.persistLikeList()
        })
        toastCallback?.($r('sys.symbol.heart'), result ? '取消喜欢歌曲' : '取消喜欢失败')
      }
    } catch (e) {
      LogUtil.error(TAG, 'likeThisSong Error: ' + e.message)
      toastCallback?.($r('sys.symbol.heart_slash'), '修改红心失败')
    } finally {
      SongLike.isThisSongLiked(NowPlayingStore.currentSong.id)
      UserManager.fetchUserPlaylists()
    }
  }
}
