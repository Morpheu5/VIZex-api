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

// Super-important memory storage thing
var allValues: [TOHLC] = []

func startup() {
	let filename = ProcessInfo.processInfo.environment["VIZEX_API_DATA_FILENAME"] ?? "/Users/morpheu5/web/vizex/api/data/ohlc.csv"

	Log.info("Loading data from \"\(filename)\"")

	let stream = InputStream(fileAtPath: filename)!
	if let csv = try? CSVReader(stream: stream, hasHeaderRow: true) {
		while let row = csv.next() {
			allValues.append(TOHLC(timestamp: Int(row[0])!, values: row[1...4].map { Double($0)! }))
		}
	} else {
		Log.error("Could not find the data file.")
		Kitura.stop()
	}

	Log.info("Data loaded.")
}

// Create a new router
let router = Router()

// Handle HTTP GET requests to /data
router.get("/data") {
	request, response, next in
	var data: [String: Any] = [:]

	let now = Int(Date().timeIntervalSince1970)
	data["now"] = now

	var values: [TOHLC] = allValues.filter() {
		row in
		return row.timestamp <= now && row.timestamp >= now-24*3600
	}

	data["values"] = values.map { row in
		[
		"timestamp" : row.timestamp,
		"open" : row.open,
		"high" : row.high,
		"low" : row.low,
		"close" : row.close
		]
	}

	response.send(json: data)
}

// Handle HTTP GET requests to everything else
router.get("*") {
	request, response, next in
	response.statusCode = .forbidden
	response.send(json: [ "message" : "Nope, go away." ])
	next()
}

// Initialize the data!
startup()

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
