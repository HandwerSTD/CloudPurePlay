import { RealIP } from "../../model/Settings"

export interface RequestContext {
  baseUrl: string
  timeout: number
  cookie: RequestCookieConfig
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