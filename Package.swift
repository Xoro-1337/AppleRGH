// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Watch360",
    platforms: [
        .watchOS(.v9),
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Watch360Core",
            targets: ["Watch360Core"]
        ),
        .executable(
            name: "Watch360App",
            targets: ["Watch360"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Watch360Core",
            dependencies: [],
            path: "Sources/Watch360Core"
        ),
        .executableTarget(
            name: "Watch360",
            dependencies: ["Watch360Core"],
            path: "Sources/Watch360",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "Watch360Tests",
            dependencies: ["Watch360Core"],
            path: "Tests/Watch360Tests"
        )
    ]
)
