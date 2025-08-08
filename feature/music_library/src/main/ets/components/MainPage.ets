import { InstanceSwitcher, PlayList } from "@handwer/api_adapter"
import { ResponsiveUtil, UserStore } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightUpContainer } from "@handwer/ui_components"
import { hdsEffect, HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from "@kit.UIDesignKit"
import { LengthMetrics } from "@kit.ArkUI"

@ComponentV2
export struct MainPage {
  @Local gridColumnNum: number = 4
  user = UserStore

  @Builder PlayList_SingleItem(list: PlayList) {
    Column() {
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
      Text(list.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }//.borderRadius(12).clip(true)
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
    ForEach(this.user.userPlaylists, (list: PlayList) => {
      GridItem() {
        LightUpContainer({
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 240,
          },
          child: () => {
            this.PlayList_SingleItem(list)
          }
        })
      }
    })
  }

  build() {
    Row() {
      Column() {
        HdsNavigation() {
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
        }.width('100%').height('100%').titleBar({
          style: HDS_TITLE_CONFIG_STYLE,
          content: {
            title: {
              mainTitle: $r('app.string.My_Music_Library'),
            }
          }
        }).titleMode(HdsNavigationTitleMode.FREE).mode(NavigationMode.Stack)
      }
      .width('100%').height('100%')
    }
    .height('100%')
  }
}
