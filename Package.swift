// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "umbracore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: ["UmbraCore", "SecurityTypes", "CryptoTypes", "UmbraMocks"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0")
    ],
    targets: [
        // MARK: - Core Layer
        .target(
            name: "UmbraCore",
            dependencies: ["SecurityTypes", "CryptoTypes"],
            path: "Sources/Core/UmbraCore"
        ),
        .target(
            name: "SecurityTypes",
            dependencies: [],
            path: "Sources/Core/SecurityTypes"
        ),
        .target(
            name: "CryptoTypes",
            dependencies: [],
            path: "Sources/Core/CryptoTypes"
        ),
        
        // MARK: - Feature Layer
        .target(
            name: "UmbraLogging",
            dependencies: [
                "UmbraCore",
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver")
            ],
            path: "Sources/Features/Logging",
            exclude: ["README.md"]
        ),
        .target(
            name: "UmbraCrypto",
            dependencies: [
                "UmbraCore",
                "CryptoTypes",
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            path: "Sources/Features/Crypto"
        ),
        
        // MARK: - Services Layer
        .target(
            name: "UmbraSecurityUtils",
            dependencies: [
                "UmbraCore",
                "SecurityTypes",
                "UmbraCrypto",
                "UmbraLogging"
            ],
            path: "Sources/Services/SecurityUtils"
        ),
        
        // MARK: - API Layer
        .target(
            name: "UmbraAPI",
            dependencies: [
                "UmbraCore",
                "UmbraSecurityUtils"
            ],
            path: "Sources/API"
        ),
        
        // MARK: - Testing Support
        .target(
            name: "UmbraMocks",
            dependencies: [
                "SecurityTypes",
                "CryptoTypes"
            ],
            path: "Sources/Mocks"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "UmbraCore",
                "UmbraMocks"
            ],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "CryptoTests",
            dependencies: [
                "UmbraCrypto",
                "UmbraMocks"
            ],
            path: "Tests/CryptoTests"
        ),
        .testTarget(
            name: "SecurityUtilsTests",
            dependencies: [
                "UmbraSecurityUtils",
                "UmbraMocks"
            ],
            path: "Tests/SecurityUtilsTests"
        ),
        .testTarget(
            name: "LoggingTests",
            dependencies: [
                "UmbraLogging"
            ],
            path: "Tests/LoggingTests"
        ),
        .testTarget(
            name: "SecurityTypesTests",
            dependencies: [
                "SecurityTypes",
                "UmbraMocks"
            ],
            path: "Tests/SecurityTypesTests"
        ),
        .testTarget(
            name: "ErrorHandlingTests",
            dependencies: [
                "UmbraCore",
                "SecurityTypes"
            ],
            path: "Tests/ErrorHandlingTests"
        ),
        .testTarget(
            name: "UmbraCoreTests",
            dependencies: [
                "UmbraCore",
                "UmbraMocks"
            ],
            path: "Tests/UmbraCoreTests"
        ),
        .testTarget(
            name: "UmbraSecurityTests",
            dependencies: [
                "UmbraSecurityUtils",
                "UmbraMocks"
            ],
            path: "Tests/UmbraSecurityTests"
        )
    ]
)
