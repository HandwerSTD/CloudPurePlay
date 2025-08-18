import { LogUtil } from "@pura/harmony-utils"
import { PlayConstants } from "../constants/PlayConstants"
// import { StorageConstants } from "../constants/StorageConstants"
import { CloudAPI_HeartMode } from "../entities/Recommend"
import { CloudAPI_PlayQueue } from "../model/PlayQueue"
import { CloudAPI_QualityType, CloudAPI_Song, CloudAPI_SongDetail, Song_INITIAL, CloudAPI_SongPlayResult, CloudAPI_SongSearchResult } from "../entities/Song"
import { CloudAPI_User } from "../entities/User"
import { CloudAPI_DailySongRes } from "./playListApi"
import commonRequest from "./request/RequestUtil"
import { CloudAPI_DailyListSongs } from "../entities/PlayList"
import { preferences } from "@kit.ArkData"

interface CheckValiableResponse {
  success: boolean
}
/**
 * 音乐是否可用
 */
export const checkMusic = async (id: number): Promise<boolean> => {
  try {
    const response = await commonRequest<CheckValiableResponse>({
      url: '/check/music',
      params: { id }
    })
    return response.success
  } catch (e) {
    return false
  }
}

export interface CloudAPI_SearchReturn {
  list: Array<CloudAPI_Song>
  hasMore: boolean
  songCount: number
}
/**
 * 搜索歌曲
 * @param keywords
 * @param offset
 * @param limit
 */
export const searchSongs = async (
  keywords: string,
  offset: number,
  limit: number = 30
): Promise<CloudAPI_SearchReturn> => {
  const response = await commonRequest<CloudAPI_SongSearchResult>({
    url: '/search',
    params: { keywords, offset, limit, noCookie: true }
  })

  let searchReturn: CloudAPI_SearchReturn = {
    list: response.result.songs,
    hasMore: response.result.hasMore,
    songCount: response.result.songCount
  }
  return searchReturn
}

/**
 * 获取歌曲播放Url
 */
export const getSongUrl = async (
  id: number,
  quality: CloudAPI_QualityType,
  isLogged: boolean
): Promise<CloudAPI_SongPlayResult> => {
  return commonRequest({
    url: '/song/url/v1',
    params: { id, level: quality }
  })
}

/**
 * 获取歌曲图片Url
 * @param id
 * @returns string
 */
export const getSongPicUrl = async (ids: number): Promise<string> => {
  const response = await commonRequest<CloudAPI_SongDetail>({
    url: '/song/detail',
    params: { ids }
  })
  return response.songs[0].al.picUrl ?? ''
}

/**
 * 获取每日推荐歌单
 * @param useCookie
 * @returns
 */
export const getDailySongs = async (useCookie: boolean = true): Promise<Array<CloudAPI_DailySongRes>> => {
  let list: Array<CloudAPI_DailySongRes> = []
  const response = await commonRequest<CloudAPI_DailyListSongs>({
    url: '/recommend/songs',
    params: useCookie ? { } : { noCookie: true }
  })
  if(response.data) {
    for (let song of response.data.dailySongs) {
      list.push({
        song: {
          id: song.id,
          name: song.name,
          artists: song.ar,
          album: song.al,
          duration: song.dt,
          alias: [],
          fee: song.fee
        },
        reason: song.reason,
        picUrl: song.al.picUrl
      })
    }
  }
  return list
}

interface LikeListResponse {
  ids: string[]
}
/**
 * 获取喜欢列表(songId 数组)
 * @param uid
 * @returns
 */
export const getLikeList = async (userId: number, statePersistent?: (val: string[]) => void): Promise<string[]> => {
  let list:Array<string> = []
  const response = await commonRequest<LikeListResponse>({
    url: '/likelist',
    params: { uid: userId, timestamp: new Date().getTime() }
  })
  try {
    const dataGot: string[] = response.ids as string[]
    list = dataGot
    statePersistent?.(list)
  } catch (e) {
    LogUtil.error('WARNING: get like list failed: ' + JSON.stringify(e))
  } finally {
    // AppStorage.setOrCreate(StorageConstants.USER_LIKELIST, list)
    return list
  }
}

interface LikeMusicResponse {
  code: number
}
/**
 * 喜欢歌曲
 * @param id
 * @returns
 */
export const likeMusic = async (id: number): Promise<boolean> => {
  const response = await commonRequest<LikeMusicResponse>({
    url: '/like',
    params: { id, timestamp: new Date().getTime() }
  })
  return response.code === 200 ? true : false
}

/**
 * 心动模式
 * @param id - 歌曲id
 * @param pid - 歌单id
 */
export const setHeartMode = async (id: number, pid: number, cleanQueue: () => Promise<void>, addQueue: (queue: CloudAPI_PlayQueue[]) => Promise<void>): Promise<void> => {
  let queue: Array<CloudAPI_PlayQueue> = []
  let tempSong: CloudAPI_Song
  const response = await commonRequest<CloudAPI_HeartMode>({
    url: '/playmode/intelligence/list',
    params: { id, pid }
  })
  for(let item of response.data) {
    tempSong = {
      id: item.songInfo.id,
      name: item.songInfo.name,
      artists: item.songInfo.ar,
      album: item.songInfo.al,
      duration: item.songInfo.dt,
      alias: [],
      fee: item.songInfo.fee
    }
    queue.push({
      playmode: 1,
      song: tempSong,
      fileName: '',
      picUrl: item.songInfo.al.picUrl ?? ''
    })
  }
  await cleanQueue();
  await addQueue(queue);
}

interface PersonalFmSongResult {
  code: number
  data: CloudAPI_Song[]
}
/**
 * 获取私人FM歌曲
 */
export const getPersonalFmSong = async (mode: number): Promise<CloudAPI_Song> => {
  const response = await commonRequest<PersonalFmSongResult>({
    url: '/personal/fm/mode',
    params: { mode: PlayConstants.PERSONAL_FM_MODE[mode], timestamp: new Date().getTime() }
  })
  if(response.code == 200) {
    let dataGot = response.data[0] as CloudAPI_Song
    return dataGot
  } else return Song_INITIAL
}