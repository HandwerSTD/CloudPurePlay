import { PlayStatUtils } from "@handwer/base/src/main/ets/services/PlayStatistics/PlayStatUtils";
import { LightedCommonListItem, HDS_TITLE_CONFIG_STYLE } from "@handwer/ui_components";
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit";
import { LengthMetrics } from "@kit.ArkUI";

@ComponentV2
export struct PlayStatistics {
  @Local firstOpenTime: Date = new Date()
  @Local pageOpacity: number = 1
  
  aboutToAppear(): void {
    this.loadPlayStatistics()
  }
  
  async loadPlayStatistics() {
    try {
      this.firstOpenTime = await PlayStatUtils.getFirstUseTime()
    } catch (error) {
      console.error('Failed to load first open time:', error)
    }
  }
  
  formatDateTime(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            ListItem() {
              LightedCommonListItem({
                icon: $r('sys.symbol.clock'),
                title: $r('app.string.first_open_time'),
                subtitle: this.formatDateTime(this.firstOpenTime)
              })
            }
          }.padding({left: 12, right: 12})
          .fadingEdge(true, {
            fadingEdgeLength: LengthMetrics.percent(10)
          })
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.play_statistics')
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