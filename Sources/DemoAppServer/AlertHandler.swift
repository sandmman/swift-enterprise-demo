/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import LoggerAPI
import SwiftyJSON
import AlertNotifications
import CloudFoundryEnv

enum AlertType {
    case MemoryAlert, CPUAlert
}

func sendAlert(type: AlertType, appEnv: AppEnv, usingCredentials credentials: ServiceCredentials, callback: @escaping (Alert?, Error?) -> Void) {
    do {
        let alert = try buildAlert(type: type, appEnv: appEnv)
        try AlertService.post(alert, usingCredentials: credentials) {
            newAlert, err in
            callback(newAlert, err)
        }
    }
    catch {
        callback(nil, error)
    }
}

func buildAlert(type: AlertType, appEnv: AppEnv) throws -> Alert {
    var appName = "App name not found."
    if let appEnvName = appEnv.name {
        appName = appEnvName
    }
    
    var builder = Alert.Builder()
    if type == .MemoryAlert {
        builder = builder.setSummary("A BlueMix application is using an excessive amount of memory and may have scaled up to another instance as a result.")
    } else {
        builder = builder.setSummary("A BlueMix application is using an excessive amount of CPU and may have scaled up to another instance as a result.")
    }
    builder = builder.setLocation("\(appName)")
    builder = builder.setSeverity(.minor)
    builder = builder.setDate(Date())
    builder = builder.setApplicationsOrServices(["\(appName)"])
    builder = builder.setURLs([Alert.URL(description: "\(appName)", URL: "\(appEnv.url)")])
    // Add details later - exact amount of memory/CPU.
    return try builder.build()
}
