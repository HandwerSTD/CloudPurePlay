import { GlobalStore, SCPref, Settings } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightedCommonListToggleItem } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"

@ComponentV2
export struct DisplaySettings {
  @Local pageOpacity: number = 1

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
    this.getUIContext().animateTo({duration: 300}, () => {
      this.pref.tabRightHand = val
    })
  }
  set playerTwoColumnRightHandMode(val: boolean) {
    this.getUIContext().animateTo({duration: 300}, () => {
      this.pref.playerRightHand = val
    })
  }

  aboutToAppear(): void {
    this.showPlayerOnLaunch = Settings.get<boolean>(SCPref.showPlayerOnLaunch) ?? false
    this.showMusicLibraryInOnlineMusic = Settings.get<boolean>(SCPref.showMusicLibraryInOnlineMusic) ?? false
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.play_round_triangle'),
                title: $r('app.string.show_player_on_launch'),
                subtitle: $r('app.string.show_player_on_launch_desc'),
                isOn: this.showPlayerOnLaunch,
                onToggleChange: (val) => {
                  this.showPlayerOnLaunch = val
                  Settings.put(SCPref.showPlayerOnLaunch, val)
                }
              })
            }
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.storagebox'),
                title: $r('app.string.show_music_library_in_online'),
                subtitle: $r('app.string.show_music_library_in_online_desc'),
                isOn: this.showMusicLibraryInOnlineMusic,
                onToggleChange: (val) => {
                  this.showMusicLibraryInOnlineMusic = val
                  Settings.put(SCPref.showMusicLibraryInOnlineMusic, val)
                }
              })
            }
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.hand_draw'),
                title: $r('app.string.navigation_right_hand_mode'),
                subtitle: $r('app.string.navigation_right_hand_mode_desc'),
                isOn: this.navigationRightHandMode,
                onToggleChange: (val) => {
                  this.navigationRightHandMode = val
                  Settings.put(SCPref.navigationRightHandMode, val)
                },
                isDisabledSwitch: GlobalStore.pref.autoNavRightHandMode
              })
            }
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.rectangle_split_2x1'),
                title: $r('app.string.player_two_column_right_hand_mode'),
                subtitle: $r('app.string.player_two_column_right_hand_mode_desc'),
                isOn: this.playerTwoColumnRightHandMode,
                onToggleChange: (val) => {
                  this.playerTwoColumnRightHandMode = val
                  Settings.put(SCPref.playerTwoColumnRightHandMode, val)
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
            mainTitle: $r('app.string.display_settings')
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
