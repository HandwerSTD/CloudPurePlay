import effectKit from "@ohos.effectKit";
import { ColorMetrics, componentSnapshot } from "@kit.ArkUI";

export class AlbumCoverColorUtils {
  static async getCoverColor(id?: string) {
    return await AlbumCoverColorUtils.getColorFromPixelMap(
      componentSnapshot.getSync(id ?? 'coverFakerUnder')
    )
  }
  static async getColorFromPixelMap(pixelMap: PixelMap) {
    const kit = await effectKit.createColorPicker(pixelMap)
    const res = kit.getTopProportionColors(7)
    let result: ColorMetrics[] = []
    res.forEach((val) => {
      if (val) {
        result.push(ColorMetrics.rgba(val.red, val.green, val.blue, val.alpha))
      }
    })
    return result.map((val): string => AlbumCoverColorUtils.RGBA2HEX(val))
      .map(val => AlbumCoverColorUtils.SaturateColor(val))
  }
  static RGBA2HEX(color: ColorMetrics) {
    const to16 = (num: number): string => {
      if (num.toString(16).length === 1) return '0'+num.toString(16)
      return num.toString(16)
    }
    return '#' +  to16(color.red) + to16(color.green) + to16(color.blue)
  }
  public static SaturateColor(color: string): string {
    // 将 HEX 转 RGB
    const hexToRgb = (hex: string): [number, number, number] => {
      let cleanHex: string = hex.replace(/^#/, "");
      if (cleanHex.length === 3) {
        cleanHex = cleanHex.split("").map(ch => ch + ch).join("");
      }
      const bigint: number = parseInt(cleanHex, 16);
      const r: number = (bigint >> 16) & 255;
      const g: number = (bigint >> 8) & 255;
      const b: number = bigint & 255;
      return [r, g, b];
    };

    // RGB 转 HEX
    const rgbToHex = (r: number, g: number, b: number): string => {
      const toHex = (n: number): string =>
      n.toString(16).padStart(2, "0");
      return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
    };

    // RGB 转 HSL
    const rgbToHsl = (r: number, g: number, b: number): [number, number, number] => {
      r /= 255;
      g /= 255;
      b /= 255;
      const max: number = Math.max(r, g, b);
      const min: number = Math.min(r, g, b);
      let h: number = 0;
      let s: number = 0;
      const l: number = (max + min) / 2;

      if (max !== min) {
        const d: number = max - min;
        s = d / (1 - Math.abs(2 * l - 1));
        switch (max) {
          case r:
            h = (g - b) / d + (g < b ? 6 : 0);
            break;
          case g:
            h = (b - r) / d + 2;
            break;
          case b:
            h = (r - g) / d + 4;
            break;
        }
        h *= 60;
      }
      return [h, s, l];
    };

    // HSL 转 RGB
    const hslToRgb = (h: number, s: number, l: number): [number, number, number] => {
      const c: number = (1 - Math.abs(2 * l - 1)) * s;
      const x: number = c * (1 - Math.abs((h / 60) % 2 - 1));
      const m: number = l - c / 2;
      let r: number = 0;
      let g: number = 0;
      let b: number = 0;

      if (0 <= h && h < 60) { r = c; g = x; b = 0; }
      else if (60 <= h && h < 120) { r = x; g = c; b = 0; }
      else if (120 <= h && h < 180) { r = 0; g = c; b = x; }
      else if (180 <= h && h < 240) { r = 0; g = x; b = c; }
      else if (240 <= h && h < 300) { r = x; g = 0; b = c; }
      else { r = c; g = 0; b = x; }

      return [
        Math.round((r + m) * 255),
        Math.round((g + m) * 255),
        Math.round((b + m) * 255)
      ];
    };

    // 1. HEX -> RGB
    const GeneratedDestructArray_1 = hexToRgb(color);
    const r = GeneratedDestructArray_1[0];
    const g = GeneratedDestructArray_1[1];
    const b = GeneratedDestructArray_1[2];

    // 2. RGB -> HSL
    const GeneratedDestructArray_2 = rgbToHsl(r, g, b);
    const h = GeneratedDestructArray_2[0];
    const s = GeneratedDestructArray_2[1];
    const l = GeneratedDestructArray_2[2];

    // 3. 调整饱和度 (提高20%)
    const factor: number = 1.2;
    const newS: number = Math.min(1, s * factor);

    // 4. HSL -> RGB
    const GeneratedDestructArray_3 = hslToRgb(h, newS, l);
    const nr = GeneratedDestructArray_3[0];
    const ng = GeneratedDestructArray_3[1];
    const nb = GeneratedDestructArray_3[2];

    // 5. RGB -> HEX
    return rgbToHex(nr, ng, nb);
  }
}