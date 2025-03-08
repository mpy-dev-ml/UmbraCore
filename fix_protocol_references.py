#!/usr/bin/env python3
"""
Script to identify and fix instances of 'UmbraErrors.Security.Protocol' that should be
'UmbraErrors.Security.Protocols' (plural) in Swift files.

This script:
1. Searches through Swift files in the project
2. Identifies files with incorrect references
3. Generates a report of affected files
4. Optionally fixes the issues (when --fix flag is provided)
"""

import os
import re
import argparse
from pathlib import Path
from typing import List, Tuple, Dict


def find_swift_files(source_dir: str) -> List[Path]:
    """Find all Swift files in the given directory and its subdirectories."""
    return list(Path(source_dir).glob("**/*.swift"))


def check_file(file_path: Path) -> List[Tuple[int, str, str]]:
    """
    Check a file for instances of 'UmbraErrors.Security.Protocol'.
    
    Returns a list of tuples (line_number, line_content, fixed_line_content)
    """
    issues = []
    
    # Create patterns for matching
    protocol_pattern = re.compile(r'UmbraErrors\.Security\.Protocol\b')
    
    # Also check for missing imports if we find protocol references
    has_protocol_reference = False
    has_import = False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for line_number, line in enumerate(lines, 1):
        if 'import ErrorHandlingDomains' in line:
            has_import = True
            
        if protocol_pattern.search(line):
            has_protocol_reference = True
            fixed_line = protocol_pattern.sub('UmbraErrors.Security.Protocols', line)
            issues.append((line_number, line, fixed_line))
    
    # If we found protocol references but no import, add a suggestion for the import
    if has_protocol_reference and not has_import:
        issues.append((0, "", "import ErrorHandlingDomains  # Missing import needed for UmbraErrors"))
        
    return issues


def fix_file(file_path: Path, issues: List[Tuple[int, str, str]]) -> bool:
    """Fix issues in a file. Returns True if file was modified."""
    if not issues:
        return False
        
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Process line replacements
    modified = False
    for line_number, _, fixed_line in issues:
        # Special case for the import suggestion
        if line_number == 0:
            # Find a good spot to add the import - after other imports
            import_added = False
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    last_import_line = i
                
            # Add after the last import if found
            if 'last_import_line' in locals():
                lines.insert(last_import_line + 1, "import ErrorHandlingDomains\n")
                import_added = modified = True
                
            # Otherwise add at the top
            if not import_added:
                lines.insert(0, "import ErrorHandlingDomains\n")
                modified = True
        else:
            if lines[line_number - 1] != fixed_line:
                lines[line_number - 1] = fixed_line
                modified = True
    
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
            
    return modified


def main():
    parser = argparse.ArgumentParser(description='Find and fix UmbraErrors.Security.Protocol references')
    parser.add_argument('--source', '-s', default='.', help='Source directory to search (default: current directory)')
    parser.add_argument('--fix', '-f', action='store_true', help='Fix issues automatically')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    swift_files = find_swift_files(args.source)
    print(f"Found {len(swift_files)} Swift files to check")
    
    files_with_issues = {}
    total_issues = 0
    
    for file_path in swift_files:
        issues = check_file(file_path)
        if issues:
            files_with_issues[file_path] = issues
            total_issues += len(issues)
    
    print(f"\nFound {total_issues} issues in {len(files_with_issues)} files")
    
    if args.verbose or not args.fix:
        for file_path, issues in files_with_issues.items():
            print(f"\n{file_path}:")
            for line_number, line, fixed_line in issues:
                if line_number == 0:  # Special case for import suggestion
                    print(f"  Missing import: {fixed_line}")
                else:
                    print(f"  Line {line_number}:")
                    print(f"    Original: {line.strip()}")
                    print(f"    Fixed:    {fixed_line.strip()}")
    
    if args.fix:
        fixed_files = 0
        for file_path, issues in files_with_issues.items():
            if fix_file(file_path, issues):
                fixed_files += 1
                print(f"Fixed: {file_path}")
        
        print(f"\nFixed issues in {fixed_files} files")
    
    return 0


if __name__ == "__main__":
    main()
