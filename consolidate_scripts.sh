#!/bin/bash
# Script to consolidate scripts from the root directory to tools/scripts/
# Created: 2025-03-09

set -e  # Exit on error
ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"
TARGET_DIR="$ROOT_DIR/tools/scripts"

# Create a log file to record all actions
LOG_FILE="$ROOT_DIR/script_consolidation_log.txt"
echo "Script consolidation log - $(date)" > "$LOG_FILE"

# Function to check if two files are identical
are_identical() {
    diff -q "$1" "$2" >/dev/null 2>&1
    return $?
}

# Find all script files in the root directory (excluding certain directories and files)
echo "Scanning for script files in root directory..."
echo "Scanning for script files in root directory..." >> "$LOG_FILE"

# Create a temporary file to store the list of scripts
SCRIPT_LIST=$(mktemp)
find "$ROOT_DIR" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.go" \) | grep -v "consolidate_scripts.sh" > "$SCRIPT_LIST"

# Statistics
TOTAL=0
REMOVED=0
MOVED=0
SKIPPED=0

# Process each script
while read -r script; do
    TOTAL=$((TOTAL+1))
    script_name=$(basename "$script")
    
    echo "Processing: $script_name"
    echo "Processing: $script_name" >> "$LOG_FILE"
    
    # Check if a file with the same name exists in the target directory
    if [ -f "$TARGET_DIR/$script_name" ]; then
        # Check if the files are identical
        if are_identical "$script" "$TARGET_DIR/$script_name"; then
            # Files are identical, remove the one in the root directory
            echo "  - Removing duplicate: $script_name (identical to the one in tools/scripts/)" 
            echo "  - Removing duplicate: $script_name (identical to the one in tools/scripts/)" >> "$LOG_FILE"
            rm "$script"
            REMOVED=$((REMOVED+1))
        else
            # Files have the same name but different content
            echo "  - WARNING: $script_name exists in both directories but has different content"
            echo "  - WARNING: $script_name exists in both directories but has different content" >> "$LOG_FILE"
            echo "  - Skipping to avoid overwriting. Please review manually."
            echo "  - Skipping to avoid overwriting. Please review manually." >> "$LOG_FILE"
            SKIPPED=$((SKIPPED+1))
        fi
    else
        # File doesn't exist in the target directory, move it
        echo "  - Moving unique script: $script_name to tools/scripts/"
        echo "  - Moving unique script: $script_name to tools/scripts/" >> "$LOG_FILE"
        mv "$script" "$TARGET_DIR/"
        MOVED=$((MOVED+1))
    fi
done < "$SCRIPT_LIST"

# Clean up
rm "$SCRIPT_LIST"

# Print summary
echo ""
echo "Consolidation complete!"
echo "Consolidation complete!" >> "$LOG_FILE"
echo "Summary:"
echo "Summary:" >> "$LOG_FILE"
echo "  - Total scripts processed: $TOTAL"
echo "  - Total scripts processed: $TOTAL" >> "$LOG_FILE"
echo "  - Duplicate scripts removed: $REMOVED"
echo "  - Duplicate scripts removed: $REMOVED" >> "$LOG_FILE"
echo "  - Unique scripts moved: $MOVED"
echo "  - Unique scripts moved: $MOVED" >> "$LOG_FILE"
echo "  - Scripts skipped (manual review needed): $SKIPPED"
echo "  - Scripts skipped (manual review needed): $SKIPPED" >> "$LOG_FILE"
echo ""
echo "Log file created at: $LOG_FILE"
