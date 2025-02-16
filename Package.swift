// swift-tools-version: 5.9.2
import PackageDescription

let package = Package(
    name: "UmbraCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: ["UmbraCore", "Core", "SecurityTypes", "UmbraSecurity", "Logging"]
        ),
    ],
    dependencies: [],
    targets: [
        // Core module containing shared protocols and types
        .target(
            name: "Core",
            dependencies: ["SecurityTypes"],
            path: "Sources/Core"
        ),
        
        // Security types module containing protocols and error types
        .target(
            name: "SecurityTypes",
            dependencies: [],
            path: "Sources/SecurityTypes"
        ),
        
        // Security module for sandbox and security-scoped resource handling
        .target(
            name: "UmbraSecurity",
            dependencies: ["SecurityTypes", "Core"],
            path: "Sources/UmbraSecurity"
        ),
        
        // Logging module for system-wide logging
        .target(
            name: "Logging",
            dependencies: ["Core", "UmbraSecurity"],
            path: "Sources/Logging"
        ),
        
        // Main module that re-exports all components
        .target(
            name: "UmbraCore",
            dependencies: [
                "Core",
                "SecurityTypes",
                "UmbraSecurity",
                "Logging"
            ],
            path: "Sources/UmbraCore"
        ),
        
        // Test targets
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "SecurityTypesTests",
            dependencies: ["SecurityTypes"],
            path: "Tests/SecurityTypesTests"
        ),
        .testTarget(
            name: "UmbraSecurityTests",
            dependencies: ["UmbraSecurity"],
            path: "Tests/UmbraSecurityTests"
        ),
        .testTarget(
            name: "LoggingTests",
            dependencies: ["Logging"],
            path: "Tests/LoggingTests"
        ),
        .testTarget(
            name: "UmbraCoreTests",
            dependencies: ["UmbraCore"],
            path: "Tests/UmbraCoreTests"
        ),
    ]
)
