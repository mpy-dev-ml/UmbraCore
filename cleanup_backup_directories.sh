#!/bin/bash
# Script to clean up backup directories that are no longer needed
# Created: 2025-03-09

set -e  # Exit on error

ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"
LOG_FILE="$ROOT_DIR/backup_cleanup_log.txt"

echo "Backup directories cleanup log - $(date)" > "$LOG_FILE"

# Define the backup directories to remove
BACKUP_DIRS=(
  "$ROOT_DIR/namespace_refactor_backup_20250307_100705"
  "$ROOT_DIR/namespace_refactor_backup_20250307_100805"
  "$ROOT_DIR/docs_archive_backup_20250309_133936"
)

# Process each backup directory
for backup_dir in "${BACKUP_DIRS[@]}"; do
  if [ -d "$backup_dir" ]; then
    echo "Removing backup directory: $(basename "$backup_dir")"
    echo "Removing backup directory: $(basename "$backup_dir")" >> "$LOG_FILE"
    
    # List files that will be removed
    echo "Files being removed from $(basename "$backup_dir"):" >> "$LOG_FILE"
    find "$backup_dir" -type f | sort >> "$LOG_FILE"
    
    # Count the number of files
    NUM_FILES=$(find "$backup_dir" -type f | wc -l)
    echo "Total files removed from $(basename "$backup_dir"): $NUM_FILES" >> "$LOG_FILE"
    
    # Remove the directory
    rm -rf "$backup_dir"
    echo "Successfully removed: $(basename "$backup_dir")" >> "$LOG_FILE"
    echo ""
  else
    echo "Directory not found: $(basename "$backup_dir")"
    echo "Directory not found: $(basename "$backup_dir")" >> "$LOG_FILE"
  fi
done

echo "Backup directory cleanup complete!"
echo "Backup directory cleanup complete!" >> "$LOG_FILE"
echo "Log file created at: $LOG_FILE"
