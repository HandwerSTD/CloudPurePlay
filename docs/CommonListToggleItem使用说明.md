# CommonListToggleItem 组件使用说明

## 简介

`CommonListToggleItem` 是一个结合了列表项和开关切换功能的复合组件，基于现有的 `CommonListItem` 和 `Toggle` 组件设计。它提供了一个带图标、标题、副标题和切换开关的列表项。

## 组件特性

1. **基础版本** (`CommonListToggleItem`): 基础的切换列表项
2. **发光版本** (`LightedCommonListToggleItem`): 带有发光效果的切换列表项

## 参数说明

### CommonListToggleItem

| 参数名 | 类型 | 是否必需 | 默认值 | 描述 |
|--------|------|----------|--------|------|
| `icon` | Resource \| null | 否 | null | 列表项的图标 |
| `isSymbol` | boolean | 否 | true | 图标是否为系统符号 |
| `title` | ResourceStr | 是 | - | 列表项的主标题 |
| `subtitle` | ResourceStr \| null | 否 | null | 列表项的副标题 |
| `filled` | boolean | 否 | true | 是否填充样式 |
| `highlightBorder` | boolean | 否 | false | 是否显示高亮边框 |
| `fontColor` | ResourceColor | 否 | $r('sys.color.font_on_primary') | 主标题字体颜色 |
| `hintFontColor` | ResourceColor | 否 | $r('sys.color.font_on_secondary') | 副标题字体颜色 |
| `isOn` | boolean | 是 | - | 切换开关的状态 |
| `toggleType` | ToggleType | 否 | ToggleType.Switch | 切换开关的类型 |
| `onToggleChange` | (isOn: boolean) => void | 是 | - | 切换状态改变时的回调函数 |

### LightedCommonListToggleItem

除了上述参数外，`LightedCommonListToggleItem` 还包含发光效果和背景样式。

## 使用示例

### 显示设置页面示例

```ets
// 显示设置页面
@ComponentV2
export struct DisplaySettings {
  @Local showPlayerOnLaunch: boolean = false
  @Local showMusicLibraryInOnlineMusic: boolean = false

  aboutToAppear(): void {
    this.showPlayerOnLaunch = Settings.get<boolean>(SCPref.showPlayerOnLaunch) ?? false
    this.showMusicLibraryInOnlineMusic = Settings.get<boolean>(SCPref.showMusicLibraryInOnlineMusic) ?? false
  }

  build() {
    List({space: 12}) {
      ListItem() {
        LightedCommonListToggleItem({
          icon: $r('sys.symbol.gearshape'),
          title: $r('app.string.show_player_on_launch'),
          subtitle: $r('app.string.show_player_on_launch_desc'),
          isOn: this.showPlayerOnLaunch,
          onToggleChange: (val) => {
            this.showPlayerOnLaunch = val
            Settings.put(SCPref.showPlayerOnLaunch, val)
          }
        })
      }
      ListItem() {
        LightedCommonListToggleItem({
          icon: $r('sys.symbol.gearshape'),
          title: $r('app.string.show_music_library_in_online'),
          subtitle: $r('app.string.show_music_library_in_online_desc'),
          isOn: this.showMusicLibraryInOnlineMusic,
          onToggleChange: (val) => {
            this.showMusicLibraryInOnlineMusic = val
            Settings.put(SCPref.showMusicLibraryInOnlineMusic, val)
          }
        })
      }
    }.padding({left: 12, right: 12})
  }
}
```

### 播放设置页面示例

```ets
// 播放设置页面
@ComponentV2
export struct PlaybackSettings {
  @Local autoPlayOnLaunch: boolean = false

  aboutToAppear(): void {
    this.autoPlayOnLaunch = Settings.get<boolean>(SCPref.autoPlayOnLaunch) ?? false
  }

  build() {
    List({space: 12}) {
      ListItem() {
        LightedCommonListToggleItem({
          icon: $r('sys.symbol.play'),
          title: $r('app.string.auto_play_on_launch'),
          subtitle: $r('app.string.auto_play_on_launch_desc'),
          isOn: this.autoPlayOnLaunch,
          onToggleChange: (val) => {
            this.autoPlayOnLaunch = val
            Settings.put(SCPref.autoPlayOnLaunch, val)
          }
        })
      }
    }.padding({left: 12, right: 12})
  }
}
```

### 基础用法

```ets
CommonListToggleItem({
  icon: $r('sys.symbol.wifi'),
  title: $r('app.string.wifi_enabled'),
  subtitle: $r('app.string.wifi_enabled_desc'),
  isOn: this.wifiEnabled,
  onToggleChange: (val) => {
    this.wifiEnabled = val
    // 处理WiFi开关逻辑
  }
})
```

## 与现有组件的对比

### 之前的实现方式

```ets
@Builder ShowPlayerOnLaunchSwitch() {
  ListItem() {
    LightedCommonListItem({
      title: $r('app.string.show_player_on_launch'),
      subtitle: $r('app.string.show_player_on_launch_desc'),
      trailing: () => {
        this.ShowPlayerOnLaunchSwitchTrailing()
      }
    })
  }
}

@Builder ShowPlayerOnLaunchSwitchTrailing() {
  Toggle({
    isOn: this.showPlayerOnLaunch!!,
    type: ToggleType.Switch
  })
    .onChange((val) => {
      this.showPlayerOnLaunch = val
      Settings.put(SCPref.showPlayerOnLaunch, val)
    })
}
```

### 使用新组件后

```ets
ListItem() {
  LightedCommonListToggleItem({
    icon: $r('sys.symbol.play'),
    title: $r('app.string.auto_play_on_launch'),
    subtitle: $r('app.string.auto_play_on_launch_desc'),
    isOn: this.autoPlayOnLaunch,
    onToggleChange: (val) => {
      this.autoPlayOnLaunch = val
      Settings.put(SCPref.autoPlayOnLaunch, val)
    }
  })
}
```

## 设置项枚举

在项目中，新增的设置项需要添加到 `SCPref` 枚举中：

```ets
export enum SCPref {
  // ... 其他设置项
  
  // 显示设置
  showPlayerOnLaunch,
  showMusicLibraryInOnlineMusic,

  // 播放设置
  autoPlayOnLaunch
}
```

## 优势

1. **代码简洁**: 减少了 Builder 方法的使用，代码更加简洁
2. **复用性强**: 可以在多个地方重复使用，无需重复编写切换逻辑
3. **一致性**: 保持了与 `CommonListItem` 一致的 API 设计
4. **灵活性**: 支持多种切换开关类型和自定义样式
5. **易于维护**: 集中管理切换逻辑，便于后续维护和修改

## 注意事项

1. 确保在使用前正确导入组件：`import { CommonListToggleItem, LightedCommonListToggleItem } from "@handwer/ui_components"`
2. `onToggleChange` 回调函数是必需的，用于处理状态变化
3. 如果需要持久化设置，记得在回调函数中调用相应的存储方法
4. 建议为每个设置项添加相应的字符串资源，支持多语言
