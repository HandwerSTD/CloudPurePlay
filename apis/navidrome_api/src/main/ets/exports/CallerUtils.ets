import { getAlbumCoverUrl, getAlbumInfo, getUserSubscribedAlbum, searchAlbums, subscribeAlbum } from '../api/albumApi';
import { getArtistInfo, searchArtists } from '../api/artistApi';
import { getLoginStatus, logOut } from '../api/loginApi';
import { getLyric, getLyricString } from '../api/LyricApi';
import { getPlayLists, getPlayListSongs, deletePlayList, createPlayList, renamePlayList,
  playListOperation } from '../api/playListApi';
import { searchSongs, getSongUrl, getLikeList, likeMusic, getCoverUrl } from '../api/songApi';
import { getTopList } from '../api/topListApi';
import { Album } from '../entity/AlbumEntity';
import { PlayList, PlayListsResult } from '../entity/PlaylistEntity';
import { Song } from '../entity/SongEntity';
import { User } from '../entity/UserEntity';

export class NavidromeAPI_AlbumAPIUtils {
  /**
   * 获取专辑信息和歌曲
   * @param id 专辑ID
   * @returns 专辑详细信息
   */
  static async getAlbumInfo(id: string) {
    return getAlbumInfo(id);
  }
  /**
   * 获取用户订阅的专辑
   * @param statePersistent 按需求，可传入回调对返回的 Album[] 进行持久化
   * @returns 用户订阅的专辑数组
   */
  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void) {
    return getUserSubscribedAlbum(statePersistent);
  }
  /**
   * 搜索专辑
   * @param keywords 搜索关键字
   * @returns 匹配到的专辑数组
   */
  static async searchAlbums(keywords: string) {
    return searchAlbums(keywords);
  }
  /**
   * 收藏/取消收藏专辑
   * @param id - 专辑id
   * @param t - 1:收藏, 0:取消收藏
   * @returns Promise<boolean>
   */
  static async subscribeAlbum(id: string, t: number): Promise<boolean> {
    return await subscribeAlbum(id, t)
  }

  static getAlbumCoverUrl(album: Album) {
    return getAlbumCoverUrl(album)
  }
}

export class NavidromeAPI_ArtistAPIUtils {
  /**
   * 获取歌手信息
   * @param id 歌手ID
   * @returns 歌手详细信息
   */
  static async getArtistInfo(id: string) {
    return getArtistInfo(id);
  }
  /**
   * 搜索歌手
   * @param keywords 搜索关键字
   * @param limit 返回数量，默认20
   * @returns 匹配到的歌手数组
   */
  static async searchArtists(keywords: string, limit: number = 20) {
    return searchArtists(keywords, limit);
  }
}

export class NavidromeAPI_LoginAPIUtils {
  /**
   * 获取登录状态
   * @param statePersistent 按需求，可传入回调对返回的 User 进行持久化
   * @returns 是否登录成功
   */
  static async getLoginStatus(statePersistent?: (val: User) => void) {
    return getLoginStatus(statePersistent);
  }
  /**
   * 登出
   * @param statePersistent 按需求，可传入回调对返回的 User 进行持久化
   * @returns 是否登出成功
   */
  static async logOut(statePersistent?: (val: User) => void) {
    return logOut(statePersistent);
  }
}

export class NavidromeAPI_LyricAPIUtils {
  /**
   * 获取歌词对象
   * @param id 歌曲ID
   * @returns 歌词对象
   */
  static async getLyric(id: string) {
    return getLyric(id);
  }
  /**
   * 获取歌词字符串
   * @param id 歌曲ID
   * @returns 歌词文本
   */
  static async getLyricString(id: string) {
    return getLyricString(id);
  }
}


export class NavidromeAPI_PlayListAPIUtils {
  /**
   * 获取用户歌单列表
   * @param offset 偏移量
   * @param user 用户对象
   * @param statePersistent 按需求，可传入回调对返回的 PlayList[] 进行持久化
   * @returns 歌单列表
   */
  static async getPlayLists(statePersistent?: (val: PlayList[]) => void): Promise<PlayListsResult> {
    const result = await getPlayLists();
    // 添加红心歌单
    const likeList = await getLikeList()
    result.playlist.unshift({
      id: '-1',
      name: '我喜欢的音乐',
      songCount: likeList.length,
      public: false,
    } as PlayList)
    statePersistent?.(result.playlist);
    return result
  }
  /**
   * 获取歌单内歌曲列表
   * @param id 歌单ID
   * @param limit 返回数量
   * @param offset 偏移量
   * @param usetimestamp 是否带时间戳，默认true
   * @returns 歌曲列表
   */
  static async getPlayListSongs(id: string) {
    if (id === '-1') {
      // like list
      return getLikeList()
    }
    return getPlayListSongs(id);
  }
  /**
   * 歌单操作（添加/删除歌曲）
   * @param op 操作类型 'add' 或 'del'
   * @param pid 歌单ID
   * @param tracks 歌曲ID
   * @returns 是否操作成功
   */
  static async PlayListOperation(op: 'add' | 'del', pid: string, tracks: string) {
    if (pid === '-1') {
      return likeMusic(tracks, op === 'add')
    }
    return playListOperation(pid, [tracks], op === 'add');
  }
  /**
   * 删除歌单
   * @param id 歌单ID
   * @returns 是否删除成功
   */
  static async deletePlayList(id: string) {
    return deletePlayList(id);
  }
  /**
   * 创建歌单
   * @param name 歌单名称
   * @param isPrivacy 是否私密
   * @returns 无
   */
  static async createPlayList(name: string): Promise<boolean> {
    return createPlayList(name);
  }
  /**
   * 重命名歌单
   * @param name 歌单名称
   * @param pid 歌单编号
   * @returns 无
   */
  static async renamePlayList(name: string, pid: string): Promise<boolean> {
    if (pid === '-1') return false;
    return renamePlayList(pid, name);
  }
}

export class NavidromeAPI_SongAPIUtils {
  static getSongPicUrl(coverArt: string): string {
    return getCoverUrl(coverArt)
  }
  /**
   * 搜索歌曲
   * @param keywords 搜索关键字
   * @param offset 偏移量
   * @param limit 返回数量，默认30
   * @returns 匹配到的歌曲列表
   */
  static async searchSongs(keywords: string, offset: number, limit: number = 30) {
    return searchSongs(keywords, limit, offset);
  }
  /**
   * 获取歌曲播放URL
   * @param id 歌曲ID
   * @param quality 音质类型
   * @param isLogged 是否已登录
   * @returns 歌曲播放信息
   */
  static async getSongUrl(id: string) {
    return getSongUrl(id);
  }
  /**
   * 获取喜欢的歌曲ID列表
   * @param user
   * @param statePersistent 按需求，可传入回调对返回的 string[] 进行持久化
   * @returns 喜欢的歌曲ID数组
   */
  static async getLikeList(statePersistent?: (val: string[]) => void): Promise<string[]> {
    const result = await getLikeList();
    statePersistent?.(result.map((val) => val.id.toString()))
    return result.map((val) => val.id)
  }
  /**
   * 喜欢某首歌曲（不喜欢请直接在红心歌单中删除）
   * @param id 歌曲ID
   * @returns 是否操作成功
   */
  static async likeMusic(id: string, setLike: boolean) {
    return likeMusic(id, setLike);
  }
}

export class NavidromeAPI_TopListAPIUtils {
  /**
   * 获取排行榜
   * @param statePersistent 按需求，可传入回调对返回的 TopListItem[] 进行持久化
   * @returns 排行榜列表
   */
  static async getTopList(statePersistent?: (val: Song[]) => void) {
    return getTopList(statePersistent);
  }
}
