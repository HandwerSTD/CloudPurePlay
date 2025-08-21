import { InstanceSwitcher } from "@handwer/api_adapter"
import { SCApp } from "@handwer/base"
import {
  LightUpLinedContainer,
  LightUpLinedDefaultConfig,
  OverrideLightUpStat,
  HDS_TITLE_CONFIG_STYLE
} from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"

export function generate_APIFinishWelcome_PageParams(userName: string, userAvatar: ResourceStr, onReInit: () => void) {
  return {
    "userName": userName,
    "userAvatar": userAvatar,
    "onReInit": onReInit
  } as Record<string, Object>
}

@ComponentV2
export struct APIFinishWelcome {
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = true
  @Local pageOpacity: number = 1

  @Local userAvatar?: ResourceStr
  @Local userName: string = ''

  onReInit?: () => void


  @Builder Main() {
    Column() {
      Blank().height(0)
      Column({space: 24}) {
        Image(this.userAvatar ?? $r('sys.media.Celia'))
          .height(100).aspectRatio(1)
          .borderRadius(100)
        Column({space: 12}) {
          Text($r('app.string.welcome_UserName', this.userName)).textOverflow({overflow: TextOverflow.Ellipsis})
            .maxLines(1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .width('100%')
            .textAlign(TextAlign.Center)
          Text($r('app.string.api_switch_from_what', InstanceSwitcher.InstanceTypeName))
            .fontColor(Color.White)
        }
      }
      Button($r('app.string.start_use'))
        .width('100%')
        .onClick(() => {
          this.onReInit?.()
          this.settingsSheet = false;
        })
    }.padding({left: 12, right: 12, top: $r('sys.float.ohos_id_navigation_bar_height'), bottom: 12})
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        this.Main()
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
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
    .onReady((context) => {
      const params = context.pathInfo.param as Record<string, Object>
      this.userName = params['userName'] as string
      this.userAvatar = params['userAvatar'] as ResourceStr
      this.onReInit = params['onReInit'] as () => void
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}
