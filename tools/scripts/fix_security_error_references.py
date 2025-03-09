#!/usr/bin/env python3
"""
Script to fix SecurityError references in Swift files.
This script addresses the following issues:
1. Replace SecurityProtocolsCore.SecurityError with UmbraErrors.Security.Protocols
2. Fix references to non-existent error cases
"""

import os
import re
import sys
from pathlib import Path

def fix_file_content(content):
    # Replace direct references to SecurityProtocolsCore.SecurityError
    content = re.sub(
        r'SecurityProtocolsCore\.SecurityError',
        'UmbraErrors.Security.Protocols',
        content
    )
    
    # Fix type aliases
    content = re.sub(
        r'typealias\s+SPCSecurityError\s*=\s*SecurityProtocolsCore\.SecurityError',
        'typealias SPCSecurityError = UmbraErrors.Security.Protocols',
        content
    )
    
    # Fix references to invalidData and general that don't exist in UmbraErrors.Security.Protocols
    content = re.sub(
        r'CoreErrors\.SecurityError\.invalidData',
        'UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")',
        content
    )
    
    content = re.sub(
        r'CoreErrors\.SecurityError\.general\(([^)]+)\)',
        r'UmbraErrors.Security.Protocols.internalError(\1)',
        content
    )
    
    # Fix test references to encryptionFailed, decryptionFailed, and invalidKey
    # Map to available cases in UmbraErrors.Security.Protocols
    content = re.sub(
        r'UmbraErrors\.Security\.Protocols\.encryptionFailed\(reason:\s*([^)]+)\)',
        r'UmbraErrors.Security.Protocols.internalError("Encryption failed: " + \1)',
        content
    )
    
    content = re.sub(
        r'UmbraErrors\.Security\.Protocols\.decryptionFailed\(reason:\s*([^)]+)\)',
        r'UmbraErrors.Security.Protocols.internalError("Decryption failed: " + \1)',
        content
    )
    
    content = re.sub(
        r'UmbraErrors\.Security\.Protocols\.invalidKey',
        r'UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid key")',
        content
    )
    
    # Also fix notImplemented with unsupportedOperation
    content = re.sub(
        r'CoreErrors\.SecurityError\.notImplemented\(feature:\s*([^)]+)\)',
        r'UmbraErrors.Security.Protocols.unsupportedOperation(name: \1)',
        content
    )
    
    return content

def process_file(file_path):
    print(f"Processing {file_path}")
    try:
        with open(file_path, 'r') as file:
            content = file.read()
        
        updated_content = fix_file_content(content)
        
        if content != updated_content:
            with open(file_path, 'w') as file:
                file.write(updated_content)
            print(f"Updated {file_path}")
        else:
            print(f"No changes needed for {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def find_and_process_swift_files(directory):
    count = 0
    for path in Path(directory).rglob('*.swift'):
        process_file(str(path))
        count += 1
    return count

if __name__ == "__main__":
    root_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    count = find_and_process_swift_files(root_dir)
    print(f"Processed {count} Swift files")
