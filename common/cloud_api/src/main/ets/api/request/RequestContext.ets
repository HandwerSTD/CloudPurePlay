import { RealIP } from "../../model/Settings"

export interface RequestContext {
  /**
   * API 地址，需要带 http/https 前缀和端口号
   */
  baseUrl: string
  /**
   * Cookie 数据，可空（填 {} 即可）
   */
  cookie: RequestCookieConfig
  /**
   * 模拟地理位置 IP，建议使用 RealIP_INITIAL
   */
  realIp: RealIP
}

/**
 * 请求的 Cookie 设置
 * 在两个都为 undefined 时，cookie = undefined
 * 在有 customCookie 时优先取 customCookie
 */
export interface RequestCookieConfig {
  cookie?: string
  customCookie?: string
}