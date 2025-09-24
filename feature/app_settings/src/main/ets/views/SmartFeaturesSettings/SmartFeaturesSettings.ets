import {
  CommonListItem,
  CommonListToggleItem,
  HDS_TITLE_CONFIG_STYLE,
  LightedCommonItem,
  LightedCommonListToggleItem,
  LightUpContainer,
  LightUpLinedContainer,
  SnackBarUtils } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { AmbientLightUtils, GlobalStore, SCPref, Settings, ThemeManager } from "@handwer/base"
import { motion } from "@kit.MultimodalAwarenessKit"
import { ConfigurationConstant } from "@kit.AbilityKit"
import { TabSegmentButtonV2, SegmentButtonV2Items } from "@kit.ArkUI"

@ComponentV2
export struct SmartFeaturesSettings {
  @Local pageOpacity: number = 1
  @Local autoNavRightHand: boolean = false
  @Local useStylusControl: boolean = false

  aboutToAppear(): void {
    // 初始化智慧功能设置数据
    this.autoNavRightHand = Settings.get<boolean>(SCPref.autoNavRightHand) ?? false
    this.useStylusControl = Settings.get<boolean>(SCPref.useStylusControl) ?? false
  }

  pref = GlobalStore.pref
  get swipeToNextTrack() {
    return this.pref.swipeToNextTrack
  }
  set swipeToNextTrack(val: boolean) {
    this.pref.swipeToNextTrack = val
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.hand_tap'),
                title: $r('app.string.auto_nav_right_hand'),
                subtitle: $r('app.string.auto_nav_right_hand_desc'),
                isOn: GlobalStore.pref.autoNavRightHandMode,
                onToggleChange: (val) => {
                  GlobalStore.pref.autoNavRightHandMode = val
                  Settings.put(SCPref.autoNavRightHand, val)
                  try {
                    motion.getRecentOperatingHandStatus()
                  } catch (e) {
                    SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.hand_tap'), $r('app.string.this_device_unsupport'))
                  }
                }
              })
            }
            
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.pencil_tip'),
                title: $r('app.string.use_stylus_control'),
                subtitle: $r('app.string.use_stylus_control_desc'),
                isOn: this.useStylusControl,
                onToggleChange: (val) => {
                  this.useStylusControl = val
                  Settings.put(SCPref.useStylusControl, val)
                  GlobalStore.pref.useStylusControl = val
                  SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.pencil_tip'), $r('app.string.restart_to_take_effect'))
                }
              })
            }

            ListItem() {
              LightedCommonItem() {
                LightUpLinedContainer() {
                  CommonListToggleItem({
                    icon: $r('sys.symbol.swipe'),
                    title: $r('app.string.swipe_to_next_track'),
                    subtitle: $r('app.string.swipe_to_next_track_desc'),
                    isOn: this.swipeToNextTrack,
                    onToggleChange: (val) => {
                      this.swipeToNextTrack = val
                      Settings.put(SCPref.swipeToNextTrack, val)
                    }
                  })
                }
                LightUpLinedContainer() {
                  CommonListItem({
                    icon: $r('sys.symbol.phone_and_hand'),
                    title: $r('app.string.air_grab'),
                  }) {
                    TabSegmentButtonV2({
                      items: new SegmentButtonV2Items([{
                        text: $r('app.string.air_grab_play')
                      }, {
                        text: $r('app.string.air_grab_heart')
                      }]),
                      selectedIndex: GlobalStore.pref.fistGesture,
                      onItemClicked: (idx) => {
                        GlobalStore.pref.fistGesture = idx
                        Settings.put(SCPref.fistGesture, idx)
                      },
                    }).width(128)
                  }
                }
              }
            }
            
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.smart_sensing_features')
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}