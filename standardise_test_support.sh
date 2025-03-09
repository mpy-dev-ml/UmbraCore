#!/bin/bash
# Script to standardise test support location to Tests/UmbraTestKit/
# Created: 2025-03-09

set -e  # Exit on error

ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"
SOURCE_DIR="$ROOT_DIR/TestSupport"
TARGET_DIR="$ROOT_DIR/Tests/UmbraTestKit"
LOG_FILE="$ROOT_DIR/test_support_standardisation_log.txt"

echo "Test support standardisation log - $(date)" > "$LOG_FILE"

# Function to check if two files are identical
are_identical() {
    diff -q "$1" "$2" >/dev/null 2>&1
    return $?
}

# Create the target directory structure if it doesn't exist
mkdir -p "$TARGET_DIR/TestKit/Mocks"
mkdir -p "$TARGET_DIR/TestKit/Helpers"
mkdir -p "$TARGET_DIR/TestKit/Common"
mkdir -p "$TARGET_DIR/TestKit/TestCases"

# Use temp file for statistics to avoid subshell issues
STATS_FILE=$(mktemp)
echo "0" > "$STATS_FILE.total"
echo "0" > "$STATS_FILE.moved"
echo "0" > "$STATS_FILE.updated"
echo "0" > "$STATS_FILE.skipped"

echo "Standardising test support files to Tests/UmbraTestKit/..."
echo "Standardising test support files to Tests/UmbraTestKit/..." >> "$LOG_FILE"

# Process each file individually to avoid subshell issues with variables
find "$SOURCE_DIR" -name "*.swift" | sort | while read -r source_file; do
    # Increment total counter
    TOTAL=$(($(cat "$STATS_FILE.total") + 1))
    echo "$TOTAL" > "$STATS_FILE.total"
    
    # Determine the relative path from TestSupport
    rel_path=$(echo "$source_file" | sed "s|$SOURCE_DIR/||")
    
    # Determine the appropriate target location based on the file's original location
    if [[ "$rel_path" == Common/* ]]; then
        target_subdir="TestKit/Common"
    elif [[ "$rel_path" == *"Mock"* ]]; then
        target_subdir="TestKit/Mocks"
    elif [[ "$rel_path" == *"TestCase"* ]]; then
        target_subdir="TestKit/TestCases"
    else
        target_subdir="TestKit/Helpers"
    fi
    
    # Extract just the filename
    filename=$(basename "$source_file")
    target_file="$TARGET_DIR/$target_subdir/$filename"
    
    echo "Processing: $rel_path"
    echo "Processing: $rel_path" >> "$LOG_FILE"
    
    if [ -f "$target_file" ]; then
        # Target file already exists, check if they're identical
        if are_identical "$source_file" "$target_file"; then
            echo "  - Skipping (identical file already exists in target): $filename"
            echo "  - Skipping (identical file already exists in target): $filename" >> "$LOG_FILE"
            SKIPPED=$(($(cat "$STATS_FILE.skipped") + 1))
            echo "$SKIPPED" > "$STATS_FILE.skipped"
        else
            # Files differ - we'll use the newer/more updated version
            # Check which file is newer or has more content
            source_size=$(wc -c < "$source_file")
            target_size=$(wc -c < "$target_file")
            
            if [[ "$target_size" -gt "$source_size" ]]; then
                echo "  - Skipping (target file appears more comprehensive): $filename"
                echo "  - Skipping (target file appears more comprehensive): $filename" >> "$LOG_FILE"
                SKIPPED=$(($(cat "$STATS_FILE.skipped") + 1))
                echo "$SKIPPED" > "$STATS_FILE.skipped"
            else
                echo "  - Updating (source file appears more comprehensive): $filename"
                echo "  - Updating (source file appears more comprehensive): $filename" >> "$LOG_FILE"
                cp "$source_file" "$target_file"
                UPDATED=$(($(cat "$STATS_FILE.updated") + 1))
                echo "$UPDATED" > "$STATS_FILE.updated"
            fi
        fi
    else
        # Target file doesn't exist, copy it
        echo "  - Moving file to target location: $filename"
        echo "  - Moving file to target location: $filename" >> "$LOG_FILE"
        cp "$source_file" "$target_file"
        MOVED=$(($(cat "$STATS_FILE.moved") + 1))
        echo "$MOVED" > "$STATS_FILE.moved"
    fi
done

# Read final statistics
TOTAL=$(cat "$STATS_FILE.total")
MOVED=$(cat "$STATS_FILE.moved")
UPDATED=$(cat "$STATS_FILE.updated")
SKIPPED=$(cat "$STATS_FILE.skipped")

# Clean up temp files
rm "$STATS_FILE.total" "$STATS_FILE.moved" "$STATS_FILE.updated" "$STATS_FILE.skipped"

# Record what we've done
echo "" >> "$LOG_FILE"
echo "Summary of standardisation process:" >> "$LOG_FILE"
echo "  - Total files processed: $TOTAL" >> "$LOG_FILE"
echo "  - Files moved to target: $MOVED" >> "$LOG_FILE"
echo "  - Files updated in target: $UPDATED" >> "$LOG_FILE"
echo "  - Files skipped: $SKIPPED" >> "$LOG_FILE"

echo ""
echo "Test support standardisation complete!"
echo "Summary:"
echo "  - Total files processed: $TOTAL"
echo "  - Files moved to target: $MOVED" 
echo "  - Files updated in target: $UPDATED"
echo "  - Files skipped: $SKIPPED"
echo ""
echo "All test support files have been standardised to Tests/UmbraTestKit/"
echo "Log file created at: $LOG_FILE"
echo ""
echo "NOTE: The original TestSupport directory has NOT been removed."
echo "After verifying everything works correctly, you can remove it with:"
echo "rm -rf '$SOURCE_DIR'"
