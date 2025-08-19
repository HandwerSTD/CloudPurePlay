import { User } from '../common_defs/entities/User';
import { PlayQueue } from '../common_defs/model/PlayQueue';
import { COMMENT_TYPE, COMMENT_SORT_TYPE } from '../common_defs/model/Enum';
import { InstanceSwitcher, INSTANCE_TYPE } from '../api_switcher/InstanceSwitcher';
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
} from '../common_defs/ExportedEntities';
import {
  CloudAPI_AlbumAPIUtils,
  CloudAPI_ArtistAPIUtils,
  CloudAPI_CommentAPIUtils,
  CloudAPI_DjAPIUtils,
  CloudAPI_LoginAPIUtils,
  CloudAPI_LyricAPIUtils,
  CloudAPI_PlayListAPIUtils,
  CloudAPI_SongAPIUtils,
  CloudAPI_TopListAPIUtils
} from './cloud_api_adapter/CloudAPIExports';
import {
  Navidrome_AlbumUtils,
  Navidrome_ArtistUtils,
  Navidrome_LoginUtils,
  Navidrome_LyricUtils,
  Navidrome_PlayListUtils,
  Navidrome_SongUtils,
  Navidrome_TopListUtils
} from './navidrome_api_adapter/NavidromeAPI_APIUtilsExports';


export class AlbumAPIUtils {
  static async getAlbumInfo(id: string): Promise<AlbumInfoResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_AlbumAPIUtils.getAlbumInfo(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_AlbumUtils.getAlbumInfo(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_AlbumAPIUtils.getUserSubscribedAlbum(statePersistent);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_AlbumUtils.getUserSubscribedAlbum(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async searchAlbums(keywords: string): Promise<Album[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_AlbumAPIUtils.searchAlbums(keywords);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_AlbumUtils.searchAlbums(keywords);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async subscribeAlbum(id: string, t: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_AlbumAPIUtils.subscribeAlbum(Number.parseInt(id), t);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_AlbumUtils.subscribeAlbum(id, t);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class ArtistAPIUtils {
  static async getArtistInfo(id: string): Promise<ArtistInfo> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_ArtistAPIUtils.getArtistInfo(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_ArtistUtils.getArtistInfo(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async searchArtists(keywords: string, limit: number = 20): Promise<ArtistItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_ArtistAPIUtils.searchArtists(keywords, limit);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_ArtistUtils.searchArtists(keywords, limit);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class CommentAPIUtils {
  static async getComment(
    id: string,
    type: COMMENT_TYPE,
    pageNo: number = 1,
    pageSize: number = 30,
    sortType: COMMENT_SORT_TYPE,
    cursor?: number
  ): Promise<CommentResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_CommentAPIUtils.getComment(Number.parseInt(id), type, pageNo, pageSize, sortType, cursor);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class DjAPIUtils {
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_DjAPIUtils.getUserDjSubscribeList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getDjPrograms(rid: string, limit: number, offset: number): Promise<DjProgramResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_DjAPIUtils.getDjPrograms(Number.parseInt(rid), limit, offset);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async putDjRadioInQueue(
    rid: string,
    trackCount: number,
    limit: number = 100,
    offset: number = 0,
    first: boolean = true,
    cleanQueue: () => Promise<void>,
    addToQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_DjAPIUtils.putDjRadioInQueue(
        Number.parseInt(rid),
        trackCount,
        limit,
        offset,
        first,
        cleanQueue,
        addToQueue
      );
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getDjRadioList(keywords: string): Promise<DjRadio[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_DjAPIUtils.getDjRadioList(keywords);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class LoginAPIUtils {
  static async getLoginStatus(statePersistent?: (val: User) => void, forceInstance?: INSTANCE_TYPE): Promise<boolean> {
    const type = forceInstance ?? InstanceSwitcher.InstanceType
    if (type === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LoginAPIUtils.getLoginStatus(statePersistent);
    } else if (type === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_LoginUtils.getLoginStatus(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async logOut(statePersistent?: (val: User) => void): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LoginAPIUtils.logOut(statePersistent);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_LoginUtils.logOut(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getQrCode(): Promise<string[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LoginAPIUtils.getQrCode();
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LoginAPIUtils.checkQrLogin(key, cookieSetter, loginStatePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class LyricAPIUtils {
  static async getLyric(id: string): Promise<LyricResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LyricAPIUtils.getLyric(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_LyricUtils.getLyric(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getLyricString(id: string): Promise<string> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_LyricAPIUtils.getLyricString(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_LyricUtils.getLyricString(id);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class PlayListAPIUtils {
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void): Promise<PlayListResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.getPlayLists(offset, user, statePersistent);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      // NavidromeAPI doesn't support offset parameter
      return Navidrome_PlayListUtils.getPlayLists(offset, user, statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getPlayListSongs(id: string, limit: number, offset: number, usetimestamp: boolean = true): Promise<PlayListSong[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.getPlayListSongs(Number.parseInt(id), limit, offset, usetimestamp);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      // NavidromeAPI doesn't support limit, offset, usetimestamp parameters
      return Navidrome_PlayListUtils.getPlayListSongs(id, limit, offset, usetimestamp);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async PlayListOperation(op: 'add' | 'del', pid: string, tracks: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.PlayListOperation(op, Number.parseInt(pid), Number.parseInt(tracks));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_PlayListUtils.PlayListOperation(op, pid, tracks);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.searchPlayLists(keywords, offset);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async subscribePlayList(id: string, mode: number): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.subscribePlayList(Number.parseInt(id), mode);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.getPersonalizedList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async deletePlayList(id: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.deletePlayList(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_PlayListUtils.deletePlayList(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async createPlayList(name: string, isPrivacy: boolean): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.createPlayList(name, isPrivacy);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      // NavidromeAPI doesn't support isPrivacy parameter
      return Navidrome_PlayListUtils.createPlayList(name, isPrivacy);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async renamePlaylist(pid: string, newName: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_PlayListAPIUtils.renamePlaylist(Number.parseInt(pid), newName);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_PlayListUtils.renamePlaylist(newName, pid);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class SongAPIUtils {
  static async checkMusic(id: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.checkMusic(Number.parseInt(id));
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async searchSongs(keywords: string, offset: number, limit: number = 30): Promise<SearchReturn> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.searchSongs(keywords, offset, limit);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_SongUtils.searchSongs(keywords, offset, limit);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getSongUrl(id: string, quality: QualityType, isLogged: boolean): Promise<SongPlayResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.getSongUrl(Number.parseInt(id), quality, isLogged);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      // NavidromeAPI doesn't support quality and isLogged parameters
      return Navidrome_SongUtils.getSongUrl(id, quality, isLogged);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getSongPicUrl(song: Song): Promise<string> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.getSongPicUrl(Number.parseInt(song.id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return song.album.picUrl
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getDailySongs(useCookie: boolean = true): Promise<DailySongRes[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.getDailySongs(useCookie);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.getLikeList(user, statePersistent);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_SongUtils.getLikeList(user, statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async likeMusic(id: string): Promise<boolean> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.likeMusic(Number.parseInt(id));
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_SongUtils.likeMusic(id);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async setHeartMode(
    id: string,
    pid: string,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.setHeartMode(Number.parseInt(id), Number.parseInt(pid), cleanQueue, addQueue);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async getPersonalFmSong(mode: number): Promise<Song> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_SongAPIUtils.getPersonalFmSong(mode);
    } else {
      throw Error('API Unimplemented')
    }
  }
}

export class TopListAPIUtils {
  static async getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPI_TopListAPIUtils.getTopList(statePersistent);
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return Navidrome_TopListUtils.getTopList(statePersistent);
    } else {
      throw Error('API Unimplemented')
    }
  }
}
