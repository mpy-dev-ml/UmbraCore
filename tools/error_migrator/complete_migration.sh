#!/bin/bash
# Complete Error Migration Script
# This script runs all the steps necessary to complete the error migration

# Enable command tracing for debugging if needed
# set -x

# Set the base directory
UMBRA_ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
MIGRATOR_DIR="$UMBRA_ROOT_DIR/tools/error_migrator"
cd "$MIGRATOR_DIR" || exit 1

echo "====================================================="
echo "           ERROR MIGRATION SCRIPT"
echo "====================================================="
echo "This script will migrate error types to the CoreErrors module."
echo "It will perform the following steps:"
echo "  1. Run the Error Migrator tool to generate consolidated error types"
echo "  2. Copy the generated files to the appropriate locations"
echo "  3. Update BUILD files to include the CoreErrors dependency"
echo "  4. Optionally build and test the project"
echo ""
echo "Would you like to continue? (y/n)"
read -r continue_answer
if [[ ! "$continue_answer" =~ ^[Yy]$ ]]; then
  echo "Migration aborted by user."
  exit 0
fi

echo ""
echo "====== STEP 1: Run Error Migrator Tool ======"
rm -rf ./generated_code
go run . --report "../../error_analysis_report.md" --config "migration_config.json" --output "./generated_code" --apply

# Verify that generated_code directory exists and contains files
if [ ! -d "./generated_code" ] || [ ! -f "./generated_code/CoreErrors/SecurityError.swift" ]; then
  echo "Error: Generated code directory not found or incomplete. Aborting migration."
  exit 1
fi

echo ""
echo "====== STEP 2: Apply Migration to Codebase ======"
echo "This will copy the generated files to the actual codebase."
echo "Would you like to continue? (y/n)"
read -r apply_answer
if [[ ! "$apply_answer" =~ ^[Yy]$ ]]; then
  echo "Migration process stopped after code generation."
  echo "You can find the generated files in $MIGRATOR_DIR/generated_code"
  exit 0
fi

# Run the apply script
./apply_migration.sh

echo ""
echo "====== STEP 3: Update BUILD Files ======"
echo "This will update BUILD files to include the CoreErrors dependency."
echo "Would you like to continue? (y/n)"
read -r build_update_answer
if [[ ! "$build_update_answer" =~ ^[Yy]$ ]]; then
  echo "Migration process stopped after applying files."
  echo "You will need to manually update BUILD files."
  exit 0
fi

# Run the update BUILD files script
./update_build_files.sh

echo ""
echo "====== STEP 4: Build and Test ======"
cd "$UMBRA_ROOT_DIR" || exit 1
echo "Would you like to build and test the project now? (y/n)"
read -r test_answer
if [[ "$test_answer" =~ ^[Yy]$ ]]; then
  echo "Building project..."
  if bazelisk build //...; then
    echo "Build successful!"
    echo "Running tests..."
    if bazelisk test //...; then
      echo "Tests passed successfully!"
    else
      echo "Some tests failed. Please review the test output."
    fi
  else
    echo "Build failed. Please fix the issues before proceeding."
  fi
else
  echo "Skipping build and test step."
fi

echo ""
echo "====== Migration Complete ======"
echo "Migration process has completed."
echo ""
echo "What to do next:"
echo "1. Review all changes before committing"
echo "2. Ensure that all import statements are updated to include CoreErrors where needed"
echo "3. Update any code that references the migrated error types"
echo "4. Run comprehensive tests to verify backward compatibility"
echo ""
echo "Refer to $MIGRATOR_DIR/MIGRATION_GUIDE.md for more information on the migration process."
