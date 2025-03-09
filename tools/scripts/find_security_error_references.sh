#!/bin/bash

# Find all instances of SecurityProtocolsCore.SecurityError
echo "Files with SecurityProtocolsCore.SecurityError references:"
grep -r "SecurityProtocolsCore.SecurityError" --include="*.swift" .

echo -e "\nFiles with UmbraErrors.Security.Protocols references with missing cases:"
grep -r "UmbraErrors.Security.Protocols" --include="*.swift" . | grep -E "encryptionFailed|decryptionFailed|invalidKey"

echo -e "\nFiles with SecurityError.invalidData references:"
grep -r "SecurityError.invalidData" --include="*.swift" .

echo -e "\nFiles with SecurityError.general references:"
grep -r "SecurityError.general" --include="*.swift" .

echo -e "\nFiles that need to be fixed for protocol conformance:"
grep -r "does not conform to protocol" build_errors.md
