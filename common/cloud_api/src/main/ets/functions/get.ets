import { LogUtil } from "@pura/harmony-utils";
import { StorageConstants } from "../constants/StorageConstants";
import { CacheSet, CacheSet_INITIAL } from "../model/Settings";
import { Artist } from "../entities/Song";
import commonRequest from "../api/request/RequestUtil";
import { getArtists } from "./convert";

const TAG = '[GET ]'

interface InnerData {
  version: string
}

interface InnerVersion {
  code: number,
  data: InnerData
}

interface checkValidUriParams {
  setChecking: (status: boolean) => void
  setResult: (success: boolean) => void
}

/**
 * 检查API URL连通性
 * @returns
 */
export async function checkValidUrl(params: checkValidUriParams): Promise<boolean> {
  try {
    params.setChecking(true)
    const response = await commonRequest<InnerVersion>({
      url: '/inner/version',
      params: { timeout: 5000, noCookie: true }
    })
    if (response.code === 200) {
      params.setResult(true)
      return true
    } else {
      params.setResult(false)
      return false
    }
  } catch (e) {
    params.setResult(false)
    return false
  } finally {
    params.setChecking(false)
  }
}

export function getLocalSongArtistsString(localSongArtists: string): string {
  let artists: string = localSongArtists
  try {
    const artistsArr: Artist[] = JSON.parse(localSongArtists)
    artists = getArtists(artistsArr)
  } catch (e) {
    LogUtil.warn(TAG + 'getLocalSongArtistString Error')
  }
  return artists
}

export async function getLocalSongArtists(localSongArtists: string): Promise<Artist[]> {
  let artists: Artist[] = [{ id: 0, name: localSongArtists.toString() }]
  try {
    artists = JSON.parse(localSongArtists)
  } catch (e) {
    LogUtil.warn(TAG + 'getLocalSongArtists Error')
  }
  return artists
}

export async function getCacheSet() {
  try {
    const cacheSet = await AppStorage.get(StorageConstants.CACHE_SETTINGS) as CacheSet
    return cacheSet ?? CacheSet_INITIAL
  } catch (e) {
    LogUtil.error(TAG, 'getCacheSet Error: ' + e.message)
    return CacheSet_INITIAL
  }
}