import { promptAction } from "@kit.ArkUI";

export class SnackBarUtils {
  static showMessage(snackbar: Object, icon: ResourceStr, message: ResourceStr, sub_msg?: ResourceStr, duration?: number) {
    promptAction.openToast({
      message: message
    })
  }
}
