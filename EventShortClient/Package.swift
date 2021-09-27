// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventShortClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "EventShortClient",
            targets: ["EventShortClient"]),
        .library(
            name: "EventShortClientLive",
            targets: ["EventShortClientLive"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "EventShortClient",
            dependencies: []),
        .testTarget(
            name: "EventShortClientTests",
            dependencies: ["EventShortClient"]),

        .target(
            name: "EventShortClientLive",
            dependencies: ["EventShortClient"]),
    ]
)
