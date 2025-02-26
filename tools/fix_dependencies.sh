#!/bin/bash
# Script to analyze and fix dependencies in a Bazel project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Analyzing project dependencies...${NC}"

# Find all Swift files
SWIFT_FILES=$(find Sources -name "*.swift" -type f)

# Temporary file to store dependency information
DEPS_FILE=$(mktemp)

echo -e "${YELLOW}Scanning import statements...${NC}"

# Extract all import statements from Swift files
for file in $SWIFT_FILES; do
  imports=$(grep -E "^import " "$file" | sed 's/import //' | sort | uniq)
  if [ -n "$imports" ]; then
    echo "$file: $imports" >> "$DEPS_FILE"
  fi
done

echo -e "${YELLOW}Analyzing BUILD files...${NC}"

# Find all BUILD.bazel files
BUILD_FILES=$(find Sources -name "BUILD.bazel" -type f)

# Check each BUILD file for missing dependencies
for build_file in $BUILD_FILES; do
  dir=$(dirname "$build_file")
  module=$(basename "$dir")
  
  echo -e "${YELLOW}Checking dependencies for $module...${NC}"
  
  # Get all Swift files in this directory
  module_files=$(find "$dir" -name "*.swift" -type f)
  
  # Get all imports in these files
  all_imports=""
  for file in $module_files; do
    imports=$(grep -E "^import " "$file" | sed 's/import //' | sort | uniq)
    all_imports="$all_imports $imports"
  done
  
  # Remove duplicates
  unique_imports=$(echo "$all_imports" | tr ' ' '\n' | sort | uniq)
  
  # Check if these imports are in the BUILD file
  for import in $unique_imports; do
    # Skip Foundation, SwiftUI, etc.
    if [[ "$import" == "Foundation" || "$import" == "SwiftUI" || "$import" == "Combine" || "$import" == "XCTest" ]]; then
      continue
    fi
    
    # Check if the import is in the BUILD file
    if ! grep -q "$import" "$build_file"; then
      echo -e "${RED}Missing dependency in $build_file: $import${NC}"
      
      # Try to find the corresponding target
      potential_target=$(find Sources -name "$import" -type d | head -1)
      if [ -n "$potential_target" ]; then
        echo -e "${GREEN}Potential target: //$(echo $potential_target | sed 's|^|/|'):$import${NC}"
      fi
    fi
  done
done

echo -e "${GREEN}Analysis complete. Check the output above for missing dependencies.${NC}"
rm "$DEPS_FILE"
