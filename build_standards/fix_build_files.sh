#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}UmbraCore BUILD File Fixer${NC}\n"

# Standard copts to add
COPTS_BLOCK='    copts = [
        "-target",
        "arm64-apple-macos14.0",
        "-strict-concurrency=complete",
        "-warn-concurrency",
        "-enable-actor-data-race-checks",
    ],'

fix_build_file() {
    local build_file=$1
    local dir_name=$(dirname "$build_file")
    local base_dir=$(basename "$dir_name")
    local parent_dir=$(basename "$(dirname "$dir_name")")
    local temp_file="${build_file}.tmp"
    
    echo "Fixing $build_file..."
    
    # Read the file
    if [ ! -f "$build_file" ]; then
        echo "File not found: $build_file"
        return 1
    fi
    
    # Copy original file
    cp "$build_file" "$temp_file"
    
    # Fix module_name if it exists
    if grep -q "module_name" "$build_file"; then
        if [[ "$parent_dir" == "Sources" ]]; then
            sed -i '' "s/module_name = \"[^\"]*\"/module_name = \"$base_dir\"/" "$temp_file"
        else
            local new_name="${parent_dir}_${base_dir}"
            sed -i '' "s/module_name = \"[^\"]*\"/module_name = \"$new_name\"/" "$temp_file"
        fi
    fi
    
    # Fix glob without allow_empty
    sed -i '' 's/glob(\([^)]*\))/glob(\1, allow_empty = True)/g' "$temp_file"
    
    # Add copts if missing
    if ! grep -q "copts.*=.*\[" "$temp_file"; then
        # Find the closing bracket of swift_library
        awk -v copts="$COPTS_BLOCK" '
        /swift_library\(/ { in_lib=1 }
        in_lib && /\)/ && !found {
            print copts
            found=1
        }
        { print }
        ' "$temp_file" > "${temp_file}.new"
        mv "${temp_file}.new" "$temp_file"
    fi
    
    # Move the fixed file back
    mv "$temp_file" "$build_file"
    echo -e "${GREEN}✓ Fixed $build_file${NC}"
}

# Find all BUILD.bazel files and fix them
find /Users/mpy/CascadeProjects/UmbraCore/Sources -name BUILD.bazel | while read -r build_file; do
    fix_build_file "$build_file"
done

echo -e "\n${BLUE}All BUILD files have been updated. Please review the changes before committing.${NC}"
