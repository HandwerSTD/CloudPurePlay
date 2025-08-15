import { Song } from "../entity/SongEntity";
import commonRequest from "./request/RequestUtil";

/**
 * 获取排行榜（Most Played Tracks）
 */
interface GetTopListResponse {
  song: Song[];
}

export const getTopList = async (statePersistent?: (val: Song[]) => void): Promise<Song[]> => {
  const response = await commonRequest<GetTopListResponse>({
    url: '/rest/getTopSongs.view',
    params: { f: 'json' }
  });

  const list = response.song ?? [];
  statePersistent?.(list);
  return list;
};
