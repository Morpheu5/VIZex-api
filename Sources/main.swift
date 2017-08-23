import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
 
// Create HTTP server.
let server = HTTPServer()
 
// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
        request, response in
        let dictionary = ["aKey": "aValue", "anotherKey": "anotherValue"]
        response.setHeader(.contentType, value: "application/json")
        response.appendBody(string: try! dictionary.jsonEncodedString())
        response.completed()
    }
)
 
// Add the routes to the server.
server.addRoutes(routes)
 
// Set a listen port of 8181
server.serverPort = 8181
 
do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
