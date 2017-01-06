import PackageDescription

let package = Package(
    name: "monitoring-auto-scaling-demo",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 1, minor: 8),
        .Package(url: "https://github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 1)
])
