import { getAlbumInfo, getUserSubscribedAlbum, searchAlbums } from '../api/albumApi';
import { getArtistInfo, searchArtists } from '../api/artistApi';
import { getComment } from '../api/commentApi';
import { getUserDjSubscribeList, getDjPrograms, putDjRadioInQueue, getDjRadioList } from '../api/djApi';
import { getLoginStatus, logOut } from '../api/loginApi';
import { getLyric, getLyricString } from '../api/LyricApi';
import { getPlayLists, getPlayListSongs, PlayListOperation, getCloudList, searchPlayLists, subscribePlayList, getPersonalizedList, deletePlayList, createPlayList } from '../api/playListApi';
import { getQrCode, checkQrLogin } from '../api/qrCodeApi';
import { checkMusic, searchSongs, getSongUrl, getSongPicUrl, getDailySongs, getLikeList, likeMusic, setHeartMode, getPersonalFmSong } from '../api/songApi';
import { getTopList } from '../api/topListApi';
import { getDownloadInfo } from '../api/getDownloadInfo';
import { User } from '../entities/User';
import { PlayQueue } from '../model/PlayQueue';
import { QualityType } from '../entities/Song';
import { COMMENT_TYPE, COMMENT_SORT_TYPE } from '../model/Enum';
import { preferences } from '@kit.ArkData';
import { Album, DjRadio, PlayList, PersonalListItem, TopListItem } from './ExportedEntities';

export class AlbumAPIUtils {
  /**
   * 获取专辑信息和歌曲
   * @param id 专辑ID
   * @returns 专辑详细信息
   */
  static async getAlbumInfo(id: number) {
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
}

export class ArtistAPIUtils {
  /**
   * 获取歌手信息
   * @param id 歌手ID
   * @returns 歌手详细信息
   */
  static async getArtistInfo(id: number) {
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
  static async getComment(id: number, type: COMMENT_TYPE, pageNo: number = 1, pageSize: number = 30, sortType: COMMENT_SORT_TYPE, cursor?: number) {
    return getComment(id, type, pageNo, pageSize, sortType, cursor);
  }
}

export class DjAPIUtils {
  /**
   * 获取用户订阅的私人电台
   * @param statePersistent 按需求，可传入回调对返回的 DjRadio[] 进行持久化
   * @returns 用户订阅的电台数组
   */
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void) {
    return getUserDjSubscribeList(statePersistent);
  }
  /**
   * 获取电台节目列表
   * @param rid 电台ID
   * @param limit 返回数量
   * @param offset 偏移量
   * @returns 节目列表
   */
  static async getDjPrograms(rid: number, limit: number, offset: number) {
    return getDjPrograms(rid, limit, offset);
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
  ) {
    return putDjRadioInQueue(rid, trackCount, limit, offset, first, cleanQueue, addToQueue);
  }
  /**
   * 搜索电台
   * @param keywords 搜索关键字
   * @returns 匹配到的电台数组
   */
  static async getDjRadioList(keywords: string) {
    return getDjRadioList(keywords);
  }
}

export class LoginAPIUtils {
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

  /**
   * 获取二维码图像
   * @returns str[0] 表示二维码的 key，str[1] 表示二维码图像链接
   */
  static async getQrCode() {
    return getQrCode();
  }
  /**
   * 在二维码扫描之后检查二维码扫描结果（可定时轮询或用户手动查询）
   * @param key 刚刚获取的二维码的 key
   * @param cookieSetter 函数会获取 cookie，此为保存 cookie 的回调
   * @param loginStatePersistent 持久化用户信息的回调
   * @returns
   */
  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ) {
    return checkQrLogin(key, cookieSetter, loginStatePersistent);
  }
}

export class LyricAPIUtils {
  /**
   * 获取歌词对象
   * @param id 歌曲ID
   * @returns 歌词对象
   */
  static async getLyric(id: number) {
    return getLyric(id);
  }
  /**
   * 获取歌词字符串
   * @param id 歌曲ID
   * @returns 歌词文本
   */
  static async getLyricString(id: number) {
    return getLyricString(id);
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
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void) {
    return getPlayLists(offset, user, statePersistent);
  }
  /**
   * 获取歌单内歌曲列表
   * @param id 歌单ID
   * @param limit 返回数量
   * @param offset 偏移量
   * @param usetimestamp 是否带时间戳，默认true
   * @returns 歌曲列表
   */
  static async getPlayListSongs(id: number, limit: number, offset: number, usetimestamp: boolean = true) {
    return getPlayListSongs(id, limit, offset, usetimestamp);
  }
  /**
   * 歌单操作（添加/删除歌曲）
   * @param op 操作类型 'add' 或 'del'
   * @param pid 歌单ID
   * @param tracks 歌曲ID
   * @returns 是否操作成功
   */
  static async PlayListOperation(op: 'add' | 'del', pid: number, tracks: number) {
    return PlayListOperation(op, pid, tracks);
  }
  /**
   * 获取云盘歌曲列表
   * @param offset 偏移量
   * @returns 云盘歌曲列表
   */
  static async getCloudList(offset: number) {
    return getCloudList(offset);
  }
  /**
   * 搜索歌单
   * @param keywords 搜索关键字
   * @param offset 偏移量
   * @returns 匹配到的歌单列表
   */
  static async searchPlayLists(keywords: string, offset: number) {
    return searchPlayLists(keywords, offset);
  }
  /**
   * 收藏/取消收藏歌单
   * @param id 歌单ID
   * @param mode 1为收藏，2为取消收藏
   * @returns 是否操作成功
   */
  static async subscribePlayList(id: number, mode: number) {
    return subscribePlayList(id, mode);
  }
  /**
   * 获取个性化推荐歌单
   * @param statePersistent 按需求，可传入回调对返回的 PersonalListItem[] 进行持久化
   * @returns 推荐歌单列表
   */
  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void) {
    return getPersonalizedList(statePersistent);
  }
  /**
   * 删除歌单
   * @param id 歌单ID
   * @returns 是否删除成功
   */
  static async deletePlayList(id: number) {
    return deletePlayList(id);
  }
  /**
   * 创建歌单（暂不可用）
   * @param name 歌单名称
   * @param isPrivacy 是否私密
   * @returns 无
   */
  static async createPlayList(name: string, isPrivacy: boolean): Promise<void> {
    return createPlayList(name, isPrivacy);
  }
}

export class SongAPIUtils {
  /**
   * 检查音乐是否可用
   * @param id 歌曲ID
   * @returns 是否可用
   */
  static async checkMusic(id: number) {
    return checkMusic(id);
  }
  /**
   * 搜索歌曲
   * @param keywords 搜索关键字
   * @param offset 偏移量
   * @param limit 返回数量，默认30
   * @returns 匹配到的歌曲列表
   */
  static async searchSongs(keywords: string, offset: number, limit: number = 30) {
    return searchSongs(keywords, offset, limit);
  }
  /**
   * 获取歌曲播放URL
   * @param id 歌曲ID
   * @param quality 音质类型
   * @param isLogged 是否已登录
   * @returns 歌曲播放信息
   */
  static async getSongUrl(id: number, quality: QualityType, isLogged: boolean) {
    return getSongUrl(id, quality, isLogged);
  }
  /**
   * 获取歌曲图片URL
   * @param ids 歌曲ID
   * @returns 歌曲图片链接
   */
  static async getSongPicUrl(ids: number) {
    return getSongPicUrl(ids);
  }
  /**
   * 获取每日推荐歌曲
   * @param useCookie 是否使用cookie，默认true
   * @returns 推荐歌曲列表
   */
  static async getDailySongs(useCookie: boolean = true) {
    return getDailySongs(useCookie);
  }
  /**
   * 获取喜欢的歌曲ID列表
   * @param statePersistent 按需求，可传入回调对返回的 string[] 进行持久化
   * @returns 喜欢的歌曲ID数组
   */
  static async getLikeList(statePersistent?: (val: string[]) => void) {
    return getLikeList(statePersistent);
  }
  /**
   * 喜欢/取消喜欢某首歌曲
   * @param id 歌曲ID
   * @returns 是否操作成功
   */
  static async likeMusic(id: number) {
    return likeMusic(id);
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
  ) {
    return setHeartMode(id, pid, cleanQueue, addQueue);
  }
  /**
   * 获取私人FM歌曲
   * @param mode 模式
   * @returns 歌曲对象
   */
  static async getPersonalFmSong(mode: number) {
    return getPersonalFmSong(mode);
  }
}

export class TopListAPIUtils {
  /**
   * 获取排行榜
   * @param statePersistent 按需求，可传入回调对返回的 TopListItem[] 进行持久化
   * @returns 排行榜列表
   */
  static async getTopList(statePersistent?: (val: TopListItem[]) => void) {
    return getTopList(statePersistent);
  }
}

export class GetDownloadInfoAPIUtils {
  /**
   * 获取下载信息
   * @param id 歌曲ID
   * @param quality 音质类型
   * @param isLogged 是否已登录
   * @returns 下载信息
   */
  static async getDownloadInfo(id: string, quality: QualityType, isLogged: boolean) {
    return getDownloadInfo(id, quality, isLogged);
  }
}
