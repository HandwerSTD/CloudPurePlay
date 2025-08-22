import { hdsEffect } from "@kit.UIDesignKit"
import { LightUpLinedContainer } from "../../light_up/LightUpContainer"

@ComponentV2
export struct CommonListItem {
  @Param icon: Resource | null = null
  @Param isSymbol: boolean = true
  @Param @Require title: ResourceStr
  @Param subtitle: ResourceStr | null = null
  @Param filled: boolean = true
  @Param highlightBorder: boolean = false

  @Param fontColor: ResourceColor = $r('sys.color.font_on_primary')
  @Param hintFontColor: ResourceColor = $r('sys.color.font_on_secondary')
  @BuilderParam trailing?: () => void

  build() {
    Row() {
      if (this.icon) {
        if (this.isSymbol) {
          SymbolGlyph(this.icon)
            .fontSize(24)
            .margin({ right: 12 })
            .fontColor([this.fontColor])
        } else {
          Image(this.icon)
            .width(24.29)
            .margin({ right: 12 })
            .draggable(false)
        }
      }
      Column() {
        Text(this.title)
          .fontColor(this.fontColor)
        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(this.hintFontColor)
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      if (this.trailing) {
        this.trailing()
      } else {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor([this.fontColor])
      }
    }
    .hoverEffect(HoverEffect.Highlight)
    .borderRadius(24)
    .border(this.highlightBorder ? {
      width: 2,
      color: Color.White,
      radius: 24
    } : {
      width: 0,
      radius: 24
    })
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Start)
    .height(54)
  }
}

@ComponentV2
export struct LightedCommonListItem {
  @Param icon: Resource | null = null
  @Param isSymbol: boolean = true
  @Param @Require title: ResourceStr
  @Param subtitle: ResourceStr | null = null
  @Param filled: boolean = true
  @Param highlightBorder: boolean = false
  @BuilderParam trailing?: () => void
  // @Param shouldBeLightedUp: boolean = false

  build() {
    Column() {
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: this.icon,
          title: this.title,
          isSymbol: this.isSymbol,
          subtitle: this.subtitle,
          filled: this.filled,
          highlightBorder: this.highlightBorder,
          trailing: this.trailing
        })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }
}