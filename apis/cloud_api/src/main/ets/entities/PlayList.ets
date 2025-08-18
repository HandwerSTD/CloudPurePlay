import { CloudAPI_Album } from "./Album"
import { CloudAPI_Artist } from "./Song"

/**
 * 歌单创建者
 */
export interface CloudAPI_Creator {
  userId: number
  nickname: string
  avatarUrl: string
}

/**
 * 歌单
 */
export interface CloudAPI_PlayList {
  coverImgUrl: string
  name: string
  id: number
  playCount: number
  subscribedCount: number
  userId: number
  trackCount: number
  subscribed: boolean
  creator: CloudAPI_Creator
  description: string
}

/**
 * 歌单结果
 */
export interface CloudAPI_PlayListResult {
  more: boolean
  playlist: CloudAPI_PlayList[]
}

interface OperationBody {
  code: number
  message: string
}

/**
 * 歌单操作结果
 */
export interface CloudAPI_PlayListOperationResult {
  status: number
  body: OperationBody
}

/**
 * 歌单列表返回类
 */
export interface CloudAPI_PlayListsResult {
  more:boolean
  playlist:CloudAPI_PlayList[]
}

interface SearchBody {
  hasMore: boolean
  playlists: Array<CloudAPI_PlayList>
}

/**
 * 搜索歌单结果
 */
export interface CloudAPI_PlayListSearchResult {
  code: number
  result: SearchBody
}

/**
 * 正在播放的歌单信息
 */
export interface CloudAPI_PlayingPlayList {
  id: number,
  count: number
}

/**
 * 歌单单曲
 */
export interface CloudAPI_PlayListSong {
  name: string
  id: number
  dt: number
  al: CloudAPI_Album
  ar: CloudAPI_Artist[]
  fee: number
}

/**
 * 歌单内歌曲结果
 */
export interface CloudAPI_PlayListSongsResult {
  songs: CloudAPI_PlayListSong[]
}

/**
 * 每日推荐歌单内歌曲
 */
interface DailySong {
  name: string
  id: number
  dt: number
  al: CloudAPI_Album
  ar: CloudAPI_Artist[]
  reason: string
  fee: number
}

interface Data {
  dailySongs: DailySong[]
}

export interface CloudAPI_DailyListSongs {
  data: Data
}

/**
 * 云盘歌单内歌曲
 */
interface CloudData {
  simpleSong: CloudAPI_PlayListSong
}

export interface CloudAPI_CloudResult {
  data: CloudData[]
  hasMore: boolean
}

export const PlayList_INITIAL: CloudAPI_PlayList = {
  coverImgUrl: '',
  name: '',
  id: 0,
  playCount: 0,
  subscribedCount: 0,
  userId: 0,
  trackCount: 0,
  subscribed: false,
  creator: {
    userId: -1,
    nickname: 'null',
    avatarUrl: ''
  },
  description: ""
};

export const PlayListResult_INITIAL: CloudAPI_PlayListResult = {
  more: false,
  playlist: [
    {
      coverImgUrl: '',
      name: '',
      id: 0,
      playCount: 0,
      subscribedCount: 0,
      userId: 0,
      trackCount: 0,
      subscribed: false,
      creator: {
        userId: -1,
        nickname: '',
        avatarUrl: ''
      },
      description: ''
    }
  ]
};

export const CloudResult_INITIAL: CloudAPI_CloudResult = {
  data: [],
  hasMore: false
}

export const PlayListOperationResult_INITIAL: CloudAPI_PlayListOperationResult = {
  status: 200,
  body:
  {
    code: -1,
    message: ''
  }
}
