import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import SwiftyJSON

// Set logger.
Log.logger = HeliumLogger()

// Acquire service credentials from the config file.
let config = try Configuration()
let credentials = try config.getAlertNotificationSDKProps()

// Create a new router
let router = Router()

// Allow for serving up static files found in the public directory.
router.get("/", middleware: StaticFileServer(path: "./Public"))

// Handle POST requests for alerts.
router.post("/alert") {
    request, response, next in
    var jsonData: Data = Data()
    do {
        if try request.read(into: &jsonData) > 0 {
            let jsonAlert = JSON(data: jsonData)
            try sendAlert(jsonAlert, usingCredentials: credentials) {
                err in
                if let err = err {
                    let _ = response.send(status: .internalServerError)
                } else {
                    let _ = response.send(status: .OK)
                }
                next()
            }
        } else {
            Log.error("No body received in POST request.")
            let _ = response.send(status: .badRequest)
            next()
        }
    }
    catch {
        Log.error("Could not process and send alert.")
        Log.error(error.localizedDescription)
        let _ = response.send(status: .internalServerError)
        next()
    }
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
