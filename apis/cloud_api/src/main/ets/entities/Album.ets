import { CloudAPI_PlayListSong } from "./PlayList"
import { CloudAPI_Artist } from "./Song"

interface CloudAPI_AlbumDetail {
  company: string
  picUrl: string
  description: string
  name: string
  id: number
}

/**
 * 专辑详细信息
 */
export interface CloudAPI_AlbumInfoResult {
  code: number
  resourceState: boolean
  songs: CloudAPI_PlayListSong[]
  album: CloudAPI_AlbumDetail
}

/**
 * 专辑
 */
export interface CloudAPI_Album {
  artists: CloudAPI_Artist[]
  picUrl: string
  name: string
  id: number
  size: number
}

/**
 * 收藏专辑结果
 */
export interface CloudAPI_SubAlbumResult {
  data: CloudAPI_Album[]
}

interface CloudAPI_SearchResult {
  albums: CloudAPI_Album[]
}

/**
 * 搜索专辑结果
 */
export interface CloudAPI_AlbumSearchResult {
  result: CloudAPI_SearchResult
}

export const AlbumInfoResult_INITIAL: CloudAPI_AlbumInfoResult = {
  code: 200,
  resourceState: false,
  songs: [],
  album: {
    company: '',
    picUrl: '',
    description: '',
    name: '',
    id: 0
  }
}

export const SubAlbumResult_INITIAL: CloudAPI_SubAlbumResult = {
  data: []
}

export const Album_INITIAL: CloudAPI_Album = {
  artists: [],
  picUrl: "",
  name: "",
  id: 0,
  size: 0
}

export const AlbumSearchResult_INITIAL: CloudAPI_AlbumSearchResult = {
  result: {
    albums: []
  }
}