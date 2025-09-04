import { distributedDeviceManager } from "@kit.DistributedServiceKit"
import { ClickUtil, PermissionUtil } from "@pura/harmony-utils"
import Logger from "../Logger"
import { promptAction } from "@kit.ArkUI"
import { distributedKVStore } from "@kit.ArkData"
import { SCDistKV } from "../../exports"
import { InstanceSwitcher, INSTANCE_TYPE } from "@handwer/api_adapter"

class DistributedUtil {

  inst?: distributedDeviceManager.DeviceManager

  checkPermission() {
    return PermissionUtil.checkPermissions('ohos.permission.DISTRIBUTED_DATASYNC')
  }
  getPermission() {
    return PermissionUtil.requestPermissions('ohos.permission.DISTRIBUTED_DATASYNC')
  }

  init(context: Context) {
    if (this.inst) return Promise.resolve()
    return this.checkPermission()
      .then(async (res) => {
        if (res) {
          this.inst = distributedDeviceManager.createDeviceManager(getContext().applicationInfo.name)
          await DistKVUtil.getInstance().init(context)
        }
      }).catch((e: Error) => {
      Logger.error(`DistributedUtils`, `init failed: ${e.message}`)
      promptAction.showToast({
        message: $r('app.string.dist_service_failed')
      })
        this.getPermission()
    })
  }
  dispose() {
    if (this.inst) distributedDeviceManager.releaseDeviceManager(this.inst)
  }
  checkService() {
    if (!this.inst || !DistKVUtil.getInstance().checkService()) {
      ClickUtil.debounce(() => {
        promptAction.showToast({
          message: $r('app.string.dist_service_failed'),
          duration: 2000
        })
      })
      return false
    } return true
  }
  scanDevices() {
    if (!this.checkService()) return
    let res = this.inst?.getAvailableDeviceListSync()
    return res ?? []
  }
  subscribeSourceDevice(callback: (notification: distributedKVStore.ChangeNotification) => void) {
    if (!this.checkService()) return
    Logger.debug(`DistributedUtils`, `subscribed remote change`)
    DistKVUtil.getInstance().registerCallback(callback)
  }
  triggerSync(deviceId: string) {
    let base = DistKVUtil.getInstance()
    base.syncData(deviceId)
  }

  async writeRequestContext(apiType: INSTANCE_TYPE, apiContext: Record<string, Object>) {
    const key = InstanceSwitcher.getInstanceNameByType(apiType) + "_apiContext"
    await DistKVUtil.getInstance().write(key, JSON.stringify(apiContext))
    await DistKVUtil.getInstance().write(SCDistKV.currentUsedAPI, InstanceSwitcher.getInstanceNameByType(apiType))
  }

  async getUsingAPIName(deviceId?: string): Promise<string> {
    return await DistKVUtil.getInstance().read(SCDistKV.currentUsedAPI, deviceId) as string
  }
  async getRequestContext(apiType: INSTANCE_TYPE, deviceId?: string): Promise<Record<string, Object>> {
    const key = InstanceSwitcher.getInstanceNameByType(apiType) + "_apiContext"
    return JSON.parse((await DistKVUtil.getInstance().read(key, deviceId) ?? '{}') as string)
  }
}

export default new DistributedUtil()

type KVValue = string | boolean | number

class DistKVUtil {
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