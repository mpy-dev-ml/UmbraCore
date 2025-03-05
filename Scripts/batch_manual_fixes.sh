#!/bin/bash
# batch_manual_fixes.sh
#
# Apply manual fixes to all migrated files that need further corrections

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
MANUAL_FIXES_SCRIPT="$SCRIPT_DIR/manual_fixes_xpc.sh"

# Ensure manual fixes script is executable
chmod +x "$MANUAL_FIXES_SCRIPT"

# Get list of migrated files
if [ -f "$SCRIPT_DIR/xpc_migration_manager.sh" ]; then
  echo "Getting list of migrated files from migration manager..."
  # Skip the header line and get only file paths
  MIGRATED_FILES=$("$SCRIPT_DIR/xpc_migration_manager.sh" list migrated | grep -v "^##" | grep "^/")
else
  echo "Error: Migration manager script not found"
  exit 1
fi

# Check if we got any files
if [ -z "$MIGRATED_FILES" ]; then
  echo "No migrated files found"
  exit 1
fi

# Count number of files to process
NUM_FILES=$(echo "$MIGRATED_FILES" | wc -l | tr -d ' ')
echo "Found $NUM_FILES migrated files to process for manual fixes"

# Process each file
COUNT=0
SUCCESSFUL=0
FAILED=0

for FILE in $MIGRATED_FILES; do
  COUNT=$((COUNT + 1))
  
  echo -e "\n[$COUNT/$NUM_FILES] Processing: $FILE"
  
  if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    FAILED=$((FAILED + 1))
    continue
  fi
  
  # Check if file has issues that need manual fixes
  NEEDS_FIXES=0
  
  if grep -q "async throws" "$FILE" || grep -q "throw " "$FILE" || grep -q "try " "$FILE"; then
    NEEDS_FIXES=1
    
    if grep -q "async throws" "$FILE"; then
      echo "- File has 'async throws' patterns that need fixing"
    fi
    
    if grep -q "throw " "$FILE"; then
      echo "- File has 'throw' statements that need fixing"
    fi
    
    if grep -q "try " "$FILE"; then
      echo "- File has 'try' statements that may need review"
    fi
  fi
  
  if [ $NEEDS_FIXES -eq 0 ]; then
    echo "- No manual fixes needed"
    SUCCESSFUL=$((SUCCESSFUL + 1))
    continue
  fi
  
  echo "Applying manual fixes..."
  if "$MANUAL_FIXES_SCRIPT" "$FILE"; then
    echo "Manual fixes successful!"
    SUCCESSFUL=$((SUCCESSFUL + 1))
  else
    echo "Manual fixes failed!"
    FAILED=$((FAILED + 1))
  fi
done

echo -e "\n## Manual Fixes Summary ##"
echo "Total files processed: $COUNT"
echo "Successfully processed: $SUCCESSFUL"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
  echo "⚠️  Some manual fixes failed. Check the log above for details."
else
  echo "✅ All manual fixes completed successfully!"
fi

echo -e "\nCompleted manual fixes for all migrated files"

# Run verification script if available
if [ -f "$SCRIPT_DIR/verify_migration_completion.sh" ]; then
  echo -e "\n## Running verification ##"
  "$SCRIPT_DIR/verify_migration_completion.sh"
fi
