import { ThemeManager } from "@handwer/base"
import { DialogOptions } from "@pura/harmony-dialog"

@Builder
export function KnockShareDialogBuilder(options: DialogOptions) {
  LoadingView()
}

@ComponentV2
export struct LoadingView {

  @Builder Symbol() {
    Column() {
      SymbolGlyph($r('sys.symbol.dual_phone_pairing'))
        .fontSize(44)
        .fontColor([Color.White])
        .symbolShadow({
          radius: 6,
          color: '#ccffffff'
        })
        // .lightUpEffect(1.3)
    }
  }

  build() {
    Row({space: 24}) {
      this.Symbol()
      Text() {
        Span($r('app.string.on_ready'))
          .fontSize(14)
        Span('\n')
        Span($r('app.string.knock_share_hop_transfer'))
          .fontWeight(FontWeight.Bold)
          .fontSize(17)
          .textShadow({
            radius: 12,
            color: '#aaffffff'
          })
      }.fontColor(Color.White)
    }
    .justifyContent(FlexAlign.Center)
    .margin(5)
    .padding(24)
    .backgroundColor($r('app.color.ui_sheet_bg_col'))
    .borderRadius(24)
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .constraintSize({
      minHeight: 116
    })
  }

}
