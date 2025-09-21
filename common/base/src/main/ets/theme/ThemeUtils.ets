import { CustomColors, CustomTheme, ThemeControl } from '@kit.ArkUI'
import { SCPref, Settings } from '../../../../Index'
import { common, ConfigurationConstant } from '@kit.AbilityKit'

export class AppColors implements CustomColors {
}

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
  constructor(colorConfig: CustomColors) {
    this.colors = colorConfig
  }
}

export let gAppTheme: CustomTheme = new AppTheme({
  brand: $r('app.color.CosmicBlue')
})

export const themeColors = [
   $r('app.color.CosmicBlue') ,
   $r('app.color.NavyBlue') ,
   $r('app.color.SkyBlue') ,
   $r('app.color.CyanGreen') ,
   $r('app.color.GrassGreen') ,
   $r('app.color.LilacPurple') ,
   $r('app.color.StrawberryPink') ,
   $r('app.color.CrimsonRed') ,
   $r('app.color.Orange') ]

export const themeNames = [
  $r('app.string.cosmic_blue'),
  $r('app.string.navy_blue'),
  $r('app.string.sky_blue'),
  $r('app.string.cyan_green'),
  $r('app.string.grass_green'),
  $r('app.string.lilac_purple'),
  $r('app.string.strawberry_pink'),
  $r('app.string.crimson_red'),
  $r('app.string.orange')
]

/**
 * Theme mode enumeration
 */
export enum AppColorMode {
  MANUAL_LIGHT = 0,      // 手动浅色
  MANUAL_DARK = 1,        // 手动深色
  FOLLOW_SYSTEM = 2,    // 跟随系统
  SMART_MODE = 3           // 智能模式（基于光传感器）
}

@ObservedV2
export class ThemeManager {
  static singleton_: ThemeManager;
  @Trace appTheme: CustomTheme = gAppTheme
  @Trace _appColorModeStat: AppColorMode = AppColorMode.FOLLOW_SYSTEM
  nowUsedThemeIndex: number = 0
  static getSingleton() {
    if(!ThemeManager.singleton_) {
      ThemeManager.singleton_ = new ThemeManager();
    };
    return ThemeManager.singleton_
  }
  static getTheme() {
    if(!ThemeManager.singleton_) {
      ThemeManager.singleton_ = new ThemeManager();
    };
    return ThemeManager.singleton_.appTheme;
  }
  static getBrand() {
    return ThemeManager.getTheme().colors?.brand!
  }
  static init(appCtx: common.ApplicationContext) {
    ThemeManager.getSingleton().appColorModeStat = Settings.get(SCPref.appColorMode) ?? AppColorMode.SMART_MODE
    const idx = ThemeManager.getSingleton().appColorModeStat
    if (idx === 3) {
      // 在 Index.ets 中注册监听了
    } else {
      let color = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
      if (idx === 0) color = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      if (idx === 1) color = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      appCtx.setColorMode(color)
    }
    ThemeManager.setTheme(Settings.get(SCPref.theme) ?? 0)
  }
  static setTheme(index: number) {
    let st = ThemeManager.getSingleton()
    st.appTheme = new AppTheme({
      brand: themeColors[index]
    })
    ThemeControl.setDefaultTheme(st.appTheme)
    st.nowUsedThemeIndex = index
    // SettingsUtil.ThemeID = index
  }
  get appColorModeStat() {
    return this._appColorModeStat
  }
  set appColorModeStat(stat: AppColorMode) {
    Settings.put(SCPref.appColorMode, stat)
    this._appColorModeStat = stat
  }
}