import { HDS_TITLE_CONFIG_STYLE, LightedCommonListToggleItem, SnackBarUtils } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { GlobalStore, SCPref, Settings } from "@handwer/base"
import { motion } from "@kit.MultimodalAwarenessKit"

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
            
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: '智慧功能'
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