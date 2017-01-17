import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import SwiftyJSON
import CloudFoundryConfiguration

// Set logger.
Log.logger = HeliumLogger()

// Acquire service credentials from the config file.
let config = try Configuration(withFile: "cloud_config.json")
let credentials = try config.getAlertNotificationSDKProps()

// Create a new router
let router = Router()

// Implement BodyParser to handle the JSON that comes in from the page.
router.all("/", middleware: BodyParser())

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
