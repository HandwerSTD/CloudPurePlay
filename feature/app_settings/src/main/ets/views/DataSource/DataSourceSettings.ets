import {
  APIConfigUtils, InstanceSwitcher,} from "@handwer/api_adapter"
import { UserManager, SCApp, Logger, ServiceInitUtils, SingleDeviceViewModel,
  DeviceSelectorViewModel,
  DeviceIcon,
  DistributedUtils,
  GlobalStore,
  UserStore,
  LoginStatus,
  ShareUtils,
  NowPlayingStore,
  ResponsiveUtil,
  ImgCache} from "@handwer/base"
import { CommonListItem,
  DialogUtils,
  HDS_TITLE_CONFIG_STYLE,
  LightUpDefaultConfig,
  LightUpLinedContainer, LightUpLinedDefaultConfig,
  LightUpRoundedButton,
  OverrideLightUpStat,
  SnackBarUtils} from "@handwer/ui_components"
import { TextModifier, SymbolGlyphModifier } from '@kit.ArkUI'
import { hdsEffect, HdsNavigation,
  HdsNavigationTitleMode, HdsNavigationAttribute,
  HdsSnackBar, HdsListItemCard, PrefixImage, SuffixIcon } from "@kit.UIDesignKit"
import { pasteboard } from "@kit.BasicServicesKit"
import { common } from "@kit.AbilityKit"
import { systemShare } from "@kit.ShareKit"
import { uniformTypeDescriptor } from "@kit.ArkData"

@ComponentV2
export struct DataSourceSettings {
  snack = new HdsSnackBar(this.getUIContext())

  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()

  readonly apiPage = ['NavidromeAPI_Source', 'CloudAPI_Source']

  @Builder CloudAPI() {
    ListItem() {
      Column() {
        LightUpLinedContainer() {
          CommonListItem({
            icon: $r('sys.symbol.play_circle_badge_music_note'),
            title: 'CloudAPI',
          }).onClick(() => {
            this.pushPage('CloudAPI_Source', {})
          })
        }
      }.backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
      }).buildEffect())
    }
  }

  @Builder NavidromeAPI() {
    ListItem() {
      Column() {
        LightUpLinedContainer() {
          CommonListItem({
            icon: $r('sys.symbol.play_circle_badge_music_note'),
            title: 'NavidromeAPI',
          }).onClick(() => {
            this.pushPage('NavidromeAPI_Source', {})
          })
        }
      }.backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
      }).buildEffect())
    }
  }
  @Builder DataSyncPanel() {
    ListItem() {
      DeviceSelectorPanel({
        onDeviceClick: async (device) => {
          const name = await DistributedUtils.getUsingAPIName(device.deviceId)
          const type = InstanceSwitcher.getTypeByName(name)
          if (type !== -1) {
            const ctx = await DistributedUtils.getRequestContext(type, device.deviceId)
            this.pushPage(this.apiPage[type], {'context': ctx['context']})
          } else {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.multi_screen_collaboration'), $r('app.string.target_device_no_api_config'))
          }
        }
      })
    }
  }
  @Builder LoadedAPICard() {
    if (UserStore.loginStatus === LoginStatus.LOGGED) {
      ListItem() {
        Row() {
          Image(ImgCache.proxy(UserStore.user.data.profile.avatarUrl as string))
            .height(48).width(48).aspectRatio(1)
            .borderRadius(32)
          Blank().width(12)
          Column() {
            Text(UserStore.user.data.profile.nickname).fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
            Text($r('app.string.api_switch_from_what', InstanceSwitcher.InstanceTypeName))
              .fontSize(14).fontColor(Color.White)
              .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
          }.layoutWeight(1).justifyContent(FlexAlign.SpaceAround)
          .height(48)
          .alignItems(HorizontalAlign.Start)
          Row() {
            LightUpRoundedButton({
              icon: $r('sys.symbol.share'),
              clickAction: async () => {
                SnackBarUtils.showMessage(this.snack, $r('sys.symbol.share'), $r('app.string.share_api_plain_notice'));
                const ctx = this.getUIContext().getHostContext()!
                const img = await DialogUtils.showLoadingUntil((): Promise<string> => {
                  return ImgCache.download(UserStore.user.data.profile.avatarUrl as string);
                });
                const thumb = await ShareUtils.copyUriAsThumbnail(ctx, img)
                ShareUtils.startKnockShare(ctx.getApplicationContext()!,
                  (onClose): string => {
                    return DialogUtils.showKnockShareDialog(onClose);
                  }, (target) => {
                    let shareData: systemShare.SharedData = new systemShare.SharedData({
                      utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
                      content: APIConfigUtils.sharePlainAPILink(),
                      title: InstanceSwitcher.InstanceTypeName,
                      thumbnailUri: thumb
                    });
                    target.share(shareData)
                  })
              }
            })
          }.justifyContent(FlexAlign.End).margin({left: 12})
        }.width('100%').padding(ResponsiveUtil.chooseByWidth([12, 12, 24])).borderRadius(24)
        .backgroundColor($r('app.color.play_list_single_item_bg'))
        // .margin({top: 24, bottom: 24})
        .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
        }).buildEffect())
      }
    }
  }

  aboutToAppear(): void {
    if (GlobalStore.outerWant.type === 'new_config') {
      const api = GlobalStore.outerWant.data['apiName'] as string
      const apiType = InstanceSwitcher.getTypeByName(api)
      this.pageStack.replacePathByName(this.apiPage[apiType], {'context': GlobalStore.outerWant.data['apiConfig']} as Record<string, Object>);
    }
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            this.LoadedAPICard()
            this.CloudAPI()
            this.NavidromeAPI()
            this.DataSyncPanel()
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.data_source')
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
    }.backgroundColor(Color.Transparent)
    .hideTitleBar(true)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
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
          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.eco_hop'), $r('app.string.need_dist_perm_to_sync'))
          DistributedUtils.getPermission()
        }
      })
  }

  @Styles CardStyle() {
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(24)
    .padding(12)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder SingleDeviceListItem(device: SingleDeviceViewModel) {
    ListItem() {
      Row({space: 4}) {
        SymbolGlyph(DeviceIcon[device.deviceType])
          .fontColor([Color.White])
          .fontSize(24)
          .width(36)
        Text(device.deviceName)
          .fontColor(Color.White)
          .fontSize(14)
          .layoutWeight(1)
      }
    }.width('100%')
    .height(45)
    .onClick(() => {
      this.onDeviceClick(device)
    })
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  @Builder DeviceListCard() {
    Stack() {
      Column() {
        Row() {
          Text($r('app.string.multi_device_sync'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          LightUpRoundedButton({
            lightUpConfig: LightUpDefaultConfig,
            icon: $r('sys.symbol.dot_radiowaves_left_and_right'),
            clickAction: () => {
              this.aboutToAppear()
              // let new_dev = DistributedUtils.scanDevices()
              // if (new_dev) {
              //   this.deviceList.devices = new_dev.map((val): SingleDeviceViewModel => {
              //     return SingleDeviceViewModel.fromDistInfo(val);
              //   })
              // }
            }
          })
        }.width('100%').padding({left: 12, right: 12})
        .justifyContent(FlexAlign.SpaceBetween)
        List() {
          if (this.deviceList.devices.length == 0) {
            ListItem() {
              Column() {
                Text($r('app.string.common_empty_content')).fontColor(Color.Gray).width('100%').height('100%')
                  .textAlign(TextAlign.Center)
              }
            }
          } else {
            ForEach(this.deviceList.devices, (device: SingleDeviceViewModel) => {
              this.SingleDeviceListItem(device)
            })
          }
        }.height(150).width('100%').padding({left: 12, right: 12})
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.ohos_id_divider_color')
        })
      }.CardStyle()
    }
  }
  build() {
    this.DeviceListCard()
  }
}
