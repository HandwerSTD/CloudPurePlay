import { SCApp } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute, hdsEffect } from "@kit.UIDesignKit"
import { MusicLibrary, PlaylistDetail } from '@handwer/music_library'

// 参数供参考：
// Grid() {
//             GridItem().height($r('sys.float.ohos_id_navigation_bar_height_emphasize'))
//               .columnStart(0).columnEnd(this.gridColumnNum-1)
//
//             ForEach((new Array(36).fill(0)), () => {
//               GridItem() {
//                 GridCard()
//               }.aspectRatio(1)
//             })
//
//           }.fadingEdge(true, {
//             fadingEdgeLength: LengthMetrics.percent(10)
//           }).edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
//           .padding({left: 12, right: 12})
//           .expandSafeArea([SafeAreaType.SYSTEM])
//           .columnsTemplate(new Array(this.gridColumnNum).fill('1fr').join(' '))
//           .width('100%')
//           .rowsGap(12).columnsGap(12)
//           .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
//             illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
//           }))

@ComponentV2
export struct MainPage {
  @Provider(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Builder pageMap(name: string) {
    if (name === 'MusicLibrary') {
      MusicLibrary()
    } else if (name === 'PlaylistDetail') {
      PlaylistDetail()
    }
  }

  build() {
    Row() {
      Column() {
        Navigation(this.pageStack) {
          MusicLibrary()
            .height('100%')
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