#!/bin/bash
# run_advanced_xpc_fixes.sh
#
# Shell script wrapper for the Go-based advanced XPC migration fixer

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
GO_SCRIPT="$SCRIPT_DIR/advanced_xpc_fixes.go"

# Check if Go is installed
if ! command -v go &> /dev/null; then
  echo "Error: Go is not installed. Please install Go to use this script."
  exit 1
fi

# Process command line arguments
FILE=""
DIR=""
DRY_RUN=false
SKIP_BACKUP=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      FILE="$2"
      shift 2
      ;;
    --dir)
      DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-backup)
      SKIP_BACKUP=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --module)
      MODULE="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --file FILE        Process a single Swift file"
      echo "  --dir DIR          Process all Swift files in a directory"
      echo "  --module MODULE    Process all files in a specific module"
      echo "  --dry-run          Perform a dry run without modifying files"
      echo "  --skip-backup      Skip creating backup files"
      echo "  --verbose          Enable verbose output"
      echo "  --help             Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Handle module-based processing
if [ -n "$MODULE" ]; then
  if [ -f "$SCRIPT_DIR/xpc_migration_manager.sh" ]; then
    echo "Getting list of files for module: $MODULE"
    MODULE_FILES=$("$SCRIPT_DIR/xpc_migration_manager.sh" list inModule "$MODULE" | grep -v "^##" | grep "^/")
    
    if [ -z "$MODULE_FILES" ]; then
      echo "No files found for module: $MODULE"
      exit 1
    fi
    
    echo "Found $(echo "$MODULE_FILES" | wc -l | tr -d ' ') files to process"
    
    # Process each file using the Go script
    for FILE_PATH in $MODULE_FILES; do
      echo "Processing: $FILE_PATH"
      GO_ARGS=""
      if [ "$DRY_RUN" = true ]; then
        GO_ARGS="$GO_ARGS -dry-run"
      fi
      if [ "$SKIP_BACKUP" = true ]; then
        GO_ARGS="$GO_ARGS -skip-backup"
      fi
      if [ "$VERBOSE" = true ]; then
        GO_ARGS="$GO_ARGS -verbose"
      fi
      
      go run "$GO_SCRIPT" -file "$FILE_PATH" $GO_ARGS
    done
    
    exit 0
  else
    echo "Error: Migration manager script not found. Cannot process by module."
    exit 1
  fi
fi

# Validate arguments
if [ -z "$FILE" ] && [ -z "$DIR" ]; then
  echo "Error: Either --file or --dir must be specified"
  exit 1
fi

# Build arguments for the Go script
GO_ARGS=""

if [ -n "$FILE" ]; then
  GO_ARGS="$GO_ARGS -file $FILE"
fi

if [ -n "$DIR" ]; then
  GO_ARGS="$GO_ARGS -dir $DIR"
fi

if [ "$DRY_RUN" = true ]; then
  GO_ARGS="$GO_ARGS -dry-run"
fi

if [ "$SKIP_BACKUP" = true ]; then
  GO_ARGS="$GO_ARGS -skip-backup"
fi

if [ "$VERBOSE" = true ]; then
  GO_ARGS="$GO_ARGS -verbose"
fi

# Run the Go script
echo "Running advanced XPC fixes..."
go run "$GO_SCRIPT" $GO_ARGS

echo "Advanced XPC fixes completed!"

# Run verification if available
if [ -f "$SCRIPT_DIR/verify_migration_completion.sh" ]; then
  echo -e "\n## Running verification ##"
  "$SCRIPT_DIR/verify_migration_completion.sh"
fi
