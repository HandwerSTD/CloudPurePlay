import { PlayQueue } from "@handwer/api_adapter"
import { GlobalStore, PlayQueueStore } from "@handwer/base"

@ComponentV2
export struct PlayQueueView {
  pq = PlayQueueStore

  build() {
    // 白嫖一个 title 而已
    Navigation() {
      Column() {
        List({space: 12}) {
          ForEach(this.pq.queue, (item: PlayQueue) => {
            ListItem() {
              Row() {
                Text(item.song.name)
              }
            }
          })
          ListItem().height(GlobalStore.wd.bottom)
        }
      }
    }
    .margin({top: 12}) // Navigation 默认避让
    .title($r('app.string.play_queue'))
    .titleMode(NavigationTitleMode.Mini)
  }
}

@Builder
export function PlayQueueViewBuilder() {
  PlayQueueView()
}
