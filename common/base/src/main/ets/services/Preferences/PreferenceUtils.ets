import { KVStoreUtil } from '../../utils/KVStore'

export class PreferenceUtils {
  kv?: KVStoreUtil
  kvName: string = 'Preferences'

  constructor(name?: string) {
    if (name) {
      this.kvName = name
    }
  }

  init() {
    this.kv = new KVStoreUtil(this.kvName)
  }
  put<T>(key_: number | string, data: T) {
    const key = key_.toString()
    this.kv!.storeString(key, JSON.stringify(data))
  }
  get<T>(key: number | string) {
    try {
      return JSON.parse(this.kv!.queryString(key.toString())) as T
    } catch (e) {
      return undefined
    }
  }
  del(key: number) {
    this.kv!.deleteByKey(key.toString())
  }
}

const Settings = new PreferenceUtils()

export default Settings