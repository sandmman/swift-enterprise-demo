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

func sendAlert(type: AutoScalingPolicy.MetricType, appEnv: AppEnv, usingCredentials credentials: ServiceCredentials, callback: @escaping (Alert?, Error?) -> Void) {
    do {
        let alert = try buildAlert(type: type, appEnv: appEnv)
        try AlertService.post(alert, usingCredentials: credentials, callback: callback)
    }
    catch {
        callback(nil, error)
    }
}

func buildAlert(type: AutoScalingPolicy.MetricType, appEnv: AppEnv) throws -> Alert {
    var appName = "App name not found."
    if let appEnvName = appEnv.name {
        appName = appEnvName
    }
    
    var builder = Alert.Builder()
    switch (type) {
    case .Memory:
        builder = builder.setSummary("A BlueMix application is using an excessive amount of memory and may have scaled up to another instance as a result.")
        break
    case .ResponseTime:
        builder = builder.setSummary("A BlueMix application is suffering from unusually long response times and may have scaled up to another instance as a result.")
        break
    case .Throughput:
        builder = builder.setSummary("A BlueMix application is witnessing an excessive amount of throughput and may have scaled up to another instance as a result.")
        break
    }
    builder = builder.setLocation("\(appName)")
    builder = builder.setSeverity(.minor)
    builder = builder.setDate(Date())
    builder = builder.setApplicationsOrServices(["\(appName)"])
    builder = builder.setURLs([Alert.URL(description: "\(appName)", URL: "\(appEnv.url)")])
    // Add details later - exact amount of memory/CPU.
    return try builder.build()
}

func deleteAlert(shortId: String, usingCredentials credentials: ServiceCredentials, callback: @escaping (Error?) -> Void) {
    do {
        try AlertService.delete(shortId: shortId, usingCredentials: credentials, callback: callback)
    }
    catch {
        callback(error)
    }
}
