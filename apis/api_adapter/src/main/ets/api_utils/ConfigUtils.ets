/**
 * ConfigUtils
 *
 */
import { AegRsa, AegStrUtil } from '@hw-agconnect/petal-aegis'
import { url } from '@kit.ArkTS'
import { Base64Util, CryptoUtil, MD5 } from '@pura/harmony-utils'
import { CloudAPIConfigUtils, Cloud_RequestContext,
  InstanceSwitcher, INSTANCE_TYPE,
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

export interface CommonRequestConfig {
  apiAddr: string
  apiUser: string
  apiPasswd: string
}

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
  // 用于 share music，而不是 share config
  static get requestConfig(): CommonRequestConfig {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.NAVIDROME) {
      const ctx = APIConfigUtils.NowRequestContext as NavidromeRequestContext
      return {
        apiAddr: ctx.baseUrl,
        apiUser: ctx.username,
        apiPasswd: ctx.password!
      }
    } else if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      const ctx = APIConfigUtils.NowRequestContext as Cloud_RequestContext
      return {
        apiAddr: ctx.baseUrl,
        apiUser: '',
        apiPasswd: ctx.cookie.cookie!
      }
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
    const raw_data = (new AegStrUtil()).ohAegStringToUint8Array(JSON.stringify(APIConfigUtils.NowRequestContext))
    const data = Base64Util.encodeToStrSync(raw_data)
    return `cloudpureplay://shareConfig/share?type=plain&api=${InstanceSwitcher.InstanceTypeName}&data=${data}`
  }
  // TODO: 加密分享，接收到的加密配置文件不可二次分享，不可查看密码
  // static async shareEncryptedAPILink(pubKey: string) {
  //   const data = (JSON.stringify(APIConfigUtils.NowRequestContext))
  //   const enc_data = await AegRsa.ohAegRsaEncTextHex(data, pubKey)
  //   return `cloudpureplay://shareConfig/share?type=encrypt&api=${InstanceSwitcher.InstanceTypeName}&data=${enc_data}`
  // }
  static getConfigFromShareLink(link: string): [Object | null, string] {
    const u = url.URL.parseURL(link)
    const type = u.params.get('type')
    const data64 = u.params.get('data')
    const api = u.params.get('api')
    const data = (new AegStrUtil()).ohAegUint8ArrayToString(Base64Util.decodeSync(data64!))
    if (type === 'plain') {
      return [JSON.parse((data!)) as Object, api!]
    }
    return [null, '']
  }
}