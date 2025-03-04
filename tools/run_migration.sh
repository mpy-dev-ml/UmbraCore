#!/bin/bash

# Run the SecureBytes to UmbraCoreTypes migration tool
# This script provides a more convenient way to run the migration

# Set default values
DRY_RUN=true
VERBOSE=false
BACKUP=true
ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"

# Parse command line options
while getopts "nvrd:b" opt; do
  case $opt in
    n) DRY_RUN=false ;;    # Actually perform the changes
    v) VERBOSE=true ;;     # Enable verbose output
    r) DRY_RUN=true ;;     # Run in dry-run mode (default)
    d) ROOT_DIR="$OPTARG" ;;  # Set custom root directory
    b) BACKUP=false ;;     # Disable backup creation
    *) echo "Usage: $0 [-n] [-v] [-r] [-d directory] [-b]" >&2
       echo "  -n: Actually perform changes (default is dry-run)"
       echo "  -v: Enable verbose output"
       echo "  -r: Run in dry-run mode (default)"
       echo "  -d: Set root directory (default is $ROOT_DIR)"
       echo "  -b: Disable backup creation (default is to create backups)"
       exit 1 ;;
  esac
done

# Convert boolean flags to Go command line flags
DRY_RUN_FLAG=""
if [ "$DRY_RUN" = true ]; then
  DRY_RUN_FLAG="-dry-run=true"
else
  DRY_RUN_FLAG="-dry-run=false"
fi

VERBOSE_FLAG=""
if [ "$VERBOSE" = true ]; then
  VERBOSE_FLAG="-verbose=true"
else
  VERBOSE_FLAG="-verbose=false"
fi

BACKUP_FLAG=""
if [ "$BACKUP" = true ]; then
  BACKUP_FLAG="-backup=true"
else
  BACKUP_FLAG="-backup=false"
fi

echo "Running SecureBytes migration tool..."
echo "Root directory: $ROOT_DIR"
echo "Dry run: $DRY_RUN"
echo "Verbose: $VERBOSE"
echo "Create backups: $BACKUP"
echo "------------------------"

# Run the migration tool
cd "$(dirname "$0")" || exit 1
go run secure_bytes_migration.go -dir="$ROOT_DIR" $DRY_RUN_FLAG $VERBOSE_FLAG $BACKUP_FLAG

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "Error: Migration tool exited with code $EXIT_CODE"
  exit $EXIT_CODE
fi

echo "------------------------"
echo "Migration completed successfully."

if [ "$DRY_RUN" = true ]; then
  echo "This was a dry run. No files were actually modified."
  echo "Run with -n flag to apply the changes."
else
  echo "Changes have been applied to the files."
  echo "Backup files (.bak) were created for each modified file."
fi
