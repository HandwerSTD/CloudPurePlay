import effectKit from "@ohos.effectKit";
import { ColorMetrics, componentSnapshot } from "@kit.ArkUI";

export class AlbumCoverColorUtils {
  static async getCoverColor() {
    return await AlbumCoverColorUtils.getColorFromPixelMap(
      componentSnapshot.getSync('coverFakerUnder')
    )
  }
  static async getColorFromPixelMap(pixelMap: PixelMap) {
    const kit = await effectKit.createColorPicker(pixelMap)
    const res = kit.getTopProportionColors(3)
    let result: ColorMetrics[] = []
    res.forEach((val) => {
      if (val) {
        result.push(ColorMetrics.rgba(val.red, val.green, val.blue, val.alpha))
      }
    })
    return result.map((val): string => AlbumCoverColorUtils.RGBA2HEX(val))
  }
  static RGBA2HEX(color: ColorMetrics) {
    const to16 = (num: number): string => {
      if (num.toString(16).length === 1) return '0'+num.toString(16)
      return num.toString(16)
    }

    return '#' +  to16(color.red) + to16(color.green) + to16(color.blue)
  }
}