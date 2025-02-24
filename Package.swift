// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UmbraCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: ["UmbraCore"]
        ),
        .library(
            name: "UmbraXPC",
            targets: ["UmbraXPC"]
        ),
        .library(
            name: "UmbraCryptoService",
            targets: ["UmbraCryptoService"]
        ),
        .library(
            name: "UmbraBookmarkService",
            targets: ["UmbraBookmarkService"]
        ),
        .library(
            name: "UmbraKeychainService",
            targets: ["UmbraKeychainService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-testing.git", exact: "0.5.0")
    ],
    targets: [
        .target(
            name: "SecurityTypes",
            dependencies: []
        ),
        .target(
            name: "SecurityUtils",
            dependencies: ["SecurityTypes"]
        ),
        .target(
            name: "CryptoTypes",
            dependencies: ["SecurityTypes", "CryptoSwift"]
        ),
        .target(
            name: "UmbraLogging",
            dependencies: ["SwiftyBeaver"]
        ),
        .target(
            name: "UmbraCore",
            dependencies: [
                "SecurityTypes",
                "SecurityUtils",
                "CryptoTypes",
                "UmbraLogging"
            ]
        ),
        .target(
            name: "UmbraXPC",
            dependencies: [
                "UmbraCore"
            ]
        ),
        .target(
            name: "UmbraCryptoService",
            dependencies: [
                "UmbraCore",
                "CryptoTypes"
            ]
        ),
        .target(
            name: "UmbraBookmarkService",
            dependencies: [
                "UmbraCore",
                "SecurityTypes"
            ]
        ),
        .target(
            name: "UmbraKeychainService",
            dependencies: [
                "UmbraCore",
                "SecurityTypes"
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "UmbraCore",
                "UmbraCryptoService",
                "UmbraBookmarkService",
                "UmbraKeychainService",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
