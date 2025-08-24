import commonRequest, { generateRequestTokenSync } from "./request/RequestUtil";
import { ToastUtil } from "@pura/harmony-utils";
import { AlbumInfoResult, AlbumInfoResult_INITIAL, Album, SubAlbumResult } from "../entity/AlbumEntity";

/** getAlbumInfo 的返回类型 */
interface GetAlbumInfoResponse {
  album: AlbumInfoResult | null;
}

/**
 * 获取专辑信息和歌曲
 * @param id - 专辑ID
 */
export const getAlbumInfo = async (id: string): Promise<AlbumInfoResult> => {
  const result = await commonRequest<GetAlbumInfoResponse>({
    url: '/rest/getAlbum.view',
    params: { id, f: 'json' }
  });
  return result.album ?? AlbumInfoResult_INITIAL;
};

/** getUserSubscribedAlbum 的返回类型 */
interface GetUserSubAlbumResponse_Inner {
  album: Album[];
}

interface GetUserSubscribedAlbumResponse {
  starred: GetUserSubAlbumResponse_Inner
}

/**
 * 获取用户收藏的专辑（Navidrome Subsonic API 不直接支持“用户订阅专辑”，可用 getStarred/view 的方式）
 */
export const getUserSubscribedAlbum = async (statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> => {
  const result = await commonRequest<GetUserSubscribedAlbumResponse>({
    url: '/rest/getStarred.view',
    params: { f: 'json', type: 'album' }
  });
  const albums = result.starred.album ?? [];
  statePersistent?.(albums);
  return { data: albums } as SubAlbumResult;
};

/** searchAlbums 的返回类型 */
interface SearchAlbumsResponse_Inner {
  album: Album[];
}

interface SearchAlbumsResponse {
  searchResult2: SearchAlbumsResponse_Inner | null;
}

/**
 * 搜索专辑
 * @param keywords - 搜索关键词
 */
export const searchAlbums = async (keywords: string): Promise<Album[]> => {
  const result = await commonRequest<SearchAlbumsResponse>({
    url: '/rest/search2.view',
    params: { query: keywords, albumCount: 50, f: 'json' }
  });
  return result.searchResult2?.album ?? [];
};

/** subscribeAlbum 的返回类型 */
interface SubscribeAlbumResponse {
  code?: number;
  status?: string;
  message?: string;
}

/**
 * 收藏/取消收藏专辑
 * Navidrome Subsonic API 里对应“starred”功能
 * @param id - 专辑ID
 * @param t - 1 收藏，0 取消收藏
 */
export const subscribeAlbum = async (id: string, t: number): Promise<boolean> => {
  try {
    const response = await commonRequest<SubscribeAlbumResponse>({
      url: t === 1 ? '/rest/star.view' : '/rest/unstar.view',
      params: { id, type: 'album', f: 'json' }
    });
    if (response.status === 'ok') return true;
    ToastUtil.showToast(response.message || '操作失败');
    return false;
  } catch (err) {
    ToastUtil.showToast(err.message || '请求失败');
    return false;
  }
};

/** getAllAlbums 的返回类型 */
interface GetAlbumListResponse_Inner {
  album: Album[];
}

interface GetAlbumListResponse {
  albumList: GetAlbumListResponse_Inner | null;
}

/**
 * 获取专辑列表 (getAlbumList API)
 * 返回随机、最新、最高评级等专辑列表，类似于 Subsonic 网页界面主页的专辑列表
 * 
 * @param type - 列表类型，必填。可选值: 'random', 'newest', 'highest', 'frequent', 'recent', 
 *               'alphabeticalByName', 'alphabeticalByArtist', 'starred', 'byYear', 'byGenre'
 * @param size - 返回专辑数量，可选，默认 10，最大 500
 * @param offset - 列表偏移量，可选，默认 0，用于分页
 * @param fromYear - 起始年份，当 type 为 'byYear' 时使用，可选
 * @param toYear - 结束年份，当 type 为 'byYear' 时使用，可选
 * @param genre - 流派名称，当 type 为 'byGenre' 时使用，可选
 */
export const getAllAlbums = async (
  type: 'random' | 'newest' | 'highest' | 'frequent' | 'recent' | 'alphabeticalByName' | 'alphabeticalByArtist' | 'starred' | 'byYear' | 'byGenre',
  size: number,
  offset: number,
  fromYear?: number,
  toYear?: number,
  genre?: string
): Promise<Album[]> => {
  // 构建参数对象
  const params: Record<string, Object> = {
    "type": type,
    "size": Math.min(size, 500), // 确保不超过最大值 500
    "offset": offset,
    "f": 'json'
  };

  // 根据 type 添加额外参数
  if (type === 'byYear') {
    if (fromYear !== undefined) params.fromYear = fromYear;
    if (toYear !== undefined) params.toYear = toYear;
  } else if (type === 'byGenre' && genre) {
    params.genre = genre;
  }

  const result = await commonRequest<GetAlbumListResponse>({
    url: '/rest/getAlbumList.view',
    params
  });

  return result.albumList?.album ?? [];
};

/**
 * 获取歌曲的专辑封面 URL
 * @param album - Album 对象
 * @param size - 尺寸，可选，默认 500
 */
export const getAlbumCoverUrl = (album: Album, size: number = 500): string => {
  const coverArtId = album.coverArt;
  const params = generateRequestTokenSync() as Record<string, string>
  if (!coverArtId) return '';
  return `${params['baseUrl']}/rest/getCoverArt?u=${params['u']}&t=${params['t']}&s=${params['s']}&f=${params['f']}&v=${params['v']}&c=${params['c']}&id=${coverArtId}&size=${size}`;
};