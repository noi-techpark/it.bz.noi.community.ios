// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NOICommunityLib",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftCache",
            targets: ["SwiftCache"]
        ),
        .library(
            name: "PascalJSONDecoder",
            targets: ["PascalJSONDecoder"]
        ),
        .library(
            name: "DecodeEmptyRepresentable",
            targets: ["DecodeEmptyRepresentable"]
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
            name: "SwiftCache",
            dependencies: []
        ),
        .target(
            name: "PascalJSONDecoder",
            dependencies: []
        ),
        .target(
            name: "DecodeEmptyRepresentable",
            dependencies: []
        ),
        .target(
            name: "EventShortTypesClient",
            dependencies: []
        ),
        .testTarget(
            name: "EventShortTypesClientTests",
            dependencies: ["EventShortTypesClient"]
        ),
        .target(
            name: "EventShortTypesClientLive",
            dependencies: [
                "PascalJSONDecoder",
                "DecodeEmptyRepresentable",
                "EventShortTypesClient"
            ]
        ),
        .target(
            name: "AppPreferencesClient",
            dependencies: []
        ),
        .testTarget(
            name: "AppPreferencesClientTests",
            dependencies: ["AppPreferencesClient"]
        ),
        .target(
            name: "AppPreferencesClientLive",
            dependencies: ["AppPreferencesClient"]
        ),
        .target(
            name: "EventShortClient",
            dependencies: []
        ),
        .testTarget(
            name: "EventShortClientTests",
            dependencies: ["EventShortClient"]
        ),
        .target(
            name: "EventShortClientLive",
            dependencies: [
                "PascalJSONDecoder",
                "DecodeEmptyRepresentable",
                "EventShortClient"
            ]
        ),
        .target(
            name: "AuthStateStorageClient",
            dependencies: []
        ),
        .target(
            name: "AuthClient",
            dependencies: []
        ),
        .target(
            name: "AuthClientLive",
            dependencies: [
                "AuthClient",
                "AuthStateStorageClient",
                .product(name: "AppAuth", package: "AppAuth-iOS")
            ]
        )
    ]
)
