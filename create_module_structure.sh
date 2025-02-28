#!/bin/bash
# Script to create the new module structure for UmbraCore

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}UmbraCore Module Structure Creator${NC}"
echo "This script will create the new module structure for UmbraCore"

# Ensure we're in the project root
if [ ! -d "Sources" ] || [ ! -d "Tests" ]; then
  echo "Error: This script must be run from the UmbraCore project root"
  exit 1
fi

# Create SecurityInterfacesBase directory if it doesn't exist
if [ ! -d "Sources/SecurityInterfacesBase" ]; then
  echo -e "${YELLOW}Creating Sources/SecurityInterfacesBase directory...${NC}"
  mkdir -p Sources/SecurityInterfacesBase
  echo -e "${GREEN}✓ Created Sources/SecurityInterfacesBase${NC}"
else
  echo -e "${GREEN}✓ Sources/SecurityInterfacesBase already exists${NC}"
fi

# Create BUILD.bazel file for SecurityInterfacesBase
echo -e "${YELLOW}Creating BUILD.bazel for SecurityInterfacesBase...${NC}"
cat > Sources/SecurityInterfacesBase/BUILD.bazel << 'EOF'
load("//:bazel/macros/swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "SecurityInterfacesBase",
    srcs = [
        "XPCServiceBaseProtocol.swift",
        "XPCServiceProtocolDefinition.swift",
    ],
    additional_copts = [],
    deps = [
        "//Sources/CoreTypes",
    ],
    visibility = ["//visibility:public"],
)
EOF
echo -e "${GREEN}✓ Created BUILD.bazel for SecurityInterfacesBase${NC}"

# Create XPCServiceBaseProtocol.swift
echo -e "${YELLOW}Creating XPCServiceBaseProtocol.swift...${NC}"
cat > Sources/SecurityInterfacesBase/XPCServiceBaseProtocol.swift << 'EOF'
import Foundation

/// Base protocol for XPC service interfaces
/// Provides minimal Foundation dependencies
@objc public protocol XPCServiceBaseProtocol: NSObjectProtocol, Sendable {
    // Basic functionality all XPC services need
}

// Use extensions to provide NSObjectProtocol conformance
extension XPCServiceBaseProtocol {
    // Extension methods to aid conformance
}
EOF
echo -e "${GREEN}✓ Created XPCServiceBaseProtocol.swift${NC}"

# Copy XPCServiceProtocolDefinition.swift from SecurityInterfaces
if [ -f "Sources/SecurityInterfaces/XPCServiceProtocolDefinition.swift" ]; then
  echo -e "${YELLOW}Copying and adapting XPCServiceProtocolDefinition.swift...${NC}"
  cp Sources/SecurityInterfaces/XPCServiceProtocolDefinition.swift Sources/SecurityInterfacesBase/
  
  # Modify the copy to use XPCServiceBaseProtocol
  sed -i '' 's/@objc public protocol XPCServiceProtocolDefinition: NSObjectProtocol, Sendable {/@objc public protocol XPCServiceProtocolDefinition: XPCServiceBaseProtocol {/g' Sources/SecurityInterfacesBase/XPCServiceProtocolDefinition.swift
  
  echo -e "${GREEN}✓ Copied and adapted XPCServiceProtocolDefinition.swift${NC}"
else
  echo "Error: Sources/SecurityInterfaces/XPCServiceProtocolDefinition.swift not found"
  exit 1
fi

echo -e "${BLUE}Next steps:${NC}"
echo "1. Update SecurityInterfaces/XPCServiceProtocol.swift to import SecurityInterfacesBase"
echo "2. Update Core/Services/TypeAliases/XPCServiceProtocolAlias.swift"
echo "3. Run bazel build to verify the changes"

echo -e "${GREEN}Module structure creation complete${NC}"
