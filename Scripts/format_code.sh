#!/bin/bash

# Script to apply SwiftFormat to the UmbraCore codebase
# Usage: ./scripts/format_code.sh [--check] [--staged-only] [path1 path2 ...]

# Set default variables
CHECK_ONLY=false
STAGED_ONLY=false
ROOT_DIR=$(git rev-parse --show-toplevel)
SWIFT_FORMAT_BIN=$(which swiftformat)
TARGET_PATHS=()

# Parse command line arguments
for arg in "$@"
do
  case $arg in
    --check)
      CHECK_ONLY=true
      ;;
    --staged-only)
      STAGED_ONLY=true
      ;;
    --*)
      # Skip other options
      ;;
    *)
      # Treat as target path
      TARGET_PATHS+=("$arg")
      ;;
  esac
done

# Ensure SwiftFormat is installed
if [ -z "$SWIFT_FORMAT_BIN" ]; then
  echo "Error: SwiftFormat not found. Please install it with 'brew install swiftformat'"
  exit 1
fi

# Check SwiftFormat version
SWIFT_FORMAT_VERSION=$($SWIFT_FORMAT_BIN --version)
echo "Using SwiftFormat version: $SWIFT_FORMAT_VERSION"

# Set options for SwiftFormat
SWIFT_FORMAT_OPTIONS="--quiet"

if [ "$CHECK_ONLY" = true ]; then
  SWIFT_FORMAT_OPTIONS="$SWIFT_FORMAT_OPTIONS --lint"
  echo "Running in check-only mode, will not modify files"
fi

# Function to format files
format_files() {
  local files=("$@")
  if [ ${#files[@]} -eq 0 ]; then
    echo "No Swift files to format"
    return 0
  fi

  echo "Formatting ${#files[@]} Swift files..."
  if [ "$CHECK_ONLY" = true ]; then
    $SWIFT_FORMAT_BIN $SWIFT_FORMAT_OPTIONS "${files[@]}"
    local result=$?
    if [ $result -ne 0 ]; then
      echo "SwiftFormat check failed! Please run './scripts/format_code.sh' to fix formatting issues."
      return 1
    fi
    echo "SwiftFormat check passed! All files are properly formatted."
  else
    $SWIFT_FORMAT_BIN $SWIFT_FORMAT_OPTIONS "${files[@]}"
    echo "SwiftFormat complete."
  fi
  return 0
}

# Additional files to exclude
EXCLUDE_PATTERNS=(".bazelrc.swift" ".swiftpm" "Package.resolved")
exclude_filter() {
  local file="$1"
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$file" == *"$pattern"* ]]; then
      return 1
    fi
  done
  
  # Make sure it's a valid Swift file (first line should be Swift code, not a shell script header or config)
  if [ -f "$file" ]; then
    local first_line=$(head -n 1 "$file")
    if [[ "$first_line" == "#!"* || "$first_line" == "#"* ]]; then
      return 1
    fi
  fi
  
  return 0
}

# Get files to format
FILES=()

if [ "$STAGED_ONLY" = true ]; then
  echo "Only formatting staged files"
  # Get staged Swift files
  while IFS= read -r line; do
    if [ -n "$line" ] && exclude_filter "$line"; then
      FILES+=("$line")
    fi
  done < <(git diff --cached --name-only --diff-filter=ACMR | grep "\.swift$" | xargs -I{} realpath --relative-to="$PWD" "$ROOT_DIR/{}" 2>/dev/null || echo "")
elif [ ${#TARGET_PATHS[@]} -gt 0 ]; then
  echo "Formatting files in specified paths: ${TARGET_PATHS[*]}"
  # Find Swift files in specified paths
  for path in "${TARGET_PATHS[@]}"; do
    if [ -f "$path" ] && [[ "$path" == *.swift ]] && exclude_filter "$path"; then
      # Direct file path
      FILES+=("$path")
    elif [ -d "$path" ]; then
      # Directory path
      while IFS= read -r line; do
        if [ -n "$line" ] && exclude_filter "$line"; then
          FILES+=("$line")
        fi
      done < <(find "$path" -name "*.swift" -not -path "*/bazel-*" -not -path "*/.build/*" -not -path "*/Pods/*" || echo "")
    fi
  done
else
  echo "Formatting all Swift files in the repository (excluding Pods, .build, and bazel-* directories)"
  # Get all Swift files in the repository (excluding specific directories)
  while IFS= read -r line; do
    if [ -n "$line" ] && exclude_filter "$line"; then
      FILES+=("$line")
    fi
  done < <(find "$ROOT_DIR" -name "*.swift" -not -path "*/bazel-*" -not -path "*/.build/*" -not -path "*/Pods/*" || echo "")
fi

# Format the files
format_files "${FILES[@]}"
exit $?
