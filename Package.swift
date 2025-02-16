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
            targets: ["UmbraCore"]),
    ],
    targets: [
        .target(
            name: "SecurityTypes",
            dependencies: [],
            path: "Sources/SecurityTypes"
        ),
        .target(
            name: "SecurityUtils",
            dependencies: ["SecurityTypes"],
            path: "Sources/SecurityUtils"
        ),
        .target(
            name: "Core",
            dependencies: ["SecurityTypes"],
            path: "Sources/Core"
        ),
        .target(
            name: "UmbraSecurity",
            dependencies: ["SecurityTypes", "Core", "SecurityUtils"],
            path: "Sources/UmbraSecurity"
        ),
        .target(
            name: "Logging",
            dependencies: ["Core"],
            path: "Sources/Logging"
        ),
        .target(
            name: "UmbraCore",
            dependencies: [
                "Core",
                "UmbraSecurity",
                "Logging"
            ],
            path: "Sources/UmbraCore"
        ),
        .testTarget(
            name: "SecurityTypesTests",
            dependencies: ["SecurityTypes"],
            path: "Tests/SecurityTypesTests"
        ),
        .testTarget(
            name: "SecurityUtilsTests",
            dependencies: ["SecurityUtils"],
            path: "Tests/SecurityUtilsTests"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
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
        )
    ]
)
