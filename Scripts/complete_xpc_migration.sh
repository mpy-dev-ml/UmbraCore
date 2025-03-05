#!/bin/bash
# complete_xpc_migration.sh
#
# Comprehensive script to run the entire XPC migration process
# combining all migration tools in the correct sequence

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Display banner
echo "=================================================="
echo "       UmbraCore XPC Protocol Migration Tool      "
echo "=================================================="
echo ""

# Check for required tools
echo "Checking prerequisites..."
MISSING_TOOLS=false

if ! command -v go &> /dev/null; then
  echo "❌ Go not found. Please install Go to continue."
  MISSING_TOOLS=true
fi

if ! command -v jq &> /dev/null; then
  echo "❌ jq not found. Please install jq to continue."
  MISSING_TOOLS=true
fi

if [ "$MISSING_TOOLS" = true ]; then
  echo "Please install the missing tools and try again."
  exit 1
fi

echo "✅ All prerequisites met"

# Make all scripts executable
echo "Setting up scripts..."
chmod +x "$SCRIPT_DIR"/*.sh

# Step 1: Run the XPC protocol analyzer if needed
if [ ! -f "$PROJECT_ROOT/xpc_protocol_analysis.json" ]; then
  echo -e "\n## Step 1: Running XPC protocol analyzer ##"
  if [ -f "$SCRIPT_DIR/xpc_protocol_analyzer.go" ]; then
    echo "Analyzing codebase..."
    (cd "$SCRIPT_DIR" && go run xpc_protocol_analyzer.go -output "$PROJECT_ROOT/xpc_protocol_analysis.json")
    echo "✅ Analysis complete"
  else
    echo "❌ XPC protocol analyzer not found. Please ensure it exists at $SCRIPT_DIR/xpc_protocol_analyzer.go"
    exit 1
  fi
else
  echo -e "\n## Step 1: Using existing XPC protocol analysis ##"
  echo "✅ Analysis file found at $PROJECT_ROOT/xpc_protocol_analysis.json"
fi

# Step 2: Initialize migration tracking if not already done
echo -e "\n## Step 2: Setting up migration tracking ##"
if [ -f "$SCRIPT_DIR/xpc_migration_manager.sh" ]; then
  if "$SCRIPT_DIR/xpc_migration_manager.sh" status | grep -q "No migration data"; then
    echo "Initializing migration tracking..."
    "$SCRIPT_DIR/xpc_migration_manager.sh" init
  else
    echo "Migration tracking already initialized"
  fi
  echo "✅ Migration tracking ready"
else
  echo "❌ Migration manager not found. Please ensure it exists at $SCRIPT_DIR/xpc_migration_manager.sh"
  exit 1
fi

# Step 3: Display current migration status
echo -e "\n## Step 3: Current migration status ##"
"$SCRIPT_DIR/xpc_migration_manager.sh" status

# Step 4: Ask which modules to process
echo -e "\n## Step 4: Module selection ##"
echo "Available modules:"
MODULES=$(jq -r '.fileAnalyses[].module' "$PROJECT_ROOT/xpc_protocol_analysis.json" | sort | uniq)
echo "$MODULES" | nl -w2 -s") "

echo ""
echo "Enter module numbers to process (comma-separated), or 'all' for all modules:"
read -r MODULE_SELECTION

# Process module selection
SELECTED_MODULES=()
if [ "$MODULE_SELECTION" = "all" ]; then
  SELECTED_MODULES=($MODULES)
else
  IFS=',' read -ra INDICES <<< "$MODULE_SELECTION"
  for INDEX in "${INDICES[@]}"; do
    MODULE_LINE=$(echo "$MODULES" | sed -n "${INDEX}p")
    if [ -n "$MODULE_LINE" ]; then
      SELECTED_MODULES+=("$MODULE_LINE")
    fi
  done
fi

if [ ${#SELECTED_MODULES[@]} -eq 0 ]; then
  echo "No valid modules selected. Exiting."
  exit 1
fi

echo "Selected modules: ${SELECTED_MODULES[*]}"

# Step 5: Ask if dryrun is needed
echo -e "\n## Step 5: Migration mode ##"
echo "Do you want to perform a dry run first? (y/n)"
read -r DRY_RUN_CHOICE
DRY_RUN_FLAG=""
if [[ "$DRY_RUN_CHOICE" =~ ^[Yy] ]]; then
  DRY_RUN_FLAG="--dry-run"
  echo "Performing dry run..."
else
  echo "Performing actual migration..."
fi

# Step 6: Process each module
echo -e "\n## Step 6: Processing modules ##"
for MODULE in "${SELECTED_MODULES[@]}"; do
  echo -e "\n### Processing module: $MODULE ###"
  
  # Step 6.1: Run batch migration first
  echo "Running basic migration..."
  if "$SCRIPT_DIR/batch_migrate_xpc.sh" "$MODULE" $DRY_RUN_FLAG; then
    echo "✅ Basic migration complete for $MODULE"
  else
    echo "⚠️ Basic migration had issues for $MODULE"
    continue
  fi
  
  # Skip remaining steps for dry run
  if [ -n "$DRY_RUN_FLAG" ]; then
    continue
  fi
  
  # Step 6.2: Apply manual fixes to migrated files
  echo "Applying manual fixes..."
  "$SCRIPT_DIR/run_advanced_xpc_fixes.sh" --module "$MODULE" --verbose
  echo "✅ Manual fixes applied for $MODULE"
done

# Step 7: Run final verification
echo -e "\n## Step 7: Final verification ##"
if [ -f "$SCRIPT_DIR/verify_migration_completion.sh" ]; then
  "$SCRIPT_DIR/verify_migration_completion.sh"
  echo "✅ Verification complete"
else
  echo "❌ Verification script not found"
fi

echo -e "\n## Migration process completed ##"
echo "Please review the changes and run tests to ensure everything is working correctly."
echo "If you encounter any issues, you can restore backup files with the .bak or .gobackup extensions."
echo "=================================================="
