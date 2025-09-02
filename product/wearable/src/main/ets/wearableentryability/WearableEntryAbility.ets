import { AbilityConstant, bundleManager, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Logger, LogStorage, GlobalStore,
  BreakpointSystem,
  DeviceCollaborationUtils,
  MissionContinueData,
  SCPref,
  ServiceInitUtils,
  Settings,
  SpiderMan,
  ThemeManager,
  WindowUtil,
  KVStoreUtil} from '@handwer/base';
import { DialogHelper } from '@pura/harmony-dialog';

const DOMAIN = 0x0000;
const TAG = 'WearableEntryAbility'

export default class WearableEntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
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
    // if (Settings.get<boolean>(SCPref.notFirstOpen) !== true) {
    //   jumpPage = 'pages/FirstOpenSubPages/FirstOpenPage'
    // }

    windowStage.loadContent(jumpPage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
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

  async onContinue(wantParam: Record<string, Object>) {
    wantParam['data'] = await DeviceCollaborationUtils.generateContinueData()
    return AbilityConstant.OnContinueResult.AGREE
  }

  onHandleMissionContinueWant(want: Want) {
    const params = want.parameters
    if (params) {
      const data = params['data'] as MissionContinueData
      if (DeviceCollaborationUtils.checkContinueData(data.requestContextHash)) {
        DeviceCollaborationUtils.applyContinuation(data)
      }
    }
  }
  onHandleWant(want: Want) {

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
      config.loading_borderRadius = '50%'
      config.cornerRadius = '50%'
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
