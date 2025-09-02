import {
  InstanceSwitcher,} from "@handwer/api_adapter"
import {
  SCApp, SingleDeviceViewModel,
  DeviceSelectorViewModel,
  DeviceIcon,
  DistributedUtils} from "@handwer/base"
import { ArcConst, ArcCommonListItem } from "@handwer/wearable_ui_components"
import { promptAction, ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute,} from "@kit.ArkUI"

@ComponentV2
export struct DataSourceSettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()

  readonly apiPage = ['NavidromeAPI_Source', 'CloudAPI_Source']

  @Builder CloudAPI() {
    ArcListItem() {
      ArcCommonListItem({
        icon: $r('sys.symbol.play_circle_badge_music_note'),
        title: 'CloudAPI',
      })
      .onClick(() => {
        this.pushPage('CloudAPI_Source', {})
      })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(50)
  }

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
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(50)
  }

  @Builder DataSyncPanel() {
    ArcListItem() {
      DeviceSelectorPanel({
        onDeviceClick: async (device) => {
          const name = await DistributedUtils.getUsingAPIName(device.deviceId)
          const type = InstanceSwitcher.getTypeByName(name)
          if (type !== -1) {
            const ctx = await DistributedUtils.getRequestContext(type, device.deviceId)
            this.pushPage(this.apiPage[type], {'context': ctx})
          } else {
            promptAction.openToast({
              message: $r('app.string.target_device_no_api_config')
            })
          }
        }
      })
    }.autoScale(true)
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          // this.DataSyncPanel()
          this.CloudAPI()
          this.NavidromeAPI()
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .space(ArcConst.ARC_LIST_SPC)
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
  @Param @Require onDeviceClick: (device: SingleDeviceViewModel) => void

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
      Row({ space: 4 }) {
        SymbolGlyph(DeviceIcon[device.deviceType])
          .fontColor([Color.White])
          .fontSize(24)
          .width(36)
        Text(device.deviceName)
          .fontColor(Color.White)
          .fontSize(14)
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height(45)
    .onClick(() => {
      this.onDeviceClick(device)
    })
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
  }

  @Builder DeviceListCard() {
    Stack() {
      Column() {
        Row() {
          Text($r('app.string.multi_device_sync'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Button() {
            Image($r('sys.symbol.dot_radiowaves_left_and_right'))
              .width(20)
              .height(20)
              .fillColor(Color.White)
          }
          .backgroundColor(Color.Transparent)
          .width(40)
          .height(40)
          .onClick(() => {
            let new_dev = DistributedUtils.scanDevices()
            if (new_dev) {
              this.deviceList.devices = new_dev.map((val): SingleDeviceViewModel => {
                return SingleDeviceViewModel.fromDistInfo(val);
              })
            }
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        ArcList() {
          if (this.deviceList.devices.length == 0) {
            ArcListItem() {
              Column() {
                Text($r('app.string.common_empty_content'))
                  .fontColor(Color.Gray)
                  .width('100%')
                  .height('100%')
                  .textAlign(TextAlign.Center)
              }
            }
          } else {
            ForEach(this.deviceList.devices, (device: SingleDeviceViewModel) => {
              this.SingleDeviceListItem(device)
            })
          }
        }
        .height(150)
        .width('100%')
        .padding({ left: 12, right: 12 })
      }
      .backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(12)
      .padding(12)
    }
  }

  build() {
    this.DeviceListCard()
  }
}
