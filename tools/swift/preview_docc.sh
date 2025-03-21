#!/bin/bash
set -e

# This script is used to preview DocC documentation for a Swift module.

# Check if DocC archive is specified
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <docc_archive>"
    exit 1
fi

# Get the path to the DocC archive
INPUT_PATH="$1"
WORKSPACE_ROOT=$(pwd)

# If the input path is absolute, use it directly
if [[ "$INPUT_PATH" == /* ]]; then
    DOCC_ARCHIVE="$INPUT_PATH"
else
    # Convert relative path to absolute
    DOCC_ARCHIVE="$WORKSPACE_ROOT/$INPUT_PATH"
fi

echo "Checking for DocC archive at: $DOCC_ARCHIVE"

# Check if the DocC archive exists
if [ ! -d "$DOCC_ARCHIVE" ]; then
    echo "Error: DocC archive not found at $DOCC_ARCHIVE"
    
    # Try direct lookup via basename
    BASENAME=$(basename "$DOCC_ARCHIVE")
    DIRECT_PATH="$WORKSPACE_ROOT/bazel-bin/Sources/CoreDTOs/$BASENAME"
    
    if [ -d "$DIRECT_PATH" ]; then
        echo "Found DocC archive at alternative location: $DIRECT_PATH"
        DOCC_ARCHIVE="$DIRECT_PATH"
    else
        # Comprehensive search for the doccarchive
        echo "Performing comprehensive search for DocC archives..."
        
        # Resolve symlinks in bazel-bin directory
        BAZEL_BIN_REAL=$(readlink -f "$WORKSPACE_ROOT/bazel-bin" 2>/dev/null || echo "$WORKSPACE_ROOT/bazel-bin")
        BAZEL_OUT_REAL=$(readlink -f "$WORKSPACE_ROOT/bazel-out" 2>/dev/null || echo "$WORKSPACE_ROOT/bazel-out")
        
        # Start with a focused search in the most likely directories
        FOUND=false
        for DIR in "$WORKSPACE_ROOT/bazel-bin" "$BAZEL_BIN_REAL" "$WORKSPACE_ROOT/bazel-out" "$BAZEL_OUT_REAL"; do
            if [ -d "$DIR" ]; then
                echo "Searching in $DIR for $BASENAME..."
                MATCHES=$(find "$DIR" -name "$BASENAME" -type d 2>/dev/null)
                if [ -n "$MATCHES" ]; then
                    FOUND=true
                    DOCC_ARCHIVE=$(echo "$MATCHES" | head -n 1)
                    echo "Found DocC archive at: $DOCC_ARCHIVE"
                    break
                fi
            fi
        done
        
        # If still not found, search for any .doccarchive
        if [ "$FOUND" = false ]; then
            echo "Searching for any .doccarchive files..."
            for DIR in "$WORKSPACE_ROOT/bazel-bin" "$BAZEL_BIN_REAL" "$WORKSPACE_ROOT/bazel-out" "$BAZEL_OUT_REAL"; do
                if [ -d "$DIR" ]; then
                    MATCHES=$(find "$DIR" -name "*.doccarchive" -type d 2>/dev/null)
                    if [ -n "$MATCHES" ]; then
                        FOUND=true
                        DOCC_ARCHIVE=$(echo "$MATCHES" | head -n 1)
                        echo "Found DocC archive at: $DOCC_ARCHIVE"
                        break
                    fi
                fi
            done
        fi
        
        # Last resort: check directly in the workspace
        if [ "$FOUND" = false ]; then
            echo "Searching in the workspace..."
            MATCHES=$(find "$WORKSPACE_ROOT" -name "*.doccarchive" -type d 2>/dev/null | grep -v "external\|execroot")
            if [ -n "$MATCHES" ]; then
                DOCC_ARCHIVE=$(echo "$MATCHES" | head -n 1)
                echo "Found DocC archive at: $DOCC_ARCHIVE"
            else
                echo "Error: Could not find any .doccarchive files"
                exit 1
            fi
        fi
    fi
fi

if [ ! -d "$DOCC_ARCHIVE" ]; then
    echo "Error: DocC archive not found after exhaustive search"
    exit 1
fi

# Check if DocC tool is available
if ! command -v xcrun &> /dev/null; then
    echo "Error: xcrun command not found. Please make sure Xcode CLI tools are installed."
    exit 1
fi

DOCC_PATH=$(xcrun --find docc 2>/dev/null || echo "")
if [ -z "$DOCC_PATH" ]; then
    echo "DocC tool not found, using Python HTTP server instead..."
    echo "Previewing documentation from $DOCC_ARCHIVE on http://localhost:8080..."
    (cd "$DOCC_ARCHIVE" && python3 -m http.server 8080)
    exit 0
fi

echo "Using DocC tool at: $DOCC_PATH"
echo "Previewing documentation from $DOCC_ARCHIVE..."

# Try to use preview command first, fallback to serve or HTTP server
if "$DOCC_PATH" help 2>&1 | grep -q "preview"; then
    "$DOCC_PATH" preview "$DOCC_ARCHIVE" --port 8080
elif "$DOCC_PATH" help 2>&1 | grep -q "serve"; then
    "$DOCC_PATH" serve "$DOCC_ARCHIVE" --port 8080
else
    echo "DocC preview/serve commands not available, using Python HTTP server instead..."
    (cd "$DOCC_ARCHIVE" && python3 -m http.server 8080)
fi
