import commonRequest from "../api/request/RequestUtil";

const TAG = '[GET ]'

interface InnerData {
  version: string
}

interface InnerVersion {
  code: number,
  data: InnerData
}

export interface checkValidUriParams {
  setChecking: (status: boolean) => void
  setResult: (success: boolean) => void
}

/**
 * 检查API URL连通性
 * @returns
 */
export async function checkValidUrl(params: checkValidUriParams): Promise<boolean> {
  try {
    params.setChecking(true)
    const response = await commonRequest<InnerVersion>({
      url: '/inner/version',
      params: { timeout: 5000, noCookie: true }
    })
    if (response.code === 200) {
      params.setResult(true)
      return true
    } else {
      params.setResult(false)
      return false
    }
  } catch (e) {
    params.setResult(false)
    return false
  } finally {
    params.setChecking(false)
  }
}
