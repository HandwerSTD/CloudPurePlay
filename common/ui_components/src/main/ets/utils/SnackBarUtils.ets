import { HdsSnackBar } from "@kit.UIDesignKit";

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
}