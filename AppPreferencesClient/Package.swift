// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppPreferencesClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AppPreferencesClient",
            targets: ["AppPreferencesClient"]),
        .library(
            name: "AppPreferencesClientLive",
            targets: ["AppPreferencesClientLive"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AppPreferencesClient",
            dependencies: []),
        .testTarget(
            name: "AppPreferencesClientTests",
            dependencies: ["AppPreferencesClient"]),

            .target(
                name: "AppPreferencesClientLive",
                dependencies: ["AppPreferencesClient"]),
    ]
)
