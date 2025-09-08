import { ThemeManager } from "@handwer/base"

@ComponentV2
export struct LoadingView {

  @Builder Symbol() {
    Column() {
      SymbolGlyph($r('sys.symbol.dual_phone_pairing'))
        .fontSize(44)
        .fontColor([ThemeManager.getBrand()])
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
        Span('已准备好')
          .fontSize(14)
        Span('\n碰一碰分享 / 隔空抓取')
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
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
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .constraintSize({
      minHeight: 116
    })
    .width('100%')
  }

}

@Builder export function KnockShareDialogBuilder() {
  LoadingView()
}
