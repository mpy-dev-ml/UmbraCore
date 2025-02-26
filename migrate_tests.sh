#!/bin/bash

# Script to migrate tests to the centralised UmbraTestKit structure
# Usage: ./migrate_tests.sh [test_category]

set -e

# Base directories
SOURCE_DIR="Tests"
TARGET_DIR="Tests/UmbraTestKit/Sources/UmbraTestKit/Categories"

# Function to migrate a test category
migrate_category() {
    local category=$1
    local source="${SOURCE_DIR}/${category}Tests"
    local target="${TARGET_DIR}/${category}"
    
    echo "Migrating ${category}Tests to ${target}..."
    
    # Create target directory if it doesn't exist
    mkdir -p "${target}"
    
    # Copy test files
    find "${source}" -name "*.swift" -not -path "*/BUILD.bazel/*" | while read file; do
        # Get relative path within source directory
        local rel_path="${file#${source}/}"
        
        # Create target directory structure
        local target_dir="${target}/$(dirname "${rel_path}")"
        mkdir -p "${target_dir}"
        
        # Copy file
        cp "${file}" "${target_dir}/"
        
        echo "  Copied ${file} to ${target_dir}/"
    done
    
    echo "Migration of ${category}Tests completed."
}

# Main script
if [ $# -eq 0 ]; then
    echo "Usage: $0 [test_category]"
    echo "Available categories:"
    find "${SOURCE_DIR}" -maxdepth 1 -name "*Tests" -type d | sed "s|${SOURCE_DIR}/||" | sed "s|Tests$||" | sort
    exit 1
fi

category=$1
category=${category%Tests}  # Remove Tests suffix if present

# Check if category exists
if [ ! -d "${SOURCE_DIR}/${category}Tests" ]; then
    echo "Error: Category ${category}Tests not found in ${SOURCE_DIR}"
    exit 1
fi

# Migrate the category
migrate_category "${category}"

echo "Done."
