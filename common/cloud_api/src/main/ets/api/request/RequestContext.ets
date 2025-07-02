import { RealIP } from "../../common/model/Settings"

export interface RequestContext {
  baseUrl: string
  timeout: number
  cookie: RequestCookieConfig
  realIp: RealIP
}

export interface RequestCookieConfig {
  cookie?: string
  customCookie?: string
}