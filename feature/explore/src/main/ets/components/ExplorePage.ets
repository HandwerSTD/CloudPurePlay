import { Album, PlayList } from "@handwer/api_adapter"
import { UserStore, ResponsiveUtil, SCApp } from "@handwer/base"
import { LightUpContainer, HDS_TITLE_CONFIG_STYLE, generatePageParams_AlbumDetail,
  Album_PopReturn,
  BackButtonUtils} from "@handwer/ui_components"
import { hdsEffect, HdsNavigation, IconStyleMode, HdsNavigationTitleMode, HdsSnackBar, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { LengthMetrics, curves } from "@kit.ArkUI"
import { LazyData } from "@pie/lazy-data"
import { ExploreSearchView } from "../views/SearchView"

@ComponentV2
export struct ExplorePage {
  @Consumer(SCApp.shouldDisableTab) shouldDisableTab: boolean = false

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false
  @Local gridColumnNum: number = 4
  user = UserStore
  snack = new HdsSnackBar(this.getUIContext())

  @Local playlistDataSource: LazyData<PlayList> = new LazyData<PlayList>()

  @Local showAlbum: boolean = false
  @Local showSearchPage: boolean = false
  @Local modifyPlaylist: boolean = false
  @Local fullWidth: number = 0

  @Builder Album_SingleItem(list: Album, index: number) {
    Column() {
      Stack({alignContent: Alignment.BottomEnd}) {
        Image(list.picUrl).borderRadius(12)
        // .margin({left:12, right: 12, top: 12})
          .draggable(false)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
          .clickEffect({
            level: ClickEffectLevel.HEAVY
          })
        // if (this.modifyPlaylist) {
        //   SymbolGlyph(this.isPlaylistCreated(list) ? $r('sys.symbol.xmark') : $r('sys.symbol.heart_square_stack_fill'))
        //     .margin({right: 12, bottom: 12})
        //     .padding(4)
        //     .fontColor([$r('sys.color.font_primary')])
        //     .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        //     .borderRadius(24)
        //     .transition(TransitionEffect.translate({x:-4}).animation({curve: curves.springMotion()}).combine(TransitionEffect.OPACITY.animation({duration: 300})))
        // }
      }
      Text(list.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
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
    ListItemGroup({space: 36}) {
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
    .padding({left: 12, right: 12})
  }

  @Builder MyContent() {
    List() {
      ForEach((new Array(this.gridColumnNum).fill(0)), (_: number) => {
        ListItem().height($r('sys.float.ohos_id_navigation_bar_height_emphasize'))
      })
      // ForEach((new Array(this.gridColumnNum).fill(0)), (_: number, index) => {
      //   ListItem() {
      //   }
      // })
      this.MyAlbumList()
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
    .fadingEdge(true, {
      fadingEdgeLength: LengthMetrics.percent(10)
    })
    .lanes(this.gridColumnNum, 24)
    .clip(false)
    .onAreaChange((_, nw) => {
      this.gridColumnNum = ResponsiveUtil.chooseByWidth([2,4,6])
      this.fullWidth = nw.width.valueOf() as number
    })
  }
  @Builder Search() {
    Column() {
      if (this.showSearchPage) {
        ExploreSearchView({
          isSearchAlbum: this.showAlbum,
          closeSearch: () => {
            this.showSearchPage = false
          },
          openPlaylist: (playlist) => {
            // this.onPushPlaylist(playlist)
          }
        })
          .transition(TransitionEffect.OPACITY.animation({duration: 500}))
      }
    }.width('100%').height('100%')
    .hitTestBehavior(this.showSearchPage ? HitTestMode.Default : HitTestMode.None)
  }
  @Builder ExploreMainPage() {
    Column() {
      HdsNavigation() {
        Stack({alignContent: Alignment.BottomEnd}) {
          this.MyContent()
        }.width('100%').height('100%')
      }.width('100%').height('100%').titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.Explore'),
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
            }]
          }
        },
      }).titleMode(HdsNavigationTitleMode.FREE).mode(NavigationMode.Stack)
    }
    .width('100%').height('100%')
    .translate(this.showSearchPage ? {
      y: '15%'
    } : undefined)
    .animation({curve: curves.springMotion(0.6, 0.7)})
    .foregroundEffect({
      radius: this.showSearchPage ? 128 : 0
    })
    .animation({duration: 300})
  }

  aboutToAppear(): void {
    BackButtonUtils.registerBackButton({
      id: 'explore_showSearch',
      judge: () => {
        return this.showSearchPage
      },
      action: () => {
        this.showSearchPage = false
      }
    })
  }
  aboutToDisappear(): void {
    BackButtonUtils.unregisterBackButton('explore_showSearch')
  }

  build() {
    Stack() {
      this.ExploreMainPage()
      this.Search()
    }
  }

  @Monitor('showSearchPage')
  onShowSearch() {
    this.shouldDisableTab = this.showSearchPage
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