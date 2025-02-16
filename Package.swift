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
            targets: ["UmbraCore"]
        ),
    ],
    dependencies: [],
    targets: [
        // Core module containing shared protocols and types
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"
        ),
        
        // Security module for sandbox and security-scoped resource handling
        .target(
            name: "Security",
            dependencies: ["Core"],
            path: "Sources/Security"
        ),
        
        // Logging module for system-wide logging
        .target(
            name: "Logging",
            dependencies: ["Core", "Security"],
            path: "Sources/Logging"
        ),
        
        // Main module that re-exports all components
        .target(
            name: "UmbraCore",
            dependencies: [
                "Core",
                "Security",
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
            name: "SecurityTests",
            dependencies: ["Security"],
            path: "Tests/SecurityTests"
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
