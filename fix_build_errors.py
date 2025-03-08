#!/usr/bin/env python3
"""
UmbraCore Build Error Fixer

This script automatically fixes common Swift errors identified in the UmbraCore build
by parsing the build output and applying targeted fixes.
"""

import os
import re
import sys
import logging
from typing import Dict, List, Tuple, Optional
from error_parser import ErrorParser

# Configure logging
logging.basicConfig(level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class BuildErrorFixer:
    """Automatically fixes common Swift build errors in UmbraCore."""
    
    def __init__(self, build_output_file: str, dry_run: bool = False):
        """Initialize with path to build output and dry run flag."""
        self.build_output_file = build_output_file
        self.dry_run = dry_run
        self.parser = ErrorParser(build_output_file)
        self.fixes_applied = 0
        self.files_modified = set()
        
    def analyze_errors(self) -> None:
        """Parse the build output and analyze errors."""
        logger.info("Analyzing build errors...")
        self.parser.parse()
        self.error_groups, self.warning_groups, self.file_errors = self.parser.get_grouped_errors()
        
    def fix_all_errors(self) -> None:
        """Apply fixes for all supported error types."""
        self.analyze_errors()
        
        # Apply fixes for each error type
        self.fix_sendable_properties()
        self.fix_missing_members()
        self.fix_extraneous_braces()
        self.fix_unterminated_strings()
        self.fix_incorrect_optionals()
        
        logger.info(f"Applied {self.fixes_applied} fixes across {len(self.files_modified)} files")
        if self.dry_run:
            logger.info("Note: This was a dry run. No actual changes were made.")
            
    def read_file(self, file_path: str) -> List[str]:
        """Read a file and return its content as a list of lines."""
        try:
            with open(file_path, 'r') as f:
                return f.readlines()
        except Exception as e:
            logger.error(f"Error reading file {file_path}: {e}")
            return []
            
    def write_file(self, file_path: str, lines: List[str]) -> bool:
        """Write content back to a file."""
        if self.dry_run:
            logger.info(f"Would write {len(lines)} lines to {file_path}")
            return True
            
        try:
            with open(file_path, 'w') as f:
                f.writelines(lines)
            self.files_modified.add(file_path)
            return True
        except Exception as e:
            logger.error(f"Error writing to file {file_path}: {e}")
            return False
    
    def fix_sendable_properties(self) -> None:
        """Fix issues with Sendable conformance for closure properties."""
        logger.info("Fixing Sendable property issues...")
        
        # Combine warnings and errors
        all_sendable_issues = self.warning_groups.get('sendable_property', [])
        
        for file_path, line_num, _, error_message in all_sendable_issues:
            match = re.search(r"stored property '(.+?)' of 'Sendable'-conforming.+?has non-sendable type '(.+?)'", error_message)
            if not match:
                continue
                
            property_name, property_type = match.groups()
            lines = self.read_file(file_path)
            
            # If the property type is a closure, add @Sendable
            if '->' in property_type and line_num-1 < len(lines):
                line = lines[line_num-1]
                if property_name in line:
                    # Check if closure type doesn't already have @Sendable
                    if '@Sendable' not in line:
                        # Insert @Sendable before the closure type
                        modified_line = re.sub(
                            r'(\s*)(let|var)\s+' + re.escape(property_name) + r'\s*:\s*(.+?)\s*->',
                            r'\1\2 ' + property_name + r': @Sendable \3->',
                            line
                        )
                        lines[line_num-1] = modified_line
                        self.fixes_applied += 1
                        logger.info(f"Fixed Sendable property in {file_path}:{line_num}")
                        self.write_file(file_path, lines)
    
    def fix_missing_members(self) -> None:
        """Fix issues with missing enum members."""
        logger.info("Fixing missing member issues...")
        
        for file_path, line_num, _, error_message in self.error_groups.get('missing_member', []):
            match = re.search(r"type '(.+?)' has no member '(.+?)'", error_message)
            if not match:
                continue
                
            type_name, missing_member = match.groups()
            lines = self.read_file(file_path)
            
            # Special case for XPCSecurityError.operationFailed
            if 'XPCSecurityError' in type_name and missing_member == 'operationFailed':
                if line_num-1 < len(lines):
                    # Replace .operationFailed with .internalError
                    line = lines[line_num-1]
                    modified_line = line.replace('.operationFailed', '.internalError')
                    lines[line_num-1] = modified_line
                    self.fixes_applied += 1
                    logger.info(f"Fixed missing member in {file_path}:{line_num} - replaced .operationFailed with .internalError")
                    self.write_file(file_path, lines)
    
    def fix_extraneous_braces(self) -> None:
        """Fix extraneous closing braces."""
        logger.info("Fixing extraneous brace issues...")
        
        for file_path, line_num, _, error_message in self.error_groups.get('extraneous_close_brace', []):
            lines = self.read_file(file_path)
            
            if line_num-1 < len(lines):
                # Simply remove the extraneous closing brace
                lines[line_num-1] = lines[line_num-1].replace('}', '', 1)
                self.fixes_applied += 1
                logger.info(f"Fixed extraneous brace in {file_path}:{line_num}")
                self.write_file(file_path, lines)
    
    def fix_unterminated_strings(self) -> None:
        """Fix unterminated string literals."""
        logger.info("Fixing unterminated string issues...")
        
        # Look for unterminated string errors
        for file_path, line_num, _, error_message in self.error_groups.get('unterminated_string', []):
            lines = self.read_file(file_path)
            
            if line_num-1 < len(lines):
                line = lines[line_num-1]
                
                # Handle common case with escaped quotes in @available annotations
                if '@available' in line and '\\"' in line:
                    modified_line = line.replace('\\"', '"')
                    lines[line_num-1] = modified_line
                    self.fixes_applied += 1
                    logger.info(f"Fixed unterminated string in {file_path}:{line_num}")
                    self.write_file(file_path, lines)
    
    def fix_incorrect_optionals(self) -> None:
        """Fix issues with optional binding and unwrapping."""
        logger.info("Fixing optional handling issues...")
        
        # Fix issues with incorrect optional handling
        optional_issues = self.error_groups.get('incorrect_optional', [])
        
        for file_path, line_num, _, error_message in optional_issues:
            lines = self.read_file(file_path)
            
            if line_num-1 < len(lines):
                line = lines[line_num-1]
                
                # Check for common pattern with guard let without optional value
                if 'guard let' in line and '=' in line:
                    parts = line.split('=')
                    if len(parts) >= 2:
                        # Make sure the right side is treated as optional
                        if '?' not in parts[1]:
                            modified_line = f"{parts[0]}= {parts[1].strip()} as? {parts[1].strip().split('(')[0]}\n"
                            lines[line_num-1] = modified_line
                            self.fixes_applied += 1
                            logger.info(f"Fixed optional binding in {file_path}:{line_num}")
                            self.write_file(file_path, lines)
    
    def scan_for_type_issues(self) -> Dict[str, List[Tuple[str, int, str]]]:
        """Scan for common type definition issues across the codebase."""
        # This would be a more comprehensive scan across the codebase
        # to find and fix type definition issues that cause cascading errors
        
        return {}
        
def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_build_errors.py <build_output_file> [--dry-run]")
        sys.exit(1)
    
    build_output_file = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    fixer = BuildErrorFixer(build_output_file, dry_run)
    fixer.fix_all_errors()
    
    # Run specific fixes for known problematic files
    if not dry_run:
        logger.info("\nAdditional targeted fixes may be required.")
        logger.info("Consider manual inspection of the following files:")
        logger.info("1. Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift - Define missing operationFailed case")
        logger.info("2. Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift - Fix type references")
    
if __name__ == "__main__":
    main()
