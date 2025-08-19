/**
 * ConfigUtils
 *
 */
import { CloudAPIConfigUtils, Cloud_RequestContext, InstanceSwitcher, INSTANCE_TYPE,
  NavidromeAPIConfigUtils,
  NavidromeRequestContext,
  RealIP_INITIAL } from '../../../../Index'

// Cloud API
export {
  Cloud_RequestContext,
  Cloud_RequestCookieConfig,
  Cloud_checkValidUriParams,
  CloudAPIConfigUtils
} from './cloud_api_adapter/CloudAPI_ConfigExports'

export {NavidromeAPIConfigUtils, NavidromeRequestContext} from './navidrome_api_adapter/NavidromeAPI_ConfigExports'

export class APIConfigUtils {
  static loadRequestContext(context: Object) {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      // API 请求初始化
      CloudAPIConfigUtils.setRequestContext(context as Cloud_RequestContext)
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      NavidromeAPIConfigUtils.setRequestContext(context as NavidromeRequestContext)
    }
  }
  static setLoginToken(userName?: string, userPasswd?: string) {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      const context = CloudAPIConfigUtils.getRequestContext()!
      context.cookie = {
        cookie: userPasswd
      }
      CloudAPIConfigUtils.setRequestContext(context)
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      const context = NavidromeAPIConfigUtils.getRequestContext()!
      context.username = userName!
      context.password = userPasswd
      NavidromeAPIConfigUtils.setRequestContext(context)
    }
  }
  static get EmptyConfig() {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return {} as Cloud_RequestContext
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return {} as NavidromeRequestContext
    } else {
      throw Error('API Unimplemented')
    }
  }
}