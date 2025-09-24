import { harmonyShare } from "@kit.ShareKit";
import { ApplicationStateChangeCallback, common, Context } from "@kit.AbilityKit";
import { DialogHelper } from "@pura/harmony-dialog";
import { fileIo, fileUri } from "@kit.CoreFileKit";
import { image } from "@kit.ImageKit";
import { ImageUtil } from "@pura/harmony-utils";

export class ShareUtils {
  static startKnockShare(ctx: common.ApplicationContext, onOpenDialog: (onClose: () => void) => string | undefined, onHandleShareTarget: (target: harmonyShare.SharableTarget) => void) {
    // 注册两个监听：knock和statechange
    // 先打开 dialog，dialog关闭时会一同取消监听knock和statechange
    const shareCallback = (target: harmonyShare.SharableTarget) => {
      onHandleShareTarget(target)
    }
    const callback: ApplicationStateChangeCallback = {
      onApplicationForeground() {

      },
      onApplicationBackground() {
        // 注册后台监听，切回后台不再分享，并关闭弹窗
        harmonyShare.off("knockShare", shareCallback)
        harmonyShare.off("gesturesShare", shareCallback)
        if (id) {
          DialogHelper.closeDialog(id)
        }
      }
    }
    const id = onOpenDialog(() => {
      harmonyShare.off("knockShare", shareCallback)
      harmonyShare.off("gesturesShare", shareCallback)
      ctx.off("applicationStateChange", callback)
    })
    // 启动分享，如果分享成功了则交给处理函数，不注销任何监听，可以再次发起分享
    ctx.on("applicationStateChange", callback)
    harmonyShare.on("knockShare", shareCallback)
    harmonyShare.on("gesturesShare", shareCallback)
  }

  static async copyUriAsThumbnail(context: Context, uri: string): Promise<string> {
    // const img = image.createImageSource(uri)
    // return ShareUtils.savePixelMapAsThumbnail(context, await img.createPixelMap())
    const res = fileUri.getUriFromPath(context.tempDir + '/knock_share_thumbnail.jpg')
    await fileIo.copy(uri, res)
    return res
  }
  static async savePixelMapAsThumbnail(context: Context, pixelMap: image.PixelMap): Promise<string> {
    const uri = fileUri.getUriFromPath(context.tempDir + '/knock_share_thumbnail.jpg')
    try {
      // 创建ImagePacker实例
      const imagePacker = image.createImagePacker();

      // 打开目标文件
      const file = fileIo.openSync(uri, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);

      // 配置编码参数
      const options: image.PackingOption = {
        format: 'image/jpeg',
        quality: 80,
      };

      // 异步保存到文件
      return await new Promise((resolve) => {
        imagePacker.packToFile(pixelMap, file.fd, options, (err: BusinessError<void>) => {
          fileIo.closeSync(file);
          if (err) {
            console.error(`Save failed: code=${err.code}, message=${err.message}`);
            resolve('');
          } else {
            console.info('PixelMap saved successfully');
            resolve(uri);
          }
        });
      });
    } catch (error) {
      console.error(`Exception occurred: ${error}`);
      return '';
    }
  }

  // static async savePixelMapAsThumbnail(context: Context, pixelMap: image.PixelMap): Promise<string> {
  //   const uri = fileUri.getUriFromPath(context.tempDir + '/knock_share_thumbnail.jpg')
  //   try {
  //     const data = await ImageUtil.compressedImage(pixelMap, 500, 'image/jpeg')
  //     await FileUtil.writeEasy(uri, data, false)
  //     return uri
  //   } catch (error) {
  //     console.error(`Exception occurred: ${error}`);
  //     return '';
  //   }
  // }
}