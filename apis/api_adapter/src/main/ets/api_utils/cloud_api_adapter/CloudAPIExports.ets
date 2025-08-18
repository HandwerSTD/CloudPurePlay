import { AlbumAPIUtils as Cloud_AlbumAPIUtils } from '@handwer/cloud_api';
import { ArtistAPIUtils as Cloud_ArtistAPIUtils } from '@handwer/cloud_api';
import { CommentAPIUtils as Cloud_CommentAPIUtils } from '@handwer/cloud_api';
import { DjAPIUtils as Cloud_DjAPIUtils } from '@handwer/cloud_api';
import { LoginAPIUtils as Cloud_LoginAPIUtils } from '@handwer/cloud_api';
import { LyricAPIUtils as Cloud_LyricAPIUtils } from '@handwer/cloud_api';
import { PlayListAPIUtils as Cloud_PlayListAPIUtils } from '@handwer/cloud_api';
import { SongAPIUtils as Cloud_SongAPIUtils } from '@handwer/cloud_api';
import { TopListAPIUtils as Cloud_TopListAPIUtils } from '@handwer/cloud_api';
import {
  AlbumInfoResult,
  Album,
  SubAlbumResult,
  ArtistInfo,
  ArtistItem,
  CommentResult,
  DjRadio,
  DjResult,
  DjProgramResult,
  User,
  LyricResult,
  PlayList,
  PlayListResult,
  PlayListSong,
  PlayListsResult,
  PersonalListItem,
  SearchReturn,
  QualityType,
  SongPlayResult,
  DailySongRes,
  Song,
  TopListItem
} from '../../common_defs/ExportedEntities';
import { COMMENT_TYPE, COMMENT_SORT_TYPE, PlayQueue } from '../../common_defs/ExportedModels';

export class CloudAPI_AlbumAPIUtils {
  static async getAlbumInfo(id: number): Promise<AlbumInfoResult> {
    return Cloud_AlbumAPIUtils.getAlbumInfo(id);
  }

  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> {
    return Cloud_AlbumAPIUtils.getUserSubscribedAlbum(statePersistent);
  }

  static async searchAlbums(keywords: string): Promise<Album[]> {
    return Cloud_AlbumAPIUtils.searchAlbums(keywords);
  }

  static async subscribeAlbum(id: number, t: number): Promise<boolean> {
    return Cloud_AlbumAPIUtils.subscribeAlbum(id, t);
  }
}

export class CloudAPI_ArtistAPIUtils {
  static async getArtistInfo(id: number): Promise<ArtistInfo> {
    return Cloud_ArtistAPIUtils.getArtistInfo(id);
  }

  static async searchArtists(keywords: string, limit: number = 20): Promise<ArtistItem[]> {
    return Cloud_ArtistAPIUtils.searchArtists(keywords, limit);
  }
}

export class CloudAPI_CommentAPIUtils {
  static async getComment(
    id: number,
    type: COMMENT_TYPE,
    pageNo: number = 1,
    pageSize: number = 30,
    sortType: COMMENT_SORT_TYPE,
    cursor?: number
  ): Promise<CommentResult> {
    return Cloud_CommentAPIUtils.getComment(id, type, pageNo, pageSize, sortType, cursor);
  }
}

export class CloudAPI_DjAPIUtils {
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult> {
    return Cloud_DjAPIUtils.getUserDjSubscribeList(statePersistent);
  }

  static async getDjPrograms(rid: number, limit: number, offset: number): Promise<DjProgramResult> {
    return Cloud_DjAPIUtils.getDjPrograms(rid, limit, offset);
  }

  static async putDjRadioInQueue(
    rid: number,
    trackCount: number,
    limit: number = 100,
    offset: number = 0,
    first: boolean = true,
    cleanQueue: () => Promise<void>,
    addToQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    return Cloud_DjAPIUtils.putDjRadioInQueue(rid, trackCount, limit, offset, first, cleanQueue, addToQueue);
  }

  static async getDjRadioList(keywords: string): Promise<DjRadio[]> {
    return Cloud_DjAPIUtils.getDjRadioList(keywords);
  }
}

export class CloudAPI_LoginAPIUtils {
  static async getLoginStatus(statePersistent?: (val: User) => void): Promise<boolean> {
    return Cloud_LoginAPIUtils.getLoginStatus(statePersistent);
  }

  static async logOut(statePersistent?: (val: User) => void): Promise<boolean> {
    return Cloud_LoginAPIUtils.logOut(statePersistent);
  }

  static async getQrCode(): Promise<string[]> {
    return Cloud_LoginAPIUtils.getQrCode();
  }

  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean> {
    return Cloud_LoginAPIUtils.checkQrLogin(key, cookieSetter, loginStatePersistent);
  }
}

export class CloudAPI_LyricAPIUtils {
  static async getLyric(id: number): Promise<LyricResult> {
    return Cloud_LyricAPIUtils.getLyric(id);
  }

  static async getLyricString(id: number): Promise<string> {
    return Cloud_LyricAPIUtils.getLyricString(id);
  }
}

export class CloudAPI_PlayListAPIUtils {
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void): Promise<PlayListResult> {
    return Cloud_PlayListAPIUtils.getPlayLists(offset, user as CloudUser, statePersistent);
  }

  static async getPlayListSongs(id: number, limit: number, offset: number, usetimestamp: boolean = true): Promise<PlayListSong[]> {
    return Cloud_PlayListAPIUtils.getPlayListSongs(id, limit, offset, usetimestamp);
  }

  static async PlayListOperation(op: 'add' | 'del', pid: number, tracks: number): Promise<boolean> {
    return Cloud_PlayListAPIUtils.PlayListOperation(op, pid, tracks);
  }

  static async searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult> {
    return Cloud_PlayListAPIUtils.searchPlayLists(keywords, offset);
  }

  static async subscribePlayList(id: number, mode: number): Promise<boolean> {
    return Cloud_PlayListAPIUtils.subscribePlayList(id, mode);
  }

  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]> {
    return Cloud_PlayListAPIUtils.getPersonalizedList(statePersistent);
  }

  static async deletePlayList(id: number): Promise<boolean> {
    return Cloud_PlayListAPIUtils.deletePlayList(id);
  }

  static async createPlayList(name: string, isPrivacy: boolean): Promise<boolean> {
    return Cloud_PlayListAPIUtils.createPlayList(name, isPrivacy);
  }

  static async renamePlaylist(pid: number, newName: string): Promise<boolean> {
    return Cloud_PlayListAPIUtils.renamePlayList(newName, pid);
  }
}

export class CloudAPI_SongAPIUtils {
  static async checkMusic(id: number): Promise<boolean> {
    return Cloud_SongAPIUtils.checkMusic(id);
  }

  static async searchSongs(keywords: string, offset: number, limit: number = 30): Promise<SearchReturn> {
    return Cloud_SongAPIUtils.searchSongs(keywords, offset, limit);
  }

  static async getSongUrl(id: number, quality: QualityType, isLogged: boolean): Promise<SongPlayResult> {
    return Cloud_SongAPIUtils.getSongUrl(id, quality, isLogged);
  }

  static async getSongPicUrl(ids: number): Promise<string> {
    return Cloud_SongAPIUtils.getSongPicUrl(ids);
  }

  static async getDailySongs(useCookie: boolean = true): Promise<DailySongRes[]> {
    return Cloud_SongAPIUtils.getDailySongs(useCookie);
  }

  static async getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]> {
    return Cloud_SongAPIUtils.getLikeList(user as CloudUser, statePersistent);
  }

  static async likeMusic(id: number): Promise<boolean> {
    return Cloud_SongAPIUtils.likeMusic(id);
  }

  static async setHeartMode(
    id: number,
    pid: number,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    return Cloud_SongAPIUtils.setHeartMode(id, pid, cleanQueue, addQueue);
  }

  static async getPersonalFmSong(mode: number): Promise<Song> {
    return Cloud_SongAPIUtils.getPersonalFmSong(mode);
  }
}

export class CloudAPI_TopListAPIUtils {
  static async getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]> {
    return Cloud_TopListAPIUtils.getTopList(statePersistent);
  }
}
