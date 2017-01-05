import PackageDescription

let package = Package(
    name: "monitoring-auto-scaling-demo",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 4)
])
