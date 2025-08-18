import { CloudAPI_ArtistInfo, CloudAPI_ArtistItem, CloudAPI_ArtistsResult } from "../entities/Artists"
import commonRequest from "./request/RequestUtil"

/**
 * 获取歌手信息
 * @param id
 * @returns
 */
export const getArtistInfo = async (id: number): Promise<CloudAPI_ArtistInfo> => {
  return commonRequest<CloudAPI_ArtistInfo>({
    url: '/artists',
    params: { id }
  })
}

/**
 * 搜索歌手列表
 * @param keyword
 * @returns
 */
export const searchArtists = async (keywords: string, limit: number = 20): Promise<CloudAPI_ArtistItem[]> => {
  const result = await commonRequest<CloudAPI_ArtistsResult>({
    url: '/search',
    params: { keywords, limit, type: 100 }
  })
  return result.result.artists ?? []
}

