/**
 * ConfigUtils
 *
 * 用于对 Navidrome 的配置信息进行增删查改
 */

import { NavidromeRequestContext as RequestContext } from '../api/request/RequestContext'
import commonRequest, { getNowRequestContext, setupRequestContext } from '../api/request/RequestUtil'

const TAG = 'NavidromeAPIConfigUtils'

export class NavidromeAPIConfigUtils {
  static getRequestContext(): RequestContext | null {
    return getNowRequestContext()
  }
  static setRequestContext(context: RequestContext) {
    setupRequestContext(context)
  }
  static checkValidConnection(param: checkValidUriParams) {
    return checkValidUrl(param)
  }
}

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
      url: '/rest/ping'
    })
    const rec = response

    if ((rec['subsonic-response'] as SubsonicPingInnerResponse).status === 'ok') {
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

