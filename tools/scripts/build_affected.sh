#!/bin/bash
# Build only targets affected by changes since the last commit
# This is a simplified version - you may want to enhance it

CHANGED_FILES=$(git diff --name-only HEAD~1)
TARGETS=()

for file in $CHANGED_FILES; do
    dir=$(dirname "$file")
    while [[ "$dir" != "." && "$dir" != "/" ]]; do
        if [[ -f "$dir/BUILD.bazel" ]]; then
            target="//$(echo $dir | sed 's/^\.\///')"
            TARGETS+=("$target")
            break
        fi
        dir=$(dirname "$dir")
    done
done

# Remove duplicates
UNIQUE_TARGETS=($(echo "${TARGETS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [[ ${#UNIQUE_TARGETS[@]} -eq 0 ]]; then
    echo "No targets affected by recent changes"
    exit 0
fi

echo "Building affected targets: ${UNIQUE_TARGETS[@]}"
bazel build "${UNIQUE_TARGETS[@]}"
