#!/bin/bash
# XPC Protocol Migration Script
# This script runs the automated XPC security error migration and provides
# additional tools for handling specific migration cases.

set -e  # Exit on error

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UmbraCore XPC Protocol Migration Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is required to run this script${NC}"
    exit 1
fi

# Make sure the migration script is executable
chmod +x xpc_security_error_migration.py

echo -e "${YELLOW}Step 1: Running automated XPCSecurityError replacement...${NC}"
./xpc_security_error_migration.py

echo
echo -e "${YELLOW}Step 2: Building project to identify any remaining issues...${NC}"
if command -v bazelisk &> /dev/null; then
    # Run a partial build to check if errors were fixed
    bazelisk build //... -k --keep_going 2>&1 | tee xpc_migration_build_results.log
    
    if grep -q "XPCSecurityError" xpc_migration_build_results.log; then
        echo
        echo -e "${RED}Some XPCSecurityError references still exist in the codebase.${NC}"
        echo -e "${YELLOW}Files with remaining references:${NC}"
        grep -B 1 "XPCSecurityError" xpc_migration_build_results.log | grep "\.swift" | sort | uniq
    else
        echo -e "${GREEN}No XPCSecurityError references found in build output.${NC}"
    fi
else
    echo -e "${YELLOW}bazelisk not found - skipping build step.${NC}"
    echo -e "${YELLOW}Please run 'bazelisk build //...' manually after the migration.${NC}"
fi

echo
echo -e "${YELLOW}Step 3: Checking for other common XPC protocol issues...${NC}"
# Look for any remaining XPC-related issues
echo -e "${BLUE}Searching for legacy XPC protocol references...${NC}"
find . -name "*.swift" -type f -exec grep -l "XPCProtocolsCore" {} \; | sort

echo
echo -e "${GREEN}Migration script completed!${NC}"
echo -e "${YELLOW}Please review the XPC_PROTOCOLS_MIGRATION_GUIDE.md for more information.${NC}"
echo -e "${YELLOW}Some manual fixes may still be required.${NC}"
