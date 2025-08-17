import { Song } from "./SongEntity";

/** 歌单信息 */
export interface PlayList {
  id: number;
  name: string;
  owner?: string;
  public?: boolean;
  songCount?: number;
  coverArt?: string
}

/** 歌单列表返回 */
export interface PlayListsResult {
  more: boolean;
  playlist: PlayList[];
}


/** 获取歌单内歌曲返回 */
export interface PlayListSongsResult {
  songs: Song[];
}

/** 收藏/取消收藏返回 */
interface StarResponse {
  status: string;
}

/** 创建/删除/重命名返回 */
interface BasicResponse {
  status: string;
  message?: string;
}
