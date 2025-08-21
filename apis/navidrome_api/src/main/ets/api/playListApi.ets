import { PlayList, PlayListsResult } from "../entity/PlaylistEntity";
import { Song } from "../entity/SongEntity";
import { User } from "../entity/UserEntity";
import commonRequest from "./request/RequestUtil";

interface GetPlaylistResponse_Inner {
  playlist: PlayList[];
}

interface GetPlaylistResponse {
  playlists: GetPlaylistResponse_Inner
}

export const getPlayLists = async (): Promise<PlayListsResult> => {

  const response = await commonRequest<GetPlaylistResponse>({
    url: '/rest/getPlaylists.view',
    params: { f: 'json' }
  });

  return {
    more: false,
    playlist: response.playlists.playlist ?? []
  };
};


interface GetPlaylistInfoResponse {
  playlist: PlayList;
}

/**
 * 获取歌单详情（包含歌曲）
 * @param playlistId - 歌单 ID
 * @returns Playlist 对象（包含 entry 歌曲列表）
 */
export const getPlaylistDetail = async (playlistId: string): Promise<PlayList> => {
  const response = await commonRequest<GetPlaylistInfoResponse>({
    url: "/rest/getPlaylist.view",
    params: { id: playlistId, f: "json" }
  });

  return response.playlist;
};

interface GetPlaylistSongResponse_Inner {
  entry: Song[];
}

interface GetPlaylistSongResponse {
  playlist: GetPlaylistSongResponse_Inner;
}

export const getPlayListSongs = async (playlistId: string): Promise<Song[]> => {
  const response = await commonRequest<GetPlaylistSongResponse>({
    url: '/rest/getPlaylist.view',
    params: { id: playlistId, f: 'json' }
  });

  return response.playlist?.entry ?? [];
};

interface BasicResponse {
  status: string
}

// 创建歌单
export const createPlayList = async (name: string): Promise<boolean> => {
  const response = await commonRequest<BasicResponse>({
    url: '/rest/createPlaylist.view',
    params: { name, f: 'json' }
  });
  return response.status === 'ok';
};

// 删除歌单
export const deletePlayList = async (playlistId: string): Promise<boolean> => {
  const response = await commonRequest<BasicResponse>({
    url: '/rest/deletePlaylist.view',
    params: { id: playlistId, f: 'json' }
  });
  return response.status === 'ok';
};

// 重命名歌单
export const renamePlayList = async (playlistId: string, name: string): Promise<boolean> => {
  const response = await commonRequest<BasicResponse>({
    url: '/rest/updatePlaylist.view',
    params: { playlistId, name, f: 'json' }
  });
  return response.status === 'ok';
};

export const playListOperation = async (
  playlistId: string,
  songIds: string[],
  add: boolean
): Promise<boolean> => {
  if (add) {
    const params: Record<string, Object> = {
      "playlistId": playlistId,
      "songIdToAdd": songIds,
      "f": 'json'
    };
    const response = await commonRequest<BasicResponse>({
      url: '/rest/updatePlaylist.view',
      params
    });
    return response.status === 'ok';
  } else {
    interface _P {
      id: string,
      index: number
    }
    // 先获取歌单详情
    const playlist = await getPlayListSongs(playlistId);
    const toRemove = playlist.map((song, index) => ({
      id: song.id, index: index
    } as _P))
      .filter((val) => songIds.includes(val.id))
      .map((val) => val.index)

    const response = await commonRequest<BasicResponse>({
      url: '/rest/updatePlaylist.view',
      params: {
        playlistId,
        songIndexToRemove: toRemove,
        f: 'json'
      }
    });
    return response.status === 'ok'
  }

};
