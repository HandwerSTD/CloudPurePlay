/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AbilityConstant, common, ConfigurationConstant, EnvironmentCallback } from '@kit.AbilityKit';
import Logger from './Logger';
import { promptAction } from '@kit.ArkUI';
import { GlobalStore } from '../../../../Index';


/**
 * Light sensor monitoring utility for light/dark theme switching.
 * Monitors ambient light levels and triggers callbacks when low light conditions are detected.
 */
export class AmbientLightUtils {
  private static readonly TAG = 'LightDarkSwitchUtils';
  private static readonly DEFAULT_LOW_LIGHT_THRESHOLD = 20; // Default low light threshold in lux
  private static readonly DEFAULT_SAMPLING_INTERVAL = 2000000000; // 5s
  
  // Light sensor related properties
  private static isListening: boolean = false;
  private static lowLightThreshold: number = AmbientLightUtils.DEFAULT_LOW_LIGHT_THRESHOLD;
  private static onLowLightCallback?: (isLowLight: boolean) => void;
  private static lastLightValue: number = -1;
  private static isInLowLightState: boolean = false;

  /**
   * Initialize and register light sensor listener
   * @param threshold Low light threshold in lux (default: 10)
   * @param callback Callback function to be triggered when low light is switched
   * @param samplingInterval Sampling interval in nanoseconds (default: 200ms)
   */
  static registerLightSensorListener(
    appContext: common.ApplicationContext,
    promptCallback?: (isLowLight: boolean) => void,
    threshold: number = AmbientLightUtils.DEFAULT_LOW_LIGHT_THRESHOLD,
    callback?: (isLowLight: boolean) => void,
    samplingInterval: number = AmbientLightUtils.DEFAULT_SAMPLING_INTERVAL
  ): void {
    if (AmbientLightUtils.isListening) {
      Logger.warn(AmbientLightUtils.TAG, 'Light sensor listener is already registered');
      return;
    }
    if (!callback) {
      callback = (isLowLight) => {
        if (isLowLight !== GlobalStore.isDarkMode) {
          // 仅不匹配时切换
          appContext.setColorMode(isLowLight ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
          promptCallback?.(isLowLight)
        }
      };
    }

    AmbientLightUtils.lowLightThreshold = threshold;
    AmbientLightUtils.onLowLightCallback = callback;

    try {
      // Subscribe to light sensor data
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, (data: sensor.LightResponse) => {
        AmbientLightUtils.handleLightSensorData(data);
      }, { interval: samplingInterval });
      // 注册不了系统深浅色监听，只能监听应用的
      AmbientLightUtils.isListening = true;
      Logger.info(AmbientLightUtils.TAG,
        `Light sensor listener registered with threshold: ${threshold} lux, interval: ${samplingInterval}ns`);
    } catch (error) {
      const businessError = error as BusinessError;
      Logger.error(AmbientLightUtils.TAG,
        `Failed to register light sensor listener: ${businessError.code} - ${businessError.message}`);
    }
  }

  /**
   * Unregister light sensor listener
   */
  static unregisterLightSensorListener(): void {
    if (!AmbientLightUtils.isListening) {
      Logger.warn(AmbientLightUtils.TAG, 'Light sensor listener is not registered');
      return;
    }

    try {
      // Unsubscribe from light sensor data
      sensor.off(sensor.SensorId.AMBIENT_LIGHT);
      
      AmbientLightUtils.isListening = false;
      AmbientLightUtils.onLowLightCallback = undefined;
      AmbientLightUtils.lastLightValue = -1;
      AmbientLightUtils.isInLowLightState = false;
      
      Logger.info(AmbientLightUtils.TAG, 'Light sensor listener unregistered');
    } catch (error) {
      const businessError = error as BusinessError;
      Logger.error(AmbientLightUtils.TAG,
        `Failed to unregister light sensor listener: ${businessError.code} - ${businessError.message}`);
    }
  }

  /**
   * Handle light sensor data and trigger callback when necessary
   * @param data Light sensor response data
   */
  private static handleLightSensorData(data: sensor.LightResponse): void {
    const currentLightValue = data.intensity;

    // Logger.debug(AmbientLightUtils.TAG, `Current light intensity: ${currentLightValue} lux`);

    // Check if we should trigger low light callback
    const isCurrentlyLowLight = currentLightValue <= AmbientLightUtils.lowLightThreshold;

    // Only trigger callback when transitioning from non-low-light to low-light state
    if ((isCurrentlyLowLight && !AmbientLightUtils.isInLowLightState)
      || (!isCurrentlyLowLight && AmbientLightUtils.isInLowLightState)
      || AmbientLightUtils.lastLightValue === -1) {
      AmbientLightUtils.isInLowLightState = isCurrentlyLowLight;
      Logger.info(AmbientLightUtils.TAG,
        `Low light detect: ${isCurrentlyLowLight}, ${currentLightValue} lux (threshold: ${AmbientLightUtils.lowLightThreshold} lux)`);

      let shouldTurnDarkWhenNight = false
      if (AmbientLightUtils.lastLightValue === -1) {
        // check time
        const hr = (new Date()).getHours()
        // 晚8点到早7点
        if ((20 <= hr && hr <= 24) || (0 <= hr && hr <= 6)) {
          shouldTurnDarkWhenNight = true;
          Logger.debug(AmbientLightUtils.TAG, `forced dark mode because of night`)
        }
      }

      if (AmbientLightUtils.onLowLightCallback) {
        try {
          AmbientLightUtils.onLowLightCallback(isCurrentlyLowLight || shouldTurnDarkWhenNight);
        } catch (error) {
          Logger.error(AmbientLightUtils.TAG, `Error in low light callback: ${error}`);
        }
      }
    }
    AmbientLightUtils.lastLightValue = currentLightValue;
  }

  /**
   * Check if light sensor listener is currently active
   * @returns true if listening, false otherwise
   */
  static isListenerActive(): boolean {
    return AmbientLightUtils.isListening;
  }

  /**
   * Get current light level (last recorded value)
   * @returns Current light intensity in lux, or -1 if no data available
   */
  static getCurrentLightLevel(): number {
    return AmbientLightUtils.lastLightValue;
  }

  /**
   * Get current low light threshold
   * @returns Current threshold value in lux
   */
  static getLowLightThreshold(): number {
    return AmbientLightUtils.lowLightThreshold;
  }

  /**
   * Update low light threshold
   * @param threshold New threshold value in lux
   */
  static updateLowLightThreshold(threshold: number): void {
    AmbientLightUtils.lowLightThreshold = threshold;
    Logger.info(AmbientLightUtils.TAG, `Low light threshold updated to: ${threshold} lux`);
  }

  /**
   * Check if currently in low light state
   * @returns true if in low light state, false otherwise
   */
  static isInLowLight(): boolean {
    return AmbientLightUtils.isInLowLightState;
  }

  /**
   * Update the callback function
   * @param callback New callback function
   */
  static updateCallback(callback?: () => void): void {
    AmbientLightUtils.onLowLightCallback = callback;
    Logger.info(AmbientLightUtils.TAG, 'Low light callback updated');
  }
}