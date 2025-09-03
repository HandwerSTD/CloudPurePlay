@ComponentV2
export struct WearableMusicActionPanel {
  @Event onSearchClick: () => void
  @Event onEditClick: () => void
  @Event onAddClick: () => void
  @Param showEditMode: boolean = false
  @Param showAddButton: boolean = false

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_primary')])
      }
      .backgroundColor($r('app.color.common_card_item_background'))
      .width(36)
      .height(36)
      .onClick(() => {
        this.onSearchClick()
      })
    }
  }
}
