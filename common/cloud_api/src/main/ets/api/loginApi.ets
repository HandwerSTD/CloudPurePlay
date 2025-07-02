import { LogUtil } from "@pura/harmony-utils"
import { User, User_INITIAL } from "../entities/User"
import commonRequest from "./request/RequestUtil"
import { preferences } from "@kit.ArkData"

/**
 * 获取登录状态，在此之前需要先把 Cookie 设置好
 */
export const getLoginStatus = async (statePersistent?: (val: preferences.ValueType) => void): Promise<boolean> => {
  try {
    const response = await commonRequest<User>({
      url: '/login/status',
      params: { timestamp: new Date().getTime() }
    })
    if (response.data.account.id && response.data.profile.nickname) {
      // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, response)
      // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, cookie)
      // AppStorage.setOrCreate(StorageConstants.VIP_TYPE, response.data.account.vipType)
      // AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, true)
      // AppStorage.setOrCreate(StorageConstants.USER, response)
      // AppStorage.setOrCreate(StorageConstants.IS_LOGGED, true)
      statePersistent?.(response)
      return true
    } else {
      // Promise.all([
      //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL),
      //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, ''),
      //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, []),
      //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, []),
      //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
      // ])
      // AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      // AppStorage.setOrCreate(StorageConstants.COOKIE, '')
      // AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      // AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
      statePersistent?.(User_INITIAL)
      return false
    }
  } catch (error) {
    LogUtil.error('获取登录状态失败: ', error.message)
    return false
  }
}

interface LogOutResponse {
  code: number
}

/**
 * 退出登录
 */
export const logOut = async (statePersistent?: (val: preferences.ValueType) => void): Promise<boolean> => {
  const response = await commonRequest<LogOutResponse>({
    url: '/logout',
    params: { timestamp: new Date().getTime() }
  })
  if(response.code === 200) {
    // Promise.all([
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL),
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, ''),
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, []),
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, []),
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
    // ])
    // AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
    // AppStorage.setOrCreate(StorageConstants.COOKIE, '')
    // AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
    // AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
    statePersistent?.(User_INITIAL)
    return true
  }
  return false
}