import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { NavidromeRequestContext as RequestContext } from './RequestContext'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { buffer } from '@kit.ArkTS';

const TAG = '[Navidrome RequestUtil]'

async function getMD5(message: string) {
  let mdAlgName = 'MD5'; // 摘要算法名。
  let md = cryptoFramework.createMd(mdAlgName);
  // 数据量较少时，可以只做一次update，将数据全部传入，接口未对入参长度做限制。
  await md.update({ data: new Uint8Array(buffer.from(message, 'utf-8').buffer) });
  let mdResult = await md.digest();

  return Array.from(mdResult.data)
    .map(b => b.toString(16).padStart(2, '0')) // 每个字节转16进制，补0
    .join('');
}

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


instance.interceptors.request.use(async (request: InternalAxiosRequestConfig ) => {
  // const settings: Api = await AppStorage.get(StorageConstants.API_SETTINGS) as Api
  if (!currentContext) return Promise.reject()
  // if(settings.user !== 'cloudmusic' && request.params?.baseUrl != Constants.API_URL) return Promise.reject()
  const ctx = JSON.parse(JSON.stringify(currentContext)) as RequestContext
  // baseUrl
  request.baseURL = !request.params?.baseUrl ? ctx.baseUrl : request.params.baseUrl
  // timeout
  request.timeout = request.params?.timeout ?? 15000
  // 补全 user token 部分

  // ===== 生成认证参数 =====
  let authParams: Record<string, string>
  if (ctx.token && ctx.salt) {
    // 已有 token + salt
    authParams = {
      "u": ctx.username,
      "t": ctx.token,
      "s": ctx.salt
    }
  } else if (ctx.password) {
    // 动态生成 salt + token
    const salt = Math.random().toString(36).substring(2, 8)
    const token = await getMD5(ctx.password + salt)
    authParams = {
      "u": ctx.username,
      "t": token,
      "s": salt
    }
  } else {
    return Promise.reject(new Error('No authentication info'))
  }

  // ===== 默认 API 参数 =====
  const defaultParams: Record<string, string> = {
    "v": ctx.apiVersion ?? '1.16.1',
    "c": ctx.clientName ?? 'CloudPurePlay',
    "f": 'json',
    ...authParams
  }

  // 合并 query 参数
  request.params = {
    ...defaultParams,
    ...request.params
  }
  return request
}, (err: AxiosError) => {
  console.error(TAG, 'request error: ' + err)
  return Promise.reject()
})

instance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (err: AxiosError) => {
  console.error(TAG, `error: ${err?.status} + ${err?.message ?? ""} -> URL = ${err.response?.config?.url}, baseURL = ${err.response?.config?.baseURL}`)
  return Promise.reject(err)
})

interface ApiResponse<T> {
  data: T
}

const commonRequest = async<T>(config: AxiosRequestConfig): Promise<T> => {
  try {
    const response = await instance.request(config) as ApiResponse<T>
    return response.data['subsonic-response']
  } catch (e) {
    console.error(TAG, `commonRequest got error: ${e.message ?? ""}, ${e.code ?? -1} for request ${config.url} with params ${JSON.stringify(config.params)}`)
    throw Error(e)
  }
}

export default commonRequest