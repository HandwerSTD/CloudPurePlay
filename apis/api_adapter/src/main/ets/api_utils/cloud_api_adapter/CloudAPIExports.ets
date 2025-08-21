import { AlbumAPIUtils as Cloud_AlbumAPIUtils,
  CloudAPI_PlayList,
  CloudAPI_PlayListsResult,
  CloudAPI_PlayQueue} from '@handwer/cloud_api';
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
import { CloudAPIEntityParser } from './CloudAPIEntityParser';

export class CloudAPI_AlbumAPIUtils {
  static async getAlbumInfo(id: number): Promise<AlbumInfoResult> {
    const cloudResult = await Cloud_AlbumAPIUtils.getAlbumInfo(id);
    return CloudAPIEntityParser.parseAlbumInfoResult(cloudResult);
  }

  static async getUserSubscribedAlbum(statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> {
    const cloudResult = await Cloud_AlbumAPIUtils.getUserSubscribedAlbum(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.parseAlbums(val)) : undefined
    );
    return CloudAPIEntityParser.parseSubAlbumResult(cloudResult);
  }

  static async searchAlbums(keywords: string): Promise<Album[]> {
    const cloudResult = await Cloud_AlbumAPIUtils.searchAlbums(keywords);
    return CloudAPIEntityParser.parseAlbums(cloudResult);
  }

  static async subscribeAlbum(id: number, t: number): Promise<boolean> {
    return Cloud_AlbumAPIUtils.subscribeAlbum(id, t);
  }
}

export class CloudAPI_ArtistAPIUtils {
  static async getArtistInfo(id: number): Promise<ArtistInfo> {
    const cloudResult = await Cloud_ArtistAPIUtils.getArtistInfo(id);
    return CloudAPIEntityParser.parseArtistInfo(cloudResult);
  }

  static async searchArtists(keywords: string, limit: number = 20): Promise<ArtistItem[]> {
    const cloudResult = await Cloud_ArtistAPIUtils.searchArtists(keywords, limit);
    return cloudResult.map(artist => CloudAPIEntityParser.parseArtistItem(artist));
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
    const cloudResult = await Cloud_CommentAPIUtils.getComment(id, type as number, pageNo, pageSize, sortType as number, cursor);
    return CloudAPIEntityParser.parseCommentResult(cloudResult);
  }
}

export class CloudAPI_DjAPIUtils {
  static async getUserDjSubscribeList(statePersistent?: (val: DjRadio[]) => void): Promise<DjResult> {
    const cloudResult = await Cloud_DjAPIUtils.getUserDjSubscribeList(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.batchParseDjRadios(val)) : undefined
    );
    return CloudAPIEntityParser.parseDjResult(cloudResult);
  }

  static async getDjPrograms(rid: number, limit: number, offset: number): Promise<DjProgramResult> {
    const cloudResult = await Cloud_DjAPIUtils.getDjPrograms(rid, limit, offset);
    return CloudAPIEntityParser.parseDjProgramResult(cloudResult);
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
    const adder = async (qq: CloudAPI_PlayQueue[]) => {
      return addToQueue(qq.map(q => ({
        playmode: q.playmode as number,
        picUrl: q.picUrl,
        fileName: q.fileName,
        song: CloudAPIEntityParser.parseSong(q.song)
      } as PlayQueue)))
    }
    return Cloud_DjAPIUtils.putDjRadioInQueue(rid, trackCount, limit, offset, first, cleanQueue, adder);
  }

  static async getDjRadioList(keywords: string): Promise<DjRadio[]> {
    const cloudResult = await Cloud_DjAPIUtils.getDjRadioList(keywords);
    return CloudAPIEntityParser.batchParseDjRadios(cloudResult);
  }
}

export class CloudAPI_LoginAPIUtils {
  static async getLoginStatus(statePersistent?: (val: User) => void): Promise<boolean> {
    return Cloud_LoginAPIUtils.getLoginStatus(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.parseUser(val)) : undefined
    );
  }

  static async logOut(statePersistent?: (val: User) => void): Promise<boolean> {
    return Cloud_LoginAPIUtils.logOut(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.parseUser(val)) : undefined
    );
  }

  static async getQrCode(): Promise<string[]> {
    return Cloud_LoginAPIUtils.getQrCode();
  }

  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: User) => void
  ): Promise<boolean> {
    return Cloud_LoginAPIUtils.checkQrLogin(
      key, 
      cookieSetter, 
      loginStatePersistent ? (val) => loginStatePersistent(CloudAPIEntityParser.parseUser(val)) : undefined
    );
  }
}

export class CloudAPI_LyricAPIUtils {
  static async getLyric(id: number): Promise<LyricResult> {
    const cloudResult = await Cloud_LyricAPIUtils.getLyric(id);
    return CloudAPIEntityParser.parseLyricResult(cloudResult);
  }

  static async getLyricString(id: number): Promise<string> {
    return Cloud_LyricAPIUtils.getLyricString(id);
  }
}

export class CloudAPI_PlayListAPIUtils {
  static async getPlaylistInfo(id: number) {
    const cloudResult: CloudAPI_PlayList = await Cloud_PlayListAPIUtils.getPlaylistInfo(id)
    return CloudAPIEntityParser.parsePlayList(cloudResult)
  }
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: PlayList[]) => void): Promise<PlayListResult> {
    const cloudResult: CloudAPI_PlayListsResult = await Cloud_PlayListAPIUtils.getPlayLists(
      offset, Number.parseInt(user.data.profile.userId),
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.parsePlayLists(val)) : undefined
    );
    return CloudAPIEntityParser.parsePlayListResult(JSON.parse(JSON.stringify(cloudResult)));
  }

  static async getPlayListSongs(id: number, limit: number, offset: number, usetimestamp: boolean = true): Promise<PlayListSong[]> {
    const cloudResult = await Cloud_PlayListAPIUtils.getPlayListSongs(id, limit, offset, usetimestamp);
    return cloudResult.map(song => ({
      id: song.id.toString(),
      ar: CloudAPIEntityParser.parseArtists(song.ar),
      al: CloudAPIEntityParser.parseAlbum(song.al),
      dt: song.dt,
      fee: song.fee,
      name: song.name
    } as PlayListSong));
  }

  static async PlayListOperation(op: 'add' | 'del', pid: number, tracks: number): Promise<boolean> {
    return Cloud_PlayListAPIUtils.PlayListOperation(op, pid, tracks);
  }

  static async searchPlayLists(keywords: string, offset: number): Promise<PlayListsResult> {
    const cloudResult = await Cloud_PlayListAPIUtils.searchPlayLists(keywords, offset);
    return CloudAPIEntityParser.parsePlayListsResult(cloudResult);
  }

  static async subscribePlayList(id: number, mode: number): Promise<boolean> {
    return Cloud_PlayListAPIUtils.subscribePlayList(id, mode);
  }

  static async getPersonalizedList(statePersistent?: (val: PersonalListItem[]) => void): Promise<PersonalListItem[]> {
    const cloudResult = await Cloud_PlayListAPIUtils.getPersonalizedList(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.batchParsePersonalListItems(val)) : undefined
    );
    return CloudAPIEntityParser.batchParsePersonalListItems(cloudResult);
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
    const cloudResult = await Cloud_SongAPIUtils.searchSongs(keywords, offset, limit);
    return CloudAPIEntityParser.parseSearchReturn(cloudResult);
  }

  static async getSongUrl(id: number, quality: QualityType, isLogged: boolean): Promise<SongPlayResult> {
    const cloudResult = await Cloud_SongAPIUtils.getSongUrl(id, quality, isLogged);
    return CloudAPIEntityParser.parseSongPlayResult(cloudResult);
  }

  static async getSongPicUrl(ids: number): Promise<string> {
    return Cloud_SongAPIUtils.getSongPicUrl(ids);
  }

  static async getDailySongs(useCookie: boolean = true): Promise<DailySongRes[]> {
    const cloudResult = await Cloud_SongAPIUtils.getDailySongs(useCookie);
    return CloudAPIEntityParser.parseDailyListSongs(cloudResult);
  }

  static async getLikeList(user: User, statePersistent?: (val: string[]) => void): Promise<string[]> {
    const cloudResult = await Cloud_SongAPIUtils.getLikeList(
      Number.parseInt(user.data.profile.userId),
      statePersistent ? (val) => statePersistent(val.map(id => id.toString())) : undefined
    );
    return cloudResult.map(id => id.toString());
  }

  static async likeMusic(id: number, setLike: boolean): Promise<boolean> {
    return Cloud_SongAPIUtils.likeMusic(id, setLike);
  }

  static async setHeartMode(
    id: number,
    pid: number,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ): Promise<void> {
    const adder = async (qq: CloudAPI_PlayQueue[]) => {
      return addQueue(qq.map(q => ({
        playmode: q.playmode as number,
        picUrl: q.picUrl,
        fileName: q.fileName,
        song: CloudAPIEntityParser.parseSong(q.song)
      } as PlayQueue)))
    }
    return Cloud_SongAPIUtils.setHeartMode(id, pid, cleanQueue, adder);
  }

  static async getPersonalFmSong(mode: number): Promise<Song> {
    const cloudResult = await Cloud_SongAPIUtils.getPersonalFmSong(mode);
    return CloudAPIEntityParser.parseSong(cloudResult);
  }
}

export class CloudAPI_TopListAPIUtils {
  static async getTopList(statePersistent?: (val: TopListItem[]) => void): Promise<TopListItem[]> {
    const cloudResult = await Cloud_TopListAPIUtils.getTopList(
      statePersistent ? (val) => statePersistent(CloudAPIEntityParser.batchParseTopListItems(val)) : undefined
    );
    return CloudAPIEntityParser.batchParseTopListItems(cloudResult);
  }
}

// Export the CloudAPI Entity Parser
export { CloudAPIEntityParser } from './CloudAPIEntityParser';