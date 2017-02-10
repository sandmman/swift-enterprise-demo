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
import LoggerAPI
import Kitura
import SwiftyJSON
import Configuration
import SwiftMetrics
import SwiftMetricsBluemix
import CloudFoundryEnv
import AlertNotifications

public class Controller {
    let config: Configuration
    let router: Router
    let credentials: ServiceCredentials
    
    // Metrics stuff.
    var metrics: SwiftMetrics
    var monitor: SwiftMonitor
    var bluemixMetrics: AutoScalar
    var metricsDict: [String: Any]
    var currentMemoryUser: MemoryUser? = nil
    var cpuUser: CPUUser
    
    // Current delay on JSON response.
    var JSONDelayTime: UInt32
    
    // Location of the cloud config file.
    let cloudConfigFile = "cloud_config.json"
    
    var port: Int {
        get { return config.getPort() }
    }
    
    var url: String {
        get { return config.getURL() }
    }
    
    init() throws {
        // AppEnv configuration.
        self.config = try Configuration(withFile: cloudConfigFile)
        self.metricsDict = [:]
        self.router = Router()
        self.cpuUser = CPUUser()
        
        // Credentials for the Alert Notifications SDK.
        guard let alertCredentials = config.getCredentials(forService: "SwiftEnterpriseDemo-Alert"),
            let url = alertCredentials["url"] as? String,
            let name = alertCredentials["name"] as? String,
            let password = alertCredentials["password"] as? String else {
                throw AlertNotificationError.credentialsError("Failed to obtain credentials for alert service.")
        }
        self.credentials = ServiceCredentials(url: url, name: name, password: password)
        
        // SwiftMetrics configuration.
        self.metrics = try SwiftMetrics()
        self.monitor = self.metrics.monitor()
        self.bluemixMetrics = AutoScalar(swiftMetricsInstance: self.metrics)
        //self.monitor.on(recordCPU)
        //self.monitor.on(recordMem)
        
        // Demo variables.
        self.JSONDelayTime = 0
        
        // Router configuration.
        self.router.all("/", middleware: BodyParser())
        self.router.get("/", middleware: StaticFileServer(path: "./public"))
        self.router.get("/initData", handler: getInitDataHandler)
        self.router.get("/metrics", handler: getMetricsHandler)
        self.router.post("/memory", handler: requestMemoryHandler)
        self.router.post("/cpu", handler: requestCPUHandler)
        self.router.post("/responseTime", handler: responseTimeHandler)
        self.router.get("/requestJSON", handler: requestJSONHandler)
    }
    
    // Take CPU data and store it in our metrics dictionary.
    func recordCPU(cpu: CPUData) {
        metricsDict["cpuUsedByApplication"] = cpu.percentUsedByApplication * 100
        metricsDict["cpuUsedBySystem"] = cpu.percentUsedBySystem * 100
    }
    
    // Take memory data and store it in our metrics dictionary.
    func recordMem(mem: MemData) {
        metricsDict["totalRAMOnSystem"] = mem.totalRAMOnSystem
        metricsDict["totalRAMUsed"] = mem.totalRAMUsed
        metricsDict["totalRAMFree"] = mem.totalRAMFree
        metricsDict["applicationAddressSpaceSize"] = mem.applicationAddressSpaceSize
        metricsDict["applicationPrivateSize"] = mem.applicationPrivateSize
        metricsDict["applicationRAMUsed"] = mem.applicationRAMUsed
    }
    
    public func getInitDataHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        var initDict: [String: Any] = [:]
        initDict["monitoringURL"] = "/swiftdash"
        let appData = self.config.getAppEnv()
        if appData.isLocal == false, let moreAppData = appData.getApp(), let appName = appData.name {
            initDict["monitoringURL"] = "https://console.ng.bluemix.net/monitoring/index?dashboard=console.dashboard.page.appmonitoring1&nav=false&ace_config=%7B%22spaceGuid%22%3A%22\(moreAppData.spaceId)%22%2C%22appGuid%22%3A%22\(moreAppData.id)%22%2C%22bluemixUIVersion%22%3A%22Atlas%22%2C%22idealHeight%22%3A571%2C%22theme%22%3A%22bx--global-light-ui%22%2C%22appName%22%3A%22\(appName)%22%2C%22appRoutes%22%3A%22\(moreAppData.uris[0])%22%7D&bluemixNav=true"
        }
        if let initData = try? JSONSerialization.data(withJSONObject: initDict, options: []) {
            let _ = response.status(.OK).send(data: initData)
            next()
        } else {
            let _ = response.status(.internalServerError).send("Could not retrieve application data.")
            next()
        }
    }
    
    public func getMetricsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let metricsData = try? JSONSerialization.data(withJSONObject: metricsDict, options: []) {
            let _ = response.status(.OK).send(data: metricsData)
            next()
        } else {
            let _ = response.status(.internalServerError).send("Could not retrieve metrics data.")
            next()
        }
    }
    
    public func requestMemoryHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parsedBody = request.body else {
            Log.error("Bad request. Could not utilize memory.")
            let _ = response.status(.badRequest).send("Bad request. Could not utilize memory.")
            next()
            return
        }
        
        switch (parsedBody) {
        case .json(let memObject):
            guard memObject.type == .number else {
                fallthrough
            }
            
            if let memoryAmount = memObject.object as? Int {
                requestMemory(inMB: memoryAmount, response: response, next: next)
            } else if let memoryNSAmount = memObject.object as? NSNumber {
                let memoryAmount = Int(memoryNSAmount)
                requestMemory(inMB: memoryAmount, response: response, next: next)
            } else {
                fallthrough
            }
        default:
            Log.error("Bad value received. Could not utilize memory.")
            let _ = response.status(.badRequest).send("Bad request. Could not utilize memory.")
            next()
        }
    }
    
    public func requestMemory(inMB memoryAmount: Int, response: RouterResponse, next: @escaping () -> Void) {
        self.currentMemoryUser = nil
        
        guard memoryAmount > 0 else {
            let _ = response.send(status: .OK)
            next()
            return
        }
        
        self.currentMemoryUser = MemoryUser(usingMB: memoryAmount)
        guard memoryAmount > 100 else {
            let _ = response.send(status: .OK)
            next()
            return
        }
        
        sendAlert(type: .MemoryAlert, appEnv: self.config.getAppEnv(), usingCredentials: self.credentials) {
            alert, err in
            if let err = err {
                Log.error("Could not send alert: \(err)")
            } else {
                Log.info("Alert sent.")
            }
            let _ = response.send(status: .OK)
            next()
        }
    }
    
    public func requestCPUHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parsedBody = request.body else {
            Log.error("Bad request. Could not utilize CPU.")
            let _ = response.status(.badRequest).send("Bad request. Could not utilize CPU.")
            next()
            return
        }
        
        switch (parsedBody) {
        case .json(let cpuObject):
            guard cpuObject.type == .number else {
                fallthrough
            }
            
            if let cpuPercent = cpuObject.object as? Double {
                self.cpuUser.utilizeCPU(cpuPercent: cpuPercent)
                let _ = response.send(status: .OK)
                next()
            } else if let cpuNSPercent = cpuObject.object as? NSNumber {
                let cpuPercent = Double(cpuNSPercent)
                self.cpuUser.utilizeCPU(cpuPercent: cpuPercent)
                let _ = response.send(status: .OK)
                next()
            } else {
                fallthrough
            }
        default:
            Log.error("Bad value received. Could not utilize CPU.")
            let _ = response.status(.badRequest).send("Bad request. Could not utilize CPU.")
            next()
        }
    }
    
    public func responseTimeHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parsedBody = request.body else {
            Log.error("Bad request. Could not change delay time.")
            let _ = response.status(.badRequest).send("Bad request. Could not change delay time.")
            next()
            return
        }
        
        switch (parsedBody) {
        case .json(let responseTimeObject):
            guard responseTimeObject.type == .number else {
                fallthrough
            }
            
            if let responseTime = responseTimeObject.object as? UInt32 {
                self.JSONDelayTime = responseTime
                let _ = response.send(status: .OK)
                next()
            } else if let NSResponseTime = responseTimeObject.object as? NSNumber {
                let responseTime = UInt32(NSResponseTime)
                self.JSONDelayTime = responseTime
                let _ = response.send(status: .OK)
                next()
            } else {
                fallthrough
            }
        default:
            Log.error("Bad value received. Could not change delay time.")
            let _ = response.status(.badRequest).send("Bad request. Could not change delay time.")
            next()
        }
    }
    
    public func requestJSONHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        usleep(self.JSONDelayTime)
        let responseDict = ["delay": Int(self.JSONDelayTime)]
        if let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: []) {
            let _ = response.status(.OK).send(data: responseData)
            next()
        } else {
            let _ = response.status(.internalServerError).send("Could not retrieve response data.")
            next()
        }
    }
}
