#!/bin/bash
# manual_fixes_xpc.sh
#
# Script to apply manual fixes to automatically migrated files
# that still have issues after the automated migration

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <file-path>"
  exit 1
fi

FILE_PATH="$1"
BACKUP_FILE="${FILE_PATH}.manual.bak"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH"
  exit 1
fi

# Create backup
cp "$FILE_PATH" "$BACKUP_FILE"
echo "Created backup at: $BACKUP_FILE"

echo "Applying manual fixes to: $FILE_PATH"

# 1. Convert remaining async throws method signatures
echo "Converting remaining 'async throws' methods..."
perl -i -pe '
  # Convert simple async throws method signatures
  s/func (\w+)(?:\((.*?)\))?\s+async\s+throws\s+->\s+(\w+)/func $1($2) async -> Result<$3, XPCSecurityError>/g;
  
  # Convert more complex signatures with multiple parameters
  s/func (\w+)\((.*?)\)\s+async\s+throws\s+->\s+(\w+)/func $1($2) async -> Result<$3, XPCSecurityError>/g;
' "$FILE_PATH"

# 2. Convert remaining throw statements
echo "Converting remaining 'throw' statements..."
perl -i -pe '
  # Common error patterns
  s/throw (\w+)Error\.(\w+)/return .failure(.$2)/g;
  s/throw (\w+)Error\((.+?)\)/return .failure(.custom(message: $2))/g;
  
  # Handle other throw statements
  s/throw ([^(]+?)\((.+?)\)/return .failure(.custom(message: "$1: $2"))/g;
  
  # Simple throw statement
  s/throw ([^(]+)/return .failure(.custom(message: "$1"))/g;
' "$FILE_PATH"

# 3. Simple approach to wrap return statements in functions that return Result
# This is a safer approach than using complex regex with the entire file
echo "Safely wrapping return statements..."
# First mark all functions that return Result
perl -i -pe '
  # Mark functions that return Result<...>
  s/(func \w+(?:\([^)]*\))?[^{]*?Result<[^,]*,[^>]*>)/\/\/ RETURNS_RESULT $1/g;
' "$FILE_PATH"

# Then in those functions, wrap return statements that don't start with .success or .failure
perl -i -0777 -pe '
  # Process each marked function
  while (s/(\/\/ RETURNS_RESULT.*?\{)([^{}]*?)(\breturn\s+)([^.][^;\n]*?)([;\n])/\1\2\3.success(\4)\5/gs) {}
' "$FILE_PATH"

# Remove the markers
perl -i -pe 's/\/\/ RETURNS_RESULT //g' "$FILE_PATH"

# 4. Fix try/catch blocks - simplified approach
echo "Converting try/catch blocks to Result pattern..."
perl -i -pe '
  # Replace simple try expressions with do-catch blocks
  s/try (\w+\([^)]*\))/do { return .success(try \1) } catch { return .failure(.custom(message: $_.localizedDescription)) }/g;
' "$FILE_PATH"

# Remove redundant try keywords in success wrappers
perl -i -pe 's/return \.success\(try /return .success(/g;' "$FILE_PATH"

echo -e "\n## Manual Fixes Analysis ##"

# Check for any remaining issues
if grep -q "async throws" "$FILE_PATH"; then
  echo "⚠️  WARNING: File still contains 'async throws' methods"
  grep -n "async throws" "$FILE_PATH"
fi

if grep -q "throw " "$FILE_PATH"; then
  echo "⚠️  WARNING: File still contains 'throw' statements"
  grep -n "throw " "$FILE_PATH"
fi

if grep -q "try " "$FILE_PATH"; then
  echo "⚠️  NOTE: File contains 'try' statements, which may need review"
  grep -n "try " "$FILE_PATH"
fi

echo -e "\nManual fixes completed for: $FILE_PATH"
echo "If something went wrong, you can restore the backup with:"
echo "mv '$BACKUP_FILE' '$FILE_PATH'"
