// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadingSystem",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "LoadingSystem",
            targets: ["LoadingSystem"]
        ),
        .library(
            name: "LoadingSystemSpec",
            targets: ["LoadingSystemSpec"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "LoadingSystem",
            dependencies: []
        ),
        .target(
            name: "FeedSystem",
            dependencies: ["LoadingSystem"],
            resources: [.process("Resources")]
        ),
        .target(name: "LoadingSystemSpec"),
        .testTarget(
            name: "LoadingSystemTests",
            dependencies: ["LoadingSystem", "FeedSystem", "Difference", "LoadingSystemSpec"]
        ),
        .testTarget(
            name: "LoadingSystemSpecTests",
            dependencies: ["LoadingSystemSpec", "LoadingSystem", "Difference"]
        ),
    ]
)
