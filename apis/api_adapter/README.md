# API Adapter

所有云净听支持的 API 必须采用本模块进行接入。

## 接入流程

1. 在父级 `apis/` 文件夹新建 module，将新的接口导入本项目，以 `web_dav_api` 为例
2. 在 `api_switcher/InstanceSwitcher.ets` 中添加新的类型枚举，如 `WEB_DAV`
3. 在 `api_utils/` 文件夹里新建 Adapter 文件夹，如 `web_dav_api_adapter/`
4. 在文件夹里实现新接口与 CloudPurePlay API 规范兼容的转换器类：
    - 需要参考下面的 Caller API Interface 实现所有（或部分）接口
    - 所有接口必须引用 `common_defs/` 中定义的数据结构
    - 所有接口最后需要导出到一个 `Exports.ets` （如 `WebDAV_APIExports.ets`），并使用别名将每个类加上 `API_` 前缀（如 `SomeApi as WebDAV_SomeApi`）
5. 如有些接口或实体实在无法兼容 CloudPurePlay API（例如，CloudPurePlay API 并未预留该功能的接口，或其接口标准参数严重不匹配等），请将它们单独导出
6. 导出该 API 接口的配置工具（考虑到各种 API 配置标准各不相同，配置工具不再由 CloudPurePlay API 统一标准，可自行实现），如 `WebDAVConfigUtils`
7. 在 `api_utils/CallerUtils.ets` 完成所有 API 所有函数的接入：
    - 使用格式 `if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.YOUR_API) { return ... }`
    - 大括号内填入刚刚实现的 Caller API
    - 为确保解耦干净，禁止在该文件内 import 任何来自外部 module 的接口，仅可导入 `common_defs/`，`api_switcher/`，`api_utils/your_api_adapter/` 中的内容
8. 在 `api_utils/ConfigUtils.ets` 导出 API 接口的配置工具与实体
9. 在 `api_utils/ExternalAPIs.ets` 导出无法兼容的接口与实体
10. 至此 API Adapter 接入完成，可以在更上层的业务逻辑实现新 API 的特有逻辑

## Caller API Interface

```extendtypescript
export interface AlbumAPIUtils {
  /**
   * 获取专辑信息和歌曲
   * @param id 专辑ID
   * @returns 专辑详细信息
   */
  getAlbumInfo(id: number): Promise<AlbumInfoResult>;

  /**
   * 获取用户订阅的专辑
   * @param statePersistent 可选回调，用于持久化返回的 Album[]
   * @returns 用户订阅的专辑数组
   */
  getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult>;

  /**
   * 搜索专辑
   * @param keywords 搜索关键字
   * @returns 匹配到的专辑数组
   */
  searchAlbums(keywords: string): Promise<Album[]>;
}

export interface ArtistAPIUtils {
  /**
   * 获取歌手信息
   * @param id 歌手ID
   * @returns 歌手详细信息
   */
  getArtistInfo(id: number): Promise<ArtistInfo>;

  /**
   * 搜索歌手
   * @param keywords 搜索关键字
   * @param limit 返回数量，默认20
   * @returns 匹配到的歌手数组
   */
  searchArtists(keywords: string, limit?: number): Promise<ArtistItem[]>;
}

export interface CommentAPIUtils {
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
  getComment(
    id: number,
    type: COMMENT_TYPE,
    pageNo?: number,
    pageSize?: number,
    sortType: COMMENT_SORT_TYPE,
    cursor?: number
  ): Promise<CommentResult>;
}

export interface DjAPIUtils {
  /**
   * 获取用户订阅的私人电台
   * @param statePersistent 可选回调
   * @returns 用户订阅的电台数组
   */
  getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult>;

  /**
   * 获取电台节目列表
   * @param rid 电台ID
   * @param limit 返回数量
   * @param offset 偏移量
   * @returns 节目列表
   */
  getDjPrograms(rid: number, limit: number, offset: number): Promise<DjProgramResult>;

  /**
   * 将电台节目加入播放队列
   */
  putDjRadioInQueue(
    rid: number,
    trackCount: number,
    limit?: number,
    offset?: number,
    first?: boolean,
    cleanQueue?: () => Promise<void>,
    addToQueue?: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void>;

  /**
   * 搜索电台
   * @param keywords 搜索关键字
   * @returns 匹配到的电台数组
   */
  getDjRadioList(keywords: string): Promise<DjRadio[]>;
}

export interface LoginAPIUtils {
  /**
   * 获取登录状态
   * @param statePersistent 可选回调
   * @returns 是否登录成功
   */
  getLoginStatus(statePersistent?: (val: User) => void): Promise<boolean>;

  /**
   * 登出
   */
  logOut(statePersistent?: (val: User) => void): Promise<boolean>;

  /**
   * 获取二维码图像
   * @returns [key, 图像链接]
   */
  getQrCode(): Promise<[string, string]>;

  /**
   * 检查二维码扫描结果
   */
  checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean>;
}

export interface LyricAPIUtils {
  /**
   * 获取歌词对象
   */
  getLyric(id: number): Promise<LyricResult>;

  /**
   * 获取歌词文本
   */
  getLyricString(id: number): Promise<string>;
}

export interface PlayListAPIUtils {
  /**
   * 获取用户歌单列表
   */
  getPlayLists(
    offset: number,
    user: User,
    statePersistent?: (val: PlayList[]) => void
  ): Promise<PlayListResult>;

  /**
   * 获取歌单内歌曲列表
   */
  getPlayListSongs(
    id: number,
    limit: number,
    offset: number,
    usetimestamp?: boolean
  ): Promise<PlayListSong[]>;

  /**
   * 歌单操作（添加/删除歌曲）
   */
  PlayListOperation(op: 'add' | 'del', pid: number, tracks: number): Promise<boolean>;

  /**
   * 搜索歌单
   */
  searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult>;

  /**
   * 收藏/取消收藏歌单
   */
  subscribePlayList(id: number, mode: number): Promise<boolean>;

  /**
   * 获取个性化推荐歌单
   */
  getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]>;

  /**
   * 删除歌单
   */
  deletePlayList(id: number): Promise<boolean>;

  /**
   * 创建歌单（暂不可用）
   */
  createPlayList(name: string, isPrivacy: boolean): Promise<void>;
}

export interface SongAPIUtils {
  /**
   * 检查音乐是否可用
   */
  checkMusic(id: number): Promise<boolean>;

  /**
   * 搜索歌曲
   */
  searchSongs(keywords: string, offset: number, limit?: number): Promise<SearchReturn>;

  /**
   * 获取歌曲播放URL
   */
  getSongUrl(id: number, quality: QualityType, isLogged: boolean): Promise<SongPlayResult>;

  /**
   * 获取歌曲图片链接
   */
  getSongPicUrl(ids: number): Promise<string>;

  /**
   * 获取每日推荐歌曲
   */
  getDailySongs(useCookie?: boolean): Promise<DailySongRes[]>;

  /**
   * 获取喜欢的歌曲ID列表
   */
  getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]>;

  /**
   * 喜欢某首歌曲
   */
  likeMusic(id: number): Promise<boolean>;

  /**
   * 设置心动模式
   */
  setHeartMode(
    id: number,
    pid: number,
    cleanQueue?: () => Promise<void>,
    addQueue?: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void>;

  /**
   * 获取私人FM歌曲
   */
  getPersonalFmSong(mode: number): Promise<Song>;
}

export interface TopListAPIUtils {
  /**
   * 获取排行榜
   */
  getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]>;
}
```