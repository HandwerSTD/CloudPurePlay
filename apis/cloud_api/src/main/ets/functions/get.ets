import commonRequest from "../api/request/RequestUtil";

const TAG = '[GET ]'

interface InnerData {
  version: string
}

interface InnerVersion {
  code: number,
  data: InnerData
}

export interface CloudAPI_checkValidUriParams {
  setChecking: (status: boolean) => void
  setResult: (success: boolean) => void
}

/**
 * 检查API URL连通性
 * @returns
 */
export async function checkValidUrl(params: CloudAPI_checkValidUriParams): Promise<boolean> {
  let result = false
  try {
    params.setChecking(true)
    const response = await commonRequest<InnerVersion>({
      url: '/inner/version',
      params: { timeout: 5000, noCookie: true }
    })
    if (response.code === 200) {
      params.setResult(true)
      result = true
    } else {
      params.setResult(false)
      result = false
    }
  } catch (e) {
    params.setResult(false)
    result = false
  } finally {
    params.setChecking(false)
    return result
  }
}


