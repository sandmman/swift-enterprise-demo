import Kitura

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
        print(error)
        next()
    }
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
