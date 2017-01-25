//
//  Controller.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 1/25/17.
//
//

import Foundation
import LoggerAPI
import Kitura
import SwiftyJSON
import Configuration
import SwiftMetrics
import CloudFoundryEnv
import AlertNotifications

public class Controller {
    let router: Router
    let appEnv: AppEnv
    let credentials: ServiceCredentials
    var metricsDict: [String: Any]
    var currentMemoryUser: MemoryUser? = nil
    
    // Location of the cloud config file.
    let cloudConfigFile = "cloud_config.json"
    
    var port: Int {
        get { return appEnv.port }
    }
    
    var url: String {
        get { return appEnv.url }
    }
    
    init() throws {
        // AppEnv configuration.
        self.appEnv = try CloudFoundryEnv.getAppEnv()
        self.metricsDict = [:]
        self.router = Router()
        
        // Credentials for the Alert Notifications SDK.
        let config = try Configuration(withFile: cloudConfigFile)
        guard let alertCredentials = config.getCredentials(forService: "SwiftEnterpriseDemo-Alert"),
            let url = alertCredentials["url"] as? String,
            let name = alertCredentials["name"] as? String,
            let password = alertCredentials["password"] as? String else {
                throw AlertNotificationError.credentialsError("Failed to obtain credentials for alert service.")
        }
        self.credentials = ServiceCredentials(url: url, name: name, password: password)
        
        // SwiftMetrics configuration.
        let sm = try SwiftMetrics()
        let monitoring = sm.monitor()
        monitoring.on(recordCPU)
        monitoring.on(recordMem)
        
        // Router configuration.
        self.router.all("/", middleware: BodyParser())
        self.router.get("/metrics", handler: getMetricsHandler)
        self.router.get("/", middleware: StaticFileServer(path: "./public"))
        self.router.post("/alert", handler: postAlertHandler)
        self.router.delete("/alert", handler: deleteAlertHandler)
        self.router.post("/memory", handler: requestMemoryHandler)
        self.router.post("/cpu", handler: requestCPUHandler)
    }
    
    // Take CPU data and store it in our metrics dictionary.
    func recordCPU(cpu: CPUData) {
        metricsDict["cpuUsedByApplication"] = cpu.percentUsedByApplication
        metricsDict["cpuUsedBySystem"] = cpu.percentUsedBySystem
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
    
    public func getMetricsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let metricsData = try? JSONSerialization.data(withJSONObject: metricsDict, options: []) {
            let _ = response.status(.OK).send(data: metricsData)
        } else {
            let _ = response.status(.internalServerError).send("Could not retrieve metrics data.")
        }
        next()
    }
    
    public func postAlertHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parsedBody = request.body else {
            Log.error("Bad request. Could not process and send alert.")
            let _ = response.send(status: .badRequest)
            next()
            return
        }
        
        switch (parsedBody) {
        case .json(let jsonBody):
            sendAlert(jsonBody, usingCredentials: credentials) {
                alert, err in
                if let alert = alert, let shortId = alert.shortId {
                    let _ = response.status(.OK).send(shortId)
                } else if let err = err {
                    Log.error(err.localizedDescription)
                    let _ = response.status(.internalServerError).send(err.localizedDescription)
                } else {
                    let _ = response.send(status: .internalServerError)
                }
                next()
            }
        default:
            Log.error("No body received in POST request.")
            let _ = response.status(.badRequest).send("No body received in POST request.")
            next()
        }
    }
    
    public func deleteAlertHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parsedBody = request.body else {
            Log.error("Bad request. Could not delete alert.")
            let _ = response.status(.badRequest).send("Bad request. Could not delete alert.")
            next()
            return
        }
        
        switch (parsedBody) {
        case .text(let deleteString):
            deleteAlert(deleteString, usingCredentials: credentials) {
                err in
                if let err = err {
                    Log.error(err.localizedDescription)
                    let _ = response.status(.internalServerError).send(err.localizedDescription)
                } else {
                    let _ = response.send(status: .OK)
                }
                next()
            }
        default:
            Log.error("No string received in DELETE request.")
            let _ = response.status(.badRequest).send("No string received in DELETE request.")
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
        case .text(let memoryString):
            if let memoryAmount = Int(memoryString) {
                currentMemoryUser = nil
                currentMemoryUser = MemoryUser(usingMB: memoryAmount)
                let _ = response.send(status: .OK)
                next()
            } else {
                fallthrough
            }
        default:
            Log.error("Bad value received. Could not utilize memory.")
            let _ = response.status(.badRequest).send("Bad request. Could not utilize memory.")
            next()
        }
    }
    
    public func requestCPUHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let _ = response.send(status: .OK)
        next()
        // Obtain the number of possible cores and spawn a thread on each.
        print("\(ProcessInfo.processInfo.activeProcessorCount)")
        print("Start")
        let workInterval: TimeInterval = -0.6
        let sleepInterval: UInt32 = UInt32(0.4 * 1_000_000)
        let startDate = Date()
        var sleepDate = Date()
        while startDate.timeIntervalSinceNow > -100 {
            if sleepDate.timeIntervalSinceNow < workInterval {
                print("Sleep")
                usleep(sleepInterval)
                sleepDate = Date()
            }
        }
        print("End")
    }
}
