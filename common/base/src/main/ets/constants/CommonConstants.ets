import { distributedKVStore } from "@kit.ArkData"

export class CommonConstants {
  static readonly bundleName = 'top.handwer.cloudpureplay'
  static readonly abilityName = 'MainAbility'
}

export class SCDistKV {
  static readonly dbName = 'distKV'
  static readonly dbOptions: distributedKVStore.Options = {
    securityLevel: distributedKVStore.SecurityLevel.S4, // for safety
    encrypt: true,
    kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
    autoSync: true,
    createIfMissing: true
  }
  static readonly currentUsedAPI = "currentUsedAPI"
}

export class SCEmitter {
  static readonly LyricUpdate = 1
  static readonly PlaylistContentUpdate = 2
}

export type ShowToastCallback = (icon: ResourceStr, msg: ResourceStr) => void

export class SCApp {
  static readonly playQueueSheet = 'playQueue'
  static exploreSheet: string = 'exploreSheet'
  static explorePageStack: string = 'explorePageStack'
  static settingsSheet: string = 'settingsSheet'
  static settingsPageStack: string = 'settingsPageStack'
  static showAddToPlaylistSheet = 'showAddToPlaylistSheet'
  static registerBackButton = 'registerBackButton'
  static shouldDisableTab = 'shouldDisableTab'
}

export class SCGlobal {
  static readonly addToPlaylistSongData = 'addToPlaylistSongData'
}