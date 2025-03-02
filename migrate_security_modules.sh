#!/bin/bash
# Script to assist with migration of security modules
# This script will find files that import legacy security modules and assist in migration

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Architecture settings
TARGET_TRIPLE="arm64-apple-macos15.4"
SWIFT_VERSION="5" 

# Progress tracking file
PROGRESS_FILE="./security_module_migration_progress.log"

# Function to display usage
show_usage() {
  echo -e "${CYAN}Security Module Migration Tool${NC}"
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --scan                Scan codebase for imports of legacy security modules"
  echo "  --update              Interactively update imports (you will be prompted for each file)"
  echo "  --check               Check if all legacy modules have been migrated"
  echo "  --verify-build-files  Verify BUILD.bazel files for consistent architecture settings"
  echo "  --fix-build-files     Update BUILD.bazel files with consistent architecture settings"
  echo "  --record-progress     Record progress of migrated files"
  echo "  --show-progress       Show migration progress"
  echo "  --help                Show this help message"
}

# Function to scan for legacy imports
scan_for_legacy_imports() {
  echo -e "${CYAN}Scanning for legacy security module imports...${NC}"
  
  echo -e "\n${YELLOW}SecurityInterfaces:${NC}"
  grep -r "import SecurityInterfaces" --include="*.swift" ./Sources | sort
  
  echo -e "\n${YELLOW}SecurityInterfacesBase:${NC}"
  grep -r "import SecurityInterfacesBase" --include="*.swift" ./Sources | sort
  
  echo -e "\n${YELLOW}SecurityInterfacesProtocols:${NC}"
  grep -r "import SecurityInterfacesProtocols" --include="*.swift" ./Sources | sort
  
  echo -e "\n${YELLOW}SecurityInterfacesFoundation*:${NC}"
  grep -r "import SecurityInterfacesFoundation" --include="*.swift" ./Sources | sort
}

# Function to check if migration is complete
check_migration() {
  echo -e "${CYAN}Checking if migration is complete...${NC}"
  
  LEGACY_IMPORTS=$(grep -r "import SecurityInterfaces\\|import SecurityInterfacesFoundation" --include="*.swift" ./Sources | wc -l)
  
  if [ "$LEGACY_IMPORTS" -eq 0 ]; then
    echo -e "${GREEN}All legacy security modules have been migrated!${NC}"
    return 0
  else
    echo -e "${RED}Found $LEGACY_IMPORTS legacy security module imports that need to be migrated.${NC}"
    echo -e "Run '$0 --scan' to see details."
    return 1
  fi
}

# Interactive update function
update_imports() {
  echo -e "${CYAN}Starting interactive update of security module imports...${NC}"
  echo -e "${YELLOW}This will help you update imports in files that use legacy security modules.${NC}"
  echo -e "Press Ctrl+C at any time to abort.\n"
  
  FILES=$(grep -l "import SecurityInterfaces\\|import SecurityInterfacesFoundation\\|import SecurityInterfacesBase\\|import SecurityInterfacesProtocols" --include="*.swift" ./Sources)
  
  for FILE in $FILES; do
    echo -e "${CYAN}Updating: ${NC}$FILE"
    echo "Original imports:"
    grep "import " $FILE
    
    read -p "Update this file? [y/N]: " CONFIRM
    if [[ $CONFIRM =~ ^[Yy]$ ]]; then
      # Perform the import replacements
      sed -i '' 's/import SecurityInterfaces/import SecurityProtocolsCore/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesBase/import SecurityProtocolsCore/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesProtocols/import SecurityProtocolsCore/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesFoundationBridge/import SecurityBridge/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesFoundation/import SecurityBridge/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesFoundationCore/import SecurityBridge/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesFoundationMinimal/import SecurityBridge/g' "$FILE"
      sed -i '' 's/import SecurityInterfacesFoundationNoFoundation/import SecurityProtocolsCore/g' "$FILE"
      
      # Handle common error type replacements
      sed -i '' 's/SecurityInterfaces\.SecurityError\.operationFailed/SecurityProtocolsCore.SecurityError.serviceError(code: -1, reason/g' "$FILE"
      sed -i '' 's/SecurityInterfaces\.SecurityError\.encryptionFailed/SecurityProtocolsCore.SecurityError.encryptionFailed(reason/g' "$FILE"
      sed -i '' 's/SecurityInterfaces\.SecurityError\.decryptionFailed/SecurityProtocolsCore.SecurityError.decryptionFailed(reason/g' "$FILE"
      sed -i '' 's/SecurityInterfaces\.SecurityError\.invalidKey/SecurityProtocolsCore.SecurityError.invalidKey/g' "$FILE"
      sed -i '' 's/SecurityInterfaces\.SecurityError\.invalidInput/SecurityProtocolsCore.SecurityError.invalidInput(reason/g' "$FILE"
      
      # General SecurityError replacement
      sed -i '' 's/SecurityInterfaces\.SecurityError/SecurityProtocolsCore.SecurityError/g' "$FILE"
      sed -i '' 's/SecurityInterfacesBase\.SecurityError/SecurityProtocolsCore.SecurityError/g' "$FILE"
      
      echo -e "${GREEN}Updated imports:${NC}"
      grep "import " "$FILE"
      echo ""
    fi
  done
  
  echo -e "${CYAN}Import update process complete.${NC}"
  echo -e "${YELLOW}Note: You may need to manually update types and protocols beyond just imports.${NC}"
  echo -e "See Documentation/SecurityModuleMigration.md for guidance."
}

# Function to verify BUILD.bazel files for consistent architecture settings
verify_build_files() {
  echo -e "${CYAN}Verifying BUILD.bazel files for consistent architecture settings...${NC}"
  
  # Check for inconsistent target triples
  INCONSISTENT_TRIPLES=$(grep -r "target" --include="BUILD.bazel" ./Sources | grep -v "${TARGET_TRIPLE}" | wc -l)
  
  if [ "$INCONSISTENT_TRIPLES" -gt 0 ]; then
    echo -e "${RED}Found potentially inconsistent target triple settings in BUILD.bazel files:${NC}"
    grep -r "target" --include="BUILD.bazel" ./Sources | grep -v "${TARGET_TRIPLE}"
  else
    echo -e "${GREEN}All target triple settings appear consistent.${NC}"
  fi
  
  # Check for library evolution settings
  echo -e "\n${CYAN}Checking library evolution settings:${NC}"
  
  # Count modules with library evolution enabled
  EVOLUTION_ENABLED=$(grep -r "enable-library-evolution" --include="BUILD.bazel" ./Sources | wc -l)
  echo -e "Modules with library evolution enabled: ${YELLOW}$EVOLUTION_ENABLED${NC}"
  
  # List modules explicitly
  echo -e "\n${CYAN}Modules with library evolution enabled:${NC}"
  grep -r "enable-library-evolution" --include="BUILD.bazel" ./Sources | cut -d':' -f1 | sort | uniq
  
  echo -e "\n${CYAN}Modules without library evolution (or with it commented out):${NC}"
  for FILE in $(find ./Sources -name "BUILD.bazel"); do
    if ! grep -q "enable-library-evolution" "$FILE"; then
      echo "$FILE"
    elif grep -q "#.*enable-library-evolution" "$FILE"; then
      echo "$FILE (commented out)"
    fi
  done
}

# Function to update BUILD.bazel files with consistent architecture settings
fix_build_files() {
  echo -e "${CYAN}Updating BUILD.bazel files with consistent architecture settings...${NC}"
  
  read -p "Do you want to apply consistent target triple (${TARGET_TRIPLE}) to all BUILD.bazel files? [y/N]: " CONFIRM
  if [[ $CONFIRM =~ ^[Yy]$ ]]; then
    # Find all BUILD.bazel files with 'target' but wrong triple
    for FILE in $(grep -l "target" --include="BUILD.bazel" ./Sources); do
      if ! grep -q "\"${TARGET_TRIPLE}\"" "$FILE"; then
        echo -e "Updating target triple in ${YELLOW}$FILE${NC}"
        sed -i '' "s/\"target\", \"[^\"]*\"/\"target\", \"${TARGET_TRIPLE}\"/g" "$FILE"
      fi
    done
  fi
  
  # Ask about library evolution
  echo -e "\n${YELLOW}Library evolution should be consistent across dependency chains.${NC}"
  echo -e "Modules that depend on CryptoSwift should have library evolution DISABLED."
  echo -e "Other modules should typically have library evolution ENABLED."
  echo ""
  echo -e "The script can:"
  echo -e "1. Enable library evolution for all modules (except those you specify)"
  echo -e "2. Disable library evolution for all modules (except those you specify)"
  echo -e "3. Skip library evolution changes"
  
  read -p "Select an option [1/2/3]: " EVOLUTION_OPTION
  
  case "$EVOLUTION_OPTION" in
    1)
      read -p "Enter comma-separated list of modules to EXCLUDE from enabling evolution (e.g., CryptoSwift,SecureBytes): " EXCLUDE_LIST
      IFS=',' read -ra EXCLUDE_MODULES <<< "$EXCLUDE_LIST"
      
      # Convert to array of patterns for grep -v
      EXCLUDE_PATTERN=""
      for module in "${EXCLUDE_MODULES[@]}"; do
        EXCLUDE_PATTERN="${EXCLUDE_PATTERN}-e ${module} "
      done
      
      # Find BUILD.bazel files not in excluded modules
      if [ -n "$EXCLUDE_PATTERN" ]; then
        FILES=$(find ./Sources -name "BUILD.bazel" | grep -v $EXCLUDE_PATTERN)
      else
        FILES=$(find ./Sources -name "BUILD.bazel")
      fi
      
      for FILE in $FILES; do
        # Check if evolution is already enabled
        if ! grep -q "enable-library-evolution" "$FILE" || grep -q "#.*enable-library-evolution" "$FILE"; then
          echo -e "Enabling library evolution in ${YELLOW}$FILE${NC}"
          
          # If commented out, uncomment
          if grep -q "#.*enable-library-evolution" "$FILE"; then
            sed -i '' 's/#\(.*"-Xfrontend", "-enable-library-evolution",\)/\1/g' "$FILE"
          else
            # Otherwise add after swift-version
            sed -i '' '/swift-version/a\\        "-Xfrontend", "-enable-library-evolution",' "$FILE"
          fi
        fi
      done
      ;;
      
    2)
      read -p "Enter comma-separated list of modules to EXCLUDE from disabling evolution: " EXCLUDE_LIST
      IFS=',' read -ra EXCLUDE_MODULES <<< "$EXCLUDE_LIST"
      
      # Convert to array of patterns for grep -v
      EXCLUDE_PATTERN=""
      for module in "${EXCLUDE_MODULES[@]}"; do
        EXCLUDE_PATTERN="${EXCLUDE_PATTERN}-e ${module} "
      done
      
      # Find BUILD.bazel files not in excluded modules
      if [ -n "$EXCLUDE_PATTERN" ]; then
        FILES=$(find ./Sources -name "BUILD.bazel" | grep -v $EXCLUDE_PATTERN)
      else
        FILES=$(find ./Sources -name "BUILD.bazel")
      fi
      
      for FILE in $FILES; do
        # Check if evolution is already enabled
        if grep -q "enable-library-evolution" "$FILE" && ! grep -q "#.*enable-library-evolution" "$FILE"; then
          echo -e "Disabling library evolution in ${YELLOW}$FILE${NC}"
          sed -i '' 's/\(.*"-Xfrontend", "-enable-library-evolution",\)/#\1/g' "$FILE"
        fi
      done
      ;;
      
    3)
      echo -e "${YELLOW}Skipping library evolution changes.${NC}"
      ;;
      
    *)
      echo -e "${RED}Invalid option. Skipping library evolution changes.${NC}"
      ;;
  esac
  
  echo -e "\n${GREEN}BUILD.bazel update complete.${NC}"
  echo -e "${YELLOW}You should run 'bazel clean --expunge' before rebuilding.${NC}"
}

# Function to record migration progress
record_progress() {
  echo -e "${CYAN}Recording migration progress...${NC}"
  
  # Create progress file if it doesn't exist
  if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "# UmbraCore Security Module Migration Progress" > "$PROGRESS_FILE"
    echo "# Format: YYYY-MM-DD | Module | Status | Notes" >> "$PROGRESS_FILE"
    echo "# Status: MIGRATED, IN_PROGRESS, PENDING, BLOCKED" >> "$PROGRESS_FILE"
    echo "-------------------------------------------" >> "$PROGRESS_FILE"
  fi
  
  # Display the current progress
  if [[ -f "$PROGRESS_FILE" ]]; then
    cat "$PROGRESS_FILE"
  fi
  
  # Prompt for new entry
  echo -e "\n${YELLOW}Enter information for a new migration record:${NC}"
  read -p "Module name: " MODULE_NAME
  
  # Validate module name is not empty
  if [[ -z "$MODULE_NAME" ]]; then
    echo -e "${RED}Module name cannot be empty.${NC}"
    return 1
  fi
  
  echo "Select status:"
  echo "1. MIGRATED"
  echo "2. IN_PROGRESS"
  echo "3. PENDING"
  echo "4. BLOCKED"
  read -p "Status [1-4]: " STATUS_OPTION
  
  case "$STATUS_OPTION" in
    1) STATUS="MIGRATED" ;;
    2) STATUS="IN_PROGRESS" ;;
    3) STATUS="PENDING" ;;
    4) STATUS="BLOCKED" ;;
    *) 
      echo -e "${RED}Invalid status option.${NC}"
      return 1
      ;;
  esac
  
  read -p "Notes (optional): " NOTES
  
  # Get current date
  DATE=$(date +%Y-%m-%d)
  
  # Add entry to the progress file
  echo "$DATE | $MODULE_NAME | $STATUS | $NOTES" >> "$PROGRESS_FILE"
  
  echo -e "${GREEN}Progress recorded.${NC}"
  echo "Latest entries:"
  tail -n 5 "$PROGRESS_FILE"
}

# Function to show migration progress
show_progress() {
  echo -e "${CYAN}Security Module Migration Progress:${NC}"
  
  if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo -e "${YELLOW}No progress has been recorded yet.${NC}"
    return 0
  fi
  
  # Count entries by status
  TOTAL_ENTRIES=$(grep -v "^#" "$PROGRESS_FILE" | grep -v "^-" | wc -l)
  MIGRATED=$(grep "| MIGRATED |" "$PROGRESS_FILE" | wc -l)
  IN_PROGRESS=$(grep "| IN_PROGRESS |" "$PROGRESS_FILE" | wc -l)
  PENDING=$(grep "| PENDING |" "$PROGRESS_FILE" | wc -l)
  BLOCKED=$(grep "| BLOCKED |" "$PROGRESS_FILE" | wc -l)
  
  # Show summary
  echo -e "${GREEN}Total modules tracked: $TOTAL_ENTRIES${NC}"
  echo -e "${GREEN}Completed: $MIGRATED${NC}"
  echo -e "${YELLOW}In progress: $IN_PROGRESS${NC}"
  echo -e "${YELLOW}Pending: $PENDING${NC}"
  echo -e "${RED}Blocked: $BLOCKED${NC}"
  
  # Show the progress file contents
  echo -e "\n${CYAN}Detailed Progress:${NC}"
  cat "$PROGRESS_FILE"
  
  # Estimate completion percentage
  if [ "$TOTAL_ENTRIES" -gt 0 ]; then
    PERCENT=$((MIGRATED * 100 / TOTAL_ENTRIES))
    echo -e "\n${GREEN}Migration is approximately $PERCENT% complete.${NC}"
  fi
}

# Main script logic
if [ $# -eq 0 ]; then
  show_usage
  exit 0
fi

case "$1" in
  --scan)
    scan_for_legacy_imports
    ;;
  --update)
    update_imports
    ;;
  --check)
    check_migration
    ;;
  --verify-build-files)
    verify_build_files
    ;;
  --fix-build-files)
    fix_build_files
    ;;
  --record-progress)
    record_progress
    ;;
  --show-progress)
    show_progress
    ;;
  --help)
    show_usage
    ;;
  *)
    echo -e "${RED}Unknown option: $1${NC}"
    show_usage
    exit 1
    ;;
esac
