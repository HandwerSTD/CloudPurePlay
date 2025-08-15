import commonRequest from "./request/RequestUtil";
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
export const getAlbumInfo = async (id: number): Promise<AlbumInfoResult> => {
  const result = await commonRequest<GetAlbumInfoResponse>({
    url: '/rest/getAlbum.view',
    params: { id, f: 'json' }
  });
  return result.album ?? AlbumInfoResult_INITIAL;
};

/** getUserSubscribedAlbum 的返回类型 */
interface GetUserSubscribedAlbumResponse {
  musicDirectory: Album[] | null;
}

/**
 * 获取用户收藏的专辑（Navidrome Subsonic API 不直接支持“用户订阅专辑”，可用 getStarred/view 的方式）
 */
export const getUserSubscribedAlbum = async (statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> => {
  const result = await commonRequest<GetUserSubscribedAlbumResponse>({
    url: '/rest/getStarred.view',
    params: { f: 'json', type: 'album' }
  });
  const albums = result.musicDirectory ?? [];
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
export const subscribeAlbum = async (id: number, t: number): Promise<boolean> => {
  try {
    const response = await commonRequest<SubscribeAlbumResponse>({
      url: '/rest/star.view',
      params: { id, type: 'album', add: t === 1 ? true : false, f: 'json' }
    });
    if (response.status === 'ok') return true;
    ToastUtil.showToast(response.message || '操作失败');
    return false;
  } catch (err) {
    ToastUtil.showToast(err.message || '请求失败');
    return false;
  }
};

/**
 * 获取歌曲的专辑封面 URL
 * @param song - Song 对象
 * @param size - 尺寸，可选，默认 500
 */
export const getAlbumCoverUrl = (album: Album, size: number = 500): string => {
  const coverArtId = album.coverArt;
  if (!coverArtId) return '';
  return `/rest/getCoverArt.view?id=${coverArtId}&size=${size}`;
};