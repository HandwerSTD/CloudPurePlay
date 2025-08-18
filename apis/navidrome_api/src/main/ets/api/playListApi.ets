import { PlayList, PlayListsResult } from "../entity/PlaylistEntity";
import { Song } from "../entity/SongEntity";
import { User } from "../entity/UserEntity";
import commonRequest from "./request/RequestUtil";

interface GetPlaylistResponse {
  playlists: PlayList[];
}

export const getPlayLists = async (user: User): Promise<PlayListsResult> => {
  if (!user?.id) return { more: false, playlist: [] };

  const response = await commonRequest<GetPlaylistResponse>({
    url: '/rest/getPlaylists.view',
    params: { f: 'json' }
  });

  return {
    more: false,
    playlist: response.playlists ?? []
  };
};

interface GetPlaylistSongResponse_Inner {
  song: Song[];
}

interface GetPlaylistSongResponse {
  playlist: GetPlaylistSongResponse_Inner;
}

export const getPlayListSongs = async (playlistId: string): Promise<Song[]> => {
  const response = await commonRequest<GetPlaylistSongResponse>({
    url: '/rest/getPlaylist.view',
    params: { id: playlistId, f: 'json' }
  });

  return response.playlist?.song ?? [];
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
  const params: Record<string, Object> = {
    "playlistId": playlistId,
    "songId": songIds.join(','),
    "f": 'json'
  };

  // 如果是删除操作，添加 op=delete
  if (!add) {
    params.op = 'delete';
  }

  const response = await commonRequest<BasicResponse>({
    url: '/rest/updatePlaylist.view',
    params
  });

  return response.status === 'ok';
};
