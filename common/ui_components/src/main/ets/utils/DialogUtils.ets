import { ThemeManager } from "@handwer/base";
import { DialogAction, DialogHelper } from "@pura/harmony-dialog";

export class DialogUtils {
  static showAlertDialog(uiContext: UIContext, title: ResourceStr, msg: ResourceStr, onCancel: () => void, onAccept: () => void) {
    uiContext.showAlertDialog({
      title: title,
      message: msg,
      primaryButton: {
        fontColor: ThemeManager.getBrand(),
        value: $r('sys.string.general_cancel'),
        action: onCancel
      },
      secondaryButton: {
        fontColor: $r('sys.color.warning'),
        value: $r('sys.string.general_confirm'),
        action: onAccept
      }
    })
  }
  static showTextInputDialog(title: ResourceStr, baseText: string, onAccept: (result: string) => void) {
    DialogHelper.showTextInputDialog({
      title: title,
      text: baseText,
      onAction: (action: number, dialogId: string, value: string): void => {
        if (action === DialogAction.SURE) {
          onAccept(value)
        }
      },
      theme: ThemeManager.getTheme()
    })
  }
}