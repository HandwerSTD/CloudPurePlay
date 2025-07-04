import Logger from "../../utils/Logger"
import { distributedDeviceManager } from "@kit.DistributedServiceKit"

export enum DeviceType {
  phone = "PHONE",
  tablet = "PAD",
  tv = "TV",
  smartScreen = "SMART_DISPLAY",
  car = "CAR",
  t2in1 = "2IN1",
  pc = "PC",
  wearable = "WATCH"
}
export const DeviceIcon: Record<DeviceType, Resource> = {
  [DeviceType.phone]: $r('sys.symbol.phone_fill_1'),
  [DeviceType.tablet]: $r('sys.symbol.pad_fill'),
  [DeviceType.tv]: $r('sys.symbol.TV_tv'),
  [DeviceType.smartScreen]: $r('sys.symbol.smartscreen_fill'),
  [DeviceType.car]: $r('sys.symbol.car_fill'),
  [DeviceType.t2in1]: $r('sys.symbol.matebook_fill'),
  [DeviceType.pc]: $r('sys.symbol.matebook_fill'),
  [DeviceType.wearable]: $r('sys.symbol.watch')
}

@ObservedV2
export class SingleDeviceViewModel {
  @Trace deviceId: string = ''
  @Trace deviceName: string = ''
  @Trace deviceType: DeviceType = DeviceType.phone
  @Trace connected: boolean = false

  static fromDistInfo(dist: distributedDeviceManager.DeviceBasicInfo) {
    let vm = new SingleDeviceViewModel()
    vm.deviceId = dist.networkId??""
    vm.deviceName = dist.deviceName
    vm.deviceType = dist.deviceType as DeviceType
    Logger.debug(`SingleDeviceVM`, `detected device: ${dist.deviceType}`)
    return vm
  }
}
@ObservedV2
export class DeviceSelectorViewModel {
  @Trace devices: SingleDeviceViewModel[] = []
}
