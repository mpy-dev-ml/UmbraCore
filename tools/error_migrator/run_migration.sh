#!/bin/bash

set -e

# Default values
REPORT_PATH="../error_analyzer/error_analysis_report.md"
CONFIG_PATH="migration_config.json"
OUTPUT_DIR="./generated_code"
DRY_RUN=true
INIT_CONFIG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --report)
      REPORT_PATH="$2"
      shift 2
      ;;
    --config)
      CONFIG_PATH="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --apply)
      DRY_RUN=false
      shift
      ;;
    --init)
      INIT_CONFIG=true
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --report PATH   Path to error analysis report (default: ../error_analyzer/error_analysis_report.md)"
      echo "  --config PATH   Path to migration configuration (default: migration_config.json)"
      echo "  --output DIR    Output directory for generated code (default: ./generated_code)"
      echo "  --apply         Apply the migration (default: dry run only)"
      echo "  --init          Initialize a default configuration file"
      echo "  --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Check if report file exists
if [ ! -f "$REPORT_PATH" ]; then
  echo "Error: Report file not found at $REPORT_PATH"
  echo "Run the error_analyzer tool first or specify a different path with --report"
  exit 1
fi

# Build the command
CMD="go run ."
CMD="$CMD -report $REPORT_PATH"
CMD="$CMD -config $CONFIG_PATH"
CMD="$CMD -outputDir $OUTPUT_DIR"
CMD="$CMD -dryRun=$DRY_RUN"

if [ "$INIT_CONFIG" = true ]; then
  CMD="$CMD -initConfig"
fi

echo "Running: $CMD"
eval "$CMD"

# Provide guidance for next steps
if [ "$INIT_CONFIG" = true ]; then
  echo ""
  echo "Next steps:"
  echo "1. Review and edit the configuration file: $CONFIG_PATH"
  echo "2. Run the migration in dry-run mode: $0 --config $CONFIG_PATH"
  echo "3. Apply the migration: $0 --config $CONFIG_PATH --apply"
elif [ "$DRY_RUN" = true ]; then
  echo ""
  echo "This was a dry run. To apply the migration, run:"
  echo "$0 --config $CONFIG_PATH --apply"
else
  echo ""
  echo "Migration completed and applied."
  echo "Generated code is available in: $OUTPUT_DIR"
fi
