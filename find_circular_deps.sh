#!/bin/bash
# Script to find circular dependencies in UmbraCore

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}UmbraCore Circular Dependency Finder${NC}"
echo "Analyzing modules for circular dependencies..."

# Define modules to check
MODULES=(
  "//Sources/SecurityInterfaces"
  "//Sources/SecurityInterfaces:XPCServiceProtocolDefinition"
  "//Sources/Core/Services"
  "//Sources/Core"
  "//Sources/SecurityUtils"
  "//Sources/UmbraSecurity/Services"
  "//Sources/CoreTypes"
  "//Sources/CoreServicesTypes"
)

# Function to check for paths between modules
check_paths() {
  local from=$1
  local to=$2
  echo -e "${YELLOW}Checking for dependency paths from ${from} to ${to}${NC}"
  
  # Use Bazel query to find all paths
  PATHS=$(bazel query "allpaths(${from}, ${to})" 2>/dev/null)
  
  if [ -n "$PATHS" ]; then
    echo -e "${RED}CIRCULAR DEPENDENCY FOUND:${NC}"
    echo "$PATHS"
    echo ""
    echo -e "${YELLOW}Checking reverse path:${NC}"
    REVERSE=$(bazel query "allpaths(${to}, ${from})" 2>/dev/null)
    echo "$REVERSE"
    echo ""
    return 0
  else
    echo -e "${GREEN}No path found.${NC}"
    echo ""
    return 1
  fi
}

# Check each pair of modules
FOUND_CIRCULAR=0

for ((i=0; i<${#MODULES[@]}; i++)); do
  for ((j=i+1; j<${#MODULES[@]}; j++)); do
    FROM="${MODULES[$i]}"
    TO="${MODULES[$j]}"
    
    # Check path from i to j
    check_paths "$FROM" "$TO"
    PATH_FROM_TO=$?
    
    # If path exists, check reverse path
    if [ $PATH_FROM_TO -eq 0 ]; then
      check_paths "$TO" "$FROM"
      PATH_TO_FROM=$?
      
      # If both paths exist, we have a circular dependency
      if [ $PATH_TO_FROM -eq 0 ]; then
        echo -e "${RED}CIRCULAR DEPENDENCY confirmed between ${FROM} and ${TO}${NC}"
        echo ""
        FOUND_CIRCULAR=1
      fi
    fi
  done
done

# Summary
if [ $FOUND_CIRCULAR -eq 1 ]; then
  echo -e "${RED}Circular dependencies found in the codebase.${NC}"
  echo "See refactoring_plan.md for resolution strategy."
else
  echo -e "${GREEN}No circular dependencies found between the checked modules.${NC}"
fi

# Check specific modules that were problematic
echo -e "\n${BLUE}Checking specific problem modules:${NC}"
echo -e "${YELLOW}Checking Foundation and XPCServiceProtocolDefinition:${NC}"
bazel query "deps(//Sources/SecurityInterfaces:XPCServiceProtocolDefinition)" --output=build
