#!/bin/bash
# Script to automatically update BUILD files with missing dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Scanning project for Swift files and imports...${NC}"

# Find all Swift files
find_swift_files() {
  local dir=$1
  find "$dir" -name "*.swift" -type f
}

# Extract imports from a Swift file
extract_imports() {
  local file=$1
  grep -E "^import " "$file" | sed 's/import //' | sort | uniq
}

# Map module name to target
module_to_target() {
  local module=$1
  
  # Handle special cases
  case "$module" in
    "Foundation"|"SwiftUI"|"Combine"|"XCTest"|"CryptoSwift")
      echo ""
      ;;
    *)
      # Try to find the corresponding target
      local target=$(find Sources -name "$module" -type d | head -1)
      if [ -n "$target" ]; then
        echo "//$(echo $target | sed 's|^|/|'):$module"
      else
        echo ""
      fi
      ;;
  esac
}

# Update BUILD file with missing dependencies
update_build_file() {
  local build_file=$1
  local missing_deps=("${@:2}")
  
  if [ ${#missing_deps[@]} -eq 0 ]; then
    echo -e "${GREEN}No missing dependencies for $build_file${NC}"
    return
  fi
  
  echo -e "${YELLOW}Updating $build_file with missing dependencies:${NC}"
  for dep in "${missing_deps[@]}"; do
    echo "  $dep"
  done
  
  # Create a backup
  cp "$build_file" "$build_file.bak"
  
  # Find the deps section
  local deps_line=$(grep -n "deps\s*=" "$build_file" | head -1 | cut -d: -f1)
  
  if [ -z "$deps_line" ]; then
    echo -e "${RED}Could not find deps section in $build_file${NC}"
    return
  fi
  
  # Find the closing bracket
  local closing_line=$(tail -n +$deps_line "$build_file" | grep -n "\]" | head -1 | cut -d: -f1)
  closing_line=$((deps_line + closing_line - 1))
  
  # Insert the new dependencies before the closing bracket
  for dep in "${missing_deps[@]}"; do
    # Check if dependency already exists
    if ! grep -q "$dep" "$build_file"; then
      sed -i '' "${closing_line}i\\
        \"$dep\"," "$build_file"
    fi
  done
  
  echo -e "${GREEN}Updated $build_file${NC}"
}

# Process each directory with a BUILD file
process_directory() {
  local dir=$1
  local build_file="$dir/BUILD.bazel"
  
  if [ ! -f "$build_file" ]; then
    echo -e "${RED}No BUILD file found in $dir${NC}"
    return
  fi
  
  echo -e "${BLUE}Processing $dir...${NC}"
  
  # Get all Swift files in this directory
  local swift_files=($(find_swift_files "$dir"))
  
  if [ ${#swift_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}No Swift files found in $dir${NC}"
    return
  fi
  
  # Extract all imports
  local all_imports=()
  for file in "${swift_files[@]}"; do
    local imports=($(extract_imports "$file"))
    all_imports+=("${imports[@]}")
  done
  
  # Remove duplicates
  local unique_imports=($(echo "${all_imports[@]}" | tr ' ' '\n' | sort | uniq))
  
  # Map imports to targets
  local missing_deps=()
  for import in "${unique_imports[@]}"; do
    local target=$(module_to_target "$import")
    if [ -n "$target" ]; then
      # Check if the target is already in the BUILD file
      if ! grep -q "$target" "$build_file"; then
        missing_deps+=("$target")
      fi
    fi
  done
  
  # Update the BUILD file
  update_build_file "$build_file" "${missing_deps[@]}"
}

# Find all directories with BUILD files
BUILD_DIRS=$(find Sources -name "BUILD.bazel" -type f | xargs dirname)

# Process each directory
for dir in $BUILD_DIRS; do
  process_directory "$dir"
done

echo -e "${GREEN}All BUILD files have been processed.${NC}"
echo -e "${YELLOW}Please review the changes and run 'bazel build //...' to verify.${NC}"
