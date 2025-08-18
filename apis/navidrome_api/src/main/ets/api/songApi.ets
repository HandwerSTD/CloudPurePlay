import { AlbumSong } from "../entity/AlbumEntity";
import { Song, SongSearchResult, SongPlayResult } from "../entity/SongEntity";
import commonRequest from "./request/RequestUtil";

/**
 * 搜索歌曲
 * @param keywords - 搜索关键词
 * @param limit - 限制返回数量
 */
export const searchSongs = async (
  keywords: string,
  limit: number = 50,
  offset: number = 0
): Promise<Song[]> => {
  const result = await commonRequest<SongSearchResult>({
    url: '/rest/search2.view',
    params: {
      query: keywords,
      songCount: limit,
      songOffset: offset,
      f: 'json'
    }
  });

  return result.searchResult2?.song ?? [];
};

export const getSongUrl = async (id: string): Promise<SongPlayResult> => {
  return commonRequest<SongPlayResult>({
    url: '/rest/stream.view',
    params: { id, f: 'json' }
  });
};

/** Navidrome 收藏歌曲列表 */
interface GetStarredSongsResponse {
  musicDirectory: Song[] | null;
}

export const getLikeList = async (): Promise<Song[]> => {
  const response = await commonRequest<GetStarredSongsResponse>({
    url: '/rest/getStarred.view',
    params: { type: 'song', f: 'json' }
  });

  return response.musicDirectory ?? [];
};
interface StarResponse {
  status: string;
}

export const likeMusic = async (songId: string, add: boolean = true): Promise<boolean> => {
  const response = await commonRequest<StarResponse>({
    url: '/rest/star.view',
    params: { id: songId, type: 'song', add, f: 'json' }
  });

  return response.status === 'ok';
};

export const getCoverUrl = (coverArtId: string, size: number = 500): string => {
  return `/rest/getCoverArt.view?id=${coverArtId}&size=${size}`;
};

/**
 * 获取歌曲的专辑封面 URL
 * @param song - Song 对象
 * @param size - 尺寸，可选，默认 500
 */
export const getSongCoverUrl = (song: Song, size: number = 500): string => {
  const coverArtId = song.album?.coverArt;
  if (!coverArtId) return '';
  return `/rest/getCoverArt.view?id=${coverArtId}&size=${size}`;
};

/**
 * 获取歌曲的专辑封面 URL
 * @param song - Song 对象
 * @param size - 尺寸，可选，默认 500
 */
export const getAlbumSongCoverUrl = (song: AlbumSong, size: number = 500): string => {
  const coverArtId = song.coverArt;
  if (!coverArtId) return '';
  return `/rest/getCoverArt.view?id=${coverArtId}&size=${size}`;
};
