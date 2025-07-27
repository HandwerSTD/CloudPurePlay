export class UIComponentUtils {
  static getTodayIcon(): ResourceStr {
    return UIComponentUtils.getCalendarIconByDay(new Date().getDate())
  }
  static getCalendarIconByDay(day: number) {
    if (day < 1 || day > 31) return $r('sys.symbol.calendar')
    // 使用 switch-case 根据 day 的所有可能情况，选择出正确的图标 sys.symbol.calendar_xx_a
    switch (day) {
      case 1:
        return $r('sys.symbol.calendar_01_a')
      case 2:
        return $r('sys.symbol.calendar_02_a')
      case 3:
        return $r('sys.symbol.calendar_03_a')
      case 4:
        return $r('sys.symbol.calendar_04_a')
      case 5:
        return $r('sys.symbol.calendar_05_a')
      case 6:
        return $r('sys.symbol.calendar_06_a')
      case 7:
        return $r('sys.symbol.calendar_07_a')
      case 8:
        return $r('sys.symbol.calendar_08_a')
      case 9:
        return $r('sys.symbol.calendar_09_a')
      case 10:
        return $r('sys.symbol.calendar_10_a')
      case 11:
        return $r('sys.symbol.calendar_11_a')
      case 12:
        return $r('sys.symbol.calendar_12_a')
      case 13:
        return $r('sys.symbol.calendar_13_a')
      case 14:
        return $r('sys.symbol.calendar_14_a')
      case 15:
        return $r('sys.symbol.calendar_15_a')
      case 16:
        return $r('sys.symbol.calendar_16_a')
      case 17:
        return $r('sys.symbol.calendar_17_a')
      case 18:
        return $r('sys.symbol.calendar_18_a')
      case 19:
        return $r('sys.symbol.calendar_19_a')
      case 20:
        return $r('sys.symbol.calendar_20_a')
      case 21:
        return $r('sys.symbol.calendar_21_a')
      case 22:
        return $r('sys.symbol.calendar_22_a')
      case 23:
        return $r('sys.symbol.calendar_23_a')
      case 24:
        return $r('sys.symbol.calendar_24_a')
      case 25:
        return $r('sys.symbol.calendar_25_a')
      case 26:
        return $r('sys.symbol.calendar_26_a')
      case 27:
        return $r('sys.symbol.calendar_27_a')
      case 28:
        return $r('sys.symbol.calendar_28_a')
      case 29:
        return $r('sys.symbol.calendar_29_a')
      case 30:
        return $r('sys.symbol.calendar_30_a')
      case 31:
        return $r('sys.symbol.calendar_31_a')
      default:
        return $r('sys.symbol.calendar')
    }
  }
}