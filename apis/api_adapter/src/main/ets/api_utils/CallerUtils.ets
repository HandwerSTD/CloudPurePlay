
import { User } from '../common_defs/entities/User';
import { PlayQueue } from '../common_defs/model/PlayQueue';
import { COMMENT_TYPE, COMMENT_SORT_TYPE } from '../common_defs/model/Enum';
import { InstanceSwitcher, INSTANCE_TYPE } from '../api_switcher/InstanceSwitcher';
import { Album, DjRadio, PlayList, PersonalListItem, TopListItem, AlbumInfoResult,
  SubAlbumResult, QualityType,
  SongPlayResult, Song, ArtistInfo,
  CommentResult, LyricResult,
  PlayListsResult,
  PlayListSong,
  PlayListResult,
  ArtistItem,
  DjResult,
  DjProgramResult,
  SearchReturn,
  DailySongRes} from '../common_defs/ExportedEntities';
import {
  CloudUser,
  Cloud_AlbumAPIUtils,
  Cloud_ArtistAPIUtils,
  Cloud_CommentAPIUtils,
  Cloud_DjAPIUtils,
  Cloud_LoginAPIUtils,
  Cloud_LyricAPIUtils,
  Cloud_PlayListAPIUtils,
  Cloud_SongAPIUtils,
  Cloud_TopListAPIUtils } from './cloud_api_adapter/CloudAPIExports';

export class AlbumAPIUtils {
  /**
   * 获取专辑信息和歌曲
   * @param id 专辑ID
   * @returns 专辑详细信息
   */
  static async getAlbumInfo(id: number): Promise<AlbumInfoResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_AlbumAPIUtils.getAlbumInfo(id);
    } else {
      throw Error('API Unimplemented')
    }
  }
  /**
   * 获取用户订阅的专辑
   * @param statePersistent 按需求，可传入回调对返回的 Album[] 进行持久化
   * @returns 用户订阅的专辑数组
   */
  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_AlbumAPIUtils.getUserSubscribedAlbum(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }
  /**
   * 搜索专辑
   * @param keywords 搜索关键字
   * @returns 匹配到的专辑数组
   */
  static async searchAlbums(keywords: string): Promise<Album[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_AlbumAPIUtils.searchAlbums(keywords);
    } else {
      throw Error('API Unimplemented')
    }
  }
  
  /**
   * 收藏/取消收藏专辑
   * @param id - 专辑id
   * @param t - 1:收藏, 0:取消收藏
   * @returns Promise<boolean>
   */
  static async subscribeAlbum(id: number, t: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_AlbumAPIUtils.subscribeAlbum(id, t);
    } else {
      throw Error('API Unimplemented')
    }
  }
}


export class ArtistAPIUtils {
  /**
   * 获取歌手信息
   * @param id 歌手ID
   * @returns 歌手详细信息
   */
  static async getArtistInfo(id: number): Promise<ArtistInfo> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_ArtistAPIUtils.getArtistInfo(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 搜索歌手
   * @param keywords 搜索关键字
   * @param limit 返回数量，默认20
   * @returns 匹配到的歌手数组
   */
  static async searchArtists(keywords: string, limit: number = 20): Promise<ArtistItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_ArtistAPIUtils.searchArtists(keywords, limit);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class CommentAPIUtils {
  /**
   * 获取评论
   * @param id 资源ID
   * @param type 评论类型
   * @param pageNo 页码，默认1
   * @param pageSize 每页数量，默认30
   * @param sortType 排序类型
   * @param cursor 游标（可选）
   * @returns 评论数据
   */
  static async getComment(
    id: number,
    type: COMMENT_TYPE,
    pageNo: number = 1,
    pageSize: number = 30,
    sortType: COMMENT_SORT_TYPE,
    cursor?: number
  ): Promise<CommentResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_CommentAPIUtils.getComment(id, type, pageNo, pageSize, sortType, cursor);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class DjAPIUtils {
  /**
   * 获取用户订阅的私人电台
   * @param statePersistent 按需求，可传入回调对返回的 DjRadio[] 进行持久化
   * @returns 用户订阅的电台数组
   */
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_DjAPIUtils.getUserDjSubscribeList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取电台节目列表
   * @param rid 电台ID
   * @param limit 返回数量
   * @param offset 偏移量
   * @returns 节目列表
   */
  static async getDjPrograms(rid: number, limit: number, offset: number): Promise<DjProgramResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_DjAPIUtils.getDjPrograms(rid, limit, offset);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 将电台节目加入播放队列
   * @param rid 电台ID
   * @param trackCount 节目总数
   * @param limit 每次获取数量，默认100
   * @param offset 偏移量，默认0
   * @param first 是否首次，默认true
   * @param cleanQueue 清空队列回调
   * @param addToQueue 添加到队列回调
   * @returns 无
   */
  static async putDjRadioInQueue(
    rid: number,
    trackCount: number,
    limit: number = 100,
    offset: number = 0,
    first: boolean = true,
    cleanQueue: () => Promise<void>,
    addToQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_DjAPIUtils.putDjRadioInQueue(
        rid,
        trackCount,
        limit,
        offset,
        first,
        cleanQueue,
        addToQueue
      );
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 搜索电台
   * @param keywords 搜索关键字
   * @returns 匹配到的电台数组
   */
  static async getDjRadioList(keywords: string): Promise<DjRadio[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_DjAPIUtils.getDjRadioList(keywords);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class LoginAPIUtils {
  /**
   * 获取登录状态
   * @param statePersistent 按需求，可传入回调对返回的 User 进行持久化
   * @returns 是否登录成功
   */
  static async getLoginStatus(statePersistent?: (val: User) => void): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LoginAPIUtils.getLoginStatus(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 登出
   * @param statePersistent 按需求，可传入回调对返回的 User 进行持久化
   * @returns 是否登出成功
   */
  static async logOut(statePersistent?: (val: User) => void): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LoginAPIUtils.logOut(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取二维码图像
   * @returns str[0] 表示二维码的 key，str[1] 表示二维码图像链接
   */
  static async getQrCode(): Promise<string[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LoginAPIUtils.getQrCode();
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 在二维码扫描之后检查二维码扫描结果（可定时轮询或用户手动查询）
   * @param key 刚刚获取的二维码的 key
   * @param cookieSetter 函数会获取 cookie，此为保存 cookie 的回调（无需重新设置 RequestContext 中的 Cookie，系统会自动处理）
   * @param loginStatePersistent 持久化用户信息的回调
   * @returns 是否登录成功
   */
  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LoginAPIUtils.checkQrLogin(key, cookieSetter, loginStatePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class LyricAPIUtils {
  /**
   * 获取歌词对象
   * @param id 歌曲ID
   * @returns 歌词对象
   */
  static async getLyric(id: number): Promise<LyricResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LyricAPIUtils.getLyric(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取歌词字符串
   * @param id 歌曲ID
   * @returns 歌词文本
   */
  static async getLyricString(id: number): Promise<string> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_LyricAPIUtils.getLyricString(id);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class PlayListAPIUtils {
  /**
   * 获取用户歌单列表
   * @param offset 偏移量
   * @param user 用户对象
   * @param statePersistent 按需求，可传入回调对返回的 PlayList[] 进行持久化
   * @returns 歌单列表
   */
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void): Promise<PlayListResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.getPlayLists(offset, user as CloudUser, statePersistent);
    } else {
      throw Error('API Unimplemented')
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
  static async getPlayListSongs(id: number, limit: number, offset: number, usetimestamp: boolean = true): Promise<PlayListSong[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.getPlayListSongs(id, limit, offset, usetimestamp);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 歌单操作（添加/删除歌曲）
   * @param op 操作类型 'add' 或 'del'
   * @param pid 歌单ID
   * @param tracks 歌曲ID
   * @returns 是否操作成功
   */
  static async PlayListOperation(op: 'add' | 'del', pid: number, tracks: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.PlayListOperation(op, pid, tracks);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 搜索歌单
   * @param keywords 搜索关键字
   * @param offset 偏移量
   * @returns 匹配到的歌单列表
   */
  static async searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.searchPlayLists(keywords, offset);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 收藏/取消收藏歌单
   * @param id 歌单ID
   * @param mode 1为收藏，2为取消收藏
   * @returns 是否操作成功
   */
  static async subscribePlayList(id: number, mode: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.subscribePlayList(id, mode);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取个性化推荐歌单
   * @param statePersistent 按需求，可传入回调对返回的 PersonalListItem[] 进行持久化
   * @returns 推荐歌单列表
   */
  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.getPersonalizedList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 删除歌单
   * @param id 歌单ID
   * @returns 是否删除成功
   */
  static async deletePlayList(id: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.deletePlayList(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 创建歌单
   * @param name 歌单名称
   * @param isPrivacy 是否私密
   * @returns 是否创建成功
   */
  static async createPlayList(name: string, isPrivacy: boolean): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.createPlayList(name, isPrivacy);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 重命名歌单
   * @param pid 歌单ID
   * @param newName 新名称
   */
  static async renamePlaylist(pid: number, newName: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_PlayListAPIUtils.renamePlayList(newName, pid)
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class SongAPIUtils {
  /**
   * 检查音乐是否可用
   * @param id 歌曲ID
   * @returns 是否可用
   */
  static async checkMusic(id: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.checkMusic(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 搜索歌曲
   * @param keywords 搜索关键字
   * @param offset 偏移量
   * @param limit 返回数量，默认30
   * @returns 匹配到的歌曲列表
   */
  static async searchSongs(keywords: string, offset: number, limit: number = 30): Promise<SearchReturn> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.searchSongs(keywords, offset, limit);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取歌曲播放URL
   * @param id 歌曲ID
   * @param quality 音质类型
   * @param isLogged 是否已登录
   * @returns 歌曲播放信息
   */
  static async getSongUrl(id: number, quality: QualityType, isLogged: boolean): Promise<SongPlayResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.getSongUrl(id, quality, isLogged);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取歌曲图片URL
   * @param ids 歌曲ID
   * @returns 歌曲图片链接
   */
  static async getSongPicUrl(ids: number): Promise<string> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.getSongPicUrl(ids);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取每日推荐歌曲
   * @param useCookie 是否使用cookie，默认true
   * @returns 推荐歌曲列表
   */
  static async getDailySongs(useCookie: boolean = true): Promise<DailySongRes[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.getDailySongs(useCookie);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取喜欢的歌曲ID列表
   * @param user
   * @param statePersistent 按需求，可传入回调对返回的 string[] 进行持久化
   * @returns 喜欢的歌曲ID数组
   */
  static async getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.getLikeList(user as CloudUser, statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 喜欢某首歌曲（不喜欢请直接在红心歌单中删除）
   * @param id 歌曲ID
   * @returns 是否操作成功
   */
  static async likeMusic(id: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.likeMusic(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 设置心动模式
   * @param id 歌曲ID
   * @param pid 歌单ID
   * @param cleanQueue 清空队列回调
   * @param addQueue 添加到队列回调
   * @returns 无
   */
  static async setHeartMode(
    id: number,
    pid: number,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.setHeartMode(id, pid, cleanQueue, addQueue);
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 获取私人FM歌曲
   * @param mode 模式
   * @returns 歌曲对象
   */
  static async getPersonalFmSong(mode: number): Promise<Song> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_SongAPIUtils.getPersonalFmSong(mode);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class TopListAPIUtils {
  /**
   * 获取排行榜
   * @param statePersistent 按需求，可传入回调对返回的 TopListItem[] 进行持久化
   * @returns 排行榜列表
   */
  static async getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return Cloud_TopListAPIUtils.getTopList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }
}
