import { ToastUtil } from "@pura/harmony-utils"
import { SongConvertUtils } from "../functions/convert"
import commonRequest, { getNowRequestContext, setupRequestContext } from "./request/RequestUtil"
import { getLoginStatus } from "./loginApi"
import { User } from "../entities/User"

interface GetQrCodeImg {
  qrimg: string
}

interface GetQrCodeKey {
  unikey: string
}

interface GetQrCodeResponse {
  data: GetQrCodeKey
}

interface GetQrCodeImgResponse {
  data: GetQrCodeImg
}

/**
 * 获取登录二维码
 * @returns string - qrImg
 */
export const getQrCode = async(): Promise<string[]> => {
  const keyResponse = await commonRequest<GetQrCodeResponse>({
    url: '/login/qr/key',
    params: { noCookie: true, timestamp: new Date().getTime() }
  })

  const unikey = keyResponse.data.unikey

  const imgResponse = await commonRequest<GetQrCodeImgResponse>({
    url: '/login/qr/create',
    params: { key: unikey, qrimg: true, timestamp: new Date().getTime(), noCookie: true }
  })

  return [unikey, imgResponse.data.qrimg]
}

/**
 * 检查二维码登录状态
 */
interface CheckQrResponse {
  code: number
  message: string
  cookie: string
}
export const checkQrLogin = async (key: string, cookieSetter: (cookie: string) => void, loginStatePersistent?: (val: User) => void): Promise<boolean> => {
  const response = await commonRequest<CheckQrResponse>({
    url: '/login/qr/check',
    params: { key, noCookie: true, timestamp: new Date().getTime() }
  })
  if(response.code === 803) { // success
    let cookie = response.cookie
    if(cookie) {
      cookie = SongConvertUtils.extractCookie(cookie)
      cookie = cookie + '; OS=pc'
      // 设置 RequestContext
      let context = getNowRequestContext()
      if (context) {
        context.cookie.cookie = cookie
        setupRequestContext(context)
      }
      // 调用 cookie 保存回调
      cookieSetter(cookie)
      // 检测登录状态，获取用户信息
      const result = await getLoginStatus(loginStatePersistent)
      return result
    }
  }
  ToastUtil.showToast(response.message)
  return false
}