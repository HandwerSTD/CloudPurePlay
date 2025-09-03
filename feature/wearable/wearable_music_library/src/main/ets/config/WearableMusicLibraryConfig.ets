import { curves } from "@kit.ArkUI"

/**
 * 可穿戴设备音乐库配置
 */
export class WearableMusicLibraryConfig {
  // 布局配置
  static readonly ITEM_HEIGHT = 48
  static readonly ITEM_SPACING = 8
  static readonly CARD_RADIUS = 8
  static readonly AVATAR_SIZE = 32
  static readonly THUMBNAIL_SIZE = 40
  
  // 字体配置
  static readonly TITLE_FONT_SIZE = 14
  static readonly SUBTITLE_FONT_SIZE = 12
  static readonly CAPTION_FONT_SIZE = 10
  
  // 颜色配置
  static readonly PRIMARY_COLOR = $r('sys.color.font_on_primary')
  static readonly SECONDARY_COLOR = $r('sys.color.font_secondary')
  static readonly TERTIARY_COLOR = $r('sys.color.font_tertiary')
  static readonly BACKGROUND_COLOR = $r('app.color.common_card_item_background')
  
  // 动画配置
  static readonly TRANSITION_DURATION = 300
  static readonly SPRING_CURVE = curves.springMotion(0.6, 0.7)
  
  // 最大显示数量配置
  static readonly MAX_VISIBLE_ITEMS = 8 // 智能手表屏幕较小，限制显示数量
  static readonly MAX_TITLE_LENGTH = 20 // 标题最大字符数
}
