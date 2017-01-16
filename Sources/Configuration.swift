//
//  Configuration.swift
//  monitoring-auto-scaling-demo
//
//  Created by Jim Avery on 1/6/17.
//
//

import Foundation
import AlertNotifications
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv

public struct Configuration {
    let configurationFile = "cloud_config.json"
    let appEnv: AppEnv
    
    init() throws {
        let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: false)
        
        guard let finalPath = path else {
            Log.warning("Could not find '\(configurationFile)'.")
            appEnv = try CloudFoundryEnv.getAppEnv()
            return
        }
        
        let url = URL(fileURLWithPath: finalPath)
        let configData = try Data(contentsOf: url)
        let configJson = JSON(data: configData)
        appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
        Log.info("Using configuration values from '\(configurationFile)'.")
    }
    
    func getAlertNotificationSDKProps() throws -> ServiceCredentials {
        if let alertCredentials = appEnv.getService(spec: "swift-enterprise-demo-alert")?.credentials {
            if let url = alertCredentials["url"].string,
                let name = alertCredentials["name"].string,
                let password = alertCredentials["password"].string {
                let credentials = ServiceCredentials(url: url, name: name, password: password)
                return credentials
            }
        }
        throw AlertNotificationError.credentialsError("Failed to obtain credentials for alert service.")
    }
    
    func getPort() -> Int {
        return appEnv.port
    }
    
    private static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
        let initialPath = #file
        let fileManager = FileManager.default
        
        // We need to search for the root directory of the package
        // by searching for Package.swift.
        let components = initialPath.characters.split(separator: "/").map(String.init)
        var rootPath = initialPath
        var filePath = ""
        for index in stride(from: components.count-1, through: 0, by: -1) {
            let subArray = components[0...index]
            rootPath = "/" + subArray.joined(separator: "/")
            if fileManager.fileExists(atPath: rootPath + "/Package.swift") {
                filePath = rootPath + "/" + relativePath
                break
            }
        }
        if filePath == "" {
            return nil
        }
        
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        } else if useFallback {
            let currentPath = fileManager.currentDirectoryPath
            filePath = currentPath + relativePath
            if fileManager.fileExists(atPath: filePath) {
                return filePath
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
