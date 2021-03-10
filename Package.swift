// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadingSystem",
    defaultLocalization: "en",
    platforms: [SupportedPlatform.macOS(.v10_15)],
    products: [
        .library(
            name: "LoadingSystem",
            targets: ["LoadingSystem"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "LoadingSystem",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "LoadingSystemTests",
            dependencies: ["LoadingSystem"],
            resources: [.process("Resources")]
        ),
    ]
)
