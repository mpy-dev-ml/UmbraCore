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
