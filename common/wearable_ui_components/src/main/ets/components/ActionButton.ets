
@ComponentV2
export struct ActionButton {
  @Param @Require icon: Resource
  @Param @Require clickAction: () => void
  @Param customBgColor: ResourceColor | undefined = undefined
  @Param customFontColor: ResourceColor[] | undefined = undefined
  @Param customFontSize: number | undefined = undefined
  @Param longPressAction: ((() => void) | undefined) = undefined
  @Param title: ResourceStr | undefined = undefined
  @Param forceRatio: boolean = false

  build() {
    Column({space: 4}) {
      Button() {
        SymbolGlyph(this.icon)
          .fontSize(this.customFontSize ? this.customFontSize: 24)
          .fontColor(this.customFontColor ? this.customFontColor : [$r('sys.color.font_primary')])
      }.onClick(() => { this.clickAction(); })
      .gesture((this.longPressAction === undefined) ? undefined : (LongPressGesture().onAction(() => {
        this.longPressAction!()
      })))
      .backgroundColor(this.customBgColor ? this.customBgColor : '#33000000')
      .padding(8)
      .clickEffect({
        level: ClickEffectLevel.LIGHT
      })
      .hoverEffect(HoverEffect.Highlight)
      if (this.title) {
        Text(this.title)
          .fontSize(10)
          .fontColor($r('sys.color.ohos_id_color_bottom_tab_text_off'))
      }
    }
  }
}

@ComponentV2
export struct ActionCommonButton {
  @Param @Require clickAction: () => void
  @BuilderParam child: () => void

  @Param customBgColor: ResourceColor | undefined = $r('sys.color.comp_background_secondary')
  @Param customPadding: Padding | number | undefined = undefined
  @Param customBorderRadius: Length | undefined = 500 // infinity
  @Param useBorder: boolean = false
  build() {
    Button() {
      this.child()
    }.borderRadius(this.customBorderRadius)
    .border({
      radius: this.customBorderRadius,
      width: this.useBorder ? 1 : 0,
      color: Color.White
    })
    .backgroundColor(this.customBgColor)
    .padding(this.customPadding ?? 12)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    //-------------------------------------
    .onClick(() => {
      this.clickAction()
    })
  }
}


@ComponentV2
export struct ActionIconTextButton {
  @Param @Require clickAction: () => void
  @Param @Require icon: Resource
  @Param @Require title: ResourceStr

  get fontColor() {
    return $r('sys.color.font_primary')
  }

  build() {
    Column() {
      ActionCommonButton({
        clickAction: this.clickAction,
        customPadding: 16,
        useBorder: true,
      }) {
        Row({space: 12}) {
          SymbolGlyph(this.icon).fontColor([this.fontColor]).fontWeight(FontWeight.Bold)
          Text(this.title).fontColor(this.fontColor)
        }
      }
    }
  }
}
