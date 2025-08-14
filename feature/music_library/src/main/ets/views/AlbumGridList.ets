import { Album } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp, UserStore } from "@handwer/base"
import { LightUpContainer } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LengthMetrics } from "@kit.ArkUI"
import { generatePageParams_AlbumDetail } from "./AlbumDetail"

const TAG = 'AlbumGridList'

@ReusableV2
@ComponentV2
export struct AlbumGridList {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local gridColumnNum: number = 4

  @Builder PlayList_SingleItem(list: Album, index: number) {
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
      // if (this.modifyPlaylist) {
      //   this.onRemovePlaylist(index)
      // } else {
      //   this.onPlayListItemClicked(index)
      // }
    })
  }

  @Builder MyPlayList() {
    Grid() {
      ForEach(UserStore.userSubAlbum, (list: Album, index) => {
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
    }.width('100%')
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.PARENT_FIRST
    })
    .padding({left: 12, right: 12})
    // .expandSafeArea([SafeAreaType.SYSTEM])
    .columnsTemplate(new Array(this.gridColumnNum).fill('1fr').join(' '))
    // .animation({duration: 300})
    .rowsGap(36).columnsGap(24)
    .clip(false)
    .onAreaChange((_, nw) => {
      this.gridColumnNum = ResponsiveUtil.chooseByWidth([2,4,6])
    })
  }

  build() {
    this.MyPlayList()
  }


  onPushAlbum(album: Album) {
    const params = generatePageParams_AlbumDetail(album)

    this.pageStack.pushPath({
      name: 'AlbumDetail',
      param: params,
    }, true)
  }
}
