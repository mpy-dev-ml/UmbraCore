#!/usr/bin/env python3
"""
XPC Security Error Migration Script

This script helps identify and fix references to the deprecated XPCSecurityError type
by replacing them with the new ErrorHandlingDomains.UmbraErrors.Security.Protocols type.

Usage:
    python3 xpc_security_error_migration.py
"""

import os
import re
import subprocess
import sys
from pathlib import Path

# Define replacements
REPLACEMENTS = [
    (r'XPCProtocolsCore\.XPCSecurityError', 'ErrorHandlingDomains.UmbraErrors.Security.Protocols'),
    (r'XPCSecurityError', 'ErrorHandlingDomains.UmbraErrors.Security.Protocols'),
    (r'typealias XPCSecurityError = SecurityError', '// DEPRECATED: typealias XPCSecurityError = SecurityError\ntypealias XPCSecurityError = ErrorHandlingDomains.UmbraErrors.Security.Protocols'),
]

# Define imports to add
IMPORTS_TO_ADD = [
    'import ErrorHandlingDomains'
]

def find_swift_files(directory):
    """Find all Swift files in the directory and subdirectories."""
    result = subprocess.run(['find', directory, '-name', '*.swift', '-type', 'f'], 
                           stdout=subprocess.PIPE, text=True)
    files = result.stdout.strip().split('\n')
    return [f for f in files if f]  # Filter out empty strings

def check_file_for_pattern(file_path, patterns):
    """Check if the file contains any of the patterns that need to be replaced."""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
        for pattern, _ in patterns:
            if re.search(pattern, content):
                return True
    return False

def add_imports_if_needed(content, imports_to_add):
    """Add necessary imports if they're not already in the file."""
    modified_content = content
    
    for import_stmt in imports_to_add:
        if import_stmt not in content:
            # Find the position after the last import statement
            import_matches = list(re.finditer(r'^import\s+\w+', content, re.MULTILINE))
            if import_matches:
                last_import_end = import_matches[-1].end()
                modified_content = (
                    content[:last_import_end] + 
                    '\n' + import_stmt + 
                    content[last_import_end:]
                )
            else:
                # If no imports, add at the beginning of the file
                modified_content = import_stmt + '\n' + content
                
    return modified_content

def process_file(file_path, patterns, imports_to_add):
    """Process a file, making the necessary replacements and adding imports."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # First, add imports if needed
        modified_content = add_imports_if_needed(content, imports_to_add)
        
        # Then make the replacements
        for pattern, replacement in patterns:
            modified_content = re.sub(pattern, replacement, modified_content)
        
        # Only write if changes were made
        if modified_content != content:
            with open(file_path, 'w', encoding='utf-8') as file:
                file.write(modified_content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Main function to run the script."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = script_dir
    
    # Find all Swift files
    swift_files = find_swift_files(project_dir)
    print(f"Found {len(swift_files)} Swift files to check")
    
    # Filter files that need processing
    files_to_process = [
        f for f in swift_files 
        if check_file_for_pattern(f, REPLACEMENTS)
    ]
    print(f"{len(files_to_process)} files contain references to deprecated XPCSecurityError")
    
    # Process each file
    processed_files = 0
    for file_path in files_to_process:
        if process_file(file_path, REPLACEMENTS, IMPORTS_TO_ADD):
            processed_files += 1
            print(f"Updated {file_path}")
    
    print(f"\nSuccessfully processed {processed_files} files")
    return 0

if __name__ == "__main__":
    sys.exit(main())
