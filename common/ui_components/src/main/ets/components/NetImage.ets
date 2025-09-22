import { ImgCache } from "@handwer/base"
import { hdsEffect } from "@kit.UIDesignKit"

export interface ImageLoadCompleteCallback {
  onComplete?: () => void
  onError?: () => void
}

/**
 * 网络图片组件
 * 封装了常用的网络图片显示功能，包括缓存、视觉效果、交互效果等
 */
@ComponentV2
export struct NetImage {
  // 必需属性
  @Param @Require imageUrlI: string

  // 基础属性
  @Param useCacheI: boolean = true
  @Param borderRadiusI: number = 12
  @Param aspectRatioI: number = 1

  // 视觉效果属性
  @Param enableShadowI: boolean = true
  @Param shadowStyleI: ShadowStyle = ShadowStyle.OUTER_DEFAULT_XS
  @Param enablePointLightI: boolean = false
  @Param brightnessI: number = 1.0
  @Param saturateI: number = 1.0
  @Param opacityI: number = 1.0

  // 交互属性
  @Param enableClickEffectI: boolean = true
  @Param clickEffectLevelI: ClickEffectLevel = ClickEffectLevel.HEAVY
  @Param onClickI?: () => void = undefined
  @Param loadCompleteCallback?: ImageLoadCompleteCallback = undefined

  // 布局属性
  @Param layoutWeightI?: number = undefined
  @Param widthI?: Length = undefined
  @Param heightI?: Length = undefined
  @Param constraintSizeI?: ConstraintSizeOptions = undefined

  /**
   * 获取处理后的图片URL
   */
  private getImageUrl(): string {
    if (!this.imageUrlI) return ''
    return this.useCacheI ? ImgCache.proxy(this.imageUrlI) : this.imageUrlI
  }

  /**
   * 应用基础样式
   */
  @Styles
  applyBaseStyle() {
    .draggable(false)
    .aspectRatio(this.aspectRatioI)
    .borderRadius(this.borderRadiusI)
    .brightness(this.brightnessI)
    .saturate(this.saturateI)
    .opacity(this.opacityI)
  }

  /**
   * 应用阴影效果
   */
  @Styles
  applyShadow() {
    .shadow(this.enableShadowI ? this.shadowStyleI : undefined)
  }

  /**
   * 应用点光源效果
   */
  @Styles
  applyPointLight() {
    .visualEffect(this.enablePointLightI ? 
      new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
      }).buildEffect() : undefined)
  }

  /**
   * 应用点击效果
   */
  @Styles
  applyClickEffect() {
    .clickEffect(this.enableClickEffectI ? {
      level: this.clickEffectLevelI
    } : undefined)
  }

  /**
   * 应用布局属性
   */
  @Styles
  applyLayout() {
    .layoutWeight(this.layoutWeightI)
    .width(this.widthI)
    .height(this.heightI)
    .constraintSize(this.constraintSizeI)
  }

  build() {
    Image(this.getImageUrl())
      .applyBaseStyle()
      .applyShadow()
      .applyPointLight()
      .applyClickEffect()
      .applyLayout()
      .onClick(() => {
        if (this.onClickI) {
          this.onClickI()
        }
      })
      .onComplete(() => {
        // 预缓存图片
        if (this.useCacheI && this.imageUrlI) {
          try {
            ImgCache.cache(this.imageUrlI)
          } catch (e) {
            // 忽略缓存错误
          }
        }
      })
  }
}

/**
 * 网络头像组件 - NetImage的特化版本
 */
@ComponentV2  
export struct NetAvatar {
  @Param @Require imageUrlI: string
  @Param sizeI: number = 48
  @Param onClickI?: () => void = undefined

  build() {
    NetImage({
      imageUrlI: this.imageUrlI,
      borderRadiusI: this.sizeI / 2, // 圆形头像
      aspectRatioI: 1,
      widthI: this.sizeI,
      heightI: this.sizeI,
      onClickI: this.onClickI
    })
  }
}
