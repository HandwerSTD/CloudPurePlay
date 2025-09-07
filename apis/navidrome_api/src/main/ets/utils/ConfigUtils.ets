/**
 * ConfigUtils
 *
 * 用于对 Navidrome 的配置信息进行增删查改
 */

import { MD5 } from '@pura/harmony-utils'
import { NavidromeRequestContext as RequestContext } from '../api/request/RequestContext'
import commonRequest, { getNowRequestContext, setupRequestContext } from '../api/request/RequestUtil'

const TAG = 'NavidromeAPIConfigUtils'

export class NavidromeAPIConfigUtils {
  static getRequestContext(): RequestContext | null {
    return getNowRequestContext()
  }
  static getRequestContextIdentifier(): string {
    const ctx = getNowRequestContext()
    return MD5.digestSync(`baseURL: ${ctx.baseUrl};username: ${ctx.username};passwd: ${ctx.password ?? ''};`)
  }
  static setRequestContext(context: RequestContext) {
    setupRequestContext(context)
  }
  static checkValidConnection(param: checkValidUriParams) {
    return checkValidUrl(param)
  }
}

export { RequestContext as NavidromeRequestContext }

interface SubsonicPingInnerResponse {
  status: string;
  version: string;
}

interface checkValidUriParams {
  setChecking: (status: boolean) => void
  setResult: (success: boolean) => void
}

/**
 * 检查 Navidrome API 连通性（Subsonic /rest/ping）
 */
export async function checkValidUrl(params: checkValidUriParams): Promise<boolean> {
  let result: boolean = false
  try {
    params.setChecking(true)

    const response = await commonRequest<Record<string, Object> >({
      url: '/rest/ping',
      params: {}
    })
    const rec = response
    console.log(TAG, `check valid url result = ${JSON.stringify(rec)}`)

    if (rec.status === 'ok') {
      params.setResult(true)
      result = true
    } else {
      params.setResult(false)
      result = false
    }
  } catch (e) {
    console.error(TAG, `check connection failed: ${JSON.stringify(e)}`)
    params.setResult(false)
    result = false
  } finally {
    params.setChecking(false)
    return result
  }
}

