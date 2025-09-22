import { ImgCache } from "@handwer/base"
import { ImageKnifeComponent, ImageKnifeOption } from "@ohos/imageknifepro"
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
  @Param @Require imageUrlI: ResourceStr

  // 交互属性
  @Param loadCompleteCallback?: ImageLoadCompleteCallback = undefined
  @Param lightedUp?: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.BORDER
  @Param radius: number = 0
  @Param customPlaceholder?: ResourceStr = undefined

  @Builder Lighter() {
    Column() {

    }.width('100%').height('100%').borderRadius(this.radius)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: this.lightedUp
    }).buildEffect())
  }

  build() {
    ImageKnifeComponent({
      imageKnifeOption: {
        loadSrc: this.imageUrlI,
        placeholderSrc: this.customPlaceholder ?? $r('app.media.icon_216_gray'),
        onLoadListener: {
          onLoadSuccess: () => {
            this.loadCompleteCallback?.onComplete?.()
          },
          onLoadFailed: () => {
            this.loadCompleteCallback?.onError?.()
          }
        },
        border: {
          radius: this.radius,
          width: 0
        }
      }
    })
      .overlay(this.lightedUp ? this.Lighter : undefined)
  }
}
