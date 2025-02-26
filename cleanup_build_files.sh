#!/bin/bash
# Script to clean up redundant parameters from BUILD.bazel files that use umbra_swift_library

# Find all BUILD.bazel files using umbra_swift_library
echo "Finding BUILD.bazel files using umbra_swift_library..."
FILES=$(cd /Users/mpy/CascadeProjects/UmbraCore && grep -l "umbra_swift_library" --include="BUILD.bazel" -r Sources/)

for file in $FILES; do
  echo "Cleaning up $file..."
  
  # Remove redundant copts sections
  perl -i -0pe 's/    copts = \[\n        "-target",\n        "arm64-apple-macos14\.0",\n        "-strict-concurrency=complete",\n        "-enable-actor-data-race-checks",\n        "-warn-concurrency",\n    \],\n//g' "$file"
  
  # Remove module_name line
  perl -i -pe 's/    module_name = "[^"]+",\n//g' "$file"
  
  # Remove visibility line
  perl -i -pe 's/    visibility = \["\/\/visibility:public"\],\n//g' "$file"
done

echo "Cleanup complete. Please build and test to ensure correctness."
