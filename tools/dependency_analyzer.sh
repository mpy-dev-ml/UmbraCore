#!/bin/bash
# Script to analyze dependencies using Bazel query

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default target pattern
TARGET_PATTERN=${1:-"//Sources/..."}

echo -e "${GREEN}Analyzing dependencies for $TARGET_PATTERN${NC}"

# Get all targets
echo -e "${YELLOW}Finding all targets...${NC}"
ALL_TARGETS=$(bazel query "$TARGET_PATTERN" --output=label)

# Create a temporary directory for reports
REPORT_DIR=$(mktemp -d)
echo -e "${BLUE}Reports will be saved in $REPORT_DIR${NC}"

# Analyze each target
for target in $ALL_TARGETS; do
  echo -e "${YELLOW}Analyzing $target...${NC}"
  
  # Get the target's dependencies
  DEPS=$(bazel query "deps($target)" --noimplicit_deps --output=label | grep "^//Sources" | sort)
  
  # Get the target's BUILD file
  TARGET_PATH=$(echo $target | sed 's|//||' | sed 's|:|/|')
  BUILD_FILE=$(dirname "$TARGET_PATH")/BUILD.bazel
  
  # Check if BUILD file exists
  if [ ! -f "$BUILD_FILE" ]; then
    echo -e "${RED}BUILD file not found for $target${NC}"
    continue
  fi
  
  # Get the declared dependencies
  DECLARED_DEPS=$(grep -E "deps\s*=\s*\[" -A 50 "$BUILD_FILE" | grep -E "//Sources" | sed 's/[",]//g' | sed 's/^ *//' | sort)
  
  # Compare dependencies
  echo -e "${BLUE}Checking for missing dependencies...${NC}"
  
  # Save to report file
  REPORT_FILE="$REPORT_DIR/$(basename $(dirname $TARGET_PATH)).txt"
  echo "=== Dependency Analysis for $target ===" > "$REPORT_FILE"
  echo "BUILD file: $BUILD_FILE" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Actual dependencies:" >> "$REPORT_FILE"
  echo "$DEPS" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Declared dependencies:" >> "$REPORT_FILE"
  echo "$DECLARED_DEPS" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  
  # Find missing dependencies
  echo "Potentially missing dependencies:" >> "$REPORT_FILE"
  for dep in $DEPS; do
    if ! echo "$DECLARED_DEPS" | grep -q "$dep"; then
      echo "  $dep" >> "$REPORT_FILE"
      echo -e "${RED}Missing dependency in $target: $dep${NC}"
    fi
  done
  
  echo -e "${GREEN}Report saved to $REPORT_FILE${NC}"
done

echo -e "${GREEN}Analysis complete. Reports saved in $REPORT_DIR${NC}"
echo -e "${YELLOW}You may want to review the reports and update your BUILD files accordingly.${NC}"
