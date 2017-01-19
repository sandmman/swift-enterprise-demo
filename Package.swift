import PackageDescription

let package = Package(
    name: "swift-enterprise-demo",
    targets: [
        Target(name: "CloudFoundryConfiguration", dependencies: []),
        Target(name: "SwiftMetrics", dependencies: []),
        Target(name: "SwiftMetricsKitura", dependencies: ["SwiftMetrics"]),
        Target(name: "swift-enterprise-demo", dependencies: ["CloudFoundryConfiguration", "SwiftMetrics", "SwiftMetricsKitura"])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/RuntimeTools/omr-agentcore.git", majorVersion: 3),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 2, minor: 0),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 0)
])
