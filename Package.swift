// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfiniteCarousel",
    platforms: [
        SupportedPlatform.iOS(
            SupportedPlatform.IOSVersion.v13
        ),
        SupportedPlatform.visionOS(
            SupportedPlatform.VisionOSVersion.v1
        ),
        SupportedPlatform.tvOS(
            SupportedPlatform.TVOSVersion.v12
        )
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "InfiniteCarousel",
            targets: ["InfiniteCarousel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "InfiniteCarousel", dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            ]),
    ]
)
