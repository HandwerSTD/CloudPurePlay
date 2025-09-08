import { APIConfigUtils, CacheSet, CacheSet_INITIAL, SongAPIUtils } from "@handwer/api_adapter";
import { LogUtil } from "@pura/harmony-utils";
import { MCMediaCache } from "@sj/mediacache";
import { NowPlayingStore } from "../../../../../../../Index";
import { SCPref } from "../../../../constants/PreferenceConstants";
import { UserManager } from "../../../Network/UserManager";
import Settings from "../../../Preferences/PreferenceUtils";

function getCacheSet() {
  try {
    const cacheSet = Settings.get<CacheSet>(SCPref.cacheSet)
    return cacheSet ?? CacheSet_INITIAL
  } catch (e) {
    LogUtil.error('[CacheSet]', 'getCacheSet Error: ' + e.message)
    return CacheSet_INITIAL
  }
}

export default class AudioCacheUtils {

  static async init() {
    const cacheSet = getCacheSet()
    MCMediaCache.setLogEnabled(false)
    MCMediaCache.setRequestHandler(async (request) => {
      let cookie = UserManager.getCookie()
      if (NowPlayingStore.currentSong.customAPI) {
        cookie = NowPlayingStore.currentSong.customAPI.apiPasswd
      }
      request.setHeader('cookie', cookie)
    })
    MCMediaCache.setAssetIdentifierPreprocessor(async (url) => {
      return SongAPIUtils.getSongUrlCacheId(url)
    })
    MCMediaCache.cacheConfig.maxDiskSize = cacheSet.songCacheMaxSize

    await MCMediaCache.prepare(getContext())
  }

  static async getProxyUrl(url: string) {
    // 临时屏蔽 Proxy
    // return url;
    return await MCMediaCache.proxy(url)
  }

  static async clearAll() {
    await MCMediaCache.removeCaches()
  }

  static async getTotalCachedSize() {
    const size = await MCMediaCache.totalCacheSize()
    return size
  }
}