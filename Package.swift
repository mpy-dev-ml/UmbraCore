// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UmbraCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: ["UmbraCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.4"))
    ],
    targets: [
        // Core Security Types
        .target(
            name: "SecurityTypes",
            dependencies: []
        ),

        // Core Crypto Types
        .target(
            name: "CryptoTypes",
            dependencies: [
                "SecurityTypes",
                "CryptoSwift"
            ]
        ),

        // Mock Implementations
        .target(
            name: "UmbraMocks",
            dependencies: [
                "SecurityTypes",
                "CryptoTypes"
            ]
        ),

        // Logging Feature
        .target(
            name: "UmbraLogging",
            dependencies: [
                "SecurityTypes",
                "UmbraMocks",
                "SwiftyBeaver"
            ],
            path: "Sources/Features/Logging"
        ),

        // Main Library
        .target(
            name: "UmbraCore",
            dependencies: [
                "SecurityTypes",
                "CryptoTypes",
                "UmbraLogging",
                "UmbraMocks"
            ]
        ),

        // Tests
        .testTarget(
            name: "CryptoTests",
            dependencies: [
                "CryptoTypes",
                "UmbraMocks"
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "UmbraCore",
                "UmbraMocks"
            ]
        )
    ]
)
