import { AmbientLightUtils, GlobalStore, SCPref, Settings, ThemeManager } from "@handwer/base"
import { BgFlowController, HDS_TITLE_CONFIG_STYLE,
  LightedCommonListItem,
  LightedCommonListToggleItem,
  SnackBarUtils} from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute, hdsEffect } from "@kit.UIDesignKit"
import { CapsuleSegmentButtonV2, SegmentButtonV2Items, TabSegmentButtonV2 } from "@ohos.arkui.advanced.SegmentButtonV2"
import { ConfigurationConstant } from "@kit.AbilityKit"

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
  get dynamicBackgroundStreaming() {
    return this.pref.dynamicBackgroundStreaming
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
  set dynamicBackgroundStreaming(val: boolean) {
    this.pref.dynamicBackgroundStreaming = val
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
                .onClick(() => {
                  if (GlobalStore.pref.autoNavRightHandMode) {
                    SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.hand_draw'), $r('app.string.navigation_right_hand_mode_desc_auto_enabled_prompt'))
                  }
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
            // ListItem() {
            //   LightedCommonListToggleItem({
            //     icon: $r('sys.symbol.background_blurred'),
            //     title: $r('app.string.dynamic_background_streaming'),
            //     // subtitle: $r('app.string.dynamic_background_streaming_desc'),
            //     isOn: this.dynamicBackgroundStreaming,
            //     onToggleChange: (val) => {
            //       this.dynamicBackgroundStreaming = val
            //       Settings.put(SCPref.dynamicBackgroundStreaming, val)
            //       if (!val) {
            //         BgFlowController.getInstance().stop()
            //       } else {
            //         BgFlowController.getInstance().play()
            //         BgFlowController.getInstance().resume()
            //       }
            //     }
            //   })
            // }

            ListItem() {
              LightedCommonListItem({
                icon: $r('sys.symbol.background_blurred'),
                title: $r('app.string.bg_flow_color_strategy'),
              }) {
                TabSegmentButtonV2({
                  items: new SegmentButtonV2Items([{
                    text: $r('app.string.bg_flow_color_fixed')
                  }, {
                    text: $r('app.string.bg_flow_color_cover')
                  }]),
                  selectedIndex: GlobalStore.pref.bgFlowColorStrat,
                  onItemClicked: (idx) => {
                    GlobalStore.pref.bgFlowColorStrat = idx
                    Settings.put(SCPref.bgFlowColorStrat, idx)
                    if (idx === 0) {
                      BgFlowController.getInstance().changeColorToDefault(this.getUIContext())
                    } else {
                      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.background_blurred'), $r('app.string.bg_flow_color_effect_next_song'))
                    }
                  },
                }).width(128)
              }
            }
            ListItem() {
              LightedCommonListItem({
                icon: $r('sys.symbol.dark_mode'),
                title: $r('app.string.dark_light_mode'),
                trailingOnBottom: true
              }) {
                TabSegmentButtonV2({
                  items: new SegmentButtonV2Items([{
                    text: $r('app.string.dark_light_mode_light')
                  }, {
                    text: $r('app.string.dark_light_mode_dark')
                  }, {
                    text: $r('app.string.dark_light_mode_system')
                  }, {
                    text: $r('app.string.dark_light_mode_auto')
                  }]),
                  selectedIndex: ThemeManager.getSingleton().appColorModeStat,
                  onItemClicked: (idx) => {
                    ThemeManager.getSingleton().appColorModeStat = idx
                    if (idx === 3) {
                      AmbientLightUtils.registerLightSensorListener(this.getUIContext().getHostContext()!.getApplicationContext(),
                        (isLowLight) => {
                          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.dark_mode'), isLowLight ? $r('app.string.auto_switched_to_dark') : $r('app.string.auto_switched_to_light'))
                        })
                    } else {
                      let color = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
                      if (idx === 0) color = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
                      if (idx === 1) color = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
                      this.getUIContext().getHostContext()?.getApplicationContext().setColorMode(color)
                      AmbientLightUtils.unregisterLightSensorListener()
                    }
                  },
                }).width('100%')
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
