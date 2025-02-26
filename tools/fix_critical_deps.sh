#!/bin/bash
# Script to fix the most critical dependencies based on the analysis

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Fixing critical dependencies...${NC}"

# Fix UmbraCore dependencies
echo -e "${YELLOW}Fixing UmbraCore dependencies...${NC}"
BUILD_FILE="Sources/UmbraCore/BUILD.bazel"

# Check if the file exists
if [ ! -f "$BUILD_FILE" ]; then
  echo -e "${RED}BUILD file not found: $BUILD_FILE${NC}"
  exit 1
fi

# Create a backup
cp "$BUILD_FILE" "$BUILD_FILE.bak"

# Update the dependencies
echo -e "${BLUE}Updating $BUILD_FILE...${NC}"
cat > "$BUILD_FILE" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "UmbraCore",
    srcs = glob(["**/*.swift"]),
    module_name = "UmbraCore",
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/CryptoTypes",
        "//Sources/CryptoTypes/Protocols:CryptoTypesProtocols",
        "//Sources/CryptoTypes/Types:CryptoTypesTypes",
        "//Sources/ErrorHandling",
        "//Sources/ErrorHandling/Common:ErrorHandlingCommon",
        "//Sources/ErrorHandling/Models:ErrorHandlingModels",
        "//Sources/ErrorHandling/Protocols:ErrorHandlingProtocols",
        "//Sources/SecurityTypes",
        "//Sources/SecurityTypes/Protocols:SecurityTypesProtocols",
        "//Sources/SecurityTypes/Types:SecurityTypesTypes",
        "//Sources/UmbraLogging",
    ],
    copts = ["-target", "arm64-apple-macos14.0"],
)
EOF

echo -e "${GREEN}Updated $BUILD_FILE${NC}"

# Fix UmbraCryptoService dependencies
echo -e "${YELLOW}Fixing UmbraCryptoService dependencies...${NC}"
BUILD_FILE="Sources/UmbraCryptoService/BUILD.bazel"

# Check if the file exists
if [ ! -f "$BUILD_FILE" ]; then
  echo -e "${RED}BUILD file not found: $BUILD_FILE${NC}"
  exit 1
fi

# Create a backup
cp "$BUILD_FILE" "$BUILD_FILE.bak"

# Update the dependencies
echo -e "${BLUE}Updating $BUILD_FILE...${NC}"
cat > "$BUILD_FILE" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "UmbraCryptoService",
    srcs = glob(["**/*.swift"]),
    module_name = "UmbraCryptoService",
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/Core",
        "//Sources/CryptoTypes",
        "//Sources/CryptoTypes/Protocols:CryptoTypesProtocols",
        "//Sources/CryptoTypes/Types:CryptoTypesTypes",
        "//Sources/ErrorHandling",
        "//Sources/ErrorHandling/Common:ErrorHandlingCommon",
        "//Sources/ErrorHandling/Models:ErrorHandlingModels",
        "//Sources/ErrorHandling/Protocols:ErrorHandlingProtocols",
        "//Sources/SecurityTypes",
        "//Sources/SecurityTypes/Protocols:SecurityTypesProtocols",
        "//Sources/SecurityTypes/Types:SecurityTypesTypes",
        "//Sources/SecurityUtils",
        "//Sources/UmbraKeychainService",
        "//Sources/UmbraLogging",
        "//Sources/UmbraXPC",
    ],
    copts = ["-target", "arm64-apple-macos14.0"],
)
EOF

echo -e "${GREEN}Updated $BUILD_FILE${NC}"

# Fix Core dependencies
echo -e "${YELLOW}Fixing Core dependencies...${NC}"
BUILD_FILE="Sources/Core/BUILD.bazel"

# Check if the file exists
if [ ! -f "$BUILD_FILE" ]; then
  echo -e "${RED}BUILD file not found: $BUILD_FILE${NC}"
  exit 1
fi

# Create a backup
cp "$BUILD_FILE" "$BUILD_FILE.bak"

# Update the dependencies
echo -e "${BLUE}Updating $BUILD_FILE...${NC}"
cat > "$BUILD_FILE" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "Core",
    srcs = glob(["**/*.swift"]),
    module_name = "Core",
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/CryptoTypes",
        "//Sources/CryptoTypes/Protocols:CryptoTypesProtocols",
        "//Sources/CryptoTypes/Types:CryptoTypesTypes",
        "//Sources/ErrorHandling",
        "//Sources/ErrorHandling/Common:ErrorHandlingCommon",
        "//Sources/ErrorHandling/Models:ErrorHandlingModels",
        "//Sources/ErrorHandling/Protocols:ErrorHandlingProtocols",
        "//Sources/SecurityTypes",
        "//Sources/SecurityTypes/Protocols:SecurityTypesProtocols",
        "//Sources/SecurityTypes/Types:SecurityTypesTypes",
        "//Sources/UmbraLogging",
    ],
    copts = ["-target", "arm64-apple-macos14.0"],
)
EOF

echo -e "${GREEN}Updated $BUILD_FILE${NC}"

# Fix XPC/Core dependencies
echo -e "${YELLOW}Fixing XPC/Core dependencies...${NC}"
BUILD_FILE="Sources/XPC/Core/BUILD.bazel"

# Check if the file exists
if [ ! -f "$BUILD_FILE" ]; then
  echo -e "${RED}BUILD file not found: $BUILD_FILE${NC}"
  exit 1
fi

# Create a backup
cp "$BUILD_FILE" "$BUILD_FILE.bak"

# Update the dependencies
echo -e "${BLUE}Updating $BUILD_FILE...${NC}"
cat > "$BUILD_FILE" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "XPCCore",
    srcs = glob(["**/*.swift"]),
    module_name = "XPCCore",
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/ErrorHandling",
        "//Sources/ErrorHandling/Common:ErrorHandlingCommon",
        "//Sources/ErrorHandling/Models:ErrorHandlingModels",
        "//Sources/ErrorHandling/Protocols:ErrorHandlingProtocols",
        "//Sources/UmbraLogging",
    ],
    copts = ["-target", "arm64-apple-macos14.0"],
)
EOF

echo -e "${GREEN}Updated $BUILD_FILE${NC}"

echo -e "${GREEN}All critical dependencies have been fixed.${NC}"
echo -e "${YELLOW}Please run 'bazel build //...' to verify the changes.${NC}"
