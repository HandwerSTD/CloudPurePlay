/**
 * ConfigUtils
 *
 * 用于对 CloudAPI 的配置信息进行增删查改
 */
import { RequestContext, RequestCookieConfig } from "../api/request/RequestContext";
import { getNowRequestContext, setupRequestContext } from "../api/request/RequestUtil";
import { checkValidUriParams, checkValidUrl } from "../functions/get";

export { RequestContext, RequestCookieConfig, checkValidUriParams }

export class CloudAPIConfigUtils {
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