import { DistributionSyncResult } from "../services/DistributionMgr/DistributionUtils"
import { SingleDeviceViewModel } from "../services/DistributionMgr/DistributionViewModels"
import { BreakpointInfo } from "../utils/BreakpointSystem"
import { WindowAvoidanceData } from "../utils/WindowUtil"

@ObservedV2
class GlobalStore {
  @Trace targetDevice?: SingleDeviceViewModel
  @Trace allDevices: SingleDeviceViewModel[] = []

  @Trace lastSyncStat?: DistributionSyncResult

  @Trace gotUpdateDeviceId?: string

  @Trace isPCMode: boolean = false
  @Trace wd: WindowAvoidanceData = new WindowAvoidanceData(0,0)

  @Trace wbp: BreakpointInfo = new BreakpointInfo('sm')
  @Trace hbp: BreakpointInfo = new BreakpointInfo('lg')
}

export default new GlobalStore()