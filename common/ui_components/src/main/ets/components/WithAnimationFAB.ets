import { ThemeManager } from "@handwer/base"
import { curves } from "@kit.ArkUI"

@ComponentV2
export struct WithAnimationFAB {
  @Param @Require clickAction: () => void
  @BuilderParam inner: () => void
  @Param icon: Resource | null = null
  @Param fontSize: number = 36
  @Param fontWeight: FontWeight = FontWeight.Medium
  @Param outerColor: ResourceColor = ThemeManager.getTheme().colors!.brand!
  @Param customAppearCurve: curves.ICurve | curves.Curve = curves.springMotion(0.5, 0.55)
  build() {
    Button({ type: ButtonType.Circle }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor([Color.White])
      } else {
        this.inner()
      }
    }.clickEffect({
      level: ClickEffectLevel.LIGHT,
    }).draggable(false)
    .hoverEffect(HoverEffect.Highlight)
    .shadow({
      radius: 16,
      offsetY: 8,
      color: this.outerColor
    })
    .transition(TransitionEffect.asymmetric(TransitionEffect.scale({
      x: -0.001, y: -0.001
    }).animation({
      curve: this.customAppearCurve
    }), TransitionEffect.scale({
      x: -0.001, y: -0.001
    }).animation({
      curve: Curve.Friction,
      duration: 300
    })))
    .backgroundColor(this.outerColor)
    .width(60)
    .height(60)
    .onClick(() => {
      this.clickAction()
    })
  }
}