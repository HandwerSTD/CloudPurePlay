import { GlobalStore, ResponsiveUtil, SCApp, SCPref, Settings } from "@handwer/base"
import { HdsActionBar, ActionBarButton, ActionBarStyle } from "@kit.UIDesignKit"
import { ColorMetrics, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { LightUpRoundedButton,LightUpDefaultConfig,OverrideLightUpStat,BackButtonUtils,
  AlbumDetail,
  PlaylistDetail } from "@handwer/ui_components"
import { MusicLibrary } from "@handwer/music_library"
import { ExplorePage } from "./ExplorePage"
import { AllAlbums } from "./ExploreSubViews/AllAlbums"


@ComponentV2
export struct MainPage {
  @Provider(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.pageStack.pushPathByName('Shell', [], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'Shell') {
      MainPage_Shell()
    } else if (name === 'PlaylistDetail') {
      PlaylistDetail()
    } else if (name === 'AlbumDetail') {
      AlbumDetail()
    } else if (name === 'AllAlbums') {
      AllAlbums()
    }
  }

  build() {
    Row() {
      Column() {
        Navigation(this.pageStack) {
          // empty
        }.navDestination(this.pageMap)
        .mode(NavigationMode.Stack)
        .hideTitleBar(true)
        .height('100%')
      }
      .width('100%').height('100%')
    }
    .height('100%')
  }
}

@Builder
export function ExplorePageBuilder() {
  MainPage()
}

@ComponentV2

struct MainPage_Shell {
  @Provider(SCApp.shouldDisableTab) shouldDisableTab: boolean = false
  @Consumer(SCApp.exploreSheet) exploreSheet: boolean = false
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false

  @Local pageOpacity: number = 1
  @Local showFloatingTab: boolean = true
  @Local isTabExpand: boolean = false
  @Local currentTabIndex: number = 0
  tabController: TabsController = new TabsController()
  defaultTabIndex: number = 0

  @Local primaryWidth: number = 0

  gs = GlobalStore

  showTabTimeoutHandler?: number

  shouldTabItemLight(index: number) {
    return this.currentTabIndex === index && !this.settingsSheet
  }

  @Builder TopAreaActionButton_ActionBar_PrimaryButton() {
    LightUpRoundedButton({
      lightUpConfig: LightUpDefaultConfig,
      icon: $r('sys.symbol.discover'),
      customBgColor: $r('sys.color.icon_fourth'),
      clickAction: () => {
        this.isTabExpand = !this.isTabExpand
        this.showTab()
      },
      customFontSize: 24,
      customPadding: 12,
      overrideLightUpStat: this.isTabExpand ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.NO_OVERRIDE,
      customFontColor: this.isTabExpand ? [Color.Black] : [Color.White, Color.White]
    })
      .borderRadius(999)
      .shadow(ShadowStyle.OUTER_FLOATING_SM)
      .onAreaChange((_, val) => {
        this.primaryWidth = val.width.valueOf() as number
      })
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
  }
  @Local actionBtns: ActionBarButton[] = [
    new ActionBarButton({
      baseIcon: $r('sys.symbol.cloud_and_stars'),
      width: LengthMetrics.vp(40),
      backgroundColor: this.shouldTabItemLight(0) ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
      baseIconSymbolGlyphModifier: this.shouldTabItemLight(0) ?
        new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
      onClick: () => {
        this.tabController.changeIndex(0)
      }
    }),

    new ActionBarButton({
      baseIcon: $r('sys.symbol.storagebox'),
      backgroundColor: this.shouldTabItemLight(1) ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
      baseIconSymbolGlyphModifier: this.shouldTabItemLight(1) ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
      width: LengthMetrics.vp(40),
      onClick: () => {
        this.tabController.changeIndex(1)
      }
    }),

    new ActionBarButton({
      baseIcon: $r('sys.symbol.gearshape'),
      backgroundColor: this.settingsSheet ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
      baseIconSymbolGlyphModifier: this.settingsSheet ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
      width: LengthMetrics.vp(40),
      onClick: () => {
        this.settingsSheet = true
      }
    })
  ]
  @Builder ActionButton_ActionBar() {
    Row() {
      HdsActionBar({
        isExpand: this.isTabExpand!!,
        primaryButtonBuilder: () => {
          this.TopAreaActionButton_ActionBar_PrimaryButton()
        },
        primaryButtonBuilderWidth: LengthMetrics.vp(this.primaryWidth),
        startButtons: !this.gs.pref.tabRightHand ? undefined: this.actionBtns,
        endButtons: this.gs.pref.tabRightHand ? undefined: this.actionBtns,
        actionBarStyle: new ActionBarStyle({
          backgroundBlurStyle: BlurStyle.COMPONENT_THIN,
        })
      })
        .hitTestBehavior(this.isTabExpand ? HitTestMode.Default : HitTestMode.Transparent)
    }.hitTestBehavior(this.isTabExpand ? HitTestMode.Default : HitTestMode.Transparent)
    .margin({bottom: 12, left: 24, right: 24})
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  build() {
    NavDestination() {
      Stack({alignContent: this.gs.pref.tabRightHand ? Alignment.BottomEnd : Alignment.BottomStart}) {
        Tabs({controller: this.tabController, index: this.defaultTabIndex}) {
          TabContent() {
            ExplorePage()
          }
          TabContent() {
            MusicLibrary()
          }
        }.height('100%').barHeight(0).edgeEffect(EdgeEffect.None)
        .scrollable(!this.shouldDisableTab)
        .onAnimationStart((_, target) => {
          this.currentTabIndex = target
        })
        if (this.showFloatingTab && !this.shouldDisableTab) {
          this.ActionButton_ActionBar()
        }
      }.width('100%').height('100%')
      .onTouch((event) => {
        if (event.type === TouchType.Down) {
          this.showTab()
        }
      })
    }.hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .onBackPressed(() => {
      for (const p of BackButtonUtils.backButtonFuncs) {
        if (p.judge()) {
          p.action();
          return true;
        }
      }
      this.exploreSheet = false;
      return true;
    })
    .opacity(this.pageOpacity)
    .animation({duration: ResponsiveUtil.chooseByWidth([300, 200, 200])})
  }

  aboutToAppear(): void {
    const showMusicLibrary = Settings.get<boolean>(SCPref.showMusicLibraryInOnlineMusic) ?? false
    if (showMusicLibrary) {
      this.tabController.changeIndex(1)
      this.currentTabIndex = 1
      this.defaultTabIndex = 1
    }
  }

  showTab() {
    this.showFloatingTab = true;
    if (this.showTabTimeoutHandler) {
      clearTimeout(this.showTabTimeoutHandler)
    }
    this.showTabTimeoutHandler = setTimeout(() => {
      this.showFloatingTab = false
      this.isTabExpand = false
      this.showTabTimeoutHandler = undefined
    }, 3000)
  }
}