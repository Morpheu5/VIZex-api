import Foundation
import Kitura
import CSV

import HeliumLogger
import LoggerAPI
let logger = HeliumLogger()
logger.colored = true
Log.logger = logger

struct TOHLC {
	var timestamp: Int
	var open: Double
	var high: Double
	var low: Double
	var close: Double

	init(timestamp: Int, values: [Double]) {
		self.timestamp = timestamp;
		open = values[0]
		high = values[1]
		low = values[2]
		close = values[3]
	}
}

// Super-important memory storage thing.
// Kids, don't do global variables...
var ohlc = [String:[TOHLC]]()

func loadData(fromFile filename: String) -> [TOHLC] {
    let stream = InputStream(fileAtPath: filename)!
    var tValues = [TOHLC]()
    if let csv = try? CSVReader(stream: stream, hasHeaderRow: true) {
        while let row = csv.next() {
            let t = Int(row[0]) ?? -1;
            let v = row[1...4].map { Double($0.trimmingCharacters(in: .whitespaces)) ?? -1.0 }
            tValues.append(TOHLC(timestamp: t, values: v))
        }
    } else {
        Log.error("Could not find the data file \(filename).")
        // How rude.
        Kitura.stop()
    }
    return tValues
}

func startup() {
	// If only there was a better way of doing this...
    // There really should be a better way of doing this...
    let fn_1h = ProcessInfo.processInfo.environment["VIZEX_API_DATA_FILENAME_1H"] ?? "/Users/morpheu5/web/vizex/api/data/ohlc_1h.csv"
    let fn_4h = ProcessInfo.processInfo.environment["VIZEX_API_DATA_FILENAME_4H"] ?? "/Users/morpheu5/web/vizex/api/data/ohlc_4h.csv"
    let fn_1d = ProcessInfo.processInfo.environment["VIZEX_API_DATA_FILENAME_1D"] ?? "/Users/morpheu5/web/vizex/api/data/ohlc_1d.csv"
    // Perhaps one day I'll just do the squeezing here so I'll only need to provide one file at minute resolution.
    // Oh, well.

	Log.info("Loading data from files.")
	ohlc["1h"] = loadData(fromFile: fn_1h)
    ohlc["4h"] = loadData(fromFile: fn_4h)
    ohlc["1d"] = loadData(fromFile: fn_1d)

	Log.info("Data loaded.")
}

// Create a new router.
let router = Router()

// Handle HTTP GET requests to /data.
// resolution: 1h, 4h, 1d
// quantity: anything between 1 and 48
router.get("/data/:resolution/:quantity") {
    request, response, next in
    
    let resolution = request.parameters["resolution"] ?? "1h"
    let quantity = max(1, min(Int(request.parameters["quantity"] ?? "48")!, 48))
    
    if let dataSource = ohlc[resolution] {
        var data = [String:Any]()
        let now = Int(Date().timeIntervalSince1970)
        data["now"] = now
        data["resolution"] = resolution

        let valuesUpToNow: [TOHLC] = dataSource.filter() {
            (row) -> Bool in
            return row.timestamp <= now
        }
        let values = valuesUpToNow[(valuesUpToNow.count - quantity)...]
        data["values"] = values.map { row in
            [
                "timestamp" : row.timestamp,
                "open" : row.open,
                "high" : row.high,
                "low" : row.low,
                "close" : row.close // I vehemently oppose trailing commas.
            ]
        }
        // Swift is so cool!
        data["lowest"] = values.map { $0.close }.min()
        data["highest"] = values.map { $0.close }.max()
        // Or maybe not. I mean, it's cool, but this is clunky!
        let env = ProcessInfo.processInfo.environment["VIZEX_API_ENVIRONMENT"]
        if env != "production" {
            // Also, CORS sucks. I know it doesn't, but yeah, it does.
            response.headers.append("Access-Control-Allow-Origin", value: "http://localhost:8000")
        }
        response.headers.append("Cache-Control", value: "max-age=120")
        response.send(json: data)
    } else {
        // Throw a tantrum
        response.headers.append("Cache-Control", value: "max-age=120")
        response.statusCode = .badRequest
        response.send(json: [ "message" : "Wrong resolution. Please use: 1h, 4h, 1d." ])
    }
}

// Handle HTTP GET requests to /data.
router.get("/data") {
	request, response, next in
    try response.redirect("/data/1h/48")
    next()
}

// Initialize the data!
startup()

// Add an HTTP server and connect it to the router.
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns).
// (unless you terminate the process, in which case maybe some stack magic
// happens, but who are we to know that?)
Kitura.run()
