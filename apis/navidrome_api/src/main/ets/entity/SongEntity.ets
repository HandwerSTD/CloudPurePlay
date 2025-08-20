/** 歌曲信息 */
export interface SongArtist {
  id: string;
  name: string;
}


/** 歌曲信息 */
export interface Song {
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
/** 搜索返回结果 */
interface SongSearchResult_Inner {
  song: Song[] | null;
}

export interface SongSearchResult {
  searchResult2: SongSearchResult_Inner;
}

/** 获取播放 URL 返回 */
export interface SongPlayResult {
  path: string; // stream URL
}

/** 喜欢歌曲列表 */
export interface LikeList {
  data: Song[];
}
