// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventShortTypesClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "EventShortTypesClient",
            targets: ["EventShortTypesClient"]),
        .library(
            name: "EventShortTypesClientLive",
            targets: ["EventShortTypesClientLive"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "EventShortTypesClient",
            dependencies: []),
        .testTarget(
            name: "EventShortTypesClientTests",
            dependencies: ["EventShortTypesClient"]),

        .target(
            name: "EventShortTypesClientLive",
            dependencies: ["EventShortTypesClient"]),
    ]
)
