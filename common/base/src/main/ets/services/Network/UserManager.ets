import { User_INITIAL } from '@handwer/cloud_api'
import { default as store } from './UserStore'


export class UserManager {
  static getCookie() {
    if (store.cookieSettings.customCookie) return store.cookieSettings.customCookie
    return store.cookieSettings.cookie
  }
  static get isLogged() {
    return store.user != User_INITIAL
  }
}

