import { CloudAPI_DjProgramResult, CloudAPI_DjRadio, CloudAPI_DjResult } from "../entities/DjRadio"
import { CloudAPI_PlayQueue } from "../model/PlayQueue"
import { CloudAPI_Song } from "../entities/Song"
import commonRequest from "./request/RequestUtil"
import { preferences } from "@kit.ArkData"

/**
 * 获取用户电台 Sublist
 * @returns DjResult
 */
export const getUserDjSubscribeList = async (statePersistent?: (val: CloudAPI_DjRadio[]) => void): Promise<CloudAPI_DjResult> => {
  const response = await commonRequest<CloudAPI_DjResult>({
    url: '/dj/sublist',
    params: { timestamp: new Date().getTime() }
  })
  // AppStorage.setOrCreate(StorageConstants.USER_DJRADIO_LIST, response.djRadios)
  // PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, response.djRadios)
  statePersistent?.(response.djRadios)
  return response
}

/**
 * 获取电台歌曲列表
 * @param rid
 * @param limit
 * @param offset
 * @returns DjProgramResult
 */
export const getDjPrograms = async (rid: number, limit: number, offset: number): Promise<CloudAPI_DjProgramResult> => {
  return commonRequest({
    url: '/dj/program',
    params: { rid, limit, offset, timestamp: new Date().getTime() }
  })
}

/**
 * Put DjRadioProgramsInQueue
 * @param rid
 * @param trackCount
 * @param limit
 * @param offset
 * @param first
 * @returns
 */
export const putDjRadioInQueue = async (
  rid: number,
  trackCount: number,
  limit: number = 100,
  offset: number = 0,
  first: boolean = true,
  cleanQueue: () => Promise<void>,
  addToQueue: (queue: CloudAPI_PlayQueue[]) => Promise<void>
): Promise<void> => {
  const allQueue: CloudAPI_PlayQueue[] = []

  while (offset < trackCount) {
    const response = await commonRequest<CloudAPI_DjProgramResult>({
      url: '/dj/program',
      params: { rid, limit, offset, timestamp: new Date().getTime() }
    })

    allQueue.push(...response.programs.map((item): CloudAPI_PlayQueue => ({
      playmode: 3,
      song: item.mainSong as CloudAPI_Song,
      fileName: '',
      picUrl: item.coverUrl ?? ''
    })))
    offset += limit
  }

  if (first) await cleanQueue()
  await addToQueue(allQueue)
}

interface DjRadioBody {
  djRadios: CloudAPI_DjRadio[]
}

interface DjRadioResult {
  result: DjRadioBody
}

/**
 * 搜索播客电台
 * @param keyword
 * @returns
 */
export const getDjRadioList = async (keywords: string): Promise<CloudAPI_DjRadio[]> => {
  const response = await commonRequest<DjRadioResult>({
    url: '/search',
    params: { keywords, type: 1009 }
  })
  return response.result.djRadios
}