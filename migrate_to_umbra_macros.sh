#!/bin/bash
# Script to find all Swift BUILD.bazel files and migrate them to use umbra_swift_library macro

# Find all BUILD.bazel files containing 'swift_library'
echo "Finding Swift BUILD.bazel files..."
FILES=$(cd /Users/mpy/CascadeProjects/UmbraCore && grep -l "swift_library" --include="BUILD.bazel" -r Sources/)

# For each file, check if it needs to be migrated
for file in $FILES; do
  echo "Checking $file..."
  
  # Check if the file already uses umbra_swift_library
  if grep -q "umbra_swift_library" "$file"; then
    echo "  Already using umbra_swift_library, skipping."
    continue
  fi
  
  # Add the import for umbra_swift_library
  echo "  Migrating to umbra_swift_library..."
  sed -i '' 's/load("@build_bazel_rules_swift\/\/swift:swift.bzl", "swift_library")/load("@build_bazel_rules_swift\/\/swift:swift.bzl", "swift_library")\nload("\/\/:bazel\/macros\/swift.bzl", "umbra_swift_library")/' "$file"
  
  # Replace swift_library with umbra_swift_library
  sed -i '' 's/swift_library(/umbra_swift_library(/' "$file"
  
  # Remove copts sections - this is a bit complex as it spans multiple lines
  # We'll output a warning to check files manually for copts
  echo "  File migrated, but please check manually for copts, module_name and visibility settings."
done

echo "Migration complete. Please build and test each module to ensure correctness."
echo "Also check files manually for any remaining copts, module_name, or visibility settings that need to be removed."
