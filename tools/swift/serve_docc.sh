#!/bin/bash
# Script to serve DocC documentation locally

set -e

# Get the path to the DocC archive from Bazel
DOCC_ARCHIVE="$1"

if [ -z "$DOCC_ARCHIVE" ]; then
    echo "Error: DocC archive not specified"
    exit 1
fi

echo "Opening DocC archive: $DOCC_ARCHIVE"

# Use xcrun to serve the documentation (for macOS)
xcrun docc preview "$DOCC_ARCHIVE" --port 8080
