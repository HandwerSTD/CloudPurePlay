import { AlbumSong } from "../entity/AlbumEntity";
import { Song, SongSearchResult, SongPlayResult } from "../entity/SongEntity";
import commonRequest, { generateRequestTokenSync } from "./request/RequestUtil";

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
  const params = generateRequestTokenSync() as Record<string, string>
  const result = `${params['baseUrl']}/rest/stream.view?u=${params['u']}&t=${params['t']}&s=${params['s']}&f=${params['f']}&v=${params['v']}&c=${params['c']}&id=${id}`;
  return {
    path: result
  }
};

/** Navidrome 收藏歌曲列表 */
interface GetStarredSong_Inner {
  song: Song[];
}

interface GetStarredSongsResponse {
  starred: GetStarredSong_Inner
}

export const getLikeList = async (): Promise<Song[]> => {
  const response = await commonRequest<GetStarredSongsResponse>({
    url: '/rest/getStarred.view',
    params: { type: 'song', f: 'json' }
  });

  return response.starred.song ?? [];
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
  const params = generateRequestTokenSync() as Record<string, string>
  if (!coverArtId) return '';
  return `${params['baseUrl']}/rest/getCoverArt?u=${params['u']}&t=${params['t']}&s=${params['s']}&f=${params['f']}&v=${params['v']}&c=${params['c']}&id=${coverArtId}&size=${size}`;
};

/**
 * 获取歌曲的专辑封面 URL
 * @param song - Song 对象
 * @param size - 尺寸，可选，默认 500
 */
export const getSongCoverUrl = (song: Song, size: number = 500): string => {
  return getCoverUrl(song.album.coverArt!, size)
};
