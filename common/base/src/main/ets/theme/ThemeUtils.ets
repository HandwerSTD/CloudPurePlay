import { CustomColors, CustomTheme, ThemeControl } from '@kit.ArkUI'

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


@ObservedV2
export class ThemeManager {
  static singleton_: ThemeManager;
  @Trace appTheme: CustomTheme = gAppTheme
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
  static setTheme(index: number) {
    let st = ThemeManager.getSingleton()
    st.appTheme = new AppTheme({
      brand: themeColors[index]
    })
    ThemeControl.setDefaultTheme(st.appTheme)
    st.nowUsedThemeIndex = index
    // SettingsUtil.ThemeID = index
  }
}