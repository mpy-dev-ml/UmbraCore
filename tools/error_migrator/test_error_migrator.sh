#!/bin/bash
set -e

# Test script for the error migrator tool
# This script tests the error migrator's functionality including:
# 1. Report parsing and configuration generation
# 2. Code generation for individual error type files
# 3. Proper handling of namespace conflicts
# 4. Module-specific alias file generation

echo "=== Testing Error Migrator Tool ==="
echo ""

# Create a temporary directory for test files
TEST_DIR=$(mktemp -d)
echo "Created test directory: $TEST_DIR"

# Clean up on exit
function cleanup {
  echo "Cleaning up test directory..."
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Create a mock error analysis report with namespace conflicts
echo "Creating mock error analysis report with intentional namespace conflicts..."
cat > "$TEST_DIR/error_analysis_report.md" << 'EOL'
# Error Analysis Report

## Error Definitions

### SecurityError (SecurityProtocolsCore)
- **File**: Sources/SecurityProtocolsCore/SecurityError.swift:10
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
- **Imported By**: [SecurityBridge UmbraSecurity SecurityInterfaces]
- **Referenced By**: 35 files

### SecurityProtocolsCore (SecurityProtocolsCore)
- **File**: Sources/SecurityProtocolsCore/SecurityProtocolsCore.swift:5
- **Public**: true
- **Cases**:
  - v1
  - v2
- **Imported By**: [SecurityBridge]
- **Referenced By**: 10 files

### SecurityError (XPCProtocolsCore)
- **File**: Sources/XPCProtocolsCore/SecurityError.swift:15
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
  - sessionExpired
- **Imported By**: [XPCBridge XPCService SecurityXPCService]
- **Referenced By**: 28 files

### XPCProtocolsCore (XPCProtocolsCore)
- **File**: Sources/XPCProtocolsCore/XPCProtocolsCore.swift:8
- **Public**: true
- **Cases**:
  - standard
  - enhanced
- **Imported By**: [XPCBridge]
- **Referenced By**: 8 files

### ResourceError (ResourceManagementCore)
- **File**: Sources/ResourceManagementCore/ResourceError.swift:8
- **Public**: true
- **Cases**:
  - notFound
  - accessDenied
  - insufficientPermissions
- **Imported By**: [StorageCore BackupCore]
- **Referenced By**: 22 files

### ResourceError (StorageCore)
- **File**: Sources/StorageCore/ResourceError.swift:12
- **Public**: true
- **Cases**:
  - notFound
  - accessDenied
  - alreadyExists
- **Imported By**: [FileManagerCore BackupCore]
- **Referenced By**: 15 files

## Duplicated Error Types

- **SecurityError** defined in 2 modules:
  - SecurityProtocolsCore
  - XPCProtocolsCore

- **ResourceError** defined in 2 modules:
  - ResourceManagementCore
  - StorageCore

## CoreErrors Migration Plan

...
EOL

# Create mock Swift files that reference these errors with namespace conflicts
echo "Creating mock Swift files for testing import updates..."

mkdir -p "$TEST_DIR/Sources/SecurityBridge"
cat > "$TEST_DIR/Sources/SecurityBridge/SecurityProvider.swift" << 'EOL'
import Foundation
import SecurityProtocolsCore

public class SecurityProvider {
    func authenticate() throws {
        // Some authentication logic
        throw SecurityProtocolsCore.SecurityError.unauthorized
        
        // Also using the module enum
        let version = SecurityProtocolsCore.SecurityProtocolsCore.v2
    }
}
EOL

mkdir -p "$TEST_DIR/Sources/XPCService"
cat > "$TEST_DIR/Sources/XPCService/XPCServiceHandler.swift" << 'EOL'
import Foundation
import XPCProtocolsCore

public class XPCServiceHandler {
    func handleRequest() throws {
        // Some request handling logic
        throw XPCProtocolsCore.SecurityError.sessionExpired
        
        // Also using the module enum
        let mode = XPCProtocolsCore.XPCProtocolsCore.standard
    }
}
EOL

# Create a file that imports both modules to test namespace conflict resolution
mkdir -p "$TEST_DIR/Sources/SecurityXPCBridge"
cat > "$TEST_DIR/Sources/SecurityXPCBridge/SecurityXPCBridge.swift" << 'EOL'
import Foundation
import SecurityProtocolsCore
import XPCProtocolsCore

public class SecurityXPCBridge {
    func processRequest() throws {
        // This will have ambiguity: which SecurityError?
        // throw SecurityError.unauthorized
        
        // This is explicit but problematic due to the module enum
        throw SecurityProtocolsCore.SecurityError.unauthorized
        
        // This is also explicit but problematic
        throw XPCProtocolsCore.SecurityError.sessionExpired
    }
}
EOL

echo "Running error migrator in init config mode..."
cd $(dirname "$0")
go run . --initConfig --report "$TEST_DIR/error_analysis_report.md" --config "$TEST_DIR/migration_config.json"

echo "Verifying config file was created..."
if [ ! -f "$TEST_DIR/migration_config.json" ]; then
    echo "FAILED: Config file was not created."
    exit 1
fi

# Modify the config file to include the CoreErrors module
cat > "$TEST_DIR/migration_config.json" << 'EOL'
{
  "targetModule": "CoreErrors",
  "errorsToMigrate": {
    "SecurityError": [
      "SecurityProtocolsCore",
      "XPCProtocolsCore"
    ],
    "ResourceError": [
      "ResourceManagementCore",
      "StorageCore"
    ]
  },
  "dryRun": true,
  "outputDir": "generated"
}
EOL

echo "Running error migrator in dry run mode with verbose output..."
go run . --config "$TEST_DIR/migration_config.json" --report "$TEST_DIR/error_analysis_report.md" --output "$TEST_DIR/generated" --verbose

echo "Running error migrator in apply mode..."
go run . --config "$TEST_DIR/migration_config.json" --report "$TEST_DIR/error_analysis_report.md" --apply --output "$TEST_DIR/generated"

echo "===== Verification Tests ====="
echo "1. Verifying individual error type files in target module..."
if [ ! -f "$TEST_DIR/generated/CoreErrors/SecurityError.swift" ]; then
    echo "FAILED: SecurityError.swift was not created in CoreErrors."
    exit 1
fi

echo "2. Verifying module-specific alias files..."
if [ ! -f "$TEST_DIR/generated/SecurityProtocolsCore/SecurityProtocolsCore_Aliases.swift" ]; then
    echo "FAILED: SecurityProtocolsCore_Aliases.swift was not created."
    exit 1
fi

if [ ! -f "$TEST_DIR/generated/XPCProtocolsCore/XPCProtocolsCore_Aliases.swift" ]; then
    echo "FAILED: XPCProtocolsCore_Aliases.swift was not created."
    exit 1
fi

echo "3. Verifying namespace conflict detection and guidance..."
# Check for namespace conflict handling in SecurityProtocolsCore alias file
grep -q "namespace conflict" "$TEST_DIR/generated/SecurityProtocolsCore/SecurityProtocolsCore_Aliases.swift"
if [ $? -ne 0 ]; then
    echo "FAILED: Namespace conflict guidance not found in SecurityProtocolsCore_Aliases.swift"
    exit 1
fi

# Check for namespace conflict handling in XPCProtocolsCore alias file
grep -q "namespace conflict" "$TEST_DIR/generated/XPCProtocolsCore/XPCProtocolsCore_Aliases.swift"
if [ $? -ne 0 ]; then
    echo "FAILED: Namespace conflict guidance not found in XPCProtocolsCore_Aliases.swift"
    exit 1
fi

echo "4. Verifying import alias suggestions in bridge file (optional)..."
# Check for import alias suggestions in bridge file if it exists
BRIDGE_FILE="$TEST_DIR/generated/Sources/SecurityXPCBridge/SecurityXPCBridge.swift"
if [ -f "$BRIDGE_FILE" ]; then
    grep -q "as CoreErr" "$BRIDGE_FILE"
    if [ $? -ne 0 ]; then
        echo "WARNING: Import alias suggestion not found in bridge file."
    else
        echo "SUCCESS: Import alias suggestions found in bridge file."
    fi
fi

echo "Running unit tests..."
go test -v

echo ""
echo "=== All tests passed! ==="
