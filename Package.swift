// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "api",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/yaslab/CSV.swift.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 7)
    ]
)
