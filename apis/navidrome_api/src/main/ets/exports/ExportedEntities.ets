// 导出所有 Navidrome API 实体

// 专辑相关实体
export {
  Album as Navidrome_Album,
  AlbumInfoResult as Navidrome_AlbumInfoResult,
  AlbumSong as Navidrome_AlbumSong,
  SubAlbumResult as Navidrome_SubAlbumResult,
  AlbumSearchResult as Navidrome_AlbumSearchResult,
  AlbumInfoResult_INITIAL as Navidrome_AlbumInfoResult_INITIAL,
  SubAlbumResult_INITIAL as Navidrome_SubAlbumResult_INITIAL
} from '../entity/AlbumEntity';

// 艺术家相关实体
export {
  ArtistInfo as Navidrome_ArtistInfo,
  ArtistItem as Navidrome_ArtistItem,
  ArtistsResult as Navidrome_ArtistsResult
} from '../entity/ArtistEntity';

// 歌单相关实体
export {
  PlayList as Navidrome_PlayList,
  PlayListsResult as Navidrome_PlayListsResult,
  PlayListSongsResult as Navidrome_PlayListSongsResult
} from '../entity/PlaylistEntity';

// 歌曲相关实体
export {
  Song as Navidrome_Song,
  SongSearchResult as Navidrome_SongSearchResult,
  SongPlayResult as Navidrome_SongPlayResult,
  LikeList as Navidrome_LikeList,
  SongArtist as Navidrome_SongArtist
} from '../entity/SongEntity';

// 排行榜相关实体
export {
  TopList as Navidrome_TopList
} from '../entity/TopListEntity';

// 用户相关实体
export {
  User as Navidrome_User,
  User_INITIAL as Navidrome_User_INITIAL
} from '../entity/UserEntity';

// 搜索相关实体
export {
  SearchParams as Navidrome_SearchParams,
  SearchResult2 as Navidrome_SearchResult2,
  Search2Response as Navidrome_Search2Response,
  UnifiedSearchResult as Navidrome_UnifiedSearchResult,
  UNIFIED_SEARCH_RESULT_INITIAL as Navidrome_UNIFIED_SEARCH_RESULT_INITIAL
} from '../entity/SearchEntity';

export { LyricResult as Navidrome_LyricResult} from '../api/LyricApi'
