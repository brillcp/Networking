// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.macOS(.v10_15),
                .iOS(.v13),
                .tvOS(.v13),
                .watchOS(.v6)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Networking",
            dependencies: [],
            path: "Sources",
            sources: [
                "Extensions",
                "HTTP",
                "Protocols",
                "Requests",
                "ServerConfig",
                "Service"
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
    ],
    swiftLanguageVersions: [.v5]
)
