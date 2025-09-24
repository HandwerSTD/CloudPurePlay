import { DialogOptions } from "@pura/harmony-dialog"

@Builder
export function PlayDialogBuilder(options: DialogOptions) {
  LoadingView({
    isRedHeart: false
  })
}
@Builder
export function PauseDialogBuilder(options: DialogOptions) {
  LoadingView({
    isRedHeart: true
  })
}


@ComponentV2
export struct LoadingView {
  @Param @Require isRedHeart: boolean

  @Builder Symbol() {
    Column() {
      if (this.isRedHeart) {
        SymbolGlyph($r('sys.symbol.play_round_triangle_fill'))
          .fontSize(44)
          .fontColor([Color.White])
          .symbolShadow({
            radius: 6,
            color: '#ccffffff'
          })
      } else {
        SymbolGlyph($r('sys.symbol.pause'))
          .fontSize(44)
          .fontColor([Color.White])
          .symbolShadow({
            radius: 6,
            color: '#ccffffff'
          })
      }
      // .lightUpEffect(1.3)
    }
  }

  build() {
    Row({space: 24}) {
      this.Symbol()
    }
    .justifyContent(FlexAlign.Center)
    .margin(5)
    .padding(24)
    .backgroundColor($r('app.color.ui_sheet_bg_col'))
    .borderRadius(24).aspectRatio(1)
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .constraintSize({
      minHeight: 116
    })
  }

}
