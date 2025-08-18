import { CloudAPI_Album } from "./Album"

/**
 * 歌手
 */
export interface CloudAPI_Artist {
  id: number
  name: string
}

/**
 * 单曲
 */
export interface CloudAPI_Song {
  id: number
  name: string
  artists: CloudAPI_Artist[]
  album: CloudAPI_Album
  duration: number
  alias: string[]
  fee: number
}

interface SearchResultBody {
  songs: CloudAPI_Song[]
  hasMore: boolean
  songCount: number // 歌曲总数
}

/**
 * 歌曲搜索结果
 */
export interface CloudAPI_SongSearchResult {
  result: SearchResultBody
}

interface CloudAPI_Al {
  picUrl:string
}

interface SongDetailItem {
  al: CloudAPI_Al
}

/**
 * SongDetail
 * 歌曲详细信息
 */
export interface CloudAPI_SongDetail {
  songs: SongDetailItem[]
}

/**
 * 音质
 */
export type CloudAPI_QualityType = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'dolby' | 'jymaster'

/**
 * 歌曲下载
 */
export interface CloudAPI_SongDownloadItem {
  id: number
  url: string
  size: number
  type: string
  level: CloudAPI_QualityType
}

/**
 * 歌曲Url
 */
export interface CloudAPI_SongDownload {
  data: CloudAPI_SongDownloadItem[]
}

interface SongPlayData {
  id: number
  url: string
  time: number
}

/**
 * 歌曲播放
 */
export interface CloudAPI_SongPlayResult {
  data: SongPlayData[]
}

/**
 * 本地歌曲
 */
export interface CloudAPI_LocalSong {
  id: number
  songId: number
  name: string
  artists: string
  picFile: string
  songFile: string
  lyricFile: string
}

export const LocalSong_INITIAL: CloudAPI_LocalSong = {
  id: -1,
  songId: -1,
  name: "",
  artists: "",
  picFile: "",
  songFile: "",
  lyricFile: "",
}

export const SongPlay_INITIAL: CloudAPI_SongPlayResult = {
  data: [{
    id: -1,
    url: '',
    time: -1
  }]
}

export const SongDownload_INITIAL: CloudAPI_SongDownload = {
  data: [{
    id: 0,
    url: '',
    size: 0,
    type: '',
    level: 'lossless',
  }],
};

export const SongDetail_INITIAL: CloudAPI_SongDetail = {
  songs: [
    {
      al: {
        picUrl: ''
      }
    }
  ]
};

export const Song_INITIAL: CloudAPI_Song = {
  id: 0,
  name: '',
  artists: [
    {
      id: 0,
      name: '',
    }
  ],
  album: {
    id: 0,
    name: '',
    picUrl: '',
    size: 0,
    artists: []
  },
  duration: 0,
  alias: [],
  fee: 0
}
