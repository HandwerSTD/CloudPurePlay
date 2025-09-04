import { SCPref, Settings, SCApp } from "@handwer/base"
import { ArcCommonListToggleItem, ArcConst } from "@handwer/wearable_ui_components";
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute,} from "@kit.ArkUI"

@ComponentV2
export struct PlaybackSettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) settingsPageStack: NavPathStack = new NavPathStack()

  @Local autoPlayOnLaunch: boolean = false
  @Local autoPlayFMOnLaunch: boolean = false

  aboutToAppear(): void {
    this.autoPlayOnLaunch = Settings.get<boolean>(SCPref.autoPlayOnLaunch) ?? false
    this.autoPlayFMOnLaunch = Settings.get<boolean>(SCPref.autoPlayFM) ?? true
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.phone_and_chevron_forward'),
              title: $r('app.string.auto_play_on_launch'),
              isOn: this.autoPlayOnLaunch,
              onToggleChange: (val) => {
                this.autoPlayOnLaunch = val
                Settings.put(SCPref.autoPlayOnLaunch, val)
                if (!val) {
                  this.autoPlayFMOnLaunch = false
                  Settings.put(SCPref.autoPlayFM, false)
                }
              }
            })
          }
          .width(ArcConst.ARC_LIST_W)
          if (this.autoPlayOnLaunch) {
            ArcListItem() {
              ArcCommonListToggleItem({
                icon: $r('sys.symbol.radiostation'),
                title: $r('app.string.auto_play_fm_on_launch_empty'),
                isOn: this.autoPlayFMOnLaunch,
                onToggleChange: (val) => {
                  this.autoPlayFMOnLaunch = val
                  Settings.put(SCPref.autoPlayFM, val)
                }
              })
            }
            .width(ArcConst.ARC_LIST_W)
            .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
          }
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .space(ArcConst.ARC_LIST_SPC)
        .fadingEdge(true)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
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
    .animation({ duration: 300 })
  }
}
