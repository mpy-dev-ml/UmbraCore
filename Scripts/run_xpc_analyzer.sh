#!/bin/bash

# Run XPC Protocol Analyzer
# This script runs the Go analyzer and produces a more detailed text report

# Set script to exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/xpc_analyzer_config.json"
JSON_OUTPUT="$PROJECT_ROOT/xpc_protocol_analysis.json"
TEXT_OUTPUT="$PROJECT_ROOT/xpc_protocol_migration_report.md"

# Check if Go is installed
if ! command -v go &>/dev/null; then
  echo "Error: Go is not installed. Please install Go to run this analyzer."
  exit 1
fi

echo "Building and running XPC Protocol Analyzer..."
cd "$SCRIPT_DIR"
go run xpc_protocol_analyzer.go -config "$CONFIG_FILE" -output "$JSON_OUTPUT"

# Generate a more readable Markdown report
echo "Generating Markdown report..."

# Function to count files in a module
count_files() {
  local module="$1"
  local module_count=$(jq ".moduleMapping[\"$module\"] | length" "$JSON_OUTPUT")
  echo "$module_count"
}

# Start generating the report
cat > "$TEXT_OUTPUT" << EOL
# XPC Protocol Migration Report

Generated on: $(date)

## Summary

This report identifies files and modules in the UmbraCore project that need to be refactored 
to use the new XPC protocols defined in XPCProtocolsCore.

EOL

# Add summary statistics
TOTAL_FILES=$(jq '.totalFiles' "$JSON_OUTPUT")
LEGACY_IMPORTS=$(jq '.filesWithLegacyImports' "$JSON_OUTPUT")
MODERN_IMPORTS=$(jq '.filesWithModernImports' "$JSON_OUTPUT")
NEEDS_REFACTORING=$(jq '.filesNeedingRefactoring' "$JSON_OUTPUT")
MODULE_COUNT=$(jq '.modulesToRefactor | length' "$JSON_OUTPUT")

cat >> "$TEXT_OUTPUT" << EOL
- **Total files analyzed**: $TOTAL_FILES
- **Files with legacy imports**: $LEGACY_IMPORTS
- **Files with modern imports**: $MODERN_IMPORTS
- **Files needing refactoring**: $NEEDS_REFACTORING
- **Modules to refactor**: $MODULE_COUNT

## Modules Needing Refactoring

| Module | Files Needing Refactoring | Priority |
|--------|---------------------------|----------|
EOL

# Get sorted list of modules by file count (largest first)
MODULES=$(jq -r '.modulesToRefactor[]' "$JSON_OUTPUT")

# For each module, count files and write to report
for MODULE in $MODULES; do
  COUNT=$(jq ".moduleMapping[\"$MODULE\"] | length" "$JSON_OUTPUT")
  
  # Determine priority
  PRIORITY="Medium"
  if [ "$COUNT" -gt 10 ]; then
    PRIORITY="High"
  elif [ "$COUNT" -lt 3 ]; then
    PRIORITY="Low"
  fi
  
  echo "| $MODULE | $COUNT | $PRIORITY |" >> "$TEXT_OUTPUT"
done

# Add section on next steps
cat >> "$TEXT_OUTPUT" << EOL

## Files to Refactor

Below is a list of the top files that need to be refactored in priority order:

EOL

# Add top 20 files needing refactoring
jq -r '.fileAnalyses | sort_by(.module, .filePath) | map(select(.needsRefactoring == true)) | .[0:20] | .[] | "- **\(.module)**: \(.filePath)"' "$JSON_OUTPUT" >> "$TEXT_OUTPUT"

# Add migration instructions
cat >> "$TEXT_OUTPUT" << EOL

## Migration Steps

For each file identified above:

1. Add imports for XPCProtocolsCore and UmbraCoreTypes:
   ```swift
   import XPCProtocolsCore
   import UmbraCoreTypes
   ```

2. Replace legacy protocol implementations with modern ones:
   - XPCServiceProtocol → XPCServiceProtocolStandard
   - XPCCryptoServiceProtocol → XPCServiceProtocolComplete
   - SecurityXPCProtocol → XPCServiceProtocolStandard

3. Update error handling to use XPCSecurityError from UmbraCoreTypes

4. Update data types:
   - BinaryData → SecureBytes
   - CryptoData → SecureBytes

5. If needed, use migration adapters from XPCProtocolsMigration.swift for backward compatibility

## Progress Tracking

Track migration progress by running this analysis tool regularly.

## Reference Documentation

For detailed migration guidance, see:
- [XPC_PROTOCOLS_MIGRATION_GUIDE.md](../XPC_PROTOCOLS_MIGRATION_GUIDE.md)
- [UmbraCore_Refactoring_Plan.md](../UmbraCore_Refactoring_Plan.md)

EOL

echo "XPC Protocol Migration report generated at: $TEXT_OUTPUT"

# Make the report file executable
chmod +x "$SCRIPT_DIR/run_xpc_analyzer.sh"
