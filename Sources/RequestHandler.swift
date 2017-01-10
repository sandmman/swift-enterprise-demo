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

func sendAlert(_ alertJSON: JSON, usingCredentials credentials: ServiceCredentials) throws {
    let alert = try alertFromJSON(alertJSON)
    try AlertService.post(alert, usingCredentials: credentials) {
        newAlert, err in
        if let err = err {
            Log.error(err.localizedDescription)
        }
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
    if let severity = alertDict["severity"] as? String {
        builder = builder.setSeverity(getSeverity(severity))
    }
    builder = builder.setDate(Date()).setStatus(.problem).setSource("Monitoring auto-scaling demo page").setURLs([Alert.URL(description: "Alert Notifications SDK on GitHub.", URL: "https://github.com/IBM-Swift/alert-notification-sdk")])
    return try builder.build()
}

func getSeverity(_ sevString: String) -> Alert.Severity {
    switch sevString.lowercased() {
    case "fatal": return .fatal
    case "critical": return .critical
    case "major": return .major
    case "minor": return .minor
    case "warning": return .warning
    case "indeterminate": return .indeterminate
    case "clear": return .clear
    default: return .indeterminate
    }
}
