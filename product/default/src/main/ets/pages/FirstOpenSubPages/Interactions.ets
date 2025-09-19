import {
  CommonListItem,
  LightUpIconTextButton, LightUpLinedContainer, LightUpRoundedButton,LightUpDefaultConfig,
  CommonListToggleItem,
  LightedCommonListToggleItem,
  SnackBarUtils,
  LightedCommonListItem,
  DialogUtils
} from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { hdsEffect } from "@kit.UIDesignKit";
import { GlobalStore, Logger, SCPref, Settings, ShareUtils } from "@handwer/base";
import { motion } from "@kit.MultimodalAwarenessKit";
import { APIConfigUtils, InstanceSwitcher } from "@handwer/api_adapter";
import { systemShare } from "@kit.ShareKit";
import { uniformTypeDescriptor } from "@kit.ArkData";
import { ImageUtil } from "@pura/harmony-utils";

@ComponentV2
export struct MultiInteractions {
  @Local useStylusControl: boolean = true
  @Local useMissionContinue: boolean = true
  shareUri: string = ''

  aboutToAppear(): void {
    this.useStylusControl = Settings.get<boolean>(SCPref.useStylusControl) ?? true
    this.useMissionContinue = Settings.get<boolean>(SCPref.useMissionContinue) ?? false

    ImageUtil.getPixelMapFromMedia($r('app.media.ff'))
      .then((res) => {
        return ShareUtils.savePixelMapAsThumbnail(this.getUIContext().getHostContext()!, res)
      })
      .then((res) => {
        this.shareUri = res
        Logger.debug('got share uri = ' + res)
      })
  }

  @Builder toggle0() {
    LightedCommonListItem({
      icon: $r('sys.symbol.dual_phone_pairing'),
      title: $r('app.string.knock_share_hop_transfer')
    }) {
      LightUpRoundedButton({
        icon: $r('sys.symbol.share'),
        clickAction: () => {
          ShareUtils.startKnockShare(this.getUIContext().getHostContext()?.getApplicationContext()!,
            (onClose): string => {
              return DialogUtils.showKnockShareDialog(onClose);
            }, (target) => {
              let shareData: systemShare.SharedData = new systemShare.SharedData({
                utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
                content: 'https://appgallery.huawei.com/app/detail?id=top.handwer.cloudpureplay',
                title: '云净听',
                thumbnailUri: this.shareUri
              });
              target.share(shareData)
            })
        }
      })
    }
  }
  @Builder toggle1() {
    LightedCommonListToggleItem({
      icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
      title: $r('app.string.settings_enable_mission_continue'),
      isOn: this.useMissionContinue,
      onToggleChange: (val) => {
        this.useMissionContinue = val
        Settings.put(SCPref.useMissionContinue, val)
      }
    })
  }
  @Builder toggle2() {
    LightedCommonListToggleItem({
      icon: $r('sys.symbol.pencil_tip'),
      title: $r('app.string.use_stylus_control'),
      subtitle: $r('app.string.use_stylus_control_desc'),
      isOn: this.useStylusControl,
      onToggleChange: (val) => {
        this.useStylusControl = val
        Settings.put(SCPref.useStylusControl, val)
        GlobalStore.pref.useStylusControl = val
        // SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.pencil_tip'), $r('app.string.restart_to_take_effect'))
      }
    })
  }
  @Builder toggle3() {
    LightedCommonListToggleItem({
      icon: $r('sys.symbol.hand_tap'),
      title: $r('app.string.auto_nav_right_hand'),
      // subtitle: $r('app.string.auto_nav_right_hand_desc'),
      isOn: GlobalStore.pref.autoNavRightHandMode,
      onToggleChange: (val) => {
        GlobalStore.pref.autoNavRightHandMode = val
        Settings.put(SCPref.autoNavRightHand, val)
        try {
          motion.getRecentOperatingHandStatus()
        } catch (e) {
          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.hand_tap'), $r('app.string.this_device_unsupport'))
        }
      }
    })
  }

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.wand_and_stars'),
      gradientColor: [0x02c1f8, 0x025fea],
    })
  }
  @Builder featureCard(symbol: Resource, msg: ResourceStr, toggleConfigIndex: number) {
    Column() {
      Blank().height(24)
      SymbolTitle({
        icon: symbol,
        gradientColor: [0xe4b7d4, 0xbc97d4]
      })
      Text(msg)
        .fontColor(Color.White)
        .padding(24)
      Column() {
        if (toggleConfigIndex === 0) this.toggle0()
        else  if (toggleConfigIndex === 1) this.toggle1()
        else  if (toggleConfigIndex === 2) this.toggle2()
        else  if (toggleConfigIndex === 3) this.toggle3()
      }.padding(12).margin({bottom: 14})
    }.width('100%').height(320).justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder footer() {
    Stack({alignContent: Alignment.TopEnd}) {
      Row() {
        Swiper() {
          this.featureCard($r('sys.symbol.dual_phone_pairing'), $r('app.string.first_open_page__interaction_share_feature'), 0)
          this.featureCard($r('sys.symbol.Interconnection_ic_multiscreen_collaboration'), $r('app.string.first_open_page_mission_continue_desc'), 1)
          this.featureCard($r('sys.symbol.pencil_waveform'), $r('app.string.first_open_page__interaction_stylus_feature'), 2)
          this.featureCard($r('sys.symbol.hand_stars'), $r('app.string.first_open_page__interaction_hand_recognition_feature'), 3)
        }.autoPlay(true)
        .indicator(new DotIndicator().selectedColor(Color.White))
      }.width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(24)
      this.overlayInfoButton()
    }
  }

  @Builder overlayInfoButton() {
    LightUpRoundedButton({
      icon: $r('sys.symbol.info_circle'),
      clickAction: () => {
        this.showInfoMenu = !this.showInfoMenu
      },
      lightUpConfig: LightUpDefaultConfig
    }).translate({x: -12, y: 12})
      .bindContextMenu(this.showInfoMenu!!, this.infoMenu, {
        backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
        hapticFeedbackMode: HapticFeedbackMode.AUTO,
        placement: Placement.Right
      })
  }


  @Local showInfoMenu: boolean = false
  @Builder infoMenu() {
    Column() {
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.phone_2'),
          title: $r('app.string.first_open_page__interaction_feature_disclaimer'),
          trailing: () => {}
        })
      }
    }.borderRadius(24).margin(2)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }
  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.first_open_page__interaction_title'),
      subtitle: $r('app.string.first_open_page__interaction_subtitle'),
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}