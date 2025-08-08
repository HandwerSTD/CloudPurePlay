import { LightUpConfig, LightUpDefaultConfig, OverrideLightUpStat } from "./LightUpConfig"
import { hdsEffect } from "@kit.UIDesignKit"

@ComponentV2
export struct LightUpContainer {
  @Param @Require lightUpConfig: LightUpConfig
  @BuilderParam child: () => void

  @Param lightAlignment: Alignment = Alignment.Center
  @Param overrideLightUpStat: OverrideLightUpStat = OverrideLightUpStat.NO_OVERRIDE
  // @Param restrictLightBorder: boolean = false
  @Param lightAnimationParam: AnimateParam = {
    duration: 300, curve: Curve.EaseInOut
  }


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

  build() {
    Stack() {
      Column() {
      }.height(1).width(1).visualEffect(new hdsEffect.HdsEffectBuilder()
        .pressShadow(this.intensity > 0 ? hdsEffect.PressShadowType.BLEND_GRADIENT : 0)
        .pointLight({
          options: {
            color: Color.White,
            intensity: this.finalIntensity,
            height: this.lightUpConfig.lightHeight ?? LightUpDefaultConfig.lightHeight,
            bloom: this.lightUpConfig.lightBloom ?? 0
          }
        }).buildEffect())
      .animation(this.lightAnimationParam)

      this.child()
    }.alignContent(this.lightAlignment)
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.intensity = this.targetIntensity
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        setTimeout(() => {
          this.intensity = 0
        }, 0)
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