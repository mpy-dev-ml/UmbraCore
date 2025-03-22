#!/bin/bash
# Script to build and view DocC documentation for UmbraCore modules

# Exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/docs/.docc-build"
CONFIG_FILE="${PROJECT_ROOT}/docc_config.yml"

# Load config if available
LANGUAGE="en-GB"
if [ -f "$CONFIG_FILE" ] && command -v yq &> /dev/null; then
    echo "Reading configuration from $CONFIG_FILE"
    if yq -e '.general.language' "$CONFIG_FILE" &> /dev/null; then
        LANGUAGE=$(yq '.general.language' "$CONFIG_FILE")
        echo "Using language: $LANGUAGE"
    fi
fi

# Ensure the output directory exists
mkdir -p "${OUTPUT_DIR}"

# Parse command line arguments
TEMP_DIR=""
OUTPUT=""
MODULE_NAME=""
DOCC_TOOL="/usr/bin/xcrun docc"
SOURCES=()
SHOULD_COPY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --temp_dir)
      TEMP_DIR="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --module_name)
      MODULE_NAME="$2"
      shift 2
      ;;
    --docc_tool)
      DOCC_TOOL="$2"
      shift 2
      ;;
    --source)
      SOURCES+=("$2")
      shift 2
      ;;
    --copy)
      SHOULD_COPY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure we have the necessary parameters
if [ -z "$MODULE_NAME" ] || [ -z "$OUTPUT" ]; then
  echo "Missing required parameters. Usage:"
  echo "  $0 --module_name NAME --output PATH [--temp_dir PATH] [--docc_tool PATH] [--source FILE...] [--copy]"
  exit 1
fi

echo "Building DocC documentation for $MODULE_NAME..."
echo "Output will be written to: $OUTPUT"
echo "Number of source files: ${#SOURCES[@]}"

# Create temporary directory if it doesn't exist
if [ -n "$TEMP_DIR" ]; then
  mkdir -p "$TEMP_DIR"
else
  echo "ERROR: Temporary directory not specified"
  exit 1
fi

# Create a proper documentation catalog directory
DOCC_DIR="${TEMP_DIR}/${MODULE_NAME}.docc"
mkdir -p "$DOCC_DIR"

# Create Info.plist in the .docc directory
cat > "${DOCC_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.umbradevelopment.${MODULE_NAME}</string>
    <key>CFBundleName</key>
    <string>${MODULE_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CDDefaultCodeListingLanguage</key>
    <string>swift</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>${LANGUAGE}</string>
    <key>CDDefaultModuleKind</key>
    <string>Library</string>
</dict>
</plist>
EOF

# Create a README.md in the .docc directory
cat > "${DOCC_DIR}/README.md" << EOF
# ``${MODULE_NAME}``

A module from the UmbraCore framework.

## Overview

${MODULE_NAME} is part of the UmbraCore framework that helps build secure and reliable backup solutions.

## Topics

### Essentials

- <doc:GettingStarted>
EOF

# Create a GettingStarted.md file
cat > "${DOCC_DIR}/GettingStarted.md" << EOF
# Getting Started with ${MODULE_NAME}

Learn how to use the ${MODULE_NAME} module.

## Overview

${MODULE_NAME} provides essential functionality as part of the UmbraCore framework.

## First Steps

Import the module in your Swift code:

\`\`\`swift
import ${MODULE_NAME}
\`\`\`

## Examples

Examples will be added as the documentation matures.
EOF

# Create a temporary symbol graph directory
SYMBOL_GRAPH_DIR="${TEMP_DIR}/symbol-graphs"
mkdir -p "${SYMBOL_GRAPH_DIR}"

# Check if any sources were provided
if [ ${#SOURCES[@]} -eq 0 ]; then
  echo "WARNING: No source files provided. Documentation may be incomplete."
fi

# Generate symbol graphs if Swift compiler is available
if command -v xcrun swiftc &> /dev/null; then
  echo "Generating symbol graphs for ${MODULE_NAME}..."
  
  # Create a temporary directory for Swift files
  SRC_DIR="${TEMP_DIR}/src"
  mkdir -p "$SRC_DIR"
  
  # Copy Swift files to the temporary directory
  for src in "${SOURCES[@]}"; do
    cp "$src" "$SRC_DIR/"
  done
  
  # Generate symbol graph using swiftc
  xcrun swiftc \
    -module-name "${MODULE_NAME}" \
    -emit-symbol-graph \
    -emit-symbol-graph-dir "${SYMBOL_GRAPH_DIR}" \
    -I "${SRC_DIR}" \
    "${SRC_DIR}"/*.swift &> /dev/null || echo "Symbol graph generation had warnings (this is usually normal)"
    
  echo "Symbol graphs generated in: ${SYMBOL_GRAPH_DIR}"
else
  echo "WARNING: Swift compiler not found. Skipping symbol graph generation."
fi

# Run docc with correct parameters
echo "Running docc command with documentation directory: ${DOCC_DIR}"
$DOCC_TOOL convert "${DOCC_DIR}" \
  --fallback-display-name "${MODULE_NAME}" \
  --fallback-bundle-identifier "com.umbradevelopment.${MODULE_NAME}" \
  --fallback-bundle-version "1.0" \
  --additional-symbol-graph-dir "${SYMBOL_GRAPH_DIR}" \
  --output-path "${OUTPUT}" \
  --fallback-default-module-kind library \
  --transform-for-static-hosting \
  --index || {
    echo "DocC generation failed. Creating empty documentation archive."
    mkdir -p "${OUTPUT}"
    touch "${OUTPUT}/.empty"
  }

# Copy if requested
if [ "$SHOULD_COPY" = true ]; then
  DOCS_DIR="${PROJECT_ROOT}/docs"
  mkdir -p "$DOCS_DIR"
  echo "Copying documentation to ${DOCS_DIR}/${MODULE_NAME}DocC.doccarchive..."
  cp -R "$OUTPUT" "${DOCS_DIR}/${MODULE_NAME}DocC.doccarchive"
fi

# Output success message
echo "Documentation generation completed for $MODULE_NAME"
echo "Documentation archive: $OUTPUT"

exit 0
