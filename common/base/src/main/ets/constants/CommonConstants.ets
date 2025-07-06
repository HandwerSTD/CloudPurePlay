import { distributedKVStore } from "@kit.ArkData"

export class CommonConstants {
  static readonly bundleName = 'top.handwer.cloudpureplay'
  static readonly abilityName = 'MainAbility'
}

export class SCDistKV {
  static readonly dbName = 'distKV'
  static readonly dbOptions: distributedKVStore.Options = {
    securityLevel: distributedKVStore.SecurityLevel.S4,
    encrypt: true,
    kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
    autoSync: true,
    createIfMissing: true
  }
  static readonly targetInput = 'targetInput'
}