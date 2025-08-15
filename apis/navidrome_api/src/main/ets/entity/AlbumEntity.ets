/** 专辑基本信息 */
export interface Album {
  id: string;              // 专辑ID
  name: string;            // 专辑名
  artist: string;          // 艺术家名
  artistId: string;        // 艺术家ID
  coverArt?: string;       // 封面ID（可以用 getCoverArt.view 获取图片）
  created?: string;        // 创建时间
  starred?: boolean;       // 是否收藏
  songCount?: number;      // 歌曲数量
}

/** 专辑详细信息，包括歌曲列表 */
export interface AlbumInfoResult extends Album {
  songs: AlbumSong[];           // 专辑下的歌曲列表
}

/** 歌曲信息 */
export interface AlbumSong {
  id: string;              // 歌曲ID
  title: string;           // 歌名
  artist: string;          // 歌手名
  artistId: string;        // 歌手ID
  album: string;           // 所属专辑
  albumId: string;         // 所属专辑ID
  track?: number;          // 曲目顺序
  duration?: number;       // 时长（秒）
  url?: string;            // 播放 URL，可通过 getSongUrl 获取
  coverArt?: string;       // 封面ID
  starred?: boolean;       // 是否收藏
}

/** 收藏专辑结果 */
export interface SubAlbumResult {
  data: Album[];
}

/** 搜索专辑结果 */
interface AlbumSearchResult_Inner {
  albums: Album[];
}

export interface AlbumSearchResult {
  result: AlbumSearchResult_Inner;
}

/** 默认初始值 */
export const AlbumInfoResult_INITIAL: AlbumInfoResult = {
  id: '',
  name: '',
  artist: '',
  artistId: '',
  songs: []
};

export const SubAlbumResult_INITIAL: SubAlbumResult = {
  data: []
}