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
            name: "UmbraCore",
            dependencies: [
                "UmbraXPC",
                "UmbraBookmarkService",
                "UmbraKeychainService",
                "SwiftyBeaver"
            ]
        ),
        .target(
            name: "UmbraXPC",
            dependencies: [],
            path: "Sources/XPC/Core"
        ),
        .target(
            name: "UmbraCryptoService",
            dependencies: [
                "UmbraXPC",
                "CryptoSwift"
            ],
            exclude: [
                "Resources/Info.plist",
                "Resources/UmbraCryptoService.entitlements"
            ]
        ),
        .target(
            name: "UmbraBookmarkService",
            dependencies: [
                "UmbraXPC"
            ]
        ),
        .target(
            name: "UmbraKeychainService",
            dependencies: [
                "UmbraXPC",
                "CryptoSwift"
            ]
        ),
        .testTarget(
            name: "UmbraCoreTests",
            dependencies: ["UmbraCore"]
        ),
        .testTarget(
            name: "XPCTests",
            dependencies: ["UmbraXPC", "UmbraCryptoService"]
        ),
        .testTarget(
            name: "BookmarkTests",
            dependencies: ["UmbraBookmarkService"]
        ),
        .testTarget(
            name: "KeychainTests",
            dependencies: ["UmbraKeychainService"],
            resources: [
                .process("UmbraKeychainService.entitlements")
            ]
        )
    ]
)
