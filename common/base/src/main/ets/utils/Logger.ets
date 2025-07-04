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

import { hilog } from '@kit.PerformanceAnalysisKit';


export class LogStorage {

  logInfo: string = ''

  static singleton_: LogStorage;
  static instance() {
    if(!LogStorage.singleton_) {
      LogStorage.singleton_ = new LogStorage();
    };
    return LogStorage.singleton_;
  }
}



class Logger {
  private readonly MAX_LOG_SIZE = 50000;
  private domain: number;
  private prefix: string;
  private format: string = "%{public}s, %{public}s";
  private st?: LogStorage

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }
  setLogStorage(st?: LogStorage) {
    this.st = st
  }
  appendLog(level: string, args: Object[]) {
    if (!this.st) {
      return
    }
    if (this.st.logInfo.length > this.MAX_LOG_SIZE) this.st.logInfo = this.st.logInfo.substring(this.st.logInfo.length/2)
    this.st.logInfo +=
    (`[${level}] `) + ((new Date()).toLocaleString()) + ', ' + args.map((val, index) => {
        return ' '+val.toString()
      }) + '\n\n'
  }

  debug(...args: Object[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
    this.appendLog(`DEBUG`, args)
  }

  info(...args: Object[]): void {
    hilog.info(this.domain, this.prefix, this.format, args);
    this.appendLog(`INFO`, args)
  }

  warn(...args: Object[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
    this.appendLog(`WARN`, args)
  }

  error(...args: Object[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
    this.appendLog(`ERROR`, args)
  }
}

export default new Logger('[QuickieSticker]');
