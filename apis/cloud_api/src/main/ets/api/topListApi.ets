import { CloudAPI_TopList, CloudAPI_TopListItem } from "../entities/Recommend"
import commonRequest from "./request/RequestUtil"

/**
 * 排行榜
 */
export const getTopList = async (statePersistent?: (val: CloudAPI_TopListItem[]) => void): Promise<CloudAPI_TopListItem[]> => {
  const response = await commonRequest<CloudAPI_TopList>({
    url: '/toplist',
    params: {}
  })
  if(response.code === 200) {
    // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.TOPLISTS, response.list)
    statePersistent?.(response.list)
  }
  return response.list
}