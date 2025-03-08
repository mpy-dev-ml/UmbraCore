#!/usr/bin/env python3
"""
Script to identify potential similar patterns to UmbraErrors.Security.Protocol that should be plural
in Swift files across the codebase.

This script searches for:
1. Any instances of "*.Protocol" that might need to be "*.Protocols" (plural)
2. Patterns following similar naming conventions that might have the same issue
"""

import os
import re
from pathlib import Path
from typing import List, Tuple, Dict, Set
import argparse


def find_swift_files(source_dir: str) -> List[Path]:
    """Find all Swift files in the given directory and its subdirectories."""
    return list(Path(source_dir).glob("**/*.swift"))


def search_potential_patterns(file_path: Path) -> List[Tuple[int, str, str]]:
    """
    Search for potential singular/plural issues like Protocol/Protocols.
    
    Returns a list of tuples (line_number, line_content, potential_issue)
    """
    issues = []
    
    # Define patterns to look for
    # This pattern will match anything followed by .Protocol that isn't .Protocols
    singular_protocol_pattern = re.compile(r'(\w+)\.Protocol\b(?!s)')
    
    with open(file_path, 'r', encoding='utf-8') as f:
        try:
            lines = f.readlines()
        except UnicodeDecodeError:
            return []  # Skip binary files or files with encoding issues
    
    for line_number, line in enumerate(lines, 1):
        # Check for singular Protocol patterns
        for match in singular_protocol_pattern.finditer(line):
            namespace = match.group(1)
            issues.append((
                line_number, 
                line.strip(), 
                f"Potential singular 'Protocol' instead of plural 'Protocols' in: {namespace}.Protocol"
            ))
    
    return issues


def main():
    parser = argparse.ArgumentParser(
        description='Find potential singular/plural naming issues like Protocol/Protocols in Swift files'
    )
    parser.add_argument('--source', '-s', default='.', 
                       help='Source directory to search (default: current directory)')
    args = parser.parse_args()
    
    swift_files = find_swift_files(args.source)
    print(f"Found {len(swift_files)} Swift files to check")
    
    potential_issues = []
    
    for file_path in swift_files:
        issues = search_potential_patterns(file_path)
        if issues:
            potential_issues.append((file_path, issues))
    
    if potential_issues:
        print(f"\nFound potential issues in {len(potential_issues)} files:\n")
        
        for file_path, issues in potential_issues:
            print(f"{file_path}:")
            for line_number, line, issue in issues:
                print(f"  Line {line_number}: {issue}")
                print(f"    {line}")
            print()
    else:
        print("\nNo potential issues found!")
    
    return 0


if __name__ == "__main__":
    main()
