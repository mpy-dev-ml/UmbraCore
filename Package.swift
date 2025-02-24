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
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.0.0")
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
            dependencies: ["UmbraCore"]
        ),
        .target(
            name: "UmbraCryptoService",
            dependencies: ["UmbraCore"]
        ),
        .target(
            name: "UmbraBookmarkService",
            dependencies: ["UmbraCore"]
        ),
        .target(
            name: "UmbraKeychainService",
            dependencies: ["UmbraCore"]
        ),
        .testTarget(
            name: "UmbraCoreTests",
            dependencies: ["UmbraCore"]
        )
    ]
)
