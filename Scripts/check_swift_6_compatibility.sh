#!/bin/bash
# Script to check Swift 6 compatibility in a codebase

set -eo pipefail

# Define colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

SWIFT_VERSION=$(swift --version | head -n 1)
echo -e "${BLUE}Swift version: ${NC}${SWIFT_VERSION}"
echo

# Check if run from project root
if [ ! -d "Sources" ] || [ ! -d "Tests" ]; then
  echo -e "${RED}Error: Please run this script from the project root directory.${NC}"
  exit 1
fi

MODULES=(
  "XPCProtocolsCore"
  "SecurityProtocolsCore"
  "SecurityInterfaces"
  "SecurityInterfacesBase"
  "UmbraCoreTypes"
)

echo -e "${CYAN}Checking Swift 6 compatibility for UmbraCore modules...${NC}"
echo

function check_module() {
  local module=$1
  echo -e "${MAGENTA}Checking $module...${NC}"
  
  swiftc -swift-version 5 \
    -target arm64-apple-macos14.0 \
    -warn-swift-5-to-swift-6-path \
    -enable-upcoming-feature Isolated \
    -enable-upcoming-feature ExistentialAny \
    -enable-upcoming-feature StrictConcurrency \
    -enable-upcoming-feature InternalImportsByDefault \
    -strict-concurrency=complete \
    -enable-actor-data-race-checks \
    -warn-concurrency \
    -module-name "$module" \
    -I ./Sources \
    -parse ./Sources/$module/**/*.swift
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ $module passed Swift 6 compatibility checks${NC}"
    return 0
  else
    echo -e "${RED}❌ $module failed Swift 6 compatibility checks${NC}"
    return 1
  fi
}

SUCCESS_COUNT=0
FAILURE_COUNT=0

for module in "${MODULES[@]}"; do
  if check_module "$module"; then
    ((SUCCESS_COUNT++))
  else
    ((FAILURE_COUNT++))
  fi
  echo
done

echo -e "${BLUE}=== Swift 6 Compatibility Summary ===${NC}"
echo -e "${GREEN}Modules passing: $SUCCESS_COUNT${NC}"
echo -e "${RED}Modules failing: $FAILURE_COUNT${NC}"

if [ $FAILURE_COUNT -gt 0 ]; then
  echo -e "\n${YELLOW}Recommendations:${NC}"
  echo -e "1. Address all 'will become an error in Swift 6' warnings"
  echo -e "2. Ensure proper use of 'any' for existential types"
  echo -e "3. Fix all actor isolation warnings"
  echo -e "4. Review concurrency warnings and ensure proper async/await usage"
  echo -e "5. Fix ambiguous type references with explicit module qualifiers"
  echo -e "\nRun with specific module checks: ${CYAN}bazel build //Sources/ModuleName:ModuleName --config=swift_6_ready${NC}"
  exit 1
else
  echo -e "\n${GREEN}All modules are Swift 6 compatible!${NC}"
  exit 0
fi
