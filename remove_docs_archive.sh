#!/bin/bash
# Script to remove the docs/archive directory
# Created: 2025-03-09

set -e  # Exit on error

ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"
ARCHIVE_DIR="$ROOT_DIR/docs/archive"
BACKUP_DIR="$ROOT_DIR/docs_archive_backup_$(date +%Y%m%d_%H%M%S)"

# Create a log file
LOG_FILE="$ROOT_DIR/docs_archive_removal_log.txt"
echo "Documentation archive removal log - $(date)" > "$LOG_FILE"

echo "Creating backup of docs/archive directory..."
echo "Creating backup of docs/archive directory..." >> "$LOG_FILE"
mkdir -p "$BACKUP_DIR"
cp -r "$ARCHIVE_DIR"/* "$BACKUP_DIR"
echo "Backup created at: $BACKUP_DIR" >> "$LOG_FILE"

# List files that will be removed
echo "The following files will be removed:" >> "$LOG_FILE"
find "$ARCHIVE_DIR" -type f | sort >> "$LOG_FILE"

# Count the number of files
NUM_FILES=$(find "$ARCHIVE_DIR" -type f | wc -l)
echo "Total files to be removed: $NUM_FILES" >> "$LOG_FILE"

# Remove the directory
echo "Removing docs/archive directory..."
echo "Removing docs/archive directory..." >> "$LOG_FILE"
rm -rf "$ARCHIVE_DIR"

echo "Removal complete!"
echo "Removal complete!" >> "$LOG_FILE"
echo "A backup of all files has been created at: $BACKUP_DIR"
echo "A backup of all files has been created at: $BACKUP_DIR" >> "$LOG_FILE"
echo "Log file created at: $LOG_FILE"
