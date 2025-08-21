import { ToastUtil } from "@pura/harmony-utils"
import {
  CloudAPI_CloudResult,
  CloudAPI_PlayList, CloudAPI_PlayListOperationResult,
  CloudAPI_PlayListResult,
  CloudAPI_PlayListSearchResult,
  CloudAPI_PlayListSong,
  CloudAPI_PlayListSongsResult,
  CloudAPI_PlayListsResult} from "../entities/PlayList"
import { CloudAPI_Song } from "../entities/Song"
import commonRequest from "./request/RequestUtil"
import { CloudAPI_Personalized, CloudAPI_PersonalListItem } from "../entities/Recommend"

/**
 * 获取用户歌单列表
 * @param offset - 偏移量
 * @returns list
 */
export const getPlayLists = async (offset: number, userId: number, statePersistent?: (val: CloudAPI_PlayList[]) => void): Promise<CloudAPI_PlayListsResult> => {
  let list: CloudAPI_PlayList[] = new Array()
  // const user = await PreferencesUtils.getPreferenceValue<User>(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL)
  if(userId === 0) {
    return { more: false, playlist: [] }
  }
  const response = await commonRequest<CloudAPI_PlayListResult>({
    url:'/user/playlist',
    params: { uid: userId, offset, timestamp: new Date().getTime() }
  })
  list = response.playlist
  // AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, list)
  // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, list)
  statePersistent?.(list)
  return response
}

/**
 * 获取歌单内歌曲列表
 * @param listId 歌单ID
 * @param trackCount 歌曲总数
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export const getPlayListSongs = async (
  id: number,
  limit: number,
  offset: number,
  usetimestamp: boolean = true
): Promise<CloudAPI_PlayListSong[]> => {
  const result = await commonRequest<CloudAPI_PlayListSongsResult>({
    url: '/playlist/track/all',
    params: { id, limit, offset, timestamp: new Date().getTime() }
  })
  return result.songs
}

export const getPlaylistInfo = async (id: number): Promise<CloudAPI_PlayList> => {
  const result = await commonRequest<Record<string, Object>>({
    url: '/playlist/detail',
    params: { id , timestamp: new Date().getTime()}
  })
  return result['playlist'] as CloudAPI_PlayList
}

/**
 * 歌单操作
 */
type OperationType = 'add' | 'del'
/**
 * 向歌单添加/删除歌曲
 * @param op - 操作 add/del
 * @param pid - 歌单id
 * @param tracks - 歌曲id(多个用,隔开)
 */
export const PlayListOperation = async (
  op: OperationType,
  pid:number,
  tracks:number
): Promise<boolean> => {
  const result = await commonRequest<CloudAPI_PlayListOperationResult>({
    url: '/playlist/tracks',
    params: { op: op, pid, tracks, timestamp: new Date().getTime() }
  })
  if(result.body.code === 200) return true
  return false
}

export interface CloudAPI_DailySongRes {
  song: CloudAPI_Song
  reason: string
  picUrl: string
}
/**
 * 获取云盘歌曲列表
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export const getCloudList = async (offset: number): Promise<CloudAPI_CloudResult> => {
  return commonRequest({
    url: '/user/cloud',
    params: { limit: 200, offset }
  })
}

/**
 * 搜索歌单
 * @returns list
 */
export const searchPlayLists = async (keywords: string, offset:number): Promise<CloudAPI_PlayListsResult> => {
  const response = await commonRequest<CloudAPI_PlayListSearchResult>({
    url: '/search',
    params: { keywords, offset, limit: 20, type: 1000 }
  })
  const result: CloudAPI_PlayListsResult = {
    more: response.result.hasMore,
    playlist: response.result.playlists
  }
  return result
}

interface subResponse {
  code: number
  message: string
}
/**
 * 收藏/取消收藏歌单
 * @param mode - 1:收藏, 2:取消收藏
 * @returns
 */
export const subscribePlayList = async (id: number, mode: number): Promise<boolean> => {
  const response = await commonRequest<subResponse>({
    url: '/playlist/subscribe',
    params: { t: mode, id, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response.message)
  return false
}

/**
 * Get personalized list
 * @returns Array<CloudAPI_PersonalListItem>
 */
export const getPersonalizedList = async (statePersistent?: (val: CloudAPI_PersonalListItem[]) => void): Promise<Array<CloudAPI_PersonalListItem>> => {
  const request = await commonRequest<CloudAPI_Personalized>({
    url: '/personalized',
    params: { timestamp: new Date().getTime() }
  })
  // AppStorage.setOrCreate(StorageConstants.PERSONALIZED_LIST, request.result)
  // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.PERSONALIZED_LIST, request.result)
  statePersistent?.(request.result)
  return request.result
}

interface delResponse {
  code: number
  message: string
}

/**
 * 删除歌单
 * @param pid
 */
export const deletePlayList = async (id: number): Promise<boolean> => {
  const response = await commonRequest<delResponse>({
    url: '/playlist/delete',
    params: { id, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response?.message)
  return false
}

interface createResponse {
  code: number
  message: string
}

/**
 * 创建歌单
 * @param name
 * @param isPrivacy
 */
export async function createPlayList(name: string, isPrivacy: boolean): Promise<boolean> {
  const response = await commonRequest<createResponse>({
    url: '/playlist/create',
    params: { name: name, privacy: isPrivacy ? 10 : 0 , timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response?.message)
  return false
}

interface renameResponse {
  code: number
  message: string
}

/**
 * 创建歌单
 * @param name
 * @param isPrivacy
 */
export async function renamePlayList(name: string, pid: number): Promise<boolean> {
  const response = await commonRequest<renameResponse>({
    url: '/playlist/name/update',
    params: { id: pid, name: name, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response?.message)
  return false
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
