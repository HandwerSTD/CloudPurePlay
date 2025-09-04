import { DeviceCollaborationUtils, Logger, NowPlayingStore, SCPref, Settings, SCApp } from "@handwer/base"
import { ArcCommonListToggleItem, ArcConst } from "@handwer/wearable_ui_components";
import { common } from "@kit.AbilityKit"
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute,} from "@kit.ArkUI"

@ComponentV2
export struct MissionContinueSettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) settingsPageStack: NavPathStack = new NavPathStack()
  @Local switch: boolean = true

  aboutToAppear(): void {
    this.switch = Settings.get<boolean>(SCPref.useMissionContinue) ?? false
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
              title: $r('app.string.settings_enable_mission_continue'),
              isOn: this.switch,
              onToggleChange: (val) => {
                this.switch = val
                Settings.put(SCPref.useMissionContinue, val)
                if (val === false) {
                  DeviceCollaborationUtils.setDisableMissionContinue(this.getUIContext().getHostContext()! as common.UIAbilityContext)
                }
                Logger.debug(`MissionContinueSettings`, `generate params: ${JSON.stringify(NowPlayingStore.toExportable())}`)
              }
            })
          }
          .width(ArcConst.ARC_LIST_W)
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
