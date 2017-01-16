import Foundation
import PackageDescription

var tokenString = ""
if let envToken = ProcessInfo.processInfo.environment["ALERT_TOKEN"] {
    tokenString = "\(envToken)@"
}

let package = Package(
    name: "swift-enterprise-demo",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 1, minor: 8),
        .Package(url: "https://\(tokenString)github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 0)
])
