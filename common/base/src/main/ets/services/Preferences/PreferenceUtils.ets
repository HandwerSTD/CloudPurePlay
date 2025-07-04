import { KVStoreUtil } from '../../utils/KVStore'

class PreferenceUtils {
  kv?: KVStoreUtil
  init() {
    this.kv = new KVStoreUtil('Preferences')
  }
  put<T>(key_: number, data: T) {
    const key = key_.toString()
    this.kv!.storeString(key, JSON.stringify(data))
  }
  get<T>(key: number) {
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