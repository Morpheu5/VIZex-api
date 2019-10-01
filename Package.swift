// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "api",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.7.0"),
        .package(url: "https://github.com/yaslab/CSV.swift.git", from: "2.4.2"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0")
    ],
    targets: [
        .target(name: "api", dependencies: ["Kitura", "CSV", "HeliumLogger"]),
    ]
)
