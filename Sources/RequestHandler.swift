//
//  AlertHandler.swift
//  monitoring-auto-scaling-demo
//
//  Created by Jim Avery on 1/6/17.
//
//

import Foundation
import LoggerAPI
import SwiftyJSON
import AlertNotifications

enum CustomError: Error {
    case RuntimeError(String)
}

func sendAlert(_ alertJSON: JSON, usingCredentials credentials: ServiceCredentials, callback: @escaping (Error?) -> Void) throws {
    let alert = try alertFromJSON(alertJSON)
    do {
        try AlertService.post(alert, usingCredentials: credentials) {
            newAlert, err in
            callback(err)
        }
    }
    catch {
        callback(error)
    }
}

func deleteAlert(_ shortId: String, usingCredentials credentials: ServiceCredentials, callback: @escaping (Error?) -> Void) throws {
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
    builder = builder.setDate(Date()).setStatus(.problem).setSource("Monitoring auto-scaling demo page").setURLs([Alert.URL(description: "Alert Notifications SDK on GitHub.", URL: "https://github.com/IBM-Swift/alert-notification-sdk")])
    return try builder.build()
}
