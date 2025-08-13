import { PlayList, Song, Song_INITIAL } from "@handwer/api_adapter"
import { GlobalContext, GlobalStore, PlayListOp, SCApp, SCGlobal, UserStore } from "@handwer/base"
import { LightUpLinedContainer, LightUpLinedDefaultConfig } from "../../../light_up/exports"
import { SnackBarUtils } from "../../../utils/exports"
import { CommonListItem } from "../../components/CommonListItem"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@hms.hds.hdsBaseComponent"
import { HDS_TITLE_CONFIG_STYLE } from "../../../../../../Index"

@ComponentV2
export struct AddToPlaylistSheet {
  @Consumer(SCApp.showAddToPlaylistSheet) sheet: boolean = false
  @Local userPlaylists: PlayList[] = []
  @Local songInfo: Song = Song_INITIAL

  aboutToAppear(): void {
    this.userPlaylists = UserStore.userPlaylists.filter((val) => {
      return val.userId === UserStore.user.data.profile.userId
    })
    this.songInfo = GlobalContext.getContext().getObject(SCGlobal.addToPlaylistSongData) as Song
  }

  build() {
    HdsNavigation() {
      Column() {
        List() {
          ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
          ForEach(this.userPlaylists, (playlist: PlayList) => {
            ListItem() {
              LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
                CommonListItem({
                  icon: $r('sys.symbol.music_note_list'),
                  title: playlist.name,
                })
                  .onClick(() => {
                    this.addToThisPlaylist(playlist)
                  })
              }
            }
          })
        }.scrollBar(BarState.Off)
      }.padding({left: 12, right: 12})
    }.titleMode(HdsNavigationTitleMode.MINI)
    .titleBar({
      style: HDS_TITLE_CONFIG_STYLE,
      content: {
        title: { mainTitle: $r('app.string.add_song_to_list') }
      }
    })
  }

  addToThisPlaylist(playlist: PlayList) {
    PlayListOp.addSongToPlaylist(playlist.id, this.songInfo)
      .then((res) => {
        if (res) {
          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.add_songlist'), $r('app.string.add_song_to_list_success'))
          this.sheet = false
        } else {
          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.add_songlist'), $r('app.string.add_song_to_list_failed'), $r('app.string.add_song_to_list_failed_reason'))
        }
      })
  }
}