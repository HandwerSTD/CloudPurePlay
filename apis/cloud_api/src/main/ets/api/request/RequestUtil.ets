import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'
import { RequestContext } from './RequestContext'

const TAG = 'RequestUtil'


let currentContext: RequestContext | null = null

export const setupRequestContext = (context: RequestContext) => {
  currentContext = context
}
export const getNowRequestContext = (): RequestContext => {
  return JSON.parse(JSON.stringify(currentContext))
}

const instance = axios.create({
  timeout: 15000
})

// custom cookie 比 cookie 优先级高
const getCookie = () => {
  if (!currentContext) return ''
  if (currentContext.cookie.customCookie) return currentContext.cookie.customCookie
  return currentContext.cookie.cookie
}

instance.interceptors.request.use(async (request: InternalAxiosRequestConfig ) => {
  // const settings: Api = await AppStorage.get(StorageConstants.API_SETTINGS) as Api
  if (!currentContext) return Promise.reject()
  // if(settings.user !== 'cloudmusic' && request.params?.baseUrl != Constants.API_URL) return Promise.reject()

  // baseUrl
  request.baseURL = !request.params.baseUrl ? currentContext.baseUrl : request.params.baseUrl
  // timeout
  request.timeout = request.params.timeout ?? 15000
  // Cookie
  if(!request.params.noCookie) {
    request.headers['cookie'] = getCookie()
  }
  // realIP
  if(!request.url?.includes('/login')) {
    const realIP = currentContext?.realIp
    if(realIP.toggle) {
      request.params.realIP = realIP.realIp
    }
  }
  return request
}, (err: AxiosError) => {
  LogUtil.error(TAG, 'request error: ' + err)
  return Promise.reject()
})

instance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (err: AxiosError) => {
  LogUtil.error(TAG, `error: ${err?.status} + ${err?.message ?? ""} -> URL =  ${err.response?.config.url}`)
  return Promise.reject(err)
})

interface ApiResponse<T> {
  data: T
}

const commonRequest = async<T>(config: AxiosRequestConfig): Promise<T> => {
  try {
    const response = await instance.request(config) as ApiResponse<T>
    return response.data
  } catch (e) {
    LogUtil.error(TAG, `commonRequest got error: ${e.message ?? ""}, ${e.code ?? -1} for request ${config.url} with params ${JSON.stringify(config.params)}`)
    throw Error(e)
  }
}

export default commonRequest