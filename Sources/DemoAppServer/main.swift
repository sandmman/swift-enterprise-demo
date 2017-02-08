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

import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import SwiftMetricsDash
import SwiftMetrics

// Set logger.
Log.logger = HeliumLogger()

// Create controller (which does basically everything).
let controller = try Controller()

// Activate the Swift Metrics dashboard.
let _ = try SwiftMetricsDash(swiftMetricsInstance: controller.metrics, endpoint: controller.router)

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: controller.port, with: controller.router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
