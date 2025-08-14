import { InstanceSwitcher, PlayList, PlayListAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp, UserManager, UserStore } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightUpContainer, LightUpRoundedButton, LightUpDefaultConfig,
  WithAnimationFAB,
  DialogUtils,
  SnackBarUtils} from "@handwer/ui_components"
import { hdsEffect, HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode,
  HdsSnackBar,
  IconStyleMode } from "@kit.UIDesignKit"
import { curves, IconType, LengthMetrics } from "@kit.ArkUI"
import { generatePageParams_PlayListDetail, PlaylistDetail_PopReturn } from "../views/PlaylistDetail"
import { MusicLibrarySearchView } from "../views/SearchView"
import { DialogHelper } from "@pura/harmony-dialog"

export function genId_MusicLibraryPlaylist(id: string) {
  return 'MusicLibraryPlaylist_'+id
}

@ComponentV2
export struct MainPage {
  @Consumer(SCApp.exploreSheet) exploreSheet: boolean = false
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false
  @Local gridColumnNum: number = 4
  @Local pageOpacity: number = 1
  user = UserStore
  snack = new HdsSnackBar(this.getUIContext())

  @Local showSearchPage: boolean = false
  @Local modifyPlaylist: boolean = false

  isPlaylistCreated(list: PlayList) {
    return list.userId === this.user.userId
  }

  @Builder PlayList_SingleItem(list: PlayList, index: number) {
    Column() {
      Stack({alignContent: Alignment.BottomEnd}) {
        Image(list.coverImgUrl).borderRadius(12)
        // .margin({left:12, right: 12, top: 12})
          .draggable(false)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
          .clickEffect({
            level: ClickEffectLevel.HEAVY
          })
        if (this.modifyPlaylist) {
          SymbolGlyph(this.isPlaylistCreated(list) ? $r('sys.symbol.xmark') : $r('sys.symbol.heart_square_stack_fill'))
            .margin({right: 12, bottom: 12})
            .padding(4)
            .fontColor([$r('sys.color.font_primary')])
            .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
            .borderRadius(24)
            .transition(TransitionEffect.translate({x:-4}).animation({curve: curves.springMotion()}).combine(TransitionEffect.OPACITY.animation({duration: 300})))
        }
      }
        Text(list.name)
          .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(12).fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
    }
    .onClick(() => {
      if (this.modifyPlaylist) {
        this.onRemovePlaylist(index)
      } else {
        this.onPlayListItemClicked(index)
      }
    })//.borderRadius(12).clip(true)
    // .backgroundColor($r('app.color.common_card_item_background'))
    // .shadow(ShadowStyle.OUTER_DEFAULT_SM)
  }

  //-------------------------

  @Builder UserCard() {
    Row() {
      Image(this.user.user.data.profile.avatarUrl)
        .height(64).width(64).aspectRatio(1)
        .borderRadius(32)
      Blank().width(12)
      Column() {
        Text(this.user.user.data.profile.nickname).fontSize(20).fontWeight(FontWeight.Bold)
        Text($r('app.string.api_switch_from_what', InstanceSwitcher.InstanceTypeName))
      }.layoutWeight(1).height(64).justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Start)
    }.width('100%').padding(ResponsiveUtil.chooseByWidth([12, 12, 24])).borderRadius(20)
    .backgroundColor($r('app.color.common_card_item_background'))
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
  }

  @Builder MyPlayList() {
    ForEach(this.user.userPlaylists, (list: PlayList, index) => {
      GridItem() {
        LightUpContainer({
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 240,
          },
          child: () => {
            this.PlayList_SingleItem(list, index)
          }
        })
      }
    })
  }

  @Builder AddButton() {
    if (this.modifyPlaylist) {
      Column() {
        LightUpContainer({
          lightUpConfig: LightUpDefaultConfig
        }) {
          WithAnimationFAB({
            icon: $r('sys.symbol.plus'),
            clickAction: () => {
              DialogUtils.showTextInputDialog($r('app.string.create_new_playlist'), '', (res) => {
                this.onCreateNewPlaylist(res)
              })
            }
          })
        }
      }.margin({right: 24, bottom: 24})
    }
  }

  @Builder MusicLibraryMainPage() {
    Column() {
      HdsNavigation() {
        Stack({alignContent: Alignment.BottomEnd}) {
          Grid() {
            GridItem().height($r('sys.float.ohos_id_navigation_bar_height_emphasize'))
              .columnStart(0).columnEnd(this.gridColumnNum-1)
            GridItem() {
              this.UserCard()
            }
            .columnStart(0).columnEnd(this.gridColumnNum-1)
            this.MyPlayList()
          }.width('100%')
          .fadingEdge(true, {
            fadingEdgeLength: LengthMetrics.percent(10)
          }).edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
          .padding({left: 12, right: 12})
          // .expandSafeArea([SafeAreaType.SYSTEM])
          .columnsTemplate(new Array(this.gridColumnNum).fill('1fr').join(' '))
          // .animation({duration: 300})
          .rowsGap(36).columnsGap(24)
          .clip(false)
          .onAreaChange((_, nw) => {
            this.gridColumnNum = ResponsiveUtil.chooseByWidth([2,4,6])
          })
          this.AddButton()
        }.width('100%').height('100%')
      }.width('100%').height('100%').titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.My_Music_Library'),
          },
          menu: {
            value: [{
              content: {
                icon: $r('sys.symbol.magnifyingglass'),
                type: IconStyleMode.NORMAL,
                action: () => {
                  this.showSearchPage = !this.showSearchPage
                }
              },
            },{
              content: {
                icon: this.modifyPlaylist ? $r('sys.symbol.square_and_pencil_fill') : $r('sys.symbol.square_and_pencil'),
                type: IconStyleMode.NORMAL,
                action: () => {
                  this.modifyPlaylist = !this.modifyPlaylist
                }
              },
            },{
              content: {
                icon: $r('sys.symbol.gearshape'),
                type: IconStyleMode.NORMAL,
                action: () => {
                  this.settingsSheet = !this.settingsSheet
                }
              },
            }]
          }
        },
      }).titleMode(HdsNavigationTitleMode.FREE).mode(NavigationMode.Stack)
    }
    .width('100%').height('100%')
    .foregroundEffect({
      radius: this.showSearchPage ? 128 : 0
    })
    .animation({duration: 300})
    .translate(this.showSearchPage ? {
      y: '15%'
    } : undefined)
    .animation({curve: curves.springMotion(0.6, 0.7)})
  }
  @Builder MusicLibrarySearch() {
    if (this.showSearchPage) {
      Column() {
        MusicLibrarySearchView({
          closeSearch: () => {
            this.showSearchPage = false
          },
          openPlaylist: (playlist) => {
            this.onPushPlaylist(playlist)
          }
        })
      }.width('100%').height('100%')
      .transition(TransitionEffect.OPACITY.animation({duration: 500}))
    }
  }

  build() {
    NavDestination() {
      Row() {
        Stack() {
          this.MusicLibraryMainPage()
          this.MusicLibrarySearch()
        }
      }
      .height('100%')
    }.hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .onBackPressed(() => {
      if (this.modifyPlaylist) {
        this.modifyPlaylist = false;
        return true;
      }
      if (this.showSearchPage) {
        this.showSearchPage = false;
        return true;
      }
      this.exploreSheet = false;
      return true;
    })
    .opacity(this.pageOpacity)
    .animation({duration: ResponsiveUtil.chooseByWidth([300, 200, 200])})
  }

  onPlayListItemClicked(index: number) {
    this.onPushPlaylist(this.user.userPlaylists[index])
  }

  onCreateNewPlaylist(res: string) {
    const id = DialogHelper.showLoadingDialog()
    PlayListAPIUtils.createPlayList(res, false)
      .then((res): Promise<void> | undefined => {
        if (res) {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.notepad_badge_plus'),
            $r('app.string.create_new_playlist_success'));
          return UserManager.fetchUserPlaylists();
        } else {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.notepad_badge_plus'),
            $r('app.string.create_new_playlist_failed'));
          return
        }
      })
      .catch(() => {
        SnackBarUtils.showMessage(this.snack, $r('sys.symbol.notepad_badge_plus'),
          $r('app.string.create_new_playlist_failed'));
        return
      })
      .finally(() => {
        DialogHelper.closeDialog(id)
        this.modifyPlaylist = false
      })
  }

  onRemovePlaylist(index: number) {
    const play = this.user.userPlaylists[index]

    const remove = () => {
      const id = DialogHelper.showLoadingDialog()
      PlayListAPIUtils.deletePlayList(play.id)
        .then((res) => {
          if (res) {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'),
              $r('app.string.remove_list_success'));
            this.user.userPlaylists.splice(index, 1)
          } else {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'),
              $r('app.string.remove_list_failed'));
          }
        })
        .catch(() => {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'),
            $r('app.string.remove_list_failed'));
        })
        .finally(() => {
          DialogHelper.closeDialog(id)
        })
    }
    const unsub = () => {
      const id = DialogHelper.showLoadingDialog()
      PlayListAPIUtils.subscribePlayList(play.id, 2)
        .then((res) => {
          if (res) {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
              $r('app.string.unsubscribe_success'));
            this.user.userPlaylists.splice(index, 1)
          } else {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
              $r('app.string.unsubscribe_failed'));
          }
        })
        .catch(() => {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
            $r('app.string.unsubscribe_failed'));
        })
        .finally(() => {
          DialogHelper.closeDialog(id)
        })
    }

    if (this.isPlaylistCreated(play)) {
      DialogUtils.showAlertDialog(
        this.getUIContext(),
        $r('app.string.remove_list'), $r('app.string.remove_list_alert_content'), () => {},
        () => {
          remove()
        })
    } else {
      DialogUtils.showAlertDialog(
        this.getUIContext(),
        $r('app.string.unsubscribe'), $r('app.string.unsubscribe_alert_content'), () => {},
        () => {
          unsub()
        })
    }
  }

  onPushPlaylist(playlist: PlayList) {
    const params = generatePageParams_PlayListDetail(playlist)
    const handlePop = (val: PopInfo) => {
      const result = val.result as PlaylistDetail_PopReturn
      if (result.removed) {
        const p = this.user.userPlaylists.findIndex((v) => v.id === playlist.id)
        if (p !== -1) this.user.userPlaylists.splice(p, 1)
      }
    }

    this.pageStack.pushPath({
      name: 'PlaylistDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }
}
