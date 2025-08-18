/** 歌曲信息 */
interface SongArtist {
  id: string;
  name: string;
}

interface SongAlbum {
  id: string;
  name: string;
  coverArt?: string;
}

export interface Song {
  id: string;
  name: string;
  artists: SongArtist[];
  album: SongAlbum;
  duration: number;
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
