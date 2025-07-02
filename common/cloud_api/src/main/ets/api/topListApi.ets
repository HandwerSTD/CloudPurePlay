import { StorageConstants } from "../constants/StorageConstants"
import { TopList, TopListItem } from "../entities/Recommend"
import commonRequest from "./request/RequestUtil"
import { preferences } from "@kit.ArkData"

/**
 * 排行榜
 */
export const getTopList = async (statePersistent?: (val: preferences.ValueType) => void): Promise<TopListItem[]> => {
  const response = await commonRequest<TopList>({
    url: '/toplist',
    params: {}
  })
  if(response.code === 200) {
    // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.TOPLISTS, response.list)
    statePersistent?.(response.list)
  }
  return response.list
}