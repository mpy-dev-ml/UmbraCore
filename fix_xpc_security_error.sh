#!/bin/bash
# Comprehensive XPCSecurityError Fix Script
# This script fixes all issues related to the missing XPCSecurityError type
# by replacing it with ErrorHandlingDomains.UmbraErrors.Security.Protocols

set -e  # Exit on error

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UmbraCore XPCSecurityError Fix Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Make sure the migration script is executable
chmod +x xpc_security_error_migration.py

# Check if we need to create a backup
echo -e "${YELLOW}Creating backup of critical files...${NC}"
TODAY=$(date +%Y%m%d)
BACKUP_DIR="./xpc_fix_backup_${TODAY}"
mkdir -p "${BACKUP_DIR}"

# Files to back up
find . -name "*.swift" -type f -exec grep -l "XPCSecurityError" {} \; | while read file; do
    relative_path=${file#./}
    backup_path="${BACKUP_DIR}/${relative_path}"
    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"
done

echo -e "${GREEN}Backup created in ${BACKUP_DIR}${NC}"
echo

# Run the migration script
echo -e "${YELLOW}Step 1: Running automated XPCSecurityError replacement...${NC}"
./xpc_security_error_migration.py

# Specifically fix LoggingService.swift and CredentialManager.swift
echo -e "${YELLOW}Step 2: Specifically fixing key files with issues...${NC}"

# Find and fix LoggingService.swift
find . -path "*/Features/Logging/Services/LoggingService.swift" -type f | while read file; do
    echo -e "${BLUE}Fixing $file...${NC}"
    sed -i.bak 's/XPCProtocolsCore\.XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    sed -i.bak 's/XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    
    # Add import if needed
    if ! grep -q "import ErrorHandlingDomains" "$file"; then
        awk 'NR==1{print "import ErrorHandlingDomains"}1' "$file" > "$file.new" && mv "$file.new" "$file"
    fi
    rm -f "$file.bak"
done

# Find and fix CredentialManager.swift
find . -path "*/CryptoTypes/Services/CredentialManager.swift" -type f | while read file; do
    echo -e "${BLUE}Fixing $file...${NC}"
    sed -i.bak 's/XPCProtocolsCore\.XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    sed -i.bak 's/XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    
    # Add import if needed
    if ! grep -q "import ErrorHandlingDomains" "$file"; then
        awk 'NR==1{print "import ErrorHandlingDomains"}1' "$file" > "$file.new" && mv "$file.new" "$file"
    fi
    rm -f "$file.bak"
done

# Fix SecurityService.swift
find . -path "*/UmbraSecurity/Services/SecurityService.swift" -type f | while read file; do
    echo -e "${BLUE}Fixing $file...${NC}"
    sed -i.bak 's/XPCProtocolsCore\.XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    sed -i.bak 's/XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    
    # Add import if needed
    if ! grep -q "import ErrorHandlingDomains" "$file"; then
        awk 'NR==1{print "import ErrorHandlingDomains"}1' "$file" > "$file.new" && mv "$file.new" "$file"
    fi
    rm -f "$file.bak"
done

# Fix CryptoErrorMapper
find . -path "*/SecurityImplementation/Sources/CryptoServices/Core/CryptoErrorMapper.swift" -type f | while read file; do
    echo -e "${BLUE}Fixing $file...${NC}"
    sed -i.bak 's/XPCProtocolsCore\.XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    sed -i.bak 's/XPCSecurityError/ErrorHandlingDomains.UmbraErrors.Security.Protocols/g' "$file"
    
    # Add import if needed
    if ! grep -q "import ErrorHandlingDomains" "$file"; then
        awk 'NR==1{print "import ErrorHandlingDomains"}1' "$file" > "$file.new" && mv "$file.new" "$file"
    fi
    rm -f "$file.bak"
done

echo
echo -e "${YELLOW}Step 3: Building project to verify fixes...${NC}"
if command -v bazelisk &> /dev/null; then
    # Run a partial build to check if errors were fixed
    bazelisk build //Sources/... --aspects=//tools/aspects.bzl%print_aspect -k --keep_going 2>&1 | tee xpc_error_fix_build_results.log
    
    # Analyze results
    if grep -q "XPCSecurityError" xpc_error_fix_build_results.log; then
        echo
        echo -e "${RED}Some XPCSecurityError references still exist in the codebase.${NC}"
        echo -e "${YELLOW}Files with remaining references:${NC}"
        grep -A 2 -B 2 "XPCSecurityError" xpc_error_fix_build_results.log | grep "\.swift" | sort | uniq
    else
        echo -e "${GREEN}No XPCSecurityError references found in build output.${NC}"
        echo -e "${GREEN}The fix appears to be successful!${NC}"
    fi
else
    echo -e "${YELLOW}bazelisk not found - skipping build step.${NC}"
    echo -e "${YELLOW}Please run 'bazelisk build //...' manually to verify the fixes.${NC}"
fi

echo
echo -e "${GREEN}Fix script completed!${NC}"
echo -e "${YELLOW}Please review the XPC_PROTOCOLS_MIGRATION_GUIDE.md for more information.${NC}"
echo -e "${YELLOW}If issues persist, check the log in xpc_error_fix_build_results.log${NC}"
