#!/bin/bash
# batch_migrate_xpc.sh
#
# Batch migration script for XPC protocol migration

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <module-name> [--dry-run]"
  echo "  --dry-run: Only show which files would be migrated without making changes"
  exit 1
fi

MODULE="$1"
DRY_RUN=0

if [ "$2" == "--dry-run" ]; then
  DRY_RUN=1
  echo "Running in dry run mode - no files will be modified"
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENHANCED_SCRIPT="$SCRIPT_DIR/enhanced_xpc_migration.sh"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Ensure the enhanced migration script is executable
chmod +x "$ENHANCED_SCRIPT"

# Check if an analysis report exists, otherwise run the analyzer
ANALYSIS_REPORT="$PROJECT_ROOT/xpc_protocol_analysis.json"
if [ ! -f "$ANALYSIS_REPORT" ] && [ -f "$SCRIPT_DIR/xpc_protocol_analyzer.go" ]; then
  echo "Analysis report not found. Running analyzer first..."
  (cd "$SCRIPT_DIR" && go run xpc_protocol_analyzer.go -output "$ANALYSIS_REPORT")
elif [ ! -f "$ANALYSIS_REPORT" ]; then
  echo "Error: Analysis report not found and analyzer script not available"
  echo "Please run the XPC protocol analyzer first or provide a list of files"
  exit 1
fi

# If analysis report exists and has JSON format, use it to get files for the module
if [ -f "$ANALYSIS_REPORT" ] && grep -q "{" "$ANALYSIS_REPORT"; then
  if command -v jq >/dev/null 2>&1; then
    FILES=$(jq -r ".fileAnalyses[] | select(.module == \"$MODULE\" and .needsRefactoring == true) | .filePath" "$ANALYSIS_REPORT")
  else
    echo "jq not found. Please install jq or manually specify files to migrate."
    exit 1
  fi
else
  echo "Error: Analysis report not found or invalid format"
  exit 1
fi

# If no files found for the module
if [ -z "$FILES" ]; then
  echo "No files found for module: $MODULE"
  echo "Available modules:"
  jq -r '.fileAnalyses[].module' "$ANALYSIS_REPORT" | sort | uniq
  exit 1
fi

# Count number of files to migrate
NUM_FILES=$(echo "$FILES" | wc -l | tr -d ' ')
echo "Found $NUM_FILES files to migrate in module: $MODULE"

# Process each file
COUNT=0
SUCCESSFUL=0
FAILED=0

for FILE in $FILES; do
  FULL_PATH="$FILE"  # File paths in the JSON should already be absolute
  COUNT=$((COUNT + 1))
  
  echo -e "\n[$COUNT/$NUM_FILES] Processing: $FILE"
  
  if [ ! -f "$FULL_PATH" ]; then
    echo "Error: File not found: $FULL_PATH"
    FAILED=$((FAILED + 1))
    continue
  fi
  
  if [ $DRY_RUN -eq 1 ]; then
    echo "  (Dry run mode - would migrate this file)"
    continue
  fi
  
  echo "Migrating..."
  if "$ENHANCED_SCRIPT" "$FULL_PATH"; then
    echo "Migration successful!"
    SUCCESSFUL=$((SUCCESSFUL + 1))
    
    # If migration tracking script exists, mark the file as migrated
    if [ -f "$SCRIPT_DIR/xpc_migration_manager.sh" ]; then
      "$SCRIPT_DIR/xpc_migration_manager.sh" complete "$FILE"
      echo "Marked as migrated in tracking system"
    fi
  else
    echo "Migration failed!"
    FAILED=$((FAILED + 1))
  fi
done

echo -e "\n## Migration Summary ##"
echo "Module: $MODULE"
echo "Total files processed: $COUNT"

if [ $DRY_RUN -eq 1 ]; then
  echo "Dry run completed. No files were modified."
else
  echo "Successfully migrated: $SUCCESSFUL"
  echo "Failed migrations: $FAILED"
  
  if [ $FAILED -gt 0 ]; then
    echo "⚠️  Some migrations failed. Check the log above for details."
  else
    echo "✅ All migrations completed successfully!"
  fi
fi

echo -e "\nCompleted batch migration for module: $MODULE"
