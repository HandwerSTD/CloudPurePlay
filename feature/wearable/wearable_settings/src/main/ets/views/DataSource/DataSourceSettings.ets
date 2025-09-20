import {
  InstanceSwitcher,} from "@handwer/api_adapter"
import {
  SCApp, SingleDeviceViewModel,
  DeviceSelectorViewModel,
  DeviceIcon,
  DistributedUtils} from "@handwer/base"
import { ArcConst, ArcCommonListItem, ActionIconTextButton, SnackBarUtils } from "@handwer/wearable_ui_components"
import { promptAction, ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute,} from "@kit.ArkUI"

@ComponentV2
export struct DataSourceSettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local showDevices: boolean = false

  readonly apiPage = ['NavidromeAPI_Source', 'CloudAPI_Source']

  // @Builder CloudAPI() {
  //   ArcListItem() {
  //     ArcCommonListItem({
  //       icon: $r('sys.symbol.play_circle_badge_music_note'),
  //       title: 'CloudAPI',
  //     })
  //     .onClick(() => {
  //       this.pushPage('CloudAPI_Source', {})
  //     })
  //   }
  //   .width(ArcConst.ARC_LIST_W)
  // }

  @Builder NavidromeAPI() {
    ArcListItem() {
      ArcCommonListItem({
        icon: $r('sys.symbol.play_circle_badge_music_note'),
        title: 'NavidromeAPI',
      })
      .onClick(() => {
        this.pushPage('NavidromeAPI_Source', {})
      })
    }
    .width(ArcConst.ARC_LIST_W)
  }

  @Builder DataSyncPanel() {
    ArcListItem() {
      ArcCommonListItem({
        icon: $r('sys.symbol.nearby_devices'),
        title: $r('app.string.multi_device_sync'),
      })
    }.autoScale(true)
    .width('100%')
    .onClick(() => {
      this.pushPage('DataSyncPanel', {})
    })
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          this.DataSyncPanel()
          // this.CloudAPI()
          this.NavidromeAPI()
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .space(ArcConst.ARC_LIST_SPC)
        .fadingEdge(true)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.Transparent)
    .hideTitleBar(true)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }

  pushPage(name: string, params: Record<string, Object>) {
    this.pageStack.pushPathByName(name, params, true)
  }
}

@ComponentV2
export struct DeviceSelectorPanel {
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local showDevices: boolean = false

  readonly apiPage = ['NavidromeAPI_Source', 'CloudAPI_Source']
  @Local pageOpacity: number = 1
  @Local deviceList: DeviceSelectorViewModel = new DeviceSelectorViewModel()

  aboutToAppear(): void {
    DistributedUtils.init(this.getUIContext().getHostContext()!)
      .then((): Promise<boolean> => {
        return DistributedUtils.checkPermission();
      }).then((res: boolean) => {
        if (res) {
          this.deviceList.devices = DistributedUtils.scanDevices()?.map((val): SingleDeviceViewModel => {
            return SingleDeviceViewModel.fromDistInfo(val);
          }) ?? []
        } else {
          promptAction.openToast({
            message: $r('app.string.need_dist_perm_to_sync')
          })
          DistributedUtils.getPermission()
        }
      })
  }

  @Builder SingleDeviceListItem(device: SingleDeviceViewModel) {
    ArcListItem() {
      ArcCommonListItem({
        icon: DeviceIcon[device.deviceType],
        title: device.deviceName
      })
    }
    .onClick(() => {
      this.onDeviceClick(device)
    })
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            ActionIconTextButton({
              icon: $r('sys.symbol.dot_radiowaves_left_and_right'),
              title: $r('sys.string.general_search'),
              clickAction: () => {
                this.aboutToAppear()
              }
            })
          }
          if (this.deviceList.devices.length > 0) {
            ForEach(this.deviceList.devices, (device: SingleDeviceViewModel) => {
              this.SingleDeviceListItem(device)
            })
          } else {
            ArcListItem() {
              Text($r('app.string.common_empty_content'))
                .fontColor(Color.White)
            }.height(ArcConst.ARC_LIST_H)
          }
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .space(ArcConst.ARC_LIST_SPC)
        .fadingEdge(true)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.Transparent)
    .hideTitleBar(true)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }

  onDeviceClick = async (device: SingleDeviceViewModel) => {
    const name = await DistributedUtils.getUsingAPIName(device.deviceId)
    const type = InstanceSwitcher.getTypeByName(name)
    if (type !== -1) {
      const ctx = await DistributedUtils.getRequestContext(type, device.deviceId)
      this.pushPage(this.apiPage[type], {'context': ctx})
    } else {
      SnackBarUtils.showMessage([], $r('sys.symbol.multi_screen_collaboration'), $r('app.string.target_device_no_api_config'))
    }
  }

  pushPage(name: string, params: Record<string, Object>) {
    this.pageStack.pushPathByName(name, params, true)
  }
}
