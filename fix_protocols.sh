#!/bin/bash

# UmbraCore Protocol Conformance Analyzer and Fixer
# This script runs the protocol analyzer to identify and optionally fix protocol conformance issues
# such as missing methods, signature mismatches, and duplicate implementations.

set -e

# Default parameters
SOURCES_PATH="./Sources/SecurityBridge"
OUTPUT_CSV="protocol_issues.csv"
FIX=false
DRY_RUN=true

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --path=*)
      SOURCES_PATH="${1#*=}"
      shift
      ;;
    --output=*)
      OUTPUT_CSV="${1#*=}"
      shift
      ;;
    --fix)
      FIX=true
      DRY_RUN=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "UmbraCore Protocol Conformance Analyzer and Fixer"
      echo
      echo "Usage: $0 [options]"
      echo
      echo "Options:"
      echo "  --path=PATH     Path to Swift source files (default: ./Sources/SecurityBridge)"
      echo "  --output=FILE   Output CSV file (default: protocol_issues.csv)"
      echo "  --fix           Apply suggested fixes (default: off)"
      echo "  --dry-run       Only show proposed changes, don't apply them (default: on)"
      echo "  --help          Show this help message"
      echo
      echo "Example:"
      echo "  $0 --path=./Sources/SecurityBridge --dry-run"
      exit 0
      ;;
    *)
      echo "Error: Unknown option $1"
      echo "Use --help to see available options"
      exit 1
      ;;
  esac
done

# Ensure source path exists
if [ ! -d "$SOURCES_PATH" ]; then
  echo "Error: Source path $SOURCES_PATH does not exist or is not a directory"
  exit 1
fi

# Ensure we're in the right directory
if [ ! -d "./tools/protocolanalyzer" ]; then
  echo "Error: tools/protocolanalyzer directory not found. Make sure you're running this from the project root."
  exit 1
fi

echo "Protocol Analyzer Settings:"
echo "  Source Path: $SOURCES_PATH"
echo "  Output CSV: $OUTPUT_CSV"
echo "  Dry Run Mode: $DRY_RUN"
echo "  Apply Fixes: $FIX"
echo

# Compile the analyzer
echo "Compiling protocol analyzer..."
(cd tools/protocolanalyzer && go build -o ../../protocol_analyzer .)

# Run the analyzer
echo "Running protocol analyzer..."
if [ "$FIX" = true ]; then
  ./protocol_analyzer -path="$SOURCES_PATH" -output="$OUTPUT_CSV" -fix
else
  ./protocol_analyzer -path="$SOURCES_PATH" -output="$OUTPUT_CSV" -dry-run="$DRY_RUN"
fi

echo
echo "Analysis complete! Results written to $OUTPUT_CSV"
if [ "$FIX" = true ]; then
  echo "Fixes have been applied to the source files. Please review the changes."
else
  echo "No changes have been applied to the source files. To apply changes, run with --fix option."
fi
