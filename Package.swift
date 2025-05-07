// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "x-simple-swift-rest-api-server",
    targets: [
        .target(
            name: "x-simple-swift-rest-api-server"),
        .testTarget(
            name: "tests",
            dependencies: ["x-simple-swift-rest-api-server"]
        ),
    ]
)
