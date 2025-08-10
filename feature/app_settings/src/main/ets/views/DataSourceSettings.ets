import { CloudAPI_Console, User } from "@handwer/api_adapter"
import { UserManager, UserSettings, SCUser } from "@handwer/base"

@ComponentV2
export struct DataSourceSettings {
  build() {
    CloudAPI_Source()
  }
}

@Builder
export function CloudAPI_Source() {
  NavDestination() {
    CloudAPI_Console({
      LoginInfoSetter: (user, cookie) => {
        UserManager.setUserInfo(user as User)
        UserSettings.put(SCUser.user, user)
        UserSettings.put(SCUser.cookie, cookie)
        UserManager.fetchAllUserData()
      }
    })
  }.title('CloudAPI')
  .backgroundColor($r('app.color.ui_sheet_bg_col'))
  .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
}