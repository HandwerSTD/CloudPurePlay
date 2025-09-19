import { AbilityConstant, bundleManager, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {
  BreakpointSystem,
  DeviceCollaborationUtils,
  GlobalStore,
  KVStoreUtil, Logger, LogStorage,
  MissionContinueData,
  OuterWantDataModel,
  PlayControl,
  RetryUtil,
  SCPref,
  ServiceInitUtils,
  Settings, SpiderMan, ThemeManager, WindowUtil } from '@handwer/base';
import { DialogHelper } from '@pura/harmony-dialog';
import { url } from '@kit.ArkTS'
import { APIConfigUtils } from '@handwer/api_adapter';
import { SnackBarUtils } from '@handwer/ui_components';
import { HdsSnackBar } from '@kit.UIDesignKit';

const DOMAIN = 0xA0FF;
const TAG = '[MainAbility]'

export default class MainAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // Logger
    Logger.setLogStorage(LogStorage.instance())
    GlobalStore.isDarkMode = (this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    GlobalStore.contextFaker = this.context
    this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE)
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.onHandleMissionContinueWant(want)
    } else {
      this.onHandleWant(want)
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.onHandleMissionContinueWant(want)
    } else {
      this.onHandleWant(want)
    }
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
      jumpPage = 'pages/FirstOpenSubPages/FirstOpenPage'
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
  onWindowStageRestore(windowStage: window.WindowStage): void {
    this.onWindowStageCreate(windowStage)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    GlobalStore.isInForeground = true
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    GlobalStore.isInForeground = false
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    GlobalStore.isDarkMode = (newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  async onContinue(wantParam: Record<string, Object>) {
    wantParam['data'] = await DeviceCollaborationUtils.generateContinueData()
    return AbilityConstant.OnContinueResult.AGREE
  }

  onHandleMissionContinueWant(want: Want) {
    const params = want.parameters
    if (params) {
      const data = params['data'] as MissionContinueData
      // TODO: else
      if (DeviceCollaborationUtils.checkContinueData(data.requestContextHash)) {
        Logger.info(TAG, `check continuation succeeded, applying data`)
        DeviceCollaborationUtils.applyContinuation(data)
        let showedSnack = false
        RetryUtil.retry(5, async () => {
          if (GlobalStore.globalSnack) {
            SnackBarUtils.showMessage(GlobalStore.globalSnack as HdsSnackBar, $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'), $r('app.string.mission_continue_from_device_name', data.deviceName ?? 'Unknown'))
            showedSnack = true
          }
        }, async () => {
          return showedSnack
        })
      } else {
        Logger.info(TAG, `check continuation failed`)
      }
    }
  }
  onHandleWant(want: Want) {
    Logger.debug(`received NewWant`)
    if (want.uri) {
      // load by uri
      const d = url.URL.parseURL(want.uri)
      if (d.protocol === 'cloudpureplay:') {
        if (d.hostname.startsWith('shareConfig')) {
          const res = APIConfigUtils.getConfigFromShareLink(want.uri)
          const api = res[1], config = res[0]
          GlobalStore.outerWant = new OuterWantDataModel('new_config', {
            "apiName": api,
            "apiConfig": config!
          })
        } else if (d.hostname.startsWith('shareSong')) {
          GlobalStore.outerWant = new OuterWantDataModel('share_song', {
            "url": want.uri,
          })
        }
      }
    }
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
      config.cornerRadius = 24
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
    // MusicAPI
    await ServiceInitUtils.init()
  }
}