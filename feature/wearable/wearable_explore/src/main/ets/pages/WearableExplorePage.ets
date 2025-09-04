import { UserStore, SCApp, FeaturedPlayUtils
} from "@handwer/base"

@ComponentV2
export struct WearableExplorePage {
  @Consumer(SCApp.shouldDisableTab) shouldDisableTab: boolean = false
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false
  
  user = UserStore

  @Local showSearchPage: boolean = false
  @Local fullWidth: number = 0

  @Builder QuickButtons() {
    Column({ space: 8 }) {
      // 搜索按钮
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_on_primary')])
          Text($r('app.string.wearable_search_hint'))
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .width('100%')
      .height(40)
      .borderRadius(20)
      .onClick(() => {
        this.showSearchPage = true
      })

      // 所有专辑按钮
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.square_grid_2x2'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_on_primary')])
          Text($r('app.string.wearable_all_albums'))
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .width('100%')
      .height(40)
      .borderRadius(20)
      .onClick(() => {
        this.pageStack.pushPathByName('AllAlbums', [])
      })

      // 个人FM按钮
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.radio'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_on_primary')])
          Text("个人FM")
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .width('100%')
      .height(40)
      .borderRadius(20)
      .onClick(() => {
        FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
          // 简化的消息提示，适合可穿戴设备
          console.info(`播放消息: ${msg}`)
        })
      })
    }
    .padding({ left: 16, right: 16 })
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        // 主要功能按钮区域
        this.QuickButtons()
      }
      .width('100%')
      .height('100%')

      // 搜索页面覆盖层
      if (this.showSearchPage) {
        // WearableSearchView({
        //   closeSearch: () => {
        //     this.showSearchPage = false
        //   }
        // })
        // .width('100%')
        // .height('100%')
        // .backgroundColor($r('sys.color.background_primary'))
        // .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 300 }))
      }
    }
    .width('100%')
    .height('100%')
  }
}
