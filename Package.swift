// swift-tools-version: 5.9

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
        .library(
            name: "Watch360",
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
        .target(
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
