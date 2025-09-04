import { PlayList, Song, Song_INITIAL } from "@handwer/api_adapter"
import { GlobalContext, GlobalStore, PlayListOp, SCApp, SCGlobal, UserStore } from "@handwer/base"
import { SnackBarUtils } from "../../../utils/export"
import { ArcCommonListItem } from "../../../components/CommonListItem"
import { ArcConst } from "../../../constants/WearableConstants"
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from "@kit.ArkUI"

@ComponentV2
export struct WearableAddToPlaylistSheet {
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
    Column() {
      // Title
      Text($r('app.string.add_song_to_list'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 16 })
        .fontColor(Color.White)

      // List
      ArcList() {
        ForEach(this.userPlaylists, (playlist: PlayList) => {
          ArcListItem() {
            ArcCommonListItem({
              icon: $r('sys.symbol.music_note_list'),
              title: playlist.name,
            })
              .onClick(() => {
                this.addToThisPlaylist(playlist)
              })
          }.width(ArcConst.ARC_LIST_W)
        })
      }
      .space(ArcConst.ARC_LIST_SPC)
      .fadingEdge(true)
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding(12)
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
      .catch(() => {
        SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.add_songlist'), $r('app.string.add_song_to_list_failed'), $r('app.string.add_song_to_list_failed_reason'))
      })
  }
}
