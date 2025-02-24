#!/bin/bash

# Find all BUILD.bazel files
find . -name "BUILD.bazel" -type f | while read -r file; do
    # Check if file contains swift_library or swift_test
    if grep -q "swift_library\|swift_test" "$file"; then
        # Check if copts is already present
        if ! grep -q "copts = \[" "$file"; then
            # Add copts before the closing parenthesis
            sed -i '' '/swift_library\|swift_test/,/)/{ /)/i\
    copts = [\
        "-target", "arm64-apple-macos14.0",\
        "-strict-concurrency=complete",\
        "-warn-concurrency",\
        "-enable-actor-data-race-checks",\
    ],
}' "$file"
        fi
    fi
done
