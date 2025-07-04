import { distributedDeviceManager } from "@kit.DistributedServiceKit"
import { ClickUtil, PermissionUtil } from "@pura/harmony-utils"
import { promptAction } from "@kit.ArkUI"
import { distributedKVStore } from "@kit.ArkData"
import { Context } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"
import Logger from "../../utils/Logger"
import { fileIo } from "@kit.CoreFileKit"
import { DialogHelper } from "@pura/harmony-dialog"
import GlobalStore from "../../statemgmt/GlobalStore"
import { KVStoreUtil } from "../../utils/KVStore"
import { SCDistKV } from "../../constants/CommonConstants"

export class DataSyncError implements BusinessError {
  code: number
  data?: void | undefined
  name: string
  message: string
  stack?: string | undefined
  constructor(code: number, message: string) {
    this.code = code
    this.name = "DataSyncError"
    this.message = message
  }
}

export interface DistributionSyncResult {
  success: boolean
  stickerCount?: number
  collectionCount?: number
  time_secs?: string
  errorCode?: number
}


type KVValue = string | boolean | number

export class DistKVUtil {
  // 单例
  private static instance?: DistKVUtil
  private constructor() { }

  kv?: distributedKVStore.DeviceKVStore

  // 获取单例
  public static getInstance(): DistKVUtil {
    if (!DistKVUtil.instance) {
      DistKVUtil.instance = new DistKVUtil()
    }
    return DistKVUtil.instance
  }
  public async init(context: Context) {
    let kvMgr = distributedKVStore.createKVManager({
      bundleName: context.applicationInfo.name,
      context: context
    })
    this.kv = await kvMgr.getKVStore(SCDistKV.dbName, SCDistKV.dbOptions)
  }
  public async registerCallback(callback: (notification: distributedKVStore.ChangeNotification) => void) {
    this.kv!.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE, callback)
  }
  public checkService() {
    return this.kv ? true : false
  }

  public async write(key: string, value: KVValue) {
    if (!this.kv) return
    await this.kv.put(key, value)
  }

  public async writeBatch<T>(keys: string[], data: T[]) {
    if (!this.kv) return
    await this.kv.putBatch(keys.map((val, index) => {
      return {
        key: val,
        value: {
          type: distributedKVStore.ValueType.STRING,
          value: JSON.stringify(data[index])
        } as distributedKVStore.Value
      } as distributedKVStore.Entry
    }))
  }

  public async read(key: string, deviceId?: string) {
    if (!this.kv) return
    try {
      if (deviceId) return await this.kv.get(deviceId, key)
      return await this.kv.get(key)
    } catch (e) {
      // Logger.error(`DistKV`, `read error: ${JSON.stringify(e)}`)
      if (JSON.stringify(e).includes(`15100004`)) return undefined
      else throw Error(e)
    }
  }

  public async remove(key: string) {
    if (!this.kv) return
    await this.kv.delete(key)
  }
  public async removeBatch(prefix: string) {
    if (!this.kv) return
    let keys = (await this.getAllKeysByPrefix(prefix))?.map((val) => {
      return val.key
    })
    if (keys && keys.length > 0) {
      await this.kv.deleteBatch(keys)
    }
  }

  public async getAllKeysByPrefix(prefix: string, deviceId?: string) {
    if (!this.kv) return
    try {
      if (deviceId) return await this.kv.getEntries(deviceId, prefix)
      else return await this.kv.getEntries(prefix)
    } catch (e) {
      Logger.error(`DistKV`, `get all keys failed: ${JSON.stringify(e)}`)
      throw Error(e)
    }
  }

  public syncData(deviceId: string) {
    if (!this.kv) return
    this.kv.sync([deviceId], distributedKVStore.SyncMode.PUSH_PULL)
  }
}