import { Album, InstanceSwitcher, PlayList, PlayListAPIUtils } from "@handwer/api_adapter"
import { GlobalStore, ResponsiveUtil, SCApp, UserManager, UserStore } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightUpContainer, LightUpRoundedButton, LightUpDefaultConfig,
  WithAnimationFAB,
  DialogUtils,
  SnackBarUtils, OverrideLightUpStat,
  LightUpCommonButton,
  LightUpIconTextButton,
  BackButtonUtils,
  Album_PopReturn,
  generatePageParams_AlbumDetail,
  generatePageParams_PlayListDetail,
  PlaylistDetail_PopReturn,
  ImageCoverThumbnail} from "@handwer/ui_components"
import { hdsEffect, HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode,
  HdsSnackBar,
  IconStyleMode } from "@kit.UIDesignKit"
import { curves, IconType, LengthMetrics } from "@kit.ArkUI"
import { MusicLibrarySearchView } from "../views/SearchView"
import { DialogHelper } from "@pura/harmony-dialog"
import { LazyData } from "@pie/lazy-data"

export function genId_MusicLibraryPlaylist(id: string) {
  return 'MusicLibraryPlaylist_'+id
}

@ComponentV2
export struct MainPage {
  @Consumer(SCApp.shouldDisableTab) shouldDisableTab: boolean = false

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Local gridColumnNum: number = 4
  user = UserStore
  snack = new HdsSnackBar(this.getUIContext())

  @Local playlistDataSource: LazyData<PlayList> = new LazyData<PlayList>()

  @Local showAlbum: boolean = false
  @Local showSearchPage: boolean = false
  @Local modifyPlaylist: boolean = false
  @Local fullWidth: number = 0

  get listPadding(): Padding {
    const fac = ResponsiveUtil.chooseByWidth([1, 1.2, 1.5])
    return GlobalStore.isDarkMode ? {left: 12 * fac, right: 12 * fac} : {left: 8 * fac, right: 8 * fac}
  }

  isPlaylistCreated(list: PlayList) {
    return list.userId === this.user.userId
  }

  @Builder PlayList_SingleItem(list: PlayList, index: number) {
    Column() {
      Stack({alignContent: Alignment.BottomEnd}) {
        ImageCoverThumbnail({
          nowPlayingCoverImg: list.coverImgUrl,
          name: list.name
        })
        if (this.modifyPlaylist) {
          SymbolGlyph(this.isPlaylistCreated(list) ? $r('sys.symbol.trash') : $r('sys.symbol.xmark'))
            .margin({right: 12, bottom: 12+20})
            .padding(4)
            .fontColor([$r('sys.color.font_primary')])
            .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
            .borderRadius(24)
            .transition(TransitionEffect.translate({x:-4}).animation({curve: curves.springMotion()}).combine(TransitionEffect.OPACITY.animation({duration: 300})))
        }
      }
    }
    .onClick(() => {
      if (this.modifyPlaylist) {
        this.onRemovePlaylist(index)
      } else {
        this.onPlayListItemClicked(index)
      }
    })
  }

  //-------------------------

  @Builder UserCard() {
    Column() {
      Row() {
        Image(this.user.user.data.profile.avatarUrl)
          .height(48).width(48).aspectRatio(1)
          .borderRadius(32)
        Blank().width(12)
        Column() {
          Text(this.user.user.data.profile.nickname).fontSize(16).fontWeight(FontWeight.Bold)
            .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
          Text($r('app.string.api_switch_from_what', InstanceSwitcher.InstanceTypeName))
            .fontSize(14)
            .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        }.layoutWeight(1).justifyContent(FlexAlign.SpaceAround)
        .height(48)
        .alignItems(HorizontalAlign.Start)
        Row() {
          LightUpIconTextButton({
            icon: this.showAlbum ? $r('sys.symbol.opticaldisc') : $r('sys.symbol.heart_square_stack'),
            title: this.showAlbum ? $r('app.string.Album') : $r('app.string.Playlist'),
            lightUpConfig: LightUpDefaultConfig,
            clickAction: () => {
              this.showAlbum = !this.showAlbum
            }
          })
        }.justifyContent(FlexAlign.End).margin({left: 12})
      }.width('100%').padding(ResponsiveUtil.chooseByWidth([12, 12, 24])).borderRadius(20)
      .backgroundColor($r('app.color.common_card_item_background'))
      .shadow(ShadowStyle.OUTER_FLOATING_SM)
      .margin({top: 24, bottom: 24})
    }.padding({left: 12, right: 12})
    .width(this.fullWidth)
    .onClick(() => {
      UserManager.fetchUserInfo()
    })
  }

  @Builder Album_SingleItem(list: Album, index: number) {
    Column() {
      ImageCoverThumbnail({
        nowPlayingCoverImg: list.picUrl,
        name: list.name
      })
    }
    .onClick(() => {
      if (this.modifyPlaylist) {
        // this.on
      } else {
        // this.onPlayListItemClicked(index)
        this.onPushAlbum(list)
      }
    })
  }

  @Builder MyAlbumList() {
    ListItemGroup({space: ResponsiveUtil.chooseByWidth([24, 36])}) {
      ForEach(UserStore.userSubAlbum, (list: Album, index) => {
        ListItem() {
          LightUpContainer({
            lightUpConfig: {
              lightIntensity: 1,
              lightHeight: 240,
            },
            child: () => {
              this.Album_SingleItem(list, index)
            }
          })
        }
      })
    }//.visibility(!this.showAlbum ? Visibility.None : Visibility.Visible)
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
    .padding(this.listPadding)
  }
  @Builder MyPlaylist() {
    ListItemGroup({space: 36}) {
      LazyForEach(this.playlistDataSource, (list: PlayList, index) => {
        ListItem() {
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
      }, (val: PlayList, index) => `${val.id}_${val.coverImgUrl}_${val.name}_${val.trackCount}_${index}`)
    }//.visibility(this.showAlbum ? Visibility.None : Visibility.Visible)
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
    .padding(this.listPadding)
  }

  @Builder MyContent() {
    List() {
      ForEach((new Array(this.gridColumnNum).fill(0)), (_: number) => {
        ListItem().height($r('sys.float.ohos_id_navigation_bar_height_emphasize'))
      })
      ForEach((new Array(this.gridColumnNum).fill(0)), (_: number, index) => {
        ListItem() {
          if (index === 0) {
            this.UserCard()
          }
        }.clip(false)
      })
      if (this.showAlbum) {
        this.MyAlbumList()
      } else {
        this.MyPlaylist()
      }
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: false})
    .fadingEdge(true, {
      fadingEdgeLength: LengthMetrics.percent(10)
    })
    .lanes(this.gridColumnNum, ResponsiveUtil.chooseByWidth([12, 24]))
    .scrollBar(BarState.Off)
    .clip(false)
    .onAreaChange((_, nw) => {
      this.gridColumnNum = ResponsiveUtil.chooseByWidth([3,4,6])
      this.fullWidth = nw.width.valueOf() as number
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
          this.MyContent()
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
            }]
          }
        },
      }).titleMode(HdsNavigationTitleMode.FREE).mode(NavigationMode.Stack)
      .translate(this.showSearchPage ? {
        y: '15%'
      } : undefined)
      .animation({curve: curves.springMotion(0.6, 0.7)})
    }
    .width('100%').height('100%')
    .foregroundBlurStyle(this.showSearchPage ? BlurStyle.COMPONENT_ULTRA_THIN : undefined, {
      colorMode: ThemeColorMode.DARK,
      scale: 0.5
    })
    .animation({duration: 300})
  }
  @Builder MusicLibrarySearch() {
    Column() {
      if (this.showSearchPage) {
        MusicLibrarySearchView({
          isSearchAlbum: this.showAlbum,
          closeSearch: () => {
            this.showSearchPage = false
          },
          openPlaylist: (playlist) => {
            this.onPushPlaylist(playlist)
          }
        })
          .transition(TransitionEffect.OPACITY.animation({duration: 500}))
      }
    }.width('100%').height('100%')
    .hitTestBehavior(this.showSearchPage ? HitTestMode.Default : HitTestMode.None)
  }

  aboutToAppear(): void {
    this.setData()
    BackButtonUtils.registerBackButton({
      id: 'musicLibrary_showSearch',
      judge: () => {
        return this.showSearchPage
      },
      action: () => {
        this.showSearchPage = false
      }
    })
    BackButtonUtils.registerBackButton({
      id: 'musicLibrary_modifyPlaylist',
      judge: () => {
        return this.modifyPlaylist
      },
      action: () => {
        this.modifyPlaylist = false
      }
    })
  }
  aboutToDisappear(): void {
    BackButtonUtils.unregisterBackButton('musicLibrary_showSearch')
    BackButtonUtils.unregisterBackButton('musicLibrary_modifyPlaylist')
  }

  @Monitor('user.userPlaylists')
  setData() {
    this.playlistDataSource.setData(this.user.userPlaylists)
    this.playlistDataSource.notifyDataReload()
  }
  @Monitor('showSearchPage')
  onShowSearch() {
    this.shouldDisableTab = this.showSearchPage
  }
  @Monitor('modifyPlaylist')
  onShowEdit() {
    this.shouldDisableTab = this.modifyPlaylist
  }
  build() {
    Row() {
      Stack() {
        this.MusicLibraryMainPage()
        this.MusicLibrarySearch()
      }
    }
    .height('100%')
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
      this.setData()
    }

    this.pageStack.pushPath({
      name: 'PlaylistDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }

  onPushAlbum(album: Album) {
    const params = generatePageParams_AlbumDetail(album)
    const handlePop = (val: PopInfo) => {
      const result = val.result as Album_PopReturn
      if (result.removed) {
        const p = this.user.userSubAlbum.findIndex((v) => v.id === album.id)
        if (p !== -1) this.user.userSubAlbum.splice(p, 1)
      }
    }

    this.pageStack.pushPath({
      name: 'AlbumDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }
}
