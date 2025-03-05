# Swift-specific configurations for ARM64
build:swift_arm64 --copt=-target
build:swift_arm64 --copt=arm64-apple-macos14.0
build:swift_arm64 --copt=-arch
build:swift_arm64 --copt=arm64
build:swift_arm64 --linkopt=-target
build:swift_arm64 --linkopt=arm64-apple-macos14.0
build:swift_arm64 --linkopt=-arch
build:swift_arm64 --linkopt=arm64
build:swift_arm64 --apple_platform_type=macos

# Explicitly set Swift toolchain path to the one bundled with Xcode
build:swift_arm64 --action_env=SWIFT_EXEC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc

# Swift 6 Preparation Configuration
build:swift_6_prep --swiftcopt=-enable-upcoming-feature
build:swift_6_prep --swiftcopt=Isolated
build:swift_6_prep --swiftcopt=-enable-upcoming-feature
build:swift_6_prep --swiftcopt=ExistentialAny
build:swift_6_prep --swiftcopt=-enable-upcoming-feature
build:swift_6_prep --swiftcopt=StrictConcurrency
build:swift_6_prep --swiftcopt=-enable-upcoming-feature
build:swift_6_prep --swiftcopt=InternalImportsByDefault
build:swift_6_prep --swiftcopt=-warn-swift-5-to-swift-6-path

# Concurrency Safety Configuration
build:swift_concurrency --swiftcopt=-strict-concurrency=complete
build:swift_concurrency --swiftcopt=-enable-actor-data-race-checks
build:swift_concurrency --swiftcopt=-warn-concurrency

# Combined Swift 6 Ready Configuration (combines ARM64, Swift 6 prep, and concurrency safety)
build:swift_6_ready --config=swift_arm64
build:swift_6_ready --config=swift_6_prep
build:swift_6_ready --config=swift_concurrency
