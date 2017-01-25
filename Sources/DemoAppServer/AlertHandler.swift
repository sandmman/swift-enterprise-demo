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

enum CustomError: Error {
    case RuntimeError(String)
}

func sendAlert(_ alertJSON: JSON, usingCredentials credentials: ServiceCredentials, callback: @escaping (Alert?, Error?) -> Void) {
    do {
        let alert = try alertFromJSON(alertJSON)
        try AlertService.post(alert, usingCredentials: credentials) {
            newAlert, err in
            callback(newAlert, err)
        }
    }
    catch {
        callback(nil, error)
    }
}

func deleteAlert(_ shortId: String, usingCredentials credentials: ServiceCredentials, callback: @escaping (Error?) -> Void) {
    do {
        try AlertService.delete(shortId: shortId, usingCredentials: credentials) {
            err in
            callback(err)
        }
    }
    catch {
        callback(error)
    }
}

func alertFromJSON(_ alertJSON: JSON) throws -> Alert {
    guard alertJSON.type == .dictionary, let alertDict = alertJSON.object as? [String: Any] else {
        throw CustomError.RuntimeError("Malformed alert received from test page.")
    }
    var builder = Alert.Builder()
    if let summary = alertDict["summary"] as? String {
        builder = builder.setSummary(summary)
    }
    if let location = alertDict["location"] as? String {
        builder = builder.setLocation(location)
    }
    if let sevValue = alertDict["severity"] as? Int, let severity = Alert.Severity(rawValue: sevValue) {
        builder = builder.setSeverity(severity)
    }
    builder = builder.setDate(Date()).setStatus(.problem).setSource("Swift enterprise demo page").setURLs([Alert.URL(description: "Alert Notifications SDK on GitHub.", URL: "https://github.com/IBM-Swift/alert-notification-sdk")])
    return try builder.build()
}
