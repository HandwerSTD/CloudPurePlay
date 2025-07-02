import { DjProgramResult, DjRadio, DjResult } from "../entities/DjRadio"
import { PlayQueue } from "../model/PlayQueue"
import { Song } from "../entities/Song"
import commonRequest from "./request/RequestUtil"
import { preferences } from "@kit.ArkData"

/**
 * 获取用户电台 Sublist
 * @returns DjResult
 */
export const getUserDjSubscribeList = async (statePersistent?: (val: preferences.ValueType) => void): Promise<DjResult> => {
  const response = await commonRequest<DjResult>({
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
export const getDjPrograms = async (rid: number, limit: number, offset: number): Promise<DjProgramResult> => {
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
  addToQueue: (queue: PlayQueue[]) => Promise<void>
): Promise<void> => {
  const allQueue: PlayQueue[] = []

  while (offset < trackCount) {
    const response = await commonRequest<DjProgramResult>({
      url: '/dj/program',
      params: { rid, limit, offset, timestamp: new Date().getTime() }
    })

    allQueue.push(...response.programs.map((item): PlayQueue => ({
      playmode: 3,
      song: item.mainSong as Song,
      fileName: '',
      picUrl: item.coverUrl ?? ''
    })))
    offset += limit
  }

  if (first) await cleanQueue()
  await addToQueue(allQueue)
}

interface DjRadioBody {
  djRadios: DjRadio[]
}

interface DjRadioResult {
  result: DjRadioBody
}

/**
 * 搜索播客电台
 * @param keyword
 * @returns
 */
export const getDjRadioList = async (keywords: string): Promise<DjRadio[]> => {
  const response = await commonRequest<DjRadioResult>({
    url: '/search',
    params: { keywords, type: 1009 }
  })
  return response.result.djRadios
}