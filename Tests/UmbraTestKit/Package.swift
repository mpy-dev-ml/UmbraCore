// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UmbraTestKit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UmbraTestKit",
            targets: ["UmbraTestKit"]
        )
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .target(
            name: "UmbraTestKit",
            dependencies: []
        ),
        .testTarget(
            name: "UmbraTestKitTests",
            dependencies: ["UmbraTestKit"]
        )
    ]
)
