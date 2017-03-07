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

import PackageDescription

let package = Package(
    name: "SwiftEnterpriseDemo",
    targets: [
        Target(name: "DemoAppServer")
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git", majorVersion: 1),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/CircuitBreaker.git", majorVersion: 0, minor: 0),
        .Package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", majorVersion: 0, minor: 0),
        .Package(url: "https://d7d10e9fbcfb7eb9c9085927777fcdca9a323586@github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 0)
])
