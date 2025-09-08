import { harmonyShare } from "@kit.ShareKit";
import { ApplicationStateChangeCallback, common } from "@kit.AbilityKit";
import { DialogHelper } from "@pura/harmony-dialog";

export class ShareUtils {
  static startKnockShare(ctx: common.ApplicationContext, onOpenDialog: (onClose: () => void) => string, onHandleShareTarget: (target: harmonyShare.SharableTarget) => void) {
    // 注册两个监听：knock和statechange
    // 先打开 dialog，dialog关闭时会一同取消监听knock和statechange
    const callback: ApplicationStateChangeCallback = {
      onApplicationForeground() {

      },
      onApplicationBackground() {
        // 注册后台监听，切回后台不再分享，并关闭弹窗
        harmonyShare.off("knockShare")
        harmonyShare.off("gesturesShare")
        DialogHelper.closeDialog(id)
      }
    }
    const id = onOpenDialog(() => {
      harmonyShare.off("knockShare")
      harmonyShare.off("gesturesShare")
      ctx.off("applicationStateChange", callback)
    })
    // 启动分享，如果分享成功了则交给处理函数，不注销任何监听，可以再次发起分享
    ctx.on("applicationStateChange", callback)
    harmonyShare.on("knockShare", (target) => {
      onHandleShareTarget(target)
    })
    harmonyShare.on("gesturesShare", (target) => {
      onHandleShareTarget(target)
    })
  }
}