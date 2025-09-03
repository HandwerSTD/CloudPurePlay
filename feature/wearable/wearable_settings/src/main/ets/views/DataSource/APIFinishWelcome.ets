import { InstanceSwitcher, INSTANCE_TYPE } from "@handwer/api_adapter"
import { SCApp } from "@handwer/base"
import { ArcConst } from "@handwer/wearable_ui_components"
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from "@ohos.arkui.ArcList"

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
    ArcListItem() {
      Image(this.userAvatar ?? $r('sys.media.Celia'))
        .height(80)
        .aspectRatio(1)
        .borderRadius(40)
    }.width(ArcConst.ARC_LIST_W)
    ArcListItem() {
      Column({ space: 12 }) {
        Text($r('app.string.welcome_UserName', this.userName))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(18)
        Text($r('app.string.api_switch_from_what', this.instance))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(14)
      }
    }.width(ArcConst.ARC_LIST_W)
    ArcListItem() {
      Button($r('app.string.start_use'))
        .width('100%')
        .backgroundColor($r('sys.color.brand'))
        .fontColor(Color.White)
        .onClick(() => {
          this.onReInit?.()
          this.settingsSheet = false;
        })
    }.width(ArcConst.ARC_LIST_W)
  }

  build() {
    NavDestination() {
      ArcList() {
        this.Main()
      }.defaultFocus(true)
      .space(ArcConst.ARC_LIST_SPC)
      .width(ArcConst.MAX_LEN)
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
    .animation({ duration: 300 })
  }
}
