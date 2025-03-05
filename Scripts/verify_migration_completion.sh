#!/bin/bash
# verify_migration_completion.sh
#
# Script to verify completion of XPC protocol migration
# by checking for lingering legacy imports, protocols and patterns

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "## XPC Migration Verification ##"
echo "Checking for lingering legacy patterns..."

# 1. Check for legacy imports
echo "Checking for legacy imports..."
LEGACY_IMPORTS=$(grep -r --include="*.swift" "import SecurityInterfaces" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with legacy SecurityInterfaces imports: $LEGACY_IMPORTS"

# 2. Check for old protocol conformances
echo "Checking for legacy protocol conformances..."
LEGACY_PROTOCOLS=$(grep -r --include="*.swift" -E ": (XPCServiceProtocol|XPCCryptoServiceProtocol|SecurityXPCProtocol|CryptoXPCProtocol)" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with legacy protocol conformances: $LEGACY_PROTOCOLS"

# 3. Check for async throws patterns
echo "Checking for legacy async throws patterns..."
ASYNC_THROWS=$(grep -r --include="*.swift" "async throws" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with 'async throws' patterns: $ASYNC_THROWS"

# 4. Check for throw statements
echo "Checking for legacy throw statements..."
THROW_STATEMENTS=$(grep -r --include="*.swift" -E "throw (SecurityError|XPCError)" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with throw statements: $THROW_STATEMENTS"

# 5. Check for modern import adoption
echo "Checking for modern import adoption..."
MODERN_IMPORTS=$(grep -r --include="*.swift" "import XPCProtocolsCore" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with modern XPCProtocolsCore imports: $MODERN_IMPORTS"

# 6. Check for Result type adoptions
echo "Checking for Result type adoptions..."
RESULT_ADOPTIONS=$(grep -r --include="*.swift" -E "Result<[^,]+, XPCSecurityError>" "$PROJECT_ROOT/Sources" | wc -l | tr -d ' ')
echo "- Files with Result<T, XPCSecurityError> patterns: $RESULT_ADOPTIONS"

# Print completion percentage based on migration tracking
if [ -f "$SCRIPT_DIR/xpc_migration_manager.sh" ]; then
  MIGRATION_STATUS=$("$SCRIPT_DIR/xpc_migration_manager.sh" status)
  MIGRATED_COUNT=$(echo "$MIGRATION_STATUS" | grep "Migrated:" | sed -E 's/.*Migrated: ([0-9]+) \/.*/\1/')
  TOTAL_COUNT=$(echo "$MIGRATION_STATUS" | grep "Migrated:" | sed -E 's/.*\/ ([0-9]+) files.*/\1/')
  
  if [[ "$MIGRATED_COUNT" =~ ^[0-9]+$ ]] && [[ "$TOTAL_COUNT" =~ ^[0-9]+$ ]]; then
    PERCENTAGE=$((MIGRATED_COUNT * 100 / TOTAL_COUNT))
    echo -e "\n## Migration Progress ##"
    echo "- Files migrated: $MIGRATED_COUNT / $TOTAL_COUNT ($PERCENTAGE%)"
  fi
fi

# Overall assessment
echo -e "\n## Migration Assessment ##"
if [ "$LEGACY_IMPORTS" -eq 0 ] && [ "$LEGACY_PROTOCOLS" -eq 0 ] && [ "$ASYNC_THROWS" -eq 0 ] && [ "$THROW_STATEMENTS" -eq 0 ]; then
  echo "✅ Migration complete! No legacy patterns detected."
else
  echo "⚠️  Migration incomplete. Issues remaining:"
  
  if [ "$LEGACY_IMPORTS" -gt 0 ]; then
    echo "  - $LEGACY_IMPORTS files still have legacy imports"
  fi
  
  if [ "$LEGACY_PROTOCOLS" -gt 0 ]; then
    echo "  - $LEGACY_PROTOCOLS files still use legacy protocol conformances"
  fi
  
  if [ "$ASYNC_THROWS" -gt 0 ]; then
    echo "  - $ASYNC_THROWS files still use 'async throws' pattern"
  fi
  
  if [ "$THROW_STATEMENTS" -gt 0 ]; then
    echo "  - $THROW_STATEMENTS files still use 'throw' statements"
  fi
fi

echo -e "\nVerification completed!"
