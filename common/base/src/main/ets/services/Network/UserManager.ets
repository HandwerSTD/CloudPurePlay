import { CloudAPIConfigUtils, LoginAPIUtils, User, User_INITIAL, PlayList, DjRadio, Album, TopListItem, PersonalListItem,
  APIConfigUtils } from '@handwer/api_adapter'
import { PreferenceUtils } from '../Preferences/PreferenceUtils'
import { PlayListAPIUtils, DjAPIUtils, AlbumAPIUtils, TopListAPIUtils, SongAPIUtils } from '@handwer/api_adapter'
import store from './UserStore'
import Logger from '../../utils/Logger'
import { SongLike } from '../PlaybackController/play/user/songLike'
import NowPlayingStore from '../PlaybackController/play/NowPlayingStore'

const TAG = '[UserManager]'

export enum SCUser {
  passwd = 1,
  user = 2,
  customCookie = 3,
  userPlaylists = 4,
  userDjRadioList = 5,
  userSubAlbum = 6,
  topLists = 7,
  personalizedList = 8,
  likeList = 9,
}

const UserSettings = new PreferenceUtils('UserSettings')

export class UserManager {
  static async init() {
    UserSettings.init()
    if (UserSettings.get<User>(SCUser.user) !== undefined) {
      Logger.info(TAG, `detected existing user info, loaded`)
      store.user = UserSettings.get<User>(SCUser.user) ?? User_INITIAL
      APIConfigUtils.setLoginToken(store.userId, UserSettings.get<string>(SCUser.passwd))
      const result = await LoginAPIUtils.getLoginStatus((val) => {
        store.user = val
        UserSettings.put(SCUser.user, val)
      })
      Logger.debug(TAG, `Login result: ${result}, user data = ${store.user.data.profile.nickname}`)
      if (result) {
        // 加载所有用户数据
        UserManager.loadAllUserData()
        // 歌曲红心信息
        SongLike.isThisSongLiked(NowPlayingStore.currentSong.id)
        UserManager.fetchAllUserData()
      }
    }
  }
  static getCookie(): string | undefined {
    if (store.cookieSettings.customCookie) return store.cookieSettings.customCookie
    return store.cookieSettings.cookie
  }
  static get isLogged() {
    return store.user != User_INITIAL
  }
  static setUserInfo(user: User, passwd?: string) {
    store.user = user
    UserSettings.put(SCUser.user, user)
    UserSettings.put(SCUser.passwd, passwd)
  }

  static async fetchAllUserData() {
    await Promise.allSettled([
    // 歌单
      PlayListAPIUtils.getPlayLists(0, store.user, (val) => {
        store.userPlaylists = val ?? store.userPlaylists
        UserManager.persistUserPlaylists()
      }),

      // 电台
      DjAPIUtils.getUserDjSubscribeList((val) => {
        store.userDjRadioList = val ?? store.userDjRadioList
        UserSettings.put(SCUser.userDjRadioList, store.userDjRadioList)
      }),

      // 收藏专辑
      AlbumAPIUtils.getUserSubscribedAlbum((val) => {
        store.userSubAlbum = val ?? store.userSubAlbum
        UserManager.persistUserSubAlbum()
      }),

      // 排行榜
      TopListAPIUtils.getTopList((val) => {
        store.topLists = val ?? store.topLists
        UserSettings.put(SCUser.topLists, store.topLists)
      }),

      // 个性化推荐歌单
      PlayListAPIUtils.getPersonalizedList((val) => {
        store.personalizedList = val ?? store.personalizedList
        UserSettings.put(SCUser.personalizedList, store.personalizedList)
      }),

      // 喜欢列表
      SongAPIUtils.getLikeList(store.user, (val) => {
        store.likeList = new Set(val ?? store.likeList)
        // 再次重置歌曲红心信息
        SongLike.isThisSongLiked(NowPlayingStore.currentSong.id)
        UserManager.persistLikeList()
      })
    ])

  }
  static async fetchDynamicData() {
    const dailySongs = await SongAPIUtils.getDailySongs()
  }
  static persistAllUserData() {
    Logger.info(TAG, 'Persisting all user data to preferences')
    
    // 存储用户歌单
    UserSettings.put(SCUser.userPlaylists, store.userPlaylists)
    
    // 存储用户电台列表
    UserSettings.put(SCUser.userDjRadioList, store.userDjRadioList)
    
    // 存储用户收藏专辑
    UserSettings.put(SCUser.userSubAlbum, store.userSubAlbum)
    
    // 存储排行榜
    UserSettings.put(SCUser.topLists, store.topLists)
    
    // 存储个性化推荐歌单
    UserSettings.put(SCUser.personalizedList, store.personalizedList)
    
    // 存储喜欢列表 (转换为数组格式存储)
    UserSettings.put(SCUser.likeList, Array.from(store.likeList))
  }
  
  static loadAllUserData() {
    Logger.info(TAG, 'Loading all user data from preferences')
    
    // 加载用户歌单
    const userPlaylists = UserSettings.get<PlayList[]>(SCUser.userPlaylists)
    if (userPlaylists) {
      store.userPlaylists = userPlaylists
    }
    
    // 加载用户电台列表
    const userDjRadioList = UserSettings.get<DjRadio[]>(SCUser.userDjRadioList)
    if (userDjRadioList) {
      store.userDjRadioList = userDjRadioList
    }
    
    // 加载用户收藏专辑
    const userSubAlbum = UserSettings.get<Album[]>(SCUser.userSubAlbum)
    if (userSubAlbum) {
      store.userSubAlbum = userSubAlbum
    }
    
    // 加载排行榜
    const topLists = UserSettings.get<TopListItem[]>(SCUser.topLists)
    if (topLists) {
      store.topLists = topLists
    }
    
    // 加载个性化推荐歌单
    const personalizedList = UserSettings.get<PersonalListItem[]>(SCUser.personalizedList)
    if (personalizedList) {
      store.personalizedList = personalizedList
    }
    
    // 加载喜欢列表 (从数组格式转换为Set)
    const likeList = UserSettings.get<string[]>(SCUser.likeList)
    if (likeList && Array.isArray(likeList)) {
      store.likeList = new Set(likeList)
    }
  }

  static clearAllUserData() {
    Logger.info(TAG, 'Clearing all user data from preferences')
    
    // 清除所有用户相关的存储数据
    UserSettings.del(SCUser.user)
    UserSettings.del(SCUser.passwd)
    UserSettings.del(SCUser.customCookie)
    UserSettings.del(SCUser.userPlaylists)
    UserSettings.del(SCUser.userDjRadioList)
    UserSettings.del(SCUser.userSubAlbum)
    UserSettings.del(SCUser.topLists)
    UserSettings.del(SCUser.personalizedList)
    UserSettings.del(SCUser.likeList)
    
    // 重置store中的数据
    store.user = User_INITIAL
    store.userPlaylists = []
    store.userDjRadioList = []
    store.userSubAlbum = []
    store.topLists = []
    store.personalizedList = []
    store.likeList = new Set()
  }

  static async fetchUserPlaylists() {
    // 歌单
    await PlayListAPIUtils.getPlayLists(0, store.user, (val) => {
      store.userPlaylists = val ?? store.userPlaylists
      UserManager.persistUserPlaylists()
    })
  }

  // 便捷方法：单独更新用户歌单
  static persistUserPlaylists() {
    UserSettings.put(SCUser.userPlaylists, store.userPlaylists)
  }

  // 便捷方法：单独更新喜欢列表
  static persistLikeList() {
    UserSettings.put(SCUser.likeList, Array.from(store.likeList))
  }

  // 便捷方法：单独更新收藏专辑
  static persistUserSubAlbum() {
    UserSettings.put(SCUser.userSubAlbum, store.userSubAlbum)
  }

  // static changeLikeStat(id: number, stat: boolean) {
  //   if (stat) store.likeList.add(id.toString())
  //   else store.likeList.delete(id.toString())
  //   setTimeout(() => {
  //     UserManager.updateLikeList()
  //   })
  // }
}

export default UserSettings