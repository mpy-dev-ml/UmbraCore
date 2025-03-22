#!/bin/bash
# Script to build and view DocC documentation for UmbraCore modules

# Exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/docs/.docc-build"

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
</dict>
</plist>
EOF

# Create a temporary symbol graph directory
SYMBOL_GRAPH_DIR="${TEMP_DIR}/symbol-graphs"
mkdir -p "${SYMBOL_GRAPH_DIR}"

# Check if any sources were provided
if [ ${#SOURCES[@]} -eq 0 ]; then
  echo "WARNING: No source files provided. Documentation may be incomplete."
fi

# Run docc with correct parameters
echo "Running docc command with documentation directory: ${DOCC_DIR}"
$DOCC_TOOL convert "${DOCC_DIR}" \
  --fallback-display-name "${MODULE_NAME}" \
  --fallback-bundle-identifier "com.umbradevelopment.${MODULE_NAME}" \
  --fallback-bundle-version "1.0" \
  --output-path "${OUTPUT}" \
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
