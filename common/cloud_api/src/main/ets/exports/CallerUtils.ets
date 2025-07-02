import { getAlbumInfo, getUserSubscribedAlbum, searchAlbums } from '../api/albumApi';
import { getArtistInfo, searchArtists } from '../api/artistApi';
import { getComment } from '../api/commentApi';
import { getUserDjSubscribeList, getDjPrograms, putDjRadioInQueue, getDjRadioList } from '../api/djApi';
import { getLoginStatus, logOut } from '../api/loginApi';
import { getLyric, getLyricString } from '../api/LyricApi';
import { getPlayLists, getPlayListSongs, PlayListOperation, getCloudList, searchPlayLists, subscribePlayList, getPersonalizedList, deletePlayList, createPlayList } from '../api/playListApi';
import { getQrCode, checkQrLogin } from '../api/qrCodeApi';
import { checkMusic, searchSongs, getSongUrl, getSongPicUrl, getDailySongs, getLikeList, likeMusic, setHeartMode, getPersonalFmSong } from '../api/songApi';
import { getTopList } from '../api/topListApi';
import { getDownloadInfo } from '../api/getDownloadInfo';
import { User } from '../entities/User';
import { PlayQueue } from '../model/PlayQueue';
import { QualityType } from '../entities/Song';
import { COMMENT_TYPE, COMMENT_SORT_TYPE } from '../model/Enum';
import { preferences } from '@kit.ArkData';

export class AlbumAPIUtils {
  static async getAlbumInfo(id: number) {
    return getAlbumInfo(id);
  }
  static async getUserSubscribedAlbum(statePersistent?: (val: preferences.ValueType) => void) {
    return getUserSubscribedAlbum(statePersistent);
  }
  static async searchAlbums(keywords: string) {
    return searchAlbums(keywords);
  }
}

export class ArtistAPIUtils {
  static async getArtistInfo(id: number) {
    return getArtistInfo(id);
  }
  static async searchArtists(keywords: string, limit: number = 20) {
    return searchArtists(keywords, limit);
  }
}

export class CommentAPIUtils {
  static async getComment(id: number, type: COMMENT_TYPE, pageNo: number = 1, pageSize: number = 30, sortType: COMMENT_SORT_TYPE, cursor?: number) {
    return getComment(id, type, pageNo, pageSize, sortType, cursor);
  }
}

export class DjAPIUtils {
  static async getUserDjSubscribeList(statePersistent?: (val: preferences.ValueType) => void) {
    return getUserDjSubscribeList(statePersistent);
  }
  static async getDjPrograms(rid: number, limit: number, offset: number) {
    return getDjPrograms(rid, limit, offset);
  }
  static async putDjRadioInQueue(
    rid: number,
    trackCount: number,
    limit: number = 100,
    offset: number = 0,
    first: boolean = true,
    cleanQueue: () => Promise<void>,
    addToQueue: (queue: PlayQueue[]) => Promise<void>
  ) {
    return putDjRadioInQueue(rid, trackCount, limit, offset, first, cleanQueue, addToQueue);
  }
  static async getDjRadioList(keywords: string) {
    return getDjRadioList(keywords);
  }
}

export class LoginAPIUtils {
  static async getLoginStatus(statePersistent?: (val: preferences.ValueType) => void) {
    return getLoginStatus(statePersistent);
  }
  static async logOut(statePersistent?: (val: preferences.ValueType) => void) {
    return logOut(statePersistent);
  }
}

export class LyricAPIUtils {
  static async getLyric(id: number) {
    return getLyric(id);
  }
  static async getLyricString(id: number) {
    return getLyricString(id);
  }
}

export class PlayListAPIUtils {
  static async getPlayLists(offset: number, user: User, statePersistent?: (val: preferences.ValueType) => void) {
    return getPlayLists(offset, user, statePersistent);
  }
  static async getPlayListSongs(id: number, limit: number, offset: number, usetimestamp: boolean = true) {
    return getPlayListSongs(id, limit, offset, usetimestamp);
  }
  static async PlayListOperation(op: 'add' | 'del', pid: number, tracks: number) {
    return PlayListOperation(op, pid, tracks);
  }
  static async getCloudList(offset: number) {
    return getCloudList(offset);
  }
  static async searchPlayLists(keywords: string, offset: number) {
    return searchPlayLists(keywords, offset);
  }
  static async subscribePlayList(id: number, mode: number) {
    return subscribePlayList(id, mode);
  }
  static async getPersonalizedList(statePersistent?: (val: preferences.ValueType) => void) {
    return getPersonalizedList(statePersistent);
  }
  static async deletePlayList(id: number) {
    return deletePlayList(id);
  }
  static async createPlayList(name: string, isPrivacy: boolean): Promise<void> {
    return createPlayList(name, isPrivacy);
  }
}

export class QrCodeAPIUtils {
  static async getQrCode() {
    return getQrCode();
  }
  static async checkQrLogin(
    key: string,
    cookieSetter: (cookie: string) => void,
    loginStatePersistent?: (val: preferences.ValueType) => void
  ) {
    return checkQrLogin(key, cookieSetter, loginStatePersistent);
  }
}

export class SongAPIUtils {
  static async checkMusic(id: number) {
    return checkMusic(id);
  }
  static async searchSongs(keywords: string, offset: number, limit: number = 30) {
    return searchSongs(keywords, offset, limit);
  }
  static async getSongUrl(id: number, quality: QualityType, isLogged: boolean) {
    return getSongUrl(id, quality, isLogged);
  }
  static async getSongPicUrl(ids: number) {
    return getSongPicUrl(ids);
  }
  static async getDailySongs(useCookie: boolean = true) {
    return getDailySongs(useCookie);
  }
  static async getLikeList(statePersistent?: (val: preferences.ValueType) => void) {
    return getLikeList(statePersistent);
  }
  static async likeMusic(id: number) {
    return likeMusic(id);
  }
  static async setHeartMode(
    id: number,
    pid: number,
    cleanQueue: () => Promise<void>,
    addQueue: (queue: PlayQueue[]) => Promise<void>
  ) {
    return setHeartMode(id, pid, cleanQueue, addQueue);
  }
  static async getPersonalFmSong(mode: number) {
    return getPersonalFmSong(mode);
  }
}

export class TopListAPIUtils {
  static async getTopList(statePersistent?: (val: preferences.ValueType) => void) {
    return getTopList(statePersistent);
  }
}

export class GetDownloadInfoAPIUtils {
  static async getDownloadInfo(id: string, quality: QualityType, isLogged: boolean) {
    return getDownloadInfo(id, quality, isLogged);
  }
}
