import { AssetUtil } from "@pura/harmony-utils";
import { Logger, SCStore } from "../../../../../Index";

const TAG = '[PlayStatUtils]'

export class PlayStatUtils {
  static async init() {
    await PlayStatUtils.setFirstUseTime()
  }
  static async getFirstUseTime() {
    const data = await AssetUtil.get(SCStore.asset_FirstOpenTime)
    if (data === '') {
      await PlayStatUtils.setFirstUseTime();
      return new Date(parseInt(await AssetUtil.get(SCStore.asset_FirstOpenTime)))
    }
    return new Date(parseInt(data))
  }
  static async setFirstUseTime() {
    const data = await AssetUtil.get(SCStore.asset_FirstOpenTime)
    if (data === '') {
      await AssetUtil.add(SCStore.asset_FirstOpenTime, Date.now().toString(), true)
    } else {
      Logger.info(TAG, `already set first time`)
    }
  }
  static async addSongPlayRecord(songId: string, albumId: string, artistId: string, playTimestamp: number) {

  }
  static async addPlaylistSongPlayedRecord(playlistId: string) {

  }
  static async onTodayPlayStart() {

  }
  static async onTodayPlayStop() {

  }
}