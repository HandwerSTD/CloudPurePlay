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
    return result
  }
}