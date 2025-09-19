import { ThemeManager } from "@handwer/base";
import { DialogAction, DialogHelper } from "@pura/harmony-dialog";
import { HeartDialogBuilder, NoHeartDialogBuilder } from "../specialized_ui/views/Dialogs/HeartDialog";
import { KnockShareDialogBuilder } from "../specialized_ui/views/Dialogs/KnockShareDialog";

export class DialogUtils {
  static async showLoadingUntil<T>(task: () => Promise<T>) {
    const id = DialogHelper.showLoadingDialog()
    return await task()
      .finally(() => {
        DialogHelper.closeDialog(id)
      })
  }
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
  static showKnockShareDialog(onWillDisappear: VoidCallback = () => {}) {
    return DialogHelper.showCustomDialog(wrapBuilder(KnockShareDialogBuilder), {
      title: '',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      backCancel: true,
      onWillDisappear: () => {
        onWillDisappear()
      }
    })
  }
  static showHeartDialog1sec(like: boolean) {
    const builder = like ? wrapBuilder(HeartDialogBuilder) : wrapBuilder(NoHeartDialogBuilder)
    const id = DialogHelper.showCustomDialog(builder, {
      title: '',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      backCancel: true,
      onWillDisappear: () => {
      }
    })
    setTimeout(() => {
      if (DialogHelper.isShowing(id)) {
        DialogHelper.closeDialog(id)
      }
    }, 1000)
  }
}

