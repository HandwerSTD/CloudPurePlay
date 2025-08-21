import { ResponsiveUtil, SCApp } from "@handwer/base"
import { AlbumDetail, MusicLibrary, PlaylistDetail } from '@handwer/music_library'
import { HdsActionBar, ActionBarButton, ActionBarStyle } from "@kit.UIDesignKit"
import { ColorMetrics, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { LightUpRoundedButton,LightUpDefaultConfig,OverrideLightUpStat,BackButtonUtils } from "@handwer/ui_components"


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

  @Local pageOpacity: number = 1
  @Local showFloatingTab: boolean = true
  @Local isTabExpand: boolean = false
  @Local currentTabIndex: number = 1
  tabController: TabsController = new TabsController()

  @Local primaryWidth: number = 0

  showTabTimeoutHandler?: number

  @Builder TopAreaActionButton_ActionBar_PrimaryButton() {
    LightUpRoundedButton({
      lightUpConfig: LightUpDefaultConfig,
      icon: $r('sys.symbol.discover'),
      customBgColor: $r('sys.color.icon_fourth'),
      clickAction: () => {
        this.isTabExpand = !this.isTabExpand
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
  }
  @Builder ActionButton_ActionBar() {
    Row() {
      HdsActionBar({
        isExpand: this.isTabExpand!!,
        primaryButtonBuilder: () => {
          this.TopAreaActionButton_ActionBar_PrimaryButton()
        },
        primaryButtonBuilderWidth: LengthMetrics.vp(this.primaryWidth),
        endButtons: [
          new ActionBarButton({
            baseIcon: $r('sys.symbol.cloud_and_stars'),
            width: LengthMetrics.vp(40),
            backgroundColor: this.currentTabIndex === 0 ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: this.currentTabIndex === 0 ?
              new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            onClick: () => {
              this.tabController.changeIndex(0)
            }
          }),

          new ActionBarButton({
            baseIcon: $r('sys.symbol.storagebox'),
            backgroundColor: this.currentTabIndex === 1 ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: this.currentTabIndex === 1 ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            width: LengthMetrics.vp(40),
            onClick: () => {
              this.tabController.changeIndex(1)
            }
          }),
        ],
        actionBarStyle: new ActionBarStyle({
          backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,

        })
      })
        .hitTestBehavior(this.isTabExpand ? HitTestMode.Default : HitTestMode.Transparent)
    }.hitTestBehavior(this.isTabExpand ? HitTestMode.Default : HitTestMode.Transparent)
    .margin({bottom: 12, left: 12})
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  build() {
    NavDestination() {
      Stack({alignContent: Alignment.BottomStart}) {
        Tabs({index: $$this.currentTabIndex, controller: this.tabController}) {
          TabContent() {

          }
          TabContent() {
            MusicLibrary()
          }
        }.height('100%').barHeight(0).edgeEffect(EdgeEffect.None)
        .scrollable(!this.shouldDisableTab)
        if (this.showFloatingTab && !this.shouldDisableTab) {
          this.ActionButton_ActionBar()
        }
      }.width('100%').height('100%')
      .onTouch((event) => {
        if (event.type === TouchType.Down) {
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
}