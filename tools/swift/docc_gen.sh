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
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure we have the necessary parameters
if [ -z "$MODULE_NAME" ] || [ -z "$OUTPUT" ]; then
  echo "Missing required parameters. Usage:"
  echo "  $0 --module_name NAME --output PATH [--temp_dir PATH] [--docc_tool PATH] [--source FILE...]"
  exit 1
fi

echo "Building DocC documentation for $MODULE_NAME..."
echo "Output will be written to: $OUTPUT"
echo "Number of source files: ${#SOURCES[@]}"

# Create temporary directory if it doesn't exist
if [ -n "$TEMP_DIR" ]; then
  mkdir -p "$TEMP_DIR"
fi

# Prepare source list for docc
SOURCES_LIST=""
for src in "${SOURCES[@]}"; do
  SOURCES_LIST="$SOURCES_LIST --source-path $src"
done

# Run docc command
echo "Running docc command..."
$DOCC_TOOL build $SOURCES_LIST --output-path "$OUTPUT" --target-name "$MODULE_NAME"

# Output success message
echo "Successfully generated DocC documentation for $MODULE_NAME"
echo "Documentation archive: $OUTPUT"

exit 0
