import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import SwiftyJSON
import CloudFoundryConfiguration
import AlertNotifications
import SwiftMetrics
import SwiftMetricsKitura

// Set logger.
Log.logger = HeliumLogger()

// Acquire service credentials from the config file.
let config = try Configuration(withFile: "cloud_config.json")
guard let alertCredentials = config.getCredentials(forService: "swift-enterprise-demo-alert"),
    let url = alertCredentails["url"] as? String,
    let name = alertCredentials["name"] as? String,
    let password = alertCredentials["password"] as? String,
    let credentials = ServiceCredentials(url: url, name: name, password: password) else {
        throw AlertNotificationError.credentialsError("Failed to obtain credentials for alert service.")
}

// System monitoring through SwiftMetrics.
let sm = try SwiftMetrics()
let monitoring = sm.monitor()

// Monitoring dictionary used to send data to the client.
var metricsDict: [String: Any] = [:]

// Process the CPU.
monitoring.on({ (cpu: CPUData) in
    metricsDict["cpuUsedByApplication"] = cpu.percentUsedByApplication
    metricsDict["cpuUsedBySystem"] = cpu.percentUsedBySystem
})

// Process the memory.
monitoring.on({ (mem: MemData) in
    metricsDict["totalRAMOnSystem"] = mem.totalRAMOnSystem
    metricsDict["totalRAMUsed"] = mem.totalRAMUsed
    metricsDict["totalRAMFree"] = mem.totalRAMFree
    metricsDict["applicationAddressSpaceSize"] = mem.applicationAddressSpaceSize
    metricsDict["applicationPrivateSize"] = mem.applicationPrivateSize
    metricsDict["applicationRAMUsed"] = mem.applicationRAMUsed
})

// Create a new router
let router = Router()

// Implement BodyParser to handle the JSON that comes in from the page.
router.all("/", middleware: BodyParser())

// Handle GET requets for metrics.
router.get("/metrics") {
    request, response, next in
    if let metricsData = try? JSONSerialization.data(withJSONObject: metricsDict, options: []) {
        let _ = response.status(.OK).send(data: metricsData)
    } else {
        let _ = response.status(.internalServerError).send("Could not retrieve metrics data.")
    }
    next()
}

// Allow for serving up static files found in the public directory.
router.get("/", middleware: StaticFileServer(path: "./Public"))

// Handle POST requests for alerts.
router.post("/alert") {
    request, response, next in
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

// Handle DELETE reuests for alerts.
router.delete("/alert") {
    request, response, next in
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

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: config.getPort(), with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
