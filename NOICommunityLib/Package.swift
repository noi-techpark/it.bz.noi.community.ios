// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import PackageDescription

let package = Package(
    name: "NOICommunityLib",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "EventShortTypesClient",
            targets: ["EventShortTypesClient"]
        ),
        .library(
            name: "EventShortTypesClientLive",
            targets: ["EventShortTypesClientLive"]
        ),
        .library(
            name: "AppPreferencesClient",
            targets: ["AppPreferencesClient"]
        ),
        .library(
            name: "AppPreferencesClientLive",
            targets: ["AppPreferencesClientLive"]
        ),
        .library(
            name: "EventShortClient",
            targets: ["EventShortClient"]
        ),
        .library(
            name: "EventShortClientLive",
            targets: ["EventShortClientLive"]
        ),
        .library(
            name: "AuthStateStorageClient",
            targets: ["AuthStateStorageClient"]
        ),
        .library(
            name: "AuthClient",
            targets: ["AuthClient"]
        ),
        .library(
            name: "AuthClientLive",
            targets: ["AuthClientLive"]
        ),
        .library(
            name: "ArticlesClient",
            targets: ["ArticlesClient"]
        ),
        .library(
            name: "ArticlesClientLive",
            targets: ["ArticlesClientLive"]
        ),
        .library(
            name: "PeopleClient",
            targets: ["PeopleClient"]
        ),
        .library(
            name: "PeopleClientLive",
            targets: ["PeopleClientLive"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/openid/AppAuth-iOS.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Core",
            dependencies: []
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core"
            ]
        ),
        .target(
            name: "EventShortTypesClient",
            dependencies: [
                "Core"
            ]
        ),
        .testTarget(
            name: "EventShortTypesClientTests",
            dependencies: [
                "Core",
                "EventShortTypesClient"
            ]
        ),
        .target(
            name: "EventShortTypesClientLive",
            dependencies: [
                "Core",
                "EventShortTypesClient"
            ]
        ),
        .target(
            name: "AppPreferencesClient",
            dependencies: [
                "Core"
            ]
        ),
        .testTarget(
            name: "AppPreferencesClientTests",
            dependencies: [
                "Core",
                "AppPreferencesClient"
            ]
        ),
        .target(
            name: "AppPreferencesClientLive",
            dependencies: [
                "Core",
                "AppPreferencesClient"
            ]
        ),
        .target(
            name: "EventShortClient",
            dependencies: [
                "Core",
            ]
        ),
        .testTarget(
            name: "EventShortClientTests",
            dependencies: [
                "Core",
                "EventShortClient"
            ]
        ),
        .target(
            name: "EventShortClientLive",
            dependencies: [
                "Core",
                "EventShortClient"
            ]
        ),
        .target(
            name: "AuthStateStorageClient",
            dependencies: [
                "Core"
            ]
        ),
        .target(
            name: "AuthClient",
            dependencies: [
                "Core"
            ]
        ),
        .target(
            name: "AuthClientLive",
            dependencies: [
                "Core",
                "AuthClient",
                "AuthStateStorageClient",
                .product(name: "AppAuth", package: "AppAuth-iOS")
            ]
        ),
        .target(
            name: "ArticlesClient",
            dependencies: []
        ),
        .target(
            name: "ArticlesClientLive",
            dependencies: [
                "Core",
                "ArticlesClient",
            ]
        ),
        .target(
            name: "PeopleClient",
            dependencies: []
        ),
        .target(
            name: "PeopleClientLive",
            dependencies: [
                "Core",
                "PeopleClient",
            ]
        )
    ]
)
