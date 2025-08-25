import { Artist, Song } from "./Song";
import { Album } from "./Album";
import { ArtistItem } from "./Artists";

export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}

/** 统一搜索结果，支持艺术家、专辑和歌曲的混合搜索 */
export interface UnifiedSearchResult {
  artists: Artist[];
  albums: Album[];
  songs: Song[];
  hasMoreArtists: boolean;
  hasMoreAlbums: boolean;
  hasMoreSongs: boolean;
}

/** 搜索参数 */
export interface SearchParams {
  query: string;
  artistCount?: number;
  artistOffset?: number;
  albumCount?: number;
  albumOffset?: number;
  songCount?: number;
  songOffset?: number;
  musicFolderId?: string;
}