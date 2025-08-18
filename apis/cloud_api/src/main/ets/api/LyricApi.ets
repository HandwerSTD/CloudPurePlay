import { CloudAPI_LyricResult } from "../entities/Lyric";
import commonRequest from "./request/RequestUtil";

/**
 * 获取歌词
 * @param id - 歌曲id
 * @returns - string[]
 */
export const getLyric = async (id: number): Promise<CloudAPI_LyricResult> => {
  return commonRequest({
    url: '/lyric',
    params: { id, noCookie: true }
  })
}

/**
 * 获取歌词完整string
 * @param id
 * @return
 */
export const getLyricString = async (id: number): Promise<string> => {
  const response = await commonRequest<CloudAPI_LyricResult>({
    url: '/lyric',
    params: { id, noCookie: true }
  })
  return response.code === 200 ? response.lrc.lyric : '[00:00:00] 暂无歌词'
}