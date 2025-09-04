import { FeaturedPlayUtils, SCApp } from "@handwer/base"
import { SnackBarUtils, UIComponentUtils } from "@handwer/wearable_ui_components"

@ComponentV2
export struct WearableMusicActionPanel {
  @Event onSearchClick: () => void
  @Event onSettingsClick: () => void

  build() {
    Row({space: 12}) {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      // .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        this.onSearchClick()
      })
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      // .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        this.onSettingsClick()
      })
    }
  }
}

@ComponentV2
export struct WearableMusicQuickButtons {

  @Consumer(SCApp.wearable_goToPlayer) goToPlayer: () => void = () => {}

  build() {
    Row({space: 12}) {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.heart_fill'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      // .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        FeaturedPlayUtils.playHeartMode((_, msg) => {
          SnackBarUtils.showMessage([], _, msg)
          this.goToPlayer()
        })
      })
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph(UIComponentUtils.getTodayIcon())
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      // .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        FeaturedPlayUtils.playDailySongs((_, msg) => {
          SnackBarUtils.showMessage([], _, msg)
          this.goToPlayer()
        }, UIComponentUtils.getTodayIcon())
      })
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.radiostation'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      // .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        FeaturedPlayUtils.playPersonalizedFM((_, msg) => {
          SnackBarUtils.showMessage([], _, msg)
          this.goToPlayer()
        })
      })
    }
  }
}
