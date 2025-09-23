import { HdsSnackBar, SnackBarOperationType } from "@kit.UIDesignKit";

interface SnackBarOperation {
  title: ResourceStr
  action: () => void
}

interface SnackBarMessageOptions {
  icon: ResourceStr,
  message: ResourceStr,
  sub_msg?: ResourceStr,
  duration?: number,
  onBackPress?: () => void
}

export class SnackBarUtils {
  static showMessage(snackbar: Object | HdsSnackBar, icon: ResourceStr, message: ResourceStr, sub_msg?: ResourceStr, duration?: number, onBackPress?: () => void) {
    (snackbar as HdsSnackBar).show({
      icon: icon
    }, {
      title: message,
      content: sub_msg
    }, {
    }, {
      backgroundBlurStyle: BlurStyle.COMPONENT_REGULAR,
      duration: duration ?? 3000,
      pressBackCallback: () => {
        if (onBackPress) {
          onBackPress();
        }
        (snackbar as HdsSnackBar).dismiss()
      }
    })
  }
  static async showMessageWithAction(snackbar: Object | HdsSnackBar, options: SnackBarMessageOptions, operation: SnackBarOperation) {
    return new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve()
      }, options.duration ?? 3000);
      (snackbar as HdsSnackBar).show({
        icon: options.icon
      }, {
        title: options.message,
        content: options.sub_msg,
      }, {
        operationType: SnackBarOperationType.TEXT_ONLY,
        content: operation.title,
        onContentClick: () => {
          operation.action();
          (snackbar as HdsSnackBar).dismiss()
          resolve()
        },
      }, {
        backgroundBlurStyle: BlurStyle.COMPONENT_REGULAR,
        duration: options.duration ?? 3000,
        pressBackCallback: () => {
          if (options.onBackPress) {
            options.onBackPress();
          }
          (snackbar as HdsSnackBar).dismiss()
          resolve()
        }
      })
      // TODO: resolve
    })
  }
}