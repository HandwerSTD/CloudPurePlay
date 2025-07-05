import { CacheSet, CacheSet_INITIAL } from "@handwer/cloud_api";
import { LogUtil } from "@pura/harmony-utils";
import { MCMediaCache } from "@sj/mediacache";
import { SCPref } from "../../../constants/PreferenceConstants";
import Settings from "../../Preferences/PreferenceUtils";

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
      let cookie = await getCookie()
      request.setHeader('cookie', cookie)
    })
    MCMediaCache.setAssetIdentifierPreprocessor(async (url) => {
      url = url.split('?')[0]
      let start: number = url.lastIndexOf("/")
      let end: number = url.lastIndexOf(".")
      let cacheName: string = url.substring(start + 1, end) + '-' + url.substring(end + 1)
      return cacheName
    })
    MCMediaCache.cacheConfig.maxDiskSize = cacheSet.songCacheMaxSize

    await MCMediaCache.prepare(getContext())
  }

  static async getProxyUrl(url: string) {
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