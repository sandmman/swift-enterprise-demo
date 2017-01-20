import PackageDescription

let package = Package(
    name: "SwiftEnterpriseDemo",
    targets: [
        Target(name: "Configuration", dependencies: []),
        Target(name: "SwiftMetricsDash", dependencies: []),
        Target(name: "DemoAppServer", dependencies: ["Configuration", "SwiftMetricsDash"])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 2, minor: 0),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/CircuitBreaker.git", majorVersion: 0, minor: 0),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/SwiftMetrics.git", majorVersion: 0),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 0)
])
