// swift-tools-version: 5.9.2
import PackageDescription

let package = Package(
    name: "UmbraCore",
    platforms: [
        .macOS(.v14) // Support only macOS 14+
    ],
    products: [
        .library(
            name: "UmbraCore",
            targets: [
                "ResticCLIHelper",
                "Repositories",
                "Snapshots",
                "Config",
                "Logging",
                "ErrorHandling",
                "Autocomplete"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main")
    ],
    targets: [
        // MARK: - ResticCLIHelper
        .target(
            name: "ResticCLIHelper",
            dependencies: [
                "ErrorHandling",
                "Logging",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/ResticCLIHelper"
        ),
        .testTarget(
            name: "ResticCLIHelperTests",
            dependencies: [
                "ResticCLIHelper",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ResticCLIHelperTests"
        ),

        // MARK: - Repositories
        .target(
            name: "Repositories",
            dependencies: [
                "ResticCLIHelper",
                "Config",
                "ErrorHandling",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Repositories"
        ),
        .testTarget(
            name: "RepositoriesTests",
            dependencies: [
                "Repositories",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/RepositoriesTests"
        ),

        // MARK: - Snapshots
        .target(
            name: "Snapshots",
            dependencies: [
                "ResticCLIHelper",
                "Repositories",
                "ErrorHandling",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Snapshots"
        ),
        .testTarget(
            name: "SnapshotsTests",
            dependencies: [
                "Snapshots",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/SnapshotsTests"
        ),

        // MARK: - Config
        .target(
            name: "Config",
            dependencies: [
                "ErrorHandling",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Config"
        ),
        .testTarget(
            name: "ConfigTests",
            dependencies: [
                "Config",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ConfigTests"
        ),

        // MARK: - Logging
        .target(
            name: "Logging",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Logging"
        ),
        .testTarget(
            name: "LoggingTests",
            dependencies: [
                "Logging",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/LoggingTests"
        ),

        // MARK: - ErrorHandling
        .target(
            name: "ErrorHandling",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/ErrorHandling"
        ),
        .testTarget(
            name: "ErrorHandlingTests",
            dependencies: [
                "ErrorHandling",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ErrorHandlingTests"
        ),

        // MARK: - Autocomplete
        .target(
            name: "Autocomplete",
            dependencies: [
                "Repositories",
                "Snapshots",
                "ErrorHandling",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Autocomplete"
        ),
        .testTarget(
            name: "AutocompleteTests",
            dependencies: [
                "Autocomplete",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/AutocompleteTests"
        )
    ]
)
