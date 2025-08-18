import { CloudAPI_PlayListSong } from "./PlayList"

/**
 * 歌手
 */
export interface CloudAPI_ArtistItem {
  id: number,
  name: string,
  picUrl: string
}

interface ArtistBody {
  artistCount: number
  artists: CloudAPI_ArtistItem[]
}

interface CloudAPI_ArtistInfoBody {
  briefDesc: string // 简介
  picUrl: string
  alias: string[] //别名
  name: string
  id: number
}

/**
 * 歌手详细信息
 */
export interface CloudAPI_ArtistInfo {
  artist: CloudAPI_ArtistInfoBody
  hotSongs: CloudAPI_PlayListSong[]
  code: number
  more: boolean
}

/**
 * 歌手请求
 */
export interface CloudAPI_ArtistsResult {
  result: ArtistBody
}

export const ArtistInfo_INITIAL: CloudAPI_ArtistInfo = {
  artist: {
    briefDesc: '',
    picUrl: '',
    alias: [],
    name: '',
    id: 0
  },
  hotSongs: [],
  code: 0,
  more: false
}