import Kitura
import LoggerAPI
import HeliumLogger

// Set logger.
Log.logger = HeliumLogger()

// Acquire service credentials from the config file.
let config = try Configuration()
let credentials = try config.getAlertNotificationSDKProps()

// Create a new router
let router = Router()

// Allow for serving up static files found in the public directory.
router.all("/", middleware: StaticFileServer(path: "./Public"))

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    do {
        try response.send(fileName: "Public/html/index.html")
    }
    catch {
        Log.error(error.localizedDescription)
    }
    next()
}

// Handle POST requests for alerts.
router.post("/alert") {
    request, response, next in
    if let jsonAlert = request.body?.asJSON {
        do {
            try sendAlert(jsonAlert, usingCredentials: credentials)
        }
        catch {
            Log.error("Could not process and send alert.")
            Log.error(error.localizedDescription)
        }
    } else {
        Log.error("No body received in POST request.")
    }
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
