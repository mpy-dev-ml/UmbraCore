// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UmbraCore",
    platforms: [
        .macOS(.v14) // ✅ Support only macOS 14+
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: ["UmbraCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "601.0.0-prerelease-2025-02-04")
    ],
    targets: [
        .target(
            name: "UmbraCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Testing", package: "swift-testing"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            exclude: ["Services/Development/README.md"], // ✅ Corrected placement
            swiftSettings: [
                .unsafeFlags(["-enable-experimental-feature", "Sendable"])
            ]),
        .testTarget(
            name: "UmbraCoreTests",
            dependencies: ["UmbraCore"])
    ])
