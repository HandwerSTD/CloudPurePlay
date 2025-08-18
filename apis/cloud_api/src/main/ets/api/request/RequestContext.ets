import { CloudAPI_RealIP } from "../../model/Settings"

export interface CloudAPI_RequestContext {
  /**
   * API 地址，需要带 http/https 前缀和端口号
   */
  baseUrl: string
  /**
   * Cookie 数据，可空（填 {} 即可）
   */
  cookie: CloudAPI_RequestCookieConfig
  /**
   * 模拟地理位置的 IP，用于突破地区限制访问网易云音乐，不知道填什么请使用 RealIP_INITIAL
   */
  realIp: CloudAPI_RealIP
}

/**
 * 请求的 Cookie 设置
 * 在两个都为 undefined 时，cookie = undefined
 * 在有 customCookie 时优先取 customCookie
 */
export interface CloudAPI_RequestCookieConfig {
  cookie?: string
  customCookie?: string
}