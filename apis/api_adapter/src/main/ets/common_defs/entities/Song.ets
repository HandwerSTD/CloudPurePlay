import { Album } from "./Album"

/**
 * 歌手
 */
export interface Artist {
  id: string
  name: string
}

/**
 * 单曲
 */
export interface Song {
  id: string
  name: string
  artists: Artist[]
  album: Album
  duration: number
  alias: string[]
  fee: number
}

interface SearchResultBody {
  songs: Song[]
  hasMore: boolean
  songCount: number // 歌曲总数
}

/**
 * 歌曲搜索结果
 */
export interface SongSearchResult {
  result: SearchResultBody
}

interface Al {
  picUrl:string
}

interface SongDetailItem {
  al: Al
}

/**
 * SongDetail
 * 歌曲详细信息
 */
export interface SongDetail {
  songs: SongDetailItem[]
}

/**
 * 音质
 */
export type QualityType = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'dolby' | 'jymaster'

/**
 * 歌曲下载
 */
export interface SongDownloadItem {
  id: string
  url: string
  size: number
  type: string
  level: QualityType
}

/**
 * 歌曲Url
 */
export interface SongDownload {
  data: SongDownloadItem[]
}

interface SongPlayData {
  id: string
  url: string
  time: number
}

/**
 * 歌曲播放
 */
export interface SongPlayResult {
  data: SongPlayData[]
}

/**
 * 本地歌曲
 */
export interface LocalSong {
  id: string
  songId: string
  name: string
  artists: string
  picFile: string
  songFile: string
  lyricFile: string
}

export const LocalSong_INITIAL: LocalSong = {
  id: "",
  songId: "",
  name: "",
  artists: "",
  picFile: "",
  songFile: "",
  lyricFile: "",
}

export const SongPlay_INITIAL: SongPlayResult = {
  data: [{
    id: "",
    url: '',
    time: -1
  }]
}

export const SongDownload_INITIAL: SongDownload = {
  data: [{
    id: "",
    url: '',
    size: 0,
    type: '',
    level: 'lossless',
  }],
};

export const SongDetail_INITIAL: SongDetail = {
  songs: [
    {
      al: {
        picUrl: ''
      }
    }
  ]
};

export const Song_INITIAL: Song = {
  id: "",
  name: '',
  artists: [
    {
      id: "",
      name: '',
    }
  ],
  album: {
    id: "",
    name: '',
    picUrl: '',
    size: 0,
    artists: []
  },
  duration: 0,
  alias: [],
  fee: 0
}
