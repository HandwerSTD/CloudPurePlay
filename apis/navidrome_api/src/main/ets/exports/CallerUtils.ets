import { DateUtil, RandomUtil } from '@pura/harmony-utils';
import { getAllAlbums, getAlbumCoverUrl, getAlbumInfo, getUserSubscribedAlbum, searchAlbums, subscribeAlbum } from '../api/albumApi';
import { getArtistInfo, searchArtists } from '../api/artistApi';
import { getLoginStatus, getGravatar, logOut } from '../api/loginApi';
import { getLyric, getLyricString } from '../api/LyricApi';
import { getPlayLists, getPlayListSongs, deletePlayList, createPlayList, renamePlayList,
  playListOperation,
  getPlaylistDetail} from '../api/playListApi';
import { getRandomSongs, searchSongs, getSongUrl, getLikeList, likeMusic, getCoverUrl } from '../api/songApi';
import { getTopList } from '../api/topListApi';
import { Album, AlbumSong } from '../entity/AlbumEntity';
import { PlayList, PlayListsResult } from '../entity/PlaylistEntity';
import { Song } from '../entity/SongEntity';
import { User } from '../entity/UserEntity';
import { MemStore } from '../utils/MemStore';

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

  /**
   * 获取专辑列表 (getAlbumList API)
   * 返回随机、最新、最高评级等专辑列表
   * @param type - 列表类型，必填。可选值: 'random', 'newest', 'highest', 'frequent', 'recent', 
   *               'alphabeticalByName', 'alphabeticalByArtist', 'starred', 'byYear', 'byGenre'
   * @param size - 返回专辑数量，可选，默认 10，最大 500
   * @param offset - 列表偏移量，可选，默认 0，用于分页
   * @param fromYear - 起始年份，当 type 为 'byYear' 时使用，可选
   * @param toYear - 结束年份，当 type 为 'byYear' 时使用，可选
   * @param genre - 流派名称，当 type 为 'byGenre' 时使用，可选
   * @returns Promise<Album[]>
   */
  static async getAllAlbums(
    type: 'random' | 'newest' | 'highest' | 'frequent' | 'recent' | 'alphabeticalByName' | 'alphabeticalByArtist' | 'starred' | 'byYear' | 'byGenre',
    size: number = 10,
    offset: number = 0,
    fromYear?: number,
    toYear?: number,
    genre?: string
  ): Promise<Album[]> {
    return await getAllAlbums(type, size, offset, fromYear, toYear, genre);
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
  static getGravatar(email: string): ResourceStr {
    return getGravatar(email)
  }
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
      coverArt: likeList[0].coverArt,
      public: false,
    } as PlayList)
    statePersistent?.(result.playlist);
    return result
  }
  static async getPlaylistInfo(id: string) {
    if (id === '-1') {
      const likeList = await getLikeList();
      return {
        id: '-1',
        name: '我喜欢的音乐',
        songCount: likeList.length,
        coverArt: likeList[0].coverArt,
        public: false,
      } as PlayList
    } else {
      return await getPlaylistDetail(id)
    }
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
   * 获取喜欢的歌曲完整对象列表（用于心动模式）
   * @returns 喜欢的歌曲对象数组
   */
  static async getLikeSongs(): Promise<Song[]> {
    return getLikeList();
  }
  /**
   * 喜欢某首歌曲（不喜欢请直接在红心歌单中删除）
   * @param id 歌曲ID
   * @returns 是否操作成功
   */
  static async likeMusic(id: string, setLike: boolean) {
    return likeMusic(id, setLike);
  }

  /**
   * 获取随机歌曲 (getRandomSongs API)
   * 返回符合给定条件的随机歌曲
   * @param size - 返回歌曲的最大数量，可选，默认 10，最大 500
   * @param genre - 只返回属于此流派的歌曲，可选
   * @param fromYear - 只返回发布于或晚于此年份的歌曲，可选
   * @param toYear - 只返回发布于或早于此年份的歌曲，可选
   * @param musicFolderId - 只返回指定音乐文件夹中的歌曲，可选
   * @returns Promise<Song[]>
   */
  static async getRandomSongs(
    size: number = 10,
    genre?: string,
    fromYear?: number,
    toYear?: number,
    musicFolderId?: string
  ): Promise<Song[]> {
    return await getRandomSongs(size, genre, fromYear, toYear, musicFolderId);
  }

  /**
   * 获取所有歌曲
   * 通过获取专辑列表然后获取每个专辑的歌曲来实现
   * @param albumType - 专辑类型
   * @param albumSize - 专辑数量
   * @param albumOffset - 专辑偏移量
   * @param fromYear - 起始年份
   * @param toYear - 结束年份
   * @param genre - 流派
   * @returns Promise<Song[]>
   */
  static async getAllSongs(
    albumType: 'random' | 'newest' | 'highest' | 'frequent' | 'recent' | 'alphabeticalByName' | 'alphabeticalByArtist' | 'starred' | 'byYear' | 'byGenre' = 'alphabeticalByName',
    albumSize: number = 1000,
    albumOffset: number = 0,
    fromYear?: number,
    toYear?: number,
    genre?: string
  ): Promise<Song[]> {
    const albumTypeKey = 'allSongs_'+albumType
    if (MemStore.getContext().getObject(albumTypeKey)) {
      return MemStore.getContext().getObject(albumTypeKey) as Song[];
    }
    try {
      // 1. 先调用getAllAlbums获取所有专辑
      const albums = await getAllAlbums(
        albumType,
        albumSize,
        albumOffset,
        fromYear,
        toYear,
        genre
      );

      // 2. 使用Promise.all并发获取所有专辑的信息
      const albumInfoPromises = albums.map(album => 
        getAlbumInfo(album.id)
          .then((albumInfo): AlbumSong[] => {
            // 如果获取成功且有歌曲，返回歌曲数组
            if (albumInfo.song && albumInfo.song.length > 0) {
              return albumInfo.song;
            }
            return [];
          })
          .catch((error: Error) => {
            // 如果单个专辑获取失败，记录错误并返回空数组
            console.error(`Failed to get album info for album ${album.id}:`, error.message);
            return [];
          })
      );

      // 3. 等待所有专辑信息获取完成
      const albumSongArrays = await Promise.all(albumInfoPromises);

      // 4. 将所有专辑的歌曲合并成一个数组
      const allSongs = albumSongArrays.flat();
      MemStore.getContext().setObject(albumTypeKey, allSongs);
      return allSongs;
    } catch (error) {
      console.error('Failed to get all songs:', error);
      return [];
    }
  }

  /**
   * 心动模式 - 获取收藏歌曲列表
   * @returns Promise<Song[]>
   */
  static async getHeartModeSongs(): Promise<Song[]> {
    try {
      // 获取Starred歌曲列表
      const starredSongs = await getLikeList();
      
      // 如果没有starred歌曲，抛出错误
      if (starredSongs.length === 0) {
        throw new Error('No starred songs found');
      }
      
      return starredSongs;
    } catch (error) {
      console.error('Failed to get heart mode songs:', error);
      return []
    }
  }

  static async getDailySongs(): Promise<Song[]> {
    const today = DateUtil.getTodayStr('yyyyMMdd');
    if (MemStore.getContext().getObject(today + "_DailySongs")) {
      return MemStore.getContext().getObject(today + "_DailySongs") as Song[]
    }

    const allSongs = await NavidromeAPI_SongAPIUtils.getAllSongs()

    let seed = parseInt(today)
    const rand = () => {
      seed = (seed * 1664525 + 1013904223) % 4294967296;
      return seed / 4294967296;
    }
    const prob = Math.min(30 / allSongs.length, 1)
    const result: Song[] = []
    for (const song of allSongs) {
      if (rand() < prob) result.push(song)
      if (result.length >= 30) break
    }
    return result
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
