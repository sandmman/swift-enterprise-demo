import PackageDescription

let package = Package(
    name: "swift-enterprise-demo",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 1, minor: 8),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 0)
])
