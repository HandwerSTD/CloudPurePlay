import { AbilityConstant, bundleManager, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {
  BreakpointSystem,
  GlobalStore,
  KVStoreUtil, Logger, LogStorage, SCPref, Settings, SpiderMan, ThemeManager, WindowUtil } from '@handwer/base';
import { DialogHelper } from '@pura/harmony-dialog';

const DOMAIN = 0xA0FF;
const TAG = '[MainAbility]'

export default class MainAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // Logger
    Logger.setLogStorage(LogStorage.instance())
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // KVStore, must before loadContent
    KVStoreUtil.initDefault(this.context.getApplicationContext())
    // Preferences
    Settings.init()

    let jumpPage = 'pages/Index'
    if (Settings.get<boolean>(SCPref.notFirstOpen) !== true) {
      jumpPage = 'pages/FirstOpenPage'
    }

    windowStage.loadContent(jumpPage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      // app startup
      this.appStartUp(windowStage)
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  async appStartUp(windowStage: window.WindowStage) {
    Logger.debug(TAG, 'app start up')
    // 折叠屏旋转控制
    WindowUtil.registerRotationControl(this.context)
    // Loading 弹窗设置
    DialogHelper.setDefaultConfig((config) => {
      config.uiAbilityContext = this.context;
      config.loading_backgroundColor = $r('sys.color.background_secondary')
      config.loading_fontColor = $r('sys.color.font_primary')
      config.loading_loadColor = $r('sys.color.font_primary')
      config.loading_borderRadius = 24
      config.autoCancel = false
      config.backCancel = false
    })
    // CrashSpider
    SpiderMan.init()
    // Theme
    ThemeManager.setTheme(Settings.get(SCPref.theme) ?? 0)
    // Breakpoint
    BreakpointSystem.instance().init(windowStage)
    // App Version
    let info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    GlobalStore.appVersion = info.versionName + ` (${info.versionCode.toString().substring(5)})`
  }
}