import { GlobalStore, NowPlayingStore, PlayControl, ResponsiveUtil } from "@handwer/base"
import { PLAYMODE, Song_INITIAL } from "@handwer/cloud_api"
import { LightUpRoundedButton, LightUpConfig, LightUpBorderRoundButton } from "@handwer/ui_components"
import { curves } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { hdsEffect } from "@kit.UIDesignKit"

const nps = NowPlayingStore
const LIGHT_TOP_BTN_SM: LightUpConfig = {
  lightIntensity: 20,
  lightHeight: 100,
  lightBloom: 0
}
const LIGHT_TOP_BTN_MD: LightUpConfig = {
  lightIntensity: 10,
  lightHeight: 200,
  lightBloom: 0
}
const LIGHT_TOP_BTN_LG: LightUpConfig = {
  lightIntensity: 3,
  lightHeight: 200,
  lightBloom: 0
}

const LIGHT_PLAYBACK_BTN_MD: LightUpConfig = {
  lightIntensity: 8,
  lightHeight: 100,
  lightBloom: 0,
}

const LIGHT_PLAYBACK_BTN_LG: LightUpConfig = {
  lightIntensity: 2,
  lightHeight: 250,
  lightBloom: 0,
}
@ComponentV2
export struct MainPage {

  gs = GlobalStore

  @Consumer('consoleSheet') consoleSheet: boolean = false

  controller: hdsEffect.ShaderEffectController = new hdsEffect.ShaderEffectController()

  get nowPlayingCoverImg() {
    if (nps.currentSong === Song_INITIAL) {
      return $r('sys.media.Celia')
    } else {
      return nps.playMode === PLAYMODE.LOCAL ? nps.currentPic : nps.currentPic + '?param=512y512'
    }
  }

  @Builder TopArea() {
    Row({space: 24}) {
      // Discover
      LightUpRoundedButton({
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
        icon: $r('sys.symbol.planets'),
        clickAction: () => {},
        customFontColor: [Color.White, Color.White]
      })

      // Settings
      LightUpRoundedButton({
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
        icon: $r('sys.symbol.gearshape'),
        clickAction: () => {
          this.consoleSheet = !this.consoleSheet
        },
        customFontColor: [Color.White, Color.White]
      })
    }.width('100%').padding({left: 24, right: 24})
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder CoverInfo() {
    Column({space: 24}) {
      Image(this.nowPlayingCoverImg)
        .aspectRatio(1)
        .layoutWeight(nps.currentSong.id === 0 ? undefined : 1)
        .borderRadius(20)
        .shadow(ShadowStyle.OUTER_DEFAULT_LG)
        .scale({ x: nps.isPaused ? 0.8 : 0.9, y: nps.isPaused ? 0.8 : 0.9})
        .animation({ curve: curves.springMotion(0.6, 0.5) })
        .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
        }).buildEffect())
        .gesture(
          TapGesture({
            count: 2,
          }).onAction(this.handleLike)
        )
      Text(nps.currentSong.name)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .aspectRatio(1)
    .constraintSize({
      minWidth: 0,
      maxWidth: '100%',
      minHeight: 0,
      maxHeight: 500
    })
  }

  @Builder PlaybackControl() {
    Row() {
      // 上一首
      LightUpBorderRoundButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontSize: 32,
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })

      // 播放
      LightUpBorderRoundButton({
        icon: nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'),
        customFontSize: 32,
        customPadding: nps.isPaused ? 10 : 14,
        customFontColor: [Color.White],
        customBgColor: Color.Transparent,
        clickAction: () => {
          if(nps.isPaused) {
            PlayControl.resumeMusic()
          } else {
            PlayControl.pauseMusic()
          }
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
        .shadow({
          color: '#ccffffff',
          radius: 36
        })
        .borderRadius(48)

      // 下一首
      LightUpBorderRoundButton({
        icon: $r('sys.symbol.forward_end_fill'),
        customFontSize: 32,
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
    }.justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  // -----------------------------------------------

  @Builder NowPlayingArea() {
    Column() {
      this.TopArea()
      this.CoverInfo()
      this.PlaybackControl()
    }.height('100%').width('100%')
    .padding({left: 24, right: 24})
    .justifyContent(FlexAlign.SpaceAround)
    .clip(false)
    .margin({bottom: this.gs.wd.bottom})
  }

  @Builder LyricArea() {

  }

  build() {
    Row() {
      Column() {
        Swiper() {
          this.NowPlayingArea()
          this.LyricArea()
        }.vertical(false)
        .displayCount(ResponsiveUtil.widthCheck(['md','lg','xl']) ? 2 : 1)
        .indicator(false)
        .animation({
          curve: curves.springMotion()
        })
        .width('100%').height('100%')
      }
      .width('100%')
    }
    .padding({
      top: this.gs.wd.top,
      // bottom: this.gs.wd.bottom
    })
    .height('100%')
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .shaderEffect({
        effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
        animation: {
          duration: 5000,
          iterations: -1,
          autoPlay: true,
          onFinish: ()=> {
            console.info('Succeeded in finishing');
          }
        },
        controller: this.controller,
      })
      .buildEffect())
  }

  async handleLike() {

  }
}
