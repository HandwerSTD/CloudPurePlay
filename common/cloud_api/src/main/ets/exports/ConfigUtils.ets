/**
 * ConfigUtils
 *
 * 用于对 CloudAPI 的配置信息进行增删查改
 */
import { RequestContext } from "../api/request/RequestContext";
import { getNowRequestContext, setupRequestContext } from "../api/request/RequestUtil";

export class ConfigUtils {
  static getRequestContext(): RequestContext | null {
    return getNowRequestContext()
  }
  static setRequestContext(context: RequestContext) {
    setupRequestContext(context)
  }
}