import { CloudAPI_Album } from "./Album"
import { CloudAPI_Artist } from "./Song"

interface SongInfo {
  id: number
  name: string
  ar: CloudAPI_Artist[]
  dt: number
  al: CloudAPI_Album
  fee: number
}

interface ResultData {
  songInfo: SongInfo
}

/**
 * 心动模式
 */
export interface CloudAPI_HeartMode {
  code: number
  data: ResultData[]
}

/**
 * 推荐歌单信息
 */
export interface CloudAPI_PersonalListItem {
  id: number
  type: number
  name: string
  copywriter: string
  picUrl: string
  playCount: number
  trackCount: number
}

/**
 * 推荐歌单
 */
export interface CloudAPI_Personalized {
  hasTaste: boolean
  code: number
  result: CloudAPI_PersonalListItem[]
}

/**
 * 排行榜单个信息
 */
export interface CloudAPI_TopListItem {
  id: number
  name: string
  trackCount: number
  updateFrequency: string // “更新xx首”
  coverImgUrl: string
  description: string
  playCount: number
  subscribedCount: number
}

/**
 * 排行榜
 */
export interface CloudAPI_TopList {
  code: number
  list: CloudAPI_TopListItem[]
}