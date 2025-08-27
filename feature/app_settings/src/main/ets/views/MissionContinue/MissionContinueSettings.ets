import { DeviceCollaborationUtils, Logger, NowPlayingStore, SCPref, Settings } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightedCommonListItem } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { common } from "@kit.AbilityKit"

@ComponentV2
export struct MissionContinueSettings {
  @Local pageOpacity: number = 1

  @Local switch: boolean = true

  aboutToAppear(): void {
    this.switch = Settings.get<boolean>(SCPref.useMissionContinue) ?? false
  }

  @Builder FullSwitchTrailing() {
    Toggle({
      isOn: this.switch!!,
      type: ToggleType.Switch
    })
      .onChange((val) => {
        Settings.put(SCPref.useMissionContinue, val)
        if (val === false) {
          DeviceCollaborationUtils.setDisableMissionContinue(this.getUIContext().getHostContext()! as common.UIAbilityContext)
        }
        Logger.debug(`MissionContinueSettings`, `generate params: ${JSON.stringify(NowPlayingStore.toExportable())}`)
      })
  }
  @Builder FullSwitch() {
    ListItem() {
      LightedCommonListItem({
        title: $r('app.string.settings_enable_mission_continue'),
        icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
        trailing: () => {
          this.FullSwitchTrailing()
        }
      })
    }
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            this.FullSwitch()
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.mission_continue')
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
    }.hideTitleBar(true).backgroundColor(Color.Transparent)
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