import { InstanceSwitcher } from "@handwer/api_adapter"
import { UserManager, UserStore } from "@handwer/base"

@ComponentV2
export struct WearableUserCard {
  @Event onToggleView: () => void
  @Param showAlbum: boolean = false

  build() {
    Row() {
      Image(UserStore.user.data.profile.avatarUrl)
        .width(28)
        .height(28)
        .borderRadius(14)
        .margin({ right: 8 })
      
      Column() {
        Text(UserStore.user.data.profile.nickname)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontColor($r('sys.color.font_on_primary'))
        
        Text($r('app.string.api_switch_from_what', InstanceSwitcher.InstanceTypeName))
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph(this.showAlbum ? $r('sys.symbol.opticaldisc') : $r('sys.symbol.heart_square_stack'))
          .fontSize(16)
          .fontColor([$r('sys.color.font_primary')])
      }
      .backgroundColor($r('app.color.common_card_item_background'))
      .width(32)
      .height(32)
      .onClick(() => {
        this.onToggleView()
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.common_card_item_background'))
    .borderRadius(8)
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .onClick(() => {
      UserManager.fetchUserInfo()
    })
  }
}
