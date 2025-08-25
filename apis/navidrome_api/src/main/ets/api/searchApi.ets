import commonRequest from "./request/RequestUtil";
import { SearchParams, Search2Response, UnifiedSearchResult, UNIFIED_SEARCH_RESULT_INITIAL } from "../entity/SearchEntity";

/**
 * Navidrome search2 API 实现
 * 根据搜索条件返回匹配的艺术家、专辑和歌曲
 * @param params - 搜索参数
 * @returns Promise<UnifiedSearchResult> 统一格式的搜索结果
 */
export const search2 = async (params: SearchParams): Promise<UnifiedSearchResult> => {
  try {
    // 构建请求参数
    const requestParams: Record<string, Object> = {
      "query": params.query,
      "f": 'json'
    };

    // 添加可选参数
    if (params.artistCount !== undefined) requestParams.artistCount = params.artistCount;
    if (params.artistOffset !== undefined) requestParams.artistOffset = params.artistOffset;
    if (params.albumCount !== undefined) requestParams.albumCount = params.albumCount;
    if (params.albumOffset !== undefined) requestParams.albumOffset = params.albumOffset;
    if (params.songCount !== undefined) requestParams.songCount = params.songCount;
    if (params.songOffset !== undefined) requestParams.songOffset = params.songOffset;
    if (params.musicFolderId !== undefined) requestParams.musicFolderId = params.musicFolderId;

    const result = await commonRequest<Search2Response>({
      url: '/rest/search2.view',
      params: requestParams
    });

    const searchResult = result.searchResult2;
    
    return {
      artists: searchResult.artist ?? [],
      albums: searchResult.album ?? [],
      songs: searchResult.song ?? [],
      hasMoreArtists: (searchResult.artist?.length ?? 0) >= (params.artistCount ?? 20),
      hasMoreAlbums: (searchResult.album?.length ?? 0) >= (params.albumCount ?? 20),
      hasMoreSongs: (searchResult.song?.length ?? 0) >= (params.songCount ?? 20)
    };
  } catch (error) {
    console.error('Search2 API error:', error);
    return UNIFIED_SEARCH_RESULT_INITIAL;
  }
};

/**
 * 便捷的搜索函数，使用默认参数
 * @param query - 搜索关键词
 * @param options - 可选的搜索选项
 * @returns Promise<UnifiedSearchResult>
 */
export interface SearchAllParams {
  artistCount?: number;
  albumCount?: number;
  songCount?: number;
  musicFolderId?: string;
}

export const searchAll = async (
  query: string,
  options?: SearchAllParams
): Promise<UnifiedSearchResult> => {
  return search2({
    query,
    artistCount: options?.artistCount ?? 20,
    albumCount: options?.albumCount ?? 20,
    songCount: options?.songCount ?? 20,
    artistOffset: 0,
    albumOffset: 0,
    songOffset: 0,
    musicFolderId: options?.musicFolderId
  });
};

/**
 * 分页搜索艺术家
 * @param query - 搜索关键词
 * @param offset - 偏移量
 * @param count - 返回数量
 * @returns Promise<UnifiedSearchResult>
 */
export const searchArtistsPaged = async (
  query: string,
  offset: number = 0,
  count: number = 20
): Promise<UnifiedSearchResult> => {
  return search2({
    query,
    artistCount: count,
    artistOffset: offset,
    albumCount: 0,
    songCount: 0
  });
};

/**
 * 分页搜索专辑
 * @param query - 搜索关键词
 * @param offset - 偏移量
 * @param count - 返回数量
 * @returns Promise<UnifiedSearchResult>
 */
export const searchAlbumsPaged = async (
  query: string,
  offset: number = 0,
  count: number = 20
): Promise<UnifiedSearchResult> => {
  return search2({
    query,
    artistCount: 0,
    albumCount: count,
    albumOffset: offset,
    songCount: 0
  });
};

/**
 * 分页搜索歌曲
 * @param query - 搜索关键词
 * @param offset - 偏移量
 * @param count - 返回数量
 * @returns Promise<UnifiedSearchResult>
 */
export const searchSongsPaged = async (
  query: string,
  offset: number = 0,
  count: number = 20
): Promise<UnifiedSearchResult> => {
  return search2({
    query,
    artistCount: 0,
    albumCount: 0,
    songCount: count,
    songOffset: offset
  });
};
