#!/bin/bash
# migrate_xpc_file.sh
#
# Script to help migrate a file to use new XPC protocols
# This script performs basic transformations and suggests manual changes needed
#
# Usage: ./migrate_xpc_file.sh <path-to-file>

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <path-to-file>"
  exit 1
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH"
  exit 1
fi

# Create backup copy
BACKUP_FILE="${FILE_PATH}.bak"
cp "$FILE_PATH" "$BACKUP_FILE"
echo "Created backup at: $BACKUP_FILE"

# Update imports
echo "Updating imports..."
sed -i '' '/import SecurityInterfaces/a\
import XPCProtocolsCore' "$FILE_PATH"

sed -i '' '/import SecurityInterfacesBase/a\
import XPCProtocolsCore' "$FILE_PATH"

sed -i '' '/import SecurityInterfacesProtocols/a\
import XPCProtocolsCore' "$FILE_PATH"

# Add UmbraCoreTypes if not already imported
if ! grep -q "import UmbraCoreTypes" "$FILE_PATH"; then
  sed -i '' '/import XPCProtocolsCore/a\
import UmbraCoreTypes' "$FILE_PATH"
fi

# Replace protocol conformances
echo "Updating protocol conformances..."
sed -i '' 's/: XPCServiceProtocol/: XPCServiceProtocolStandard/g' "$FILE_PATH"
sed -i '' 's/: XPCCryptoServiceProtocol/: XPCServiceProtocolComplete/g' "$FILE_PATH"
sed -i '' 's/: SecurityXPCProtocol/: XPCServiceProtocolStandard/g' "$FILE_PATH"
sed -i '' 's/: CryptoXPCProtocol/: XPCServiceProtocolStandard/g' "$FILE_PATH"

# Update data types
echo "Updating data types..."
sed -i '' 's/BinaryData/SecureBytes/g' "$FILE_PATH"
sed -i '' 's/CryptoData/SecureBytes/g' "$FILE_PATH"

# Add @available attribute to deprecated methods
echo "Adding deprecation warnings..."
sed -i '' 's/func \(.*\): BinaryData/\/* @available(*, deprecated, message: "Use SecureBytes-based methods instead") *\/\n    func \1: BinaryData/g' "$FILE_PATH"

# Check for XPCSecurityError usage
NEEDS_SECURITY_ERROR=0
if grep -q "SecurityProtocolError" "$FILE_PATH"; then
  NEEDS_SECURITY_ERROR=1
fi

if grep -q "throw .*Error" "$FILE_PATH"; then
  NEEDS_SECURITY_ERROR=1
fi

# Perform static analysis and print warnings
echo -e "\n## Migration Analysis ##"

# Check for method signature pattern that needs to be updated
if grep -q "async throws" "$FILE_PATH"; then
  echo "⚠️  WARNING: File contains 'async throws' methods that should be converted to 'async -> Result<...>' pattern"
  echo "    Example change:"
  echo "      Before: func encryptData(_ data: SecureBytes) async throws -> SecureBytes"
  echo "      After:  func encryptData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>"
fi

# Check for throw statements that need to be converted
if grep -q "throw " "$FILE_PATH"; then
  echo "⚠️  WARNING: File contains 'throw' statements that should be converted to 'return .failure(...)'"
  echo "    Example change:"
  echo "      Before: throw SecurityError.invalidData"
  echo "      After:  return .failure(.invalidData)"
fi

# Detect return statements that need to be wrapped
if grep -q "return [^.]" "$FILE_PATH" && grep -q "Result<" "$FILE_PATH"; then
  echo "⚠️  WARNING: File contains return statements that should be updated to use Result.success"
  echo "    Example change:"
  echo "      Before: return data"
  echo "      After:  return .success(data)"
fi

if [ "$NEEDS_SECURITY_ERROR" -eq 1 ]; then
  echo "⚠️  WARNING: File contains error types that should be replaced with XPCSecurityError"
  echo "    Example mapping:"
  echo "      SecurityProtocolError.implementationMissing -> XPCSecurityError.implementationMissing"
  echo "      SecurityError.invalidData -> XPCSecurityError.invalidData"
fi

echo -e "\n## Manual Actions Required ##"
echo "1. Update method signatures to use 'async -> Result<Value, XPCSecurityError>' pattern"
echo "2. Convert 'throw' statements to 'return .failure(...)'"
echo "3. Wrap return values with 'return .success(...)'"
echo "4. Add any missing required protocol methods"
echo "5. Run tests to verify correct behavior"

echo -e "\nInitial migration completed. Check the file and make manual adjustments as needed."
echo "If something went wrong, you can restore the backup with:"
echo "mv '$BACKUP_FILE' '$FILE_PATH'"
