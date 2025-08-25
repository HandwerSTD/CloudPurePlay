import { Album } from './AlbumEntity';
import { ArtistItem } from './ArtistEntity';
import { Song } from './SongEntity';

/** search2 API 参数 */
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

/** search2 API 返回的搜索结果 */
export interface SearchResult2 {
  artist?: ArtistItem[];
  album?: Album[];
  song?: Song[];
}

/** search2 API 响应结构 */
export interface Search2Response {
  searchResult2: SearchResult2;
}

/** 统一的搜索结果，用于 API Adapter */
export interface UnifiedSearchResult {
  artists: ArtistItem[];
  albums: Album[];
  songs: Song[];
  hasMoreArtists: boolean;
  hasMoreAlbums: boolean;
  hasMoreSongs: boolean;
}

/** 搜索结果初始值 */
export const UNIFIED_SEARCH_RESULT_INITIAL: UnifiedSearchResult = {
  artists: [],
  albums: [],
  songs: [],
  hasMoreArtists: false,
  hasMoreAlbums: false,
  hasMoreSongs: false
};
