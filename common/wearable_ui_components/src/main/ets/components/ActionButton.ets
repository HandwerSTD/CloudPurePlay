
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
      .backgroundColor(this.customBgColor ? this.customBgColor : $r('sys.color.comp_background_secondary'))
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

export class UIComponentUtils {
  static getTodayIcon(): Resource {
    return UIComponentUtils.getCalendarIconByDay(new Date().getDate())
  }
  static getCalendarIconByDay(day: number) {
    if (day < 1 || day > 31) return $r('sys.symbol.calendar')
    // 使用 switch-case 根据 day 的所有可能情况，选择出正确的图标 sys.symbol.calendar_xx_a
    switch (day) {
      case 1:
        return $r('sys.symbol.calendar_01_a')
      case 2:
        return $r('sys.symbol.calendar_02_a')
      case 3:
        return $r('sys.symbol.calendar_03_a')
      case 4:
        return $r('sys.symbol.calendar_04_a')
      case 5:
        return $r('sys.symbol.calendar_05_a')
      case 6:
        return $r('sys.symbol.calendar_06_a')
      case 7:
        return $r('sys.symbol.calendar_07_a')
      case 8:
        return $r('sys.symbol.calendar_08_a')
      case 9:
        return $r('sys.symbol.calendar_09_a')
      case 10:
        return $r('sys.symbol.calendar_10_a')
      case 11:
        return $r('sys.symbol.calendar_11_a')
      case 12:
        return $r('sys.symbol.calendar_12_a')
      case 13:
        return $r('sys.symbol.calendar_13_a')
      case 14:
        return $r('sys.symbol.calendar_14_a')
      case 15:
        return $r('sys.symbol.calendar_15_a')
      case 16:
        return $r('sys.symbol.calendar_16_a')
      case 17:
        return $r('sys.symbol.calendar_17_a')
      case 18:
        return $r('sys.symbol.calendar_18_a')
      case 19:
        return $r('sys.symbol.calendar_19_a')
      case 20:
        return $r('sys.symbol.calendar_20_a')
      case 21:
        return $r('sys.symbol.calendar_21_a')
      case 22:
        return $r('sys.symbol.calendar_22_a')
      case 23:
        return $r('sys.symbol.calendar_23_a')
      case 24:
        return $r('sys.symbol.calendar_24_a')
      case 25:
        return $r('sys.symbol.calendar_25_a')
      case 26:
        return $r('sys.symbol.calendar_26_a')
      case 27:
        return $r('sys.symbol.calendar_27_a')
      case 28:
        return $r('sys.symbol.calendar_28_a')
      case 29:
        return $r('sys.symbol.calendar_29_a')
      case 30:
        return $r('sys.symbol.calendar_30_a')
      case 31:
        return $r('sys.symbol.calendar_31_a')
      default:
        return $r('sys.symbol.calendar')
    }
  }
  static getQueueCycleModeIcon(cycleMode: number) {
    if (cycleMode === 0) return $r('sys.symbol.order_play')
    if (cycleMode === 1) return $r('sys.symbol.repeat_1')
    if (cycleMode === 2) return $r('sys.symbol.repeat')
    return $r('sys.symbol.shuffle')
  }
}