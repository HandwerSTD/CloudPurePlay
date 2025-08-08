import { TitleBarStyleOptions, ScrollEffectType } from "@kit.UIDesignKit";
import { LengthMetrics } from "@kit.ArkUI";

export const HDS_TITLE_CONFIG_STYLE: TitleBarStyleOptions = { // 设置Hds导航组件标题栏样式
  // 标题栏动态模糊样式，包括是否使能滚动动态模糊，动态模糊类型，动态模糊生效的滚动距离等
  scrollEffectOpts: {
    enableScrollEffect: true,
    scrollEffectType: ScrollEffectType.GRADIENT_BLUR,
    blurEffectiveStartOffset: LengthMetrics.vp(0),
    blurEffectiveEndOffset: LengthMetrics.vp(20)
  },
  originalStyle: { // 内容区滚动前初始样式设置
    backgroundStyle: { // 标题栏背板样式设置
      backgroundColor: //$r('sys.color.comp_background_secondary'),
      Color.Transparent
    },
    contentStyle: { // 标题栏内容区样式设置，包括标题区域，菜单区域，返回按钮区域
      titleStyle: {
        mainTitleColor: $r('sys.color.font_on_primary'),
        subTitleColor: $r('sys.color.font_on_secondary')
      },
      menuStyle: {
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        iconColor: $r('sys.color.icon_on_primary')
      },
      backIconStyle: {
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        iconColor: $r('sys.color.icon_on_primary')
      }
    }
  },
  scrollEffectStyle: { // 内容区滚动超过blurEffectiveEndOffset后样式设置
    backgroundStyle: {
      backgroundColor: $r('sys.color.ohos_id_color_background_transparent'),
    },
    contentStyle: {
      titleStyle: {
        mainTitleColor: $r('sys.color.font_on_primary'),
        subTitleColor: $r('sys.color.font_on_secondary')
      },
      menuStyle: {
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        iconColor: $r('sys.color.icon_on_primary')
      },
      backIconStyle: {
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        iconColor: $r('sys.color.icon_on_primary')
      }
    }
  }
}