#!/bin/bash

# Function to generate a BUILD.bazel file for a directory containing Swift files
generate_build_file() {
    local dir="$1"
    local module_name=$(basename "$dir")
    local target_name=$(echo "$dir" | tr '/' '_' | tr '.' '_')
    
    # Find all Swift files in the directory
    local swift_files=$(find "$dir" -maxdepth 1 -name "*.swift" -type f -exec basename {} \; | sort)
    
    if [ -n "$swift_files" ]; then
        echo "Generating BUILD.bazel for $dir"
        
        # Create the BUILD.bazel file
        {
            echo 'load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")'
            echo
            echo 'swift_library('
            echo '    name = "'"$target_name"'",'
            echo '    srcs = ['
            while IFS= read -r file; do
                echo '        "'"$file"'",'
            done <<< "$swift_files"
            echo '    ],'
            echo '    module_name = "'"$module_name"'",'
            echo '    visibility = ["//visibility:public"],'
            echo '    copts = ['
            echo '        "-target",'
            echo '        "arm64-apple-macos14.0",'
            echo '        "-strict-concurrency=complete",'
            echo '        "-warn-concurrency",'
            echo '        "-enable-actor-data-race-checks",'
            echo '    ],'
            echo ')'
        } > "$dir/BUILD.bazel"
    fi
}

# Find all directories containing Swift files
find Sources -type f -name "*.swift" -exec dirname {} \; | sort -u | while read dir; do
    generate_build_file "$dir"
done
