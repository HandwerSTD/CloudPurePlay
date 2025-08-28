import { HdsSnackBar } from "@kit.UIDesignKit";

export class SnackBarUtils {
  static showMessage(snackbar: HdsSnackBar, icon: ResourceStr, message: ResourceStr, sub_msg?: ResourceStr, duration?: number) {
    snackbar.show({
      icon: icon
    }, {
      title: message,
      content: sub_msg
    }, {
    }, {
      backgroundBlurStyle: BlurStyle.COMPONENT_REGULAR,
      duration: duration ?? 3000,
      pressBackCallback: () => {
        snackbar.dismiss()
      }
    })
  }
}