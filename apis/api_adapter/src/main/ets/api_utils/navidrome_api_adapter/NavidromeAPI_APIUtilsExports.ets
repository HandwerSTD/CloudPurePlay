import {
  NavidromeAPI_AlbumAPIUtils,
  NavidromeAPI_ArtistAPIUtils,
  NavidromeAPI_LoginAPIUtils,
  NavidromeAPI_LyricAPIUtils,
  NavidromeAPI_PlayListAPIUtils,
  NavidromeAPI_SongAPIUtils,
  NavidromeAPI_TopListAPIUtils
} from "@handwer/navidrome_api";
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
} from "../../common_defs/ExportedEntities";
import { COMMENT_TYPE, COMMENT_SORT_TYPE, PlayQueue } from "../../common_defs/ExportedModels";
import { NavidromeAPI_EntityParser } from "./NavidromeAPI_EntityParser";

export class Navidrome_AlbumUtils {
  static async getAlbumInfo(id: string): Promise<AlbumInfoResult> {
    const navidromeResult = await NavidromeAPI_AlbumAPIUtils.getAlbumInfo(id);
    return NavidromeAPI_EntityParser.parseAlbumInfoResult(navidromeResult);
  }

  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> {
    const navidromeResult = await NavidromeAPI_AlbumAPIUtils.getUserSubscribedAlbum();
    const parsedResult = NavidromeAPI_EntityParser.parseSubAlbumResult(navidromeResult);
    
    // 如果提供了状态持久化回调，调用它
    if (statePersistent) {
      statePersistent(parsedResult.data);
    }
    
    return parsedResult;
  }

  static async searchAlbums(keywords: string): Promise<Album[]> {
    const navidromeResult = await NavidromeAPI_AlbumAPIUtils.searchAlbums(keywords);
    const parsedResult = NavidromeAPI_EntityParser.parseAlbums(navidromeResult);
    return parsedResult;
  }

  static async subscribeAlbum(id: string, t: number): Promise<boolean> {
    return NavidromeAPI_AlbumAPIUtils.subscribeAlbum(id, t);
  }
}

export class Navidrome_ArtistUtils {
  static async getArtistInfo(id: string): Promise<ArtistInfo> {
    const navidromeResult = await NavidromeAPI_ArtistAPIUtils.getArtistInfo(id);
    return NavidromeAPI_EntityParser.parseArtistInfo(navidromeResult);
  }

  static async searchArtists(keywords: string, limit: number = 20): Promise<ArtistItem[]> {
    const navidromeResult = await NavidromeAPI_ArtistAPIUtils.searchArtists(keywords, limit);
    const parsedResult = navidromeResult.map(v => NavidromeAPI_EntityParser.parseArtistItem(v));
    return parsedResult;
  }
}

export class Navidrome_CommentUtils {
  static async getComment(
    id: string,
    type: COMMENT_TYPE,
    pageNo: number = 1,
    pageSize: number = 30,
    sortType: COMMENT_SORT_TYPE,
    cursor?: number
  ): Promise<CommentResult> {
    // NavidromeAPI doesn't support comments, return empty result
    throw Error('API Unimplemented - NavidromeAPI does not support comments');
  }
}

export class Navidrome_DjUtils {
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult> {
    // NavidromeAPI doesn't support DJ radios
    throw Error('API Unimplemented - NavidromeAPI does not support DJ radios');
  }

  static async getDjPrograms(rid: string, limit: number, offset: number): Promise<DjProgramResult> {
    // NavidromeAPI doesn't support DJ programs
    throw Error('API Unimplemented - NavidromeAPI does not support DJ programs');
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
    // NavidromeAPI doesn't support DJ radios
    throw Error('API Unimplemented - NavidromeAPI does not support DJ radios');
  }

  static async getDjRadioList(keywords: string): Promise<DjRadio[]> {
    // NavidromeAPI doesn't support DJ radios
    throw Error('API Unimplemented - NavidromeAPI does not support DJ radios');
  }
}

export class Navidrome_LoginUtils {
  static async getLoginStatus(statePersistent?: (val: User) => void): Promise<boolean> {
    const isLoggedIn = await NavidromeAPI_LoginAPIUtils.getLoginStatus((val) => {
      if (statePersistent) {
        statePersistent(NavidromeAPI_EntityParser.parseUser(val))
      }
    });
    return isLoggedIn;
  }

  static async logOut(statePersistent?: (val: User) => void): Promise<boolean> {
    const result = await NavidromeAPI_LoginAPIUtils.logOut((val) => {
      if (statePersistent) {
        statePersistent(NavidromeAPI_EntityParser.parseUser(val))
      }
    });
    return result;
  }

  static async getQrCode(): Promise<string[]> {
    // NavidromeAPI doesn't support QR code login
    throw Error('API Unimplemented - NavidromeAPI does not support QR code login');
  }

  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean> {
    // NavidromeAPI doesn't support QR code login
    throw Error('API Unimplemented - NavidromeAPI does not support QR code login');
  }
}

export class Navidrome_LyricUtils {
  static async getLyric(id: string): Promise<LyricResult> {
    const navidromeResult = await NavidromeAPI_LyricAPIUtils.getLyric(id);
    return NavidromeAPI_EntityParser.parseLyricResult(navidromeResult);
  }

  static async getLyricString(id: string): Promise<string> {
    return NavidromeAPI_LyricAPIUtils.getLyricString(id);
  }
}

export class Navidrome_PlayListUtils {
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void): Promise<PlayListResult> {
    // NavidromeAPI doesn't support offset parameter
    const res = await NavidromeAPI_PlayListAPIUtils.getPlayLists((v) => {
      statePersistent?.(v.map(vv => NavidromeAPI_EntityParser.parsePlayList(vv)))
    });
    return NavidromeAPI_EntityParser.parsePlayListsResult(res)
  }

  static async getPlayListSongs(id: string, limit: number, offset: number, usetimestamp: boolean = true): Promise<PlayListSong[]> {
    // NavidromeAPI doesn't support limit, offset, usetimestamp parameters
    const navidromeResult = await NavidromeAPI_PlayListAPIUtils.getPlayListSongs(id);
    return NavidromeAPI_EntityParser.parsePlayListSongs({
      songs: navidromeResult
    });
  }

  static async PlayListOperation(op: 'add' | 'del', pid: string, tracks: string): Promise<boolean> {
    return NavidromeAPI_PlayListAPIUtils.PlayListOperation(op, pid, tracks);
  }

  static async searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult> {
    // NavidromeAPI doesn't support playlist search
    throw Error('API Unimplemented - NavidromeAPI does not support playlist search');
  }

  static async subscribePlayList(id: string, mode: number): Promise<boolean> {
    // NavidromeAPI doesn't support playlist subscription
    throw Error('API Unimplemented - NavidromeAPI does not support playlist subscription');
  }

  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]> {
    // NavidromeAPI doesn't support personalized lists
    throw Error('API Unimplemented - NavidromeAPI does not support personalized lists');
  }

  static async deletePlayList(id: string): Promise<boolean> {
    return NavidromeAPI_PlayListAPIUtils.deletePlayList(id);
  }

  static async createPlayList(name: string, isPrivacy: boolean): Promise<boolean> {
    // NavidromeAPI doesn't support isPrivacy parameter
    return NavidromeAPI_PlayListAPIUtils.createPlayList(name);
  }

  static async renamePlaylist(pid: string, newName: string): Promise<boolean> {
    return NavidromeAPI_PlayListAPIUtils.renamePlayList(newName, pid);
  }
}

export class Navidrome_SongUtils {
  static async checkMusic(id: string): Promise<boolean> {
    // NavidromeAPI doesn't support music check
    throw Error('API Unimplemented - NavidromeAPI does not support music check');
  }

  static async searchSongs(keywords: string, offset: number, limit: number = 30): Promise<SearchReturn> {
    const navidromeResult = await NavidromeAPI_SongAPIUtils.searchSongs(keywords, offset, limit);
    const parsedResult = NavidromeAPI_EntityParser.parseSongs(navidromeResult);
    return {
      list: parsedResult,
      hasMore: false,
      songCount: parsedResult.length
    } as SearchReturn;
  }

  static async getSongUrl(id: string, quality: QualityType, isLogged: boolean): Promise<SongPlayResult> {
    // NavidromeAPI doesn't support quality and isLogged parameters
    const navidromeResult = await NavidromeAPI_SongAPIUtils.getSongUrl(id);
    return NavidromeAPI_EntityParser.parseSongPlayResult(navidromeResult);
  }

  static async getSongPicUrl(coverArtId: string): Promise<string> {
    // NavidromeAPI doesn't support getting song picture URL
    return NavidromeAPI_SongAPIUtils.getSongPicUrl(coverArtId)
  }

  static async getDailySongs(useCookie: boolean = true): Promise<DailySongRes[]> {
    // NavidromeAPI doesn't support daily songs
    throw Error('API Unimplemented - NavidromeAPI does not support daily songs');
  }

  static async getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]> {
    return NavidromeAPI_SongAPIUtils.getLikeList(statePersistent);
  }

  static async likeMusic(id: string): Promise<boolean> {
    return NavidromeAPI_SongAPIUtils.likeMusic(id);
  }

  static async setHeartMode(
    id: string,
    pid: string,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    // NavidromeAPI doesn't support heart mode
    throw Error('API Unimplemented - NavidromeAPI does not support heart mode');
  }

  static async getPersonalFmSong(mode: number): Promise<Song> {
    // NavidromeAPI doesn't support personal FM
    throw Error('API Unimplemented - NavidromeAPI does not support personal FM');
  }
}

export class Navidrome_TopListUtils {
  static async getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]> {
    const navidromeResult = await NavidromeAPI_TopListAPIUtils.getTopList();
    const parsedResult = NavidromeAPI_EntityParser.parseTopListItem({
      topSongs: navidromeResult
    });

    // NavidromeAPI返回的是单个TopList，我们将其包装为数组
    const topListItems = [parsedResult];

    // 如果提供了状态持久化回调，调用它
    if (statePersistent) {
      statePersistent(topListItems);
    }

    return topListItems;
  }
}