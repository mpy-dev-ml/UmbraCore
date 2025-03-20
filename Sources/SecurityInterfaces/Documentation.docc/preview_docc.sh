#!/bin/bash
# Script to preview DocC documentation locally

set -e

# Find the DocC archive
DOCC_ARCHIVE=$(find . -name "*.doccarchive" | head -n 1)

if [ -z "$DOCC_ARCHIVE" ]; then
    echo "Error: DocC archive not found"
    exit 1
fi

echo "Opening DocC archive: $DOCC_ARCHIVE"

# Use xcrun to serve the documentation (for macOS)
xcrun docc preview "$DOCC_ARCHIVE" --port 8080
