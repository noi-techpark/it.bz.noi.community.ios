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
            name: "CoreUI",
            targets: ["CoreUI"]
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
            name: "PeopleClient",
            targets: ["PeopleClient"]
        ),
        .library(
            name: "PeopleClientLive",
            targets: ["PeopleClientLive"]
        ),
		.library(
			name: "VimeoOEmbedClient",
			targets: ["VimeoOEmbedClient"]
		),
        .library(
            name: "VimeoVideoThumbnailClient",
            targets: ["VimeoVideoThumbnailClient"]
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
            name: "CoreUI",
            dependencies: []
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: [
                "CoreUI"
            ]
        ),
        .target(
            name: "EventShortTypesClient",
            dependencies: [
                "Core"
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
            dependencies: [
				"Core"
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
        ),
		.target(
			name: "VimeoOEmbedClient",
			dependencies: ["Core"]
		),
		.testTarget(
			name: "VimeoOEmbedClientTests",
			dependencies: ["VimeoOEmbedClient"]
		),
        .target(
            name: "VimeoVideoThumbnailClient",
            dependencies: ["Core", "VimeoOEmbedClient"]
        )
    ]
)
