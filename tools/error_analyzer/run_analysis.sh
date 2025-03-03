#!/bin/bash

# Exit on any error
set -e

# Default values
PROJECT_ROOT="/Users/mpy/CascadeProjects/UmbraCore"
SOURCES_DIR="$PROJECT_ROOT/Sources"
OUTPUT_FILE="$PROJECT_ROOT/error_analysis_report.md"

# Build the tool
echo "Building error analyzer..."
go build -o error_analyzer

# Run the analysis
echo "Running error analysis on $SOURCES_DIR..."
./error_analyzer --dir "$SOURCES_DIR" --output "$OUTPUT_FILE"

echo "Analysis complete! Report generated at $OUTPUT_FILE"
echo "----------------------------------------"
echo "Next steps:"
echo "1. Review the report"
echo "2. Create the CoreErrors module"
echo "3. Begin implementing the migration plan"
echo "----------------------------------------"
