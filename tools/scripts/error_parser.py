#!/usr/bin/env python3
"""
UmbraCore Build Error Parser

This script analyzes the Bazel build error output and groups errors by type
to facilitate systematic resolution of Swift compatibility issues.
"""

import re
import os
import sys
from collections import defaultdict
from typing import Dict, List, Set, Tuple

class ErrorParser:
    """Parser for Swift build errors in UmbraCore."""
    
    def __init__(self, build_output_file: str):
        """Initialize with path to build output file."""
        self.build_output_file = build_output_file
        self.error_groups = defaultdict(list)
        self.warning_groups = defaultdict(list)
        self.file_errors = defaultdict(list)
        self.error_patterns = {
            'unterminated_string': re.compile(r'unterminated string literal'),
            'sendable_property': re.compile(r"stored property '(.+?)' of 'Sendable'-conforming.+?has non-sendable type"),
            'missing_member': re.compile(r"type '(.+?)' has no member '(.+?)'"),
            'type_not_found': re.compile(r"cannot find type '(.+?)' in"),
            'extraneous_close_brace': re.compile(r"extraneous '}' at top level"),
            'incorrect_optional': re.compile(r"initializer for conditional binding must have Optional type"),
            'unwrap_optional': re.compile(r"value of optional type '(.+?)' must be unwrapped"),
            'non_sendable_cross_actor': re.compile(r"non-sendable type '(.+?)' in parameter .+? cannot cross actor boundary"),
        }
        
    def parse(self) -> None:
        """Parse the build output file and categorize errors."""
        try:
            with open(self.build_output_file, 'r') as f:
                content = f.read()
                
            # Extract error sections
            error_sections = re.findall(r'(Sources/.+?\.swift:\d+:\d+:.+?(?=Sources/|\Z))', 
                                       content, re.DOTALL)
            
            for section in error_sections:
                lines = section.strip().split('\n')
                file_info = lines[0].split(':')
                if len(file_info) >= 3:
                    file_path = file_info[0]
                    line_num = int(file_info[1])
                    col_num = int(file_info[2])
                    
                    error_message = ' '.join(lines)
                    
                    # Categorize by error type
                    error_type = self._determine_error_type(error_message)
                    if 'warning:' in error_message.lower():
                        self.warning_groups[error_type].append((file_path, line_num, col_num, error_message))
                    else:
                        self.error_groups[error_type].append((file_path, line_num, col_num, error_message))
                    
                    # Group by file
                    self.file_errors[file_path].append((error_type, line_num, col_num, error_message))
            
            # Sort errors by file and line number
            for file_path in self.file_errors:
                self.file_errors[file_path].sort(key=lambda x: x[1])
                
        except Exception as e:
            print(f"Error parsing build output: {e}")
    
    def _determine_error_type(self, error_message: str) -> str:
        """Determine the type of error based on the message."""
        for error_type, pattern in self.error_patterns.items():
            if pattern.search(error_message):
                return error_type
        
        if "warning:" in error_message.lower():
            return "general_warning"
        return "other_error"
    
    def print_summary(self) -> None:
        """Print a summary of the parsed errors."""
        print("\n=== BUILD ERROR SUMMARY ===\n")
        
        print(f"Total files with errors/warnings: {len(self.file_errors)}")
        print(f"Total error types: {len(self.error_groups)}")
        print(f"Total warning types: {len(self.warning_groups)}")
        
        print("\n--- Error Groups ---")
        for error_type, errors in self.error_groups.items():
            print(f"{error_type}: {len(errors)} occurrences")
        
        print("\n--- Warning Groups ---")
        for warning_type, warnings in self.warning_groups.items():
            print(f"{warning_type}: {len(warnings)} occurrences")
        
        print("\n--- Files With Most Issues ---")
        file_issue_count = {f: len(issues) for f, issues in self.file_errors.items()}
        for file_path, count in sorted(file_issue_count.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"{file_path}: {count} issues")
    
    def get_grouped_errors(self) -> Tuple[Dict, Dict, Dict]:
        """Return the grouped errors for programmatic use."""
        return self.error_groups, self.warning_groups, self.file_errors

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python error_parser.py <build_output_file>")
        sys.exit(1)
    
    build_output_file = sys.argv[1]
    parser = ErrorParser(build_output_file)
    parser.parse()
    parser.print_summary()
