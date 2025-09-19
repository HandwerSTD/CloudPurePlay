import { hdsEffect } from '@kit.UIDesignKit'
import { LightUpConfig, LightUpDefaultConfig, LightUpLinedDefaultConfig, OverrideLightUpStat } from './LightUpConfig'
import { curves } from '@kit.ArkUI'
import { ThemeManager } from '@handwer/base'
import { LightUpLinedContainer } from '../../../../Index'

@ComponentV2
export struct LightUpRoundedButton {
  @Param @Require icon: Resource
  @Param @Require clickAction: () => void
  @Param lightUpConfig: LightUpConfig = LightUpDefaultConfig

  @Param customBgColor: ResourceColor | undefined = undefined
  @Param customFontColor: ResourceColor[] | undefined = undefined
  @Param customFontSize: number | undefined = undefined
  @Param customFontWeight: FontWeight | undefined = undefined
  @Param customPadding: Length | undefined = undefined
  @Param overrideLightUpStat: OverrideLightUpStat = OverrideLightUpStat.NO_OVERRIDE
  @Param useAnimationToAll: boolean = false

  @Local intensity: number = 0
  @Local illuminatedType: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT

  @Monitor('intensity', 'overrideLightUpStat')
  onLightUp() {
    if (this.finalIntensity > 0) {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER
    } else {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
    }
  }

  get targetIntensity() {
    return (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
  }
  get finalIntensity() {
    if (this.overrideLightUpStat === OverrideLightUpStat.NO_OVERRIDE) return this.intensity
    if (this.overrideLightUpStat === OverrideLightUpStat.ALWAYS_DISABLED) return 0
    return this.targetIntensity
  }
  get buttonBgColor() {
    if (this.finalIntensity > 0) {
      return Color.White
    }
    return this.customBgColor ? this.customBgColor : $r('sys.color.comp_background_secondary')
  }
  get isChevron() {
    return this.icon.id === $r('sys.symbol.chevron_right').id || this.icon.id === $r('sys.symbol.chevron_left').id
  }

  @Builder ChevronButton() {
    Text() {
      SymbolSpan(this.icon)
        .fontWeight(this.customFontWeight)
        .fontSize(this.customFontSize ? this.customFontSize: 24)
        .fontColor(this.customFontColor ? this.customFontColor : [$r('sys.color.font_primary')])
        .hitTestBehavior(HitTestMode.Transparent)
    }.offset({y: -7})
  }

  get FontColor() {
    if (this.intensity > 0 || this.overrideLightUpStat === OverrideLightUpStat.ALWAYS_ENABLED) return [ThemeManager.getBrand()]
    return this.customFontColor ? this.customFontColor : [Color.White]
  }

  build() {
    Column() {
      if (this.isChevron) {
        this.ChevronButton()
      } else {
        SymbolGlyph(this.icon)
          .fontWeight(this.customFontWeight)
          .fontSize(this.customFontSize ? this.customFontSize: 24)
          .fontColor(this.FontColor)
          .hitTestBehavior(HitTestMode.Transparent)
      }
    }.borderRadius(this.customFontSize ? this.customFontSize*2 : 48)
    .backgroundColor(this.buttonBgColor)
    .padding(this.customPadding ?? 8)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .aspectRatio(1)
    .animation({
      duration: this.useAnimationToAll ? 300 : 0,
      curve: Curve.EaseInOut
    })
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .pressShadow(this.intensity > 0 ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
      .pointLight({
        illuminatedType: this.illuminatedType,
        options: {
          color: Color.White,
          intensity: this.finalIntensity,
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
        this.intensity = this.targetIntensity
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.intensity = 0
      }
    })
    .onHover((is) => {
      if (is) {
        this.intensity = this.targetIntensity/2
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


@ComponentV2
export struct LightUpCommonButton {
  @Param @Require clickAction: () => void
  @Param @Require lightUpConfig: LightUpConfig
  @BuilderParam child: () => void

  @Param customBgColor: ResourceColor | undefined = undefined
  @Param customPadding: Padding | number | undefined = undefined
  @Param customBorderRadius: Length | undefined = 500 // infinity
  @Param overrideLightUpStat: OverrideLightUpStat = OverrideLightUpStat.NO_OVERRIDE
  @Param useBorder: boolean = false

  @Local intensity: number = 0
  @Local illuminatedType: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT

  @Monitor('intensity', 'overrideLightUpStat')
  onLightUp() {
    if (this.finalIntensity > 0) {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER
    } else {
      this.illuminatedType = hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
    }
  }

  get targetIntensity() {
    return (this.lightUpConfig.lightIntensity ?? LightUpDefaultConfig.lightIntensity!)
  }
  get finalIntensity() {
    if (this.overrideLightUpStat === OverrideLightUpStat.NO_OVERRIDE) return this.intensity
    if (this.overrideLightUpStat === OverrideLightUpStat.ALWAYS_DISABLED) return 0
    return this.targetIntensity
  }
  get buttonBgColor() {
    if (this.finalIntensity > 0) {
      return Color.White
    }
    return this.customBgColor ? this.customBgColor : $r('sys.color.comp_background_secondary')
  }

  build() {
    Button() {
      this.child()
    }.borderRadius(this.customBorderRadius)
    .border({
      radius: this.customBorderRadius,
      width: this.useBorder ? 1 : 0,
      color: Color.White
    })
    .backgroundColor(this.buttonBgColor)
    .padding(this.customPadding ?? 12)
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .pressShadow(this.intensity > 0 ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
      .pointLight({
        illuminatedType: this.illuminatedType,
        options: {
          color: Color.White,
          intensity: this.finalIntensity,
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
        this.intensity = this.targetIntensity
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.intensity = 0
      }
    })
    .onHover((is) => {
      if (is) {
        this.intensity = this.targetIntensity/2
      } else {
        this.intensity = 0
      }
    })

  }
}

@ComponentV2
export struct LightUpIconTextButton {
  @Param @Require clickAction: () => void
  @Param @Require lightUpConfig: LightUpConfig
  @Param @Require icon: Resource
  @Param @Require title: ResourceStr
  @Param overrideLightStat: OverrideLightUpStat = OverrideLightUpStat.NO_OVERRIDE

  @Local lighted: boolean = false

  get fontColor() {
    if (this.lighted || this.overrideLightStat === OverrideLightUpStat.ALWAYS_ENABLED) return ThemeManager.getBrand()
    return Color.White
  }

  build() {
    Column() {
      LightUpCommonButton({
        clickAction: this.clickAction,
        lightUpConfig: { lightIntensity: 1, lightHeight: 240},
        customPadding: 16,
        useBorder: true,
        overrideLightUpStat: this.overrideLightStat
      }) {
        Row({space: 12}) {
          SymbolGlyph(this.icon).fontColor([this.fontColor]).fontWeight(FontWeight.Bold)
          Text(this.title).fontColor(this.fontColor)
        }
      }
    }
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.lighted = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.lighted = false
      }
    })
  }
}


@ComponentV2
export struct LightUpLongButton {
  @Param @Require clickAction: () => void
  @Param @Require title: ResourceStr
  @Param overrideLightUpStat: OverrideLightUpStat = OverrideLightUpStat.NO_OVERRIDE

  @Param isEmphasized: boolean = true
  @Param icon: Resource | undefined = undefined
  @Param lightUpConfig: LightUpConfig = LightUpLinedDefaultConfig

  @Local lighted: boolean = false

  get fontColor() {
    if (this.lighted || this.overrideLightUpStat === OverrideLightUpStat.ALWAYS_ENABLED) return ThemeManager.getBrand()
    return Color.White
  }


  build() {
    LightUpLinedContainer({
      overrideLightUpStat: this.overrideLightUpStat,
      lightUpConfig: this.lightUpConfig,
      lightNum: 10
    }) {
      Button() {
        Row({space: 12}) {
          if (this.icon) {
            SymbolGlyph(this.icon).fontColor([this.fontColor]).fontWeight(FontWeight.Bold)
          }
          Text(this.title).fontColor(this.fontColor)
        }
      }
      .border({
        radius: '50%',
        width: this.isEmphasized ? 1.5 : 0.5,
        color: (this.isEmphasized ? '#ff' : '#66') + 'ffffff'
      })
      .backgroundColor(this.isEmphasized ? '#33ffffff' : '#11ffffff')
      .padding(12)
      .visualEffect(new hdsEffect.HdsEffectBuilder()
        .pressShadow(this.lighted ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
        .pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
        })
        .buildEffect())
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
      .clickEffect({
        level: ClickEffectLevel.HEAVY
      })
      //-------------------------------------
      .onClick(() => {
        this.clickAction()
      })
      .width('100%')
      .onTouch((event) => {
        if (event.type === TouchType.Down) {
          this.lighted = true
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.lighted = false
        }
      })
    }
  }
}