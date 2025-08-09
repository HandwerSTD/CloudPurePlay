import { PlayList, PlayList_INITIAL } from "@handwer/api_adapter";
import { ResponsiveUtil, SCApp } from "@handwer/base";
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute, HdsNavDestinationTitleMode } from "@kit.UIDesignKit";
import { genId_MusicLibraryPlaylist } from "../components/MusicLibrary_MainPage";

@ComponentV2
export struct PlaylistDetail {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local playListInfo: PlayList = PlayList_INITIAL

  @Builder TopArea() {
    Column({space: 24}) {
      Image(this.playListInfo.coverImgUrl)
        .width(ResponsiveUtil.chooseByWidth<Dimension>(['100%', '50%'])).aspectRatio(1)
      Text(this.playListInfo.name)
        .fontWeight(FontWeight.Bold).fontSize(24)
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        this.TopArea()
      }.height('100%')
    }.onReady((context) => {
      this.playListInfo = (context.pathInfo.param as Record<string, Object>)['playListInfo'] as PlayList
    })
    .visualEffect(new hdsEffect.HdsEffectBuilder().shaderEffect({
      effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
      animation: {
        duration: 5000,
        iterations: -1
      }
    }).buildEffect())
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }
}

export function generatePageParams_PlayListDetail(playList: PlayList) {
  const params: Record<string, Object> = {}
  params['playListInfo'] = playList
  return params
}