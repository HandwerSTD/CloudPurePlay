import { GlobalStore, SCPref, Settings, SCApp } from "@handwer/base"
import { ArcCommonListToggleItem, ArcConst } from "@handwer/wearable_ui_components";
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute, promptAction } from "@kit.ArkUI"

@ComponentV2
export struct DisplaySettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) settingsPageStack: NavPathStack = new NavPathStack()

  @Local showPlayerOnLaunch: boolean = false
  @Local showMusicLibraryInOnlineMusic: boolean = false

  pref = GlobalStore.pref
  get navigationRightHandMode() {
    return this.pref.tabRightHand
  }
  get playerTwoColumnRightHandMode() {
    return this.pref.playerRightHand
  }
  set navigationRightHandMode(val: boolean) {
    this.getUIContext().animateTo({ duration: 300 }, () => {
      this.pref.tabRightHand = val
    })
  }
  set playerTwoColumnRightHandMode(val: boolean) {
    this.getUIContext().animateTo({ duration: 300 }, () => {
      this.pref.playerRightHand = val
    })
  }

  aboutToAppear(): void {
    this.showPlayerOnLaunch = Settings.get<boolean>(SCPref.showPlayerOnLaunch) ?? false
    this.showMusicLibraryInOnlineMusic = Settings.get<boolean>(SCPref.showMusicLibraryInOnlineMusic) ?? false
  }

  build() {
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.play_round_triangle'),
              title: $r('app.string.show_player_on_launch'),
              isOn: this.showPlayerOnLaunch,
              onToggleChange: (val) => {
                this.showPlayerOnLaunch = val
                Settings.put(SCPref.showPlayerOnLaunch, val)
              }
            })
          }
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.storagebox'),
              title: $r('app.string.show_music_library_in_online'),
              isOn: this.showMusicLibraryInOnlineMusic,
              onToggleChange: (val) => {
                this.showMusicLibraryInOnlineMusic = val
                Settings.put(SCPref.showMusicLibraryInOnlineMusic, val)
              }
            })
          }
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.hand_draw'),
              title: $r('app.string.navigation_right_hand_mode'),
              isOn: this.navigationRightHandMode,
              onToggleChange: (val) => {
                this.navigationRightHandMode = val
                Settings.put(SCPref.navigationRightHandMode, val)
              }
            })
          }
          ArcListItem() {
            ArcCommonListToggleItem({
              icon: $r('sys.symbol.rectangle_split_2x1'),
              title: $r('app.string.player_two_column_right_hand_mode'),
              isOn: this.playerTwoColumnRightHandMode,
              onToggleChange: (val) => {
                this.playerTwoColumnRightHandMode = val
                Settings.put(SCPref.playerTwoColumnRightHandMode, val)
              }
            })
          }
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .space(ArcConst.ARC_LIST_SPC)
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
