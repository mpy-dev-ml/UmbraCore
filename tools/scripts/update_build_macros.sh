#!/bin/bash
# Script to update BUILD.bazel files to use the standardized macros
# This will find all swift_library usages and replace them with umbra_swift_library

set -e

echo "Scanning for BUILD.bazel files with swift_library..."

# Find all BUILD.bazel files with swift_library
BUILD_FILES=$(grep -l "swift_library" $(find Sources -name "BUILD.bazel"))

if [ -z "$BUILD_FILES" ]; then
  echo "No files found with swift_library usage."
  exit 0
fi

echo "Found $(echo "$BUILD_FILES" | wc -l | xargs) files to update."

for file in $BUILD_FILES; do
  echo "Processing $file..."
  
  # Check if the file already uses our macro
  if grep -q "umbra_swift_library" "$file"; then
    echo "  Already using umbra_swift_library, skipping."
    continue
  fi
  
  # Check if the import is already there
  if ! grep -q "load(\"//:bazel/macros/swift.bzl\"" "$file"; then
    # Add the import
    sed -i '' '/load("@build_bazel_rules_swift\/\/swift:swift.bzl", "swift_library")/a\
load("//:bazel/macros/swift.bzl", "umbra_swift_library")
' "$file"
  fi
  
  # Replace swift_library with umbra_swift_library
  sed -i '' 's/swift_library(/umbra_swift_library(/g' "$file"
  
  # Remove copts, module_name, and visibility since they're in the macro
  sed -i '' '/copts = \[/,/\],/d' "$file"
  sed -i '' '/module_name = /d' "$file"
  sed -i '' '/visibility = /d' "$file"
  
  echo "  Updated $file"
done

echo "Update complete!"
echo "Please review the changes and run 'bazel build //...' to verify everything works."
