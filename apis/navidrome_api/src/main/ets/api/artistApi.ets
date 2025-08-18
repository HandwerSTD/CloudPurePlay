import commonRequest from "./request/RequestUtil";
import { ArtistInfo, ArtistItem, ArtistsResult } from "../entity/ArtistEntity";

/** 获取歌手信息 */
interface ArtistInfoResponse {
  artist: ArtistInfo;
}

export const getArtistInfo = async (id: string): Promise<ArtistInfo> => {
  const result = await commonRequest<ArtistInfoResponse>({
    url: '/artists',
    params: { id }
  });
  return result.artist;
};

/** 搜索歌手列表 */
export const searchArtists = async (keywords: string, limit: number = 20): Promise<ArtistItem[]> => {
  const result = await commonRequest<ArtistsResult>({
    url: '/search',
    params: { keywords, limit, type: 100 } // type=100 表示搜索歌手
  });
  return result.result.artists ?? [];
};
