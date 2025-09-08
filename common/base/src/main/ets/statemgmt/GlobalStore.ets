import { DistributionSyncResult } from "../services/DistributionMgr/DistributionUtils"
import { SingleDeviceViewModel } from "../services/DistributionMgr/DistributionViewModels"
import { WindowAvoidanceData } from "../utils/WindowUtil"
import { common } from "@kit.AbilityKit"
import { PrefDataModel } from "./PreferenceDataModel"
import { OuterWantDataModel } from "./OuterWantDataModel"

@ObservedV2
class GlobalStore {

  private static _instance?: GlobalStore

  static get instance() {
    if (!GlobalStore._instance) {
      GlobalStore._instance = new GlobalStore()
    }
    return GlobalStore._instance
  }

  @Trace targetDevice?: SingleDeviceViewModel
  @Trace allDevices: SingleDeviceViewModel[] = []

  @Trace lastSyncStat?: DistributionSyncResult

  @Trace gotUpdateDeviceId?: string

  @Trace isPCMode: boolean = false
  @Trace wd: WindowAvoidanceData = new WindowAvoidanceData(0,0)

  @Trace wbp: string = 'sm'
  @Trace hbp: string = 'lg'

  @Trace appVersion: string = ''

  @Trace isInForeground: boolean = true

  @Trace isDarkMode: boolean = false

  @Trace pref: PrefDataModel = new PrefDataModel()

  @Trace outerWant: OuterWantDataModel = new OuterWantDataModel('', {})

  @Trace initialized: boolean = false

  globalSnack?: Object
  contextFaker?: common.UIAbilityContext
}

export default GlobalStore.instance