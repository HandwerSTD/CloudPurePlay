import { WearablePlayerUI } from '@handwer/wearable_player_ui'

@Entry
@ComponentV2
struct Index {


  build() {
    Column() {
      WearablePlayerUI()
    }.width('100%').height('100%').borderRadius('50%')
  }
}