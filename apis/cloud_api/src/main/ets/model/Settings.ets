/**
 * 歌词样式
 */
export interface CloudAPI_LyricStyle {
  size: number
  weight: number | FontWeight

  onNotPlayScale: number
  onPlayWeight: number | FontWeight

  color: ResourceColor | string
  align: TextAlign
  mode: number // 0 - Normal, 1 - Translate, 2 - Roma
}

/**
 * 歌词位置
 */
export interface CloudAPI_LyricPosition {
  x: number,
  y: number
}

/**
 * 浮动歌词
 */
export interface CloudAPI_FloatLyric {
  on: boolean
  position: CloudAPI_LyricPosition
  size: number
  width: number
  lines: number
  align: 'start' | 'center' | 'end'
  bgBlur: boolean
  touchable: boolean
  opacity: number
  color: string | ResourceStr
  movable: boolean
}

/**
 * 缓存设置
 */
export interface CloudAPI_CacheSet {
  songCacheMaxSize: number
  staticCacheMaxSize: number
}

/**
 * Real IP 设置
 */
export interface CloudAPI_RealIP {
  /**
   * 是否使用 Real IP
   */
  toggle: boolean
  /**
   * 设置的 Real IP 值
   */
  realIp: string
}

export const RealIP_INITIAL: CloudAPI_RealIP = {
  toggle: false,
  realIp: '116.25.146.177'
}

export const CacheSet_INITIAL: CloudAPI_CacheSet = {
  songCacheMaxSize: 1024 * 1024 * 1024,
  staticCacheMaxSize: 1024 * 1024 * 1024
}

export const LyricStyle_INITIAL: CloudAPI_LyricStyle = {
  size: 28,
  weight: FontWeight.Bold,
  onNotPlayScale: 0.8,
  onPlayWeight: FontWeight.Bold,
  color: Color.White,
  align: TextAlign.Center,
  mode: 0
}

export const FloatLyric_INITIAL: CloudAPI_FloatLyric = {
  on: false,
  position: {
    x: 0,
    y: 30
  },
  size: 16,
  color: $r('app.color.app_red'),
  align: 'center',
  lines: 1,
  opacity: 1.0,
  touchable: true,
  bgBlur: false,
  width: 100,
  movable: false
}