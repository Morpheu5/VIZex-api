// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "api",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "1.7.0"),
        .package(url: "https://github.com/yaslab/CSV.swift.git", from: "2.0.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.0")
    ],
    targets: [
        .target(
            name: "api",
            dependencies: ["Kitura", "CSV", "HeliumLogger"]),
    ]
)

