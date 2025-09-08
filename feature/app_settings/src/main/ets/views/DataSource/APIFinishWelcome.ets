import { InstanceSwitcher, INSTANCE_TYPE } from "@handwer/api_adapter"
import { SCApp } from "@handwer/base"
import {
  HDS_TITLE_CONFIG_STYLE, LightUpLongButton
} from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"

export function generate_APIFinishWelcome_PageParams(userName: string, userAvatar: ResourceStr, onReInit: () => void, instance: string) {
  return {
    "userName": userName,
    "userAvatar": userAvatar,
    "onReInit": onReInit,
    "instance": instance
  } as Record<string, Object>
}

@ComponentV2
export struct APIFinishWelcome {
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = true
  @Local pageOpacity: number = 1

  @Local userAvatar?: ResourceStr
  @Local userName: string = ''
  @Local instance: string = ''

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
          Text($r('app.string.api_switch_from_what', this.instance))
            .fontColor(Color.White)
        }
      }
      LightUpLongButton({
        title: $r('app.string.start_use'),
        icon: $r('sys.symbol.checkmark'),
        clickAction: () => {
          this.onReInit?.()
          this.settingsSheet = false;
        }
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
      this.instance = params['instance'] as string
      this.onReInit = params['onReInit'] as () => void
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}
