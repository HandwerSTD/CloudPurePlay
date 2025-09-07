/**
 * ConfigUtils
 *
 */
import { url } from '@kit.ArkTS'
import { Base64Util, CryptoUtil, MD5 } from '@pura/harmony-utils'
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
  static get NowRequestContext(): Object | null {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return CloudAPIConfigUtils.getRequestContext()
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return NavidromeAPIConfigUtils.getRequestContext()
    } else {
      throw Error('API Unimplemented')
    }
  }

  /**
   * 生成该 API Config 的标识符，用于判断两个 API Config 是否指向相同音乐库
   * @returns string
   */
  static getRequestContextIdentifier(): string {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      return MD5.digestSync(CloudAPIConfigUtils.getRequestContext()?.cookie.cookie ?? '_');
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      return NavidromeAPIConfigUtils.getRequestContextIdentifier()
    } else {
      throw Error('API Unimplemented')
    }
  }
  static sharePlainAPILink() {
    const data = encodeURIComponent(JSON.stringify(APIConfigUtils.NowRequestContext))
    return `cloudpureplay://handwer.top/share?type=plain&api=${InstanceSwitcher.InstanceTypeName}&data=${data}`
  }
  static shareEncryptedAPILink() {

  }
  static getConfigFromShareLink(link: string): [Object | null, string] {
    const u = url.URL.parseURL(link)
    const type = u.params.get('type')
    const data = u.params.get('data')
    const api = u.params.get('api')
    if (type === 'plain') {
      return [JSON.parse(decodeURIComponent(data!)) as Object, api!]
    }
    return [null, '']
  }
}