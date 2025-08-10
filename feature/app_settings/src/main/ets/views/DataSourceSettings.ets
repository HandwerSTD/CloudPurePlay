import { CloudAPI_Console, User } from "@handwer/api_adapter"
import { UserManager, UserSettings, SCUser } from "@handwer/base"
import { HdsNavDestination, HdsNavDestinationAttribute } from "@kit.UIDesignKit"

@ComponentV2
export struct DataSourceSettings {
  @Local pageOpacity: number = 1
  build() {
    HdsNavDestination() {
    }.backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
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
  .backgroundColor(Color.Transparent)
}