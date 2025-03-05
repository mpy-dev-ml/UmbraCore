#!/bin/bash
# enhanced_xpc_migration.sh
#
# A comprehensive script to automate XPC protocol migration
# including error handling pattern conversion

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

# Convert error handling patterns - more complex transforms
echo "Converting error handling patterns..."

# Add temporary markers for method signatures
# This helps identify methods that need to be transformed
grep -n "func.*async.*throws" "$FILE_PATH" | cut -d: -f1 | while read -r line; do
  sed -i '' "${line}s/func \(.*\)async throws/func \1async throws \/\* TO_TRANSFORM_RESULT \*\//" "$FILE_PATH"
done

# Now run the perl transformations
perl -i -pe '
  # Convert async throws method signatures
  s/func (.*?)async throws \/\* TO_TRANSFORM_RESULT \*\/ -> ([^{]+)/func $1async -> Result<$2, XPCSecurityError>/g;
  
  # Convert throw statements to return .failure with common error types
  s/throw SecurityError\.invalidData/return .failure(.invalidData)/g;
  s/throw SecurityError\.encryptionFailed/return .failure(.encryptionFailed)/g;
  s/throw SecurityError\.decryptionFailed/return .failure(.decryptionFailed)/g;
  s/throw SecurityError\.cryptoError/return .failure(.cryptoError)/g;
  s/throw SecurityError\.notImplemented/return .failure(.implementationMissing)/g;
  s/throw SecurityError\.serviceFailed/return .failure(.serviceError)/g;
  
  # More general pattern for other throw statements
  s/throw (\w+)Error\.(\w+)(?:\([^)]*\))?/return .failure(.$2)/g;
  
  # Handle return statements in Result-returning functions
  if (/Result<.*?,.*?>/) {
    s/return ([^.].+?)(\s*\/\/.*)?$/return .success($1)$2/g unless /return \.(success|failure)/;
  }
' "$FILE_PATH"

# Clean up temporary markers if any remain
sed -i '' 's/ \/\* TO_TRANSFORM_RESULT \*\///' "$FILE_PATH"

# Perform static analysis and print warnings
echo -e "\n## Migration Analysis ##"

# Check for method signature patterns that need manual attention
if grep -q "async throws" "$FILE_PATH"; then
  echo "⚠️  WARNING: File still contains 'async throws' methods that need manual conversion to 'async -> Result<...>' pattern"
  echo "    Example change:"
  echo "      Before: func encryptData(_ data: SecureBytes) async throws -> SecureBytes"
  echo "      After:  func encryptData(_ data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError>"
fi

# Check for throw statements that need manual conversion
if grep -q "throw " "$FILE_PATH"; then
  echo "⚠️  WARNING: File still contains 'throw' statements that need manual conversion to 'return .failure(...)'"
  echo "    Example change:"
  echo "      Before: throw SecurityError.invalidData"
  echo "      After:  return .failure(.invalidData)"
fi

# Check for return statements that might need wrapping
if grep -q "Result<" "$FILE_PATH" && grep -q "return [^.]" "$FILE_PATH"; then
  echo "⚠️  WARNING: File might contain return statements that need wrapping with .success()"
  echo "    Example change:"
  echo "      Before: return data"
  echo "      After:  return .success(data)"
fi

echo -e "\n## Manual Actions Required ##"
echo "1. Check method signatures for 'async throws' that need to be converted to 'async -> Result<Value, XPCSecurityError>'"
echo "2. Verify that 'throw' statements were properly converted to 'return .failure(...)'"
echo "3. Ensure return values are properly wrapped with 'return .success(...)'"
echo "4. Add any missing required protocol methods"
echo "5. Run tests to verify correct behavior"

echo -e "\nEnhanced migration completed for: $FILE_PATH"
echo "If something went wrong, you can restore the backup with:"
echo "mv '$BACKUP_FILE' '$FILE_PATH'"
