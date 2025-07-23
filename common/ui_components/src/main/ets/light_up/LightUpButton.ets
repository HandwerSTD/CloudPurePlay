import { hdsEffect } from '@kit.UIDesignKit'
import { LightUpConfig, LightUpDefaultConfig } from './LightUpConfig'
import { curves } from '@kit.ArkUI'

@ComponentV2
export struct LightUpRoundedButton {
  @Param @Require icon: Resource
  @Param @Require clickAction: () => void
  @Param @Require lightUpConfig: LightUpConfig

  @Param customBgColor: ResourceColor | undefined = undefined
  @Param customFontColor: ResourceColor[] | undefined = undefined
  @Param customFontSize: number | undefined = undefined

  @Local intensity: number = 0
  @Local illuminatedType: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT

  @Monitor('intensity')
  onLightUp() {
    if (this.intensity > 0) {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER
    } else {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
    }
  }

  build() {
    Button() {
      SymbolGlyph(this.icon)
        .fontSize(this.customFontSize ? this.customFontSize: 24)
        .fontColor(this.customFontColor ? this.customFontColor : [$r('sys.color.font_primary')])
        .hitTestBehavior(HitTestMode.Transparent)
    }.borderRadius(this.customFontSize ? this.customFontSize*2 : 48)
    .backgroundColor(this.customBgColor ? this.customBgColor : $r('sys.color.comp_background_secondary'))
    .padding(8)
    .aspectRatio(1)
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .pressShadow(this.intensity > 0 ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
      .pointLight({
        illuminatedType: this.illuminatedType,
        options: {
          color: Color.White,
          intensity: this.intensity,
          height: this.lightUpConfig.lightHeight ?? LightUpDefaultConfig.lightHeight,
          bloom: this.lightUpConfig.lightBloom ?? 0
        }
      }).buildEffect())
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
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.intensity = (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.intensity = 0
      }
    })
    .onHover((is) => {
      if (is) {
        this.intensity = (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
      } else {
        this.intensity = 0
      }
    })

  }
}

@ComponentV2
export struct LightUpBorderRoundButton {
  @Param @Require icon: Resource
  @Param @Require clickAction: () => void
  @Param @Require lightUpConfig: LightUpConfig

  @Param customBgColor: ResourceColor | undefined = undefined
  @Param customFontColor: ResourceColor[] | undefined = undefined
  @Param customFontSize: number | undefined = undefined
  @Param customPadding: number | undefined = undefined
  @Param customBorderOption: BorderOptions | undefined = undefined

  @Local intensity: number = 0
  @Local illuminatedType: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT

  @Monitor('intensity')
  onLightUp() {
    if (this.intensity > 0) {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER
    } else {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
    }
  }

  build() {
    Button() {
      SymbolGlyph(this.icon)
        .fontSize(this.customFontSize ? this.customFontSize: 24)
        .fontColor(this.customFontColor ? this.customFontColor : [$r('sys.color.font_primary')])
        .hitTestBehavior(HitTestMode.Transparent)
    }
    .border(this.customBorderOption ?? {
      radius: this.customFontSize ? this.customFontSize*2 : 48,
      width: 1,
      color: this.customFontColor ? this.customFontColor[0] : $r('sys.color.font_primary')
    })
    .backgroundColor(this.customBgColor ? this.customBgColor : Color.Transparent)
    .padding(this.customPadding ?? 8)
    .animation({
      curve: curves.springMotion(0.6)
    })
    .aspectRatio(1)
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .pressShadow(this.intensity > 0 ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
      .pointLight({
        illuminatedType: this.illuminatedType,
        options: {
          color: Color.White,
          intensity: this.intensity,
          height: this.lightUpConfig.lightHeight ?? LightUpDefaultConfig.lightHeight,
          bloom: this.lightUpConfig.lightBloom ?? 0
        }
      }).buildEffect())
    .animation({
      duration: 200,
      curve: Curve.Ease
    })
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    //-------------------------------------
    .onClick(() => {
      this.clickAction()
    })
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.intensity = (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.intensity = 0
      }
    })
    .onHover((is) => {
      if (is) {
        this.intensity = (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
      } else {
        this.intensity = 0
      }
    })

  }
}