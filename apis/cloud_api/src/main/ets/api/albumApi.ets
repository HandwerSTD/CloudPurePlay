import {
  Album,
  AlbumInfoResult,
  AlbumSearchResult,
  SubAlbumResult, SubAlbumResult_INITIAL } from "../entities/Album";
import commonRequest from "./request/RequestUtil";
import { preferences } from "@kit.ArkData";
import { ToastUtil } from "@pura/harmony-utils";

/**
 * 获取专辑信息和歌曲
 * @param id
 * @returns
 */
export const getAlbumInfo = async (id: number): Promise<AlbumInfoResult> =>
  commonRequest({
    url: '/album',
    params: { id }
})


/**
 * 获取收藏的专辑
 * @returns
 */
export const getUserSubscribedAlbum = async (statePersistent?: (val: Album[]) => void): Promise<SubAlbumResult> => {
  const result = await commonRequest<SubAlbumResult>({
    url: '/album/sublist',
    params: {}
  })
  // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, result.data)
  statePersistent?.(result.data)
  return result ?? SubAlbumResult_INITIAL
}

/**
 * 搜索专辑
 * @param keyword
 * @returns Album[]
 */
export const searchAlbums = async (keywords: string): Promise<Album[]> => {
  const result = await commonRequest<AlbumSearchResult>({
    url: '/search',
    params: { keywords, type: 10 }
  })
  return result.result.albums ?? []
}


interface albumSubResponse {
  code: number
  message: string
}

/**
 * 收藏/取消收藏专辑
 * @param id - 专辑id
 * @param t - 1:收藏, 0:取消收藏
 * @returns Promise<boolean>
 */
export const subscribeAlbum = async (id: number, t: number): Promise<boolean> => {
  const response = await commonRequest<albumSubResponse>({
    url: '/album/sub',
    params: { id, t, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response.message)
  return false
}
