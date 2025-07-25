import { CloudAPIConfigUtils, LoginAPIUtils, User, User_INITIAL } from '@handwer/cloud_api'
import { Logger } from '../../exports'
import { PreferenceUtils } from '../Preferences/PreferenceUtils'
import { default as store } from './UserStore'

const TAG = '[UserManager]'

export enum SCUser {
  cookie = 1,
  user = 2,
  customCookie = 3,
}

const UserSettings = new PreferenceUtils('UserSettings')

export class UserManager {
  static async init() {
    UserSettings.init()
    if (UserSettings.get<string>(SCUser.user) !== undefined) {
      Logger.info(TAG, `detected existing user info, loaded`)
      store.user = UserSettings.get<User>(SCUser.user) ?? User_INITIAL
      let requestContext = CloudAPIConfigUtils.getRequestContext()
      if (requestContext) {
        requestContext.cookie.cookie = UserSettings.get<string>(SCUser.cookie)
        requestContext.cookie.customCookie = UserSettings.get<string>(SCUser.customCookie)
      }
      await LoginAPIUtils.getLoginStatus((val) => {
        store.user = val
        UserSettings.put(SCUser.user, val)
      })
    }
  }
  static getCookie() {
    if (store.cookieSettings.customCookie) return store.cookieSettings.customCookie
    return store.cookieSettings.cookie
  }
  static get isLogged() {
    return store.user != User_INITIAL
  }
  static setUserInfo(user: User) {
    store.user = user
  }
}

export default UserSettings