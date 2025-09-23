import { SCPref, Settings, GlobalStore } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightedCommonListToggleItem } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"

@ComponentV2
export struct PlaybackSettings {
  @Local pageOpacity: number = 1

  @Local autoPlayOnLaunch: boolean = false
  @Local autoPlayFMOnLaunch: boolean = false

  pref = GlobalStore.pref
  get swipeToNextTrack() {
    return this.pref.swipeToNextTrack
  }
  set swipeToNextTrack(val: boolean) {
    this.pref.swipeToNextTrack = val
  }

  aboutToAppear(): void {
    this.autoPlayOnLaunch = Settings.get<boolean>(SCPref.autoPlayOnLaunch) ?? false
    this.autoPlayFMOnLaunch = Settings.get<boolean>(SCPref.autoPlayFM) ?? true
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            ListItem() {
              LightedCommonListToggleItem({
                icon: $r('sys.symbol.phone_and_chevron_forward'),
                title: $r('app.string.auto_play_on_launch'),
                subtitle: $r('app.string.auto_play_on_launch_desc'),
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
            if (this.autoPlayOnLaunch) {
              ListItem() {
                LightedCommonListToggleItem({
                  icon: $r('sys.symbol.radiostation'),
                  title: $r('app.string.auto_play_fm_on_launch_empty'),
                  isOn: this.autoPlayFMOnLaunch,
                  onToggleChange: (val) => {
                    this.autoPlayFMOnLaunch = val
                    Settings.put(SCPref.autoPlayFM, val)
                  }
                })
              }.transition(TransitionEffect.OPACITY.animation({duration: 300}))
            }
            ListItem() {
              LightedCommonListToggleItem({
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
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.playback_settings')
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
