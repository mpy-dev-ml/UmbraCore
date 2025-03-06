#!/usr/bin/env python3
"""
CoreTypes Migration Automation Script

This script automates the migration from CoreTypes to CoreTypesInterfaces in the UmbraCore project.
It handles both Swift import statements and Bazel dependencies.

Usage:
    python3 coretypes_migration.py --project-dir /path/to/project --dry-run
    python3 coretypes_migration.py --project-dir /path/to/project --interactive
    python3 coretypes_migration.py --project-dir /path/to/project --apply-all

Author: UmbraCore Team
Date: March 2025
"""

import os
import re
import shutil
import argparse
import datetime
from pathlib import Path
from typing import List, Tuple, Dict

# Configuration
OLD_IMPORT = "CoreTypes"
NEW_IMPORT = "CoreTypesInterfaces"
OLD_BAZEL_DEP = "//Sources/CoreTypes"
NEW_BAZEL_DEP = "//Sources/CoreTypesInterfaces"
BACKUP_DIR = "migration_backups"


class MigrationStats:
    """Track statistics about the migration process."""
    
    def __init__(self):
        self.swift_files_found = 0
        self.swift_files_updated = 0
        self.bazel_files_found = 0
        self.bazel_files_updated = 0
        self.errors = []
        self.warnings = []
        self.skipped_files = []
        
    def add_error(self, file_path: str, error_msg: str):
        """Add an error message to the stats."""
        self.errors.append((file_path, error_msg))
        
    def add_warning(self, file_path: str, warning_msg: str):
        """Add a warning message to the stats."""
        self.warnings.append((file_path, warning_msg))
        
    def add_skipped(self, file_path: str, reason: str):
        """Track a skipped file."""
        self.skipped_files.append((file_path, reason))
        
    def __str__(self) -> str:
        """Generate a human-readable report of the migration statistics."""
        report = []
        report.append("=" * 80)
        report.append("CORETYPES MIGRATION REPORT")
        report.append("=" * 80)
        report.append(f"Swift files found with CoreTypes imports: {self.swift_files_found}")
        report.append(f"Swift files successfully updated: {self.swift_files_updated}")
        report.append(f"BUILD.bazel files found with CoreTypes dependencies: {self.bazel_files_found}")
        report.append(f"BUILD.bazel files successfully updated: {self.bazel_files_updated}")
        
        if self.errors:
            report.append("\nERRORS:")
            for file_path, error in self.errors:
                report.append(f"  - {file_path}: {error}")
                
        if self.warnings:
            report.append("\nWARNINGS:")
            for file_path, warning in self.warnings:
                report.append(f"  - {file_path}: {warning}")
                
        if self.skipped_files:
            report.append("\nSKIPPED FILES:")
            for file_path, reason in self.skipped_files:
                report.append(f"  - {file_path}: {reason}")
                
        return "\n".join(report)


def create_backup(file_path: str, backup_dir: str) -> str:
    """Create a backup of the file before modifying it."""
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    rel_path = os.path.relpath(file_path, os.path.dirname(backup_dir))
    backup_path = os.path.join(backup_dir, f"{rel_path}.{timestamp}.bak")
    
    # Create directory structure if it doesn't exist
    os.makedirs(os.path.dirname(backup_path), exist_ok=True)
    
    # Copy the file
    shutil.copy2(file_path, backup_path)
    return backup_path


def find_swift_files_with_import(directory: str, import_name: str) -> List[str]:
    """Find all Swift files containing a specific import statement."""
    result = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".swift"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                    # Using regex to match both standard and @testable import statements
                    if re.search(r"(@testable\s+)?import\s+" + re.escape(import_name) + r"\b", content):
                        result.append(file_path)
                except Exception as e:
                    print(f"Error reading file {file_path}: {e}")
    return result


def find_bazel_files_with_dependency(directory: str, dependency: str) -> List[str]:
    """Find all BUILD.bazel files with a specific dependency."""
    result = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file == "BUILD.bazel":
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                    if dependency in content:
                        result.append(file_path)
                except Exception as e:
                    print(f"Error reading file {file_path}: {e}")
    return result


def update_swift_import(file_path: str, old_import: str, new_import: str, 
                       backup_dir: str, stats: MigrationStats, dry_run: bool = False) -> bool:
    """Update import statements in a Swift file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Use regex to match both standard and @testable import statements
        pattern = r"^(@testable\s+)?import\s+" + re.escape(old_import) + r"\b.*$"
        
        # Find all matches to preserve @testable if present
        matches = re.finditer(pattern, content, re.MULTILINE)
        updated_content = content
        
        for match in matches:
            original_line = match.group(0)
            testable_prefix = match.group(1) or ""
            new_line = f"{testable_prefix}import {new_import}"
            updated_content = updated_content.replace(original_line, new_line)
        
        # Check if content was actually modified
        if content == updated_content:
            stats.add_warning(file_path, "Import statement found but no changes were made")
            return False
        
        # In dry-run mode, just report what would change
        if dry_run:
            matches = re.finditer(pattern, content, re.MULTILINE)
            for match in matches:
                original_line = match.group(0)
                testable_prefix = match.group(1) or ""
                new_line = f"{testable_prefix}import {new_import}"
                print(f"Would change in {file_path}:\n  - {original_line}\n  + {new_line}")
            return True
            
        # Create backup before modifying
        backup_path = create_backup(file_path, backup_dir)
        
        # Write the updated content
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(updated_content)
            
        print(f"Updated imports in {file_path} (backup at {backup_path})")
        return True
        
    except Exception as e:
        stats.add_error(file_path, f"Error updating file: {str(e)}")
        return False


def update_bazel_dependency(file_path: str, old_dep: str, new_dep: str, 
                           backup_dir: str, stats: MigrationStats, dry_run: bool = False) -> bool:
    """Update a dependency in a BUILD.bazel file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Check if the dependency exists in the content
        if old_dep not in content:
            stats.add_warning(file_path, f"Dependency {old_dep} not found in file")
            return False
            
        # Simple string replacement for dependencies
        updated_content = content.replace(old_dep, new_dep)
        
        # Check if content was actually modified
        if content == updated_content:
            stats.add_warning(file_path, "Dependency found but no changes were made")
            return False
        
        # In dry-run mode, just report what would change
        if dry_run:
            print(f"Would replace all occurrences of {old_dep} with {new_dep} in {file_path}")
            return True
            
        # Create backup before modifying
        backup_path = create_backup(file_path, backup_dir)
        
        # Write the updated content
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(updated_content)
            
        print(f"Updated dependencies in {file_path} (backup at {backup_path})")
        return True
        
    except Exception as e:
        stats.add_error(file_path, f"Error updating file: {str(e)}")
        return False


def interactive_update(files: List[str], update_func, old_value: str, new_value: str,
                      file_type: str, backup_dir: str, stats: MigrationStats) -> None:
    """Interactively update files with user confirmation."""
    print(f"\nFound {len(files)} {file_type} files to update.")
    
    for file_path in files:
        print(f"\nFile: {file_path}")
        choice = input("Update this file? (y/n/q to quit): ").lower()
        
        if choice == 'q':
            print("Exiting interactive mode")
            break
        elif choice == 'y':
            success = update_func(file_path, old_value, new_value, backup_dir, stats)
            if success and file_type == "Swift":
                stats.swift_files_updated += 1
            elif success and file_type == "Bazel":
                stats.bazel_files_updated += 1
        else:
            stats.add_skipped(file_path, "Skipped by user")


def main():
    """Main function to run the migration script."""
    parser = argparse.ArgumentParser(description="Migrate CoreTypes to CoreTypesInterfaces")
    parser.add_argument("--project-dir", required=True, help="Path to the project directory")
    parser.add_argument("--backup-dir", help="Directory for file backups")
    
    # Execution modes
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--dry-run", action="store_true", help="Don't make any changes, just report what would change")
    group.add_argument("--interactive", action="store_true", help="Confirm each change interactively")
    group.add_argument("--apply-all", action="store_true", help="Apply all changes without confirmation")
    
    # Additional options
    parser.add_argument("--swift-only", action="store_true", help="Only update Swift files")
    parser.add_argument("--bazel-only", action="store_true", help="Only update Bazel files")
    parser.add_argument("--output-report", help="Path to write the migration report")
    
    args = parser.parse_args()
    
    # Initialize statistics
    stats = MigrationStats()
    
    # Set up backup directory
    project_dir = os.path.abspath(args.project_dir)
    backup_dir = args.backup_dir or os.path.join(project_dir, BACKUP_DIR)
    os.makedirs(backup_dir, exist_ok=True)
    print(f"Backups will be stored in: {backup_dir}")
    
    # Find files to update
    if not args.bazel_only:
        swift_files = find_swift_files_with_import(project_dir, OLD_IMPORT)
        stats.swift_files_found = len(swift_files)
        print(f"Found {stats.swift_files_found} Swift files importing {OLD_IMPORT}")
    else:
        swift_files = []
        
    if not args.swift_only:
        bazel_files = find_bazel_files_with_dependency(project_dir, OLD_BAZEL_DEP)
        stats.bazel_files_found = len(bazel_files)
        print(f"Found {stats.bazel_files_found} BUILD.bazel files with {OLD_BAZEL_DEP} dependencies")
    else:
        bazel_files = []
    
    # Handle different execution modes
    if args.dry_run:
        print("\nDRY RUN MODE - No changes will be made\n")
        
        # Just show what would change
        for file_path in swift_files:
            update_swift_import(file_path, OLD_IMPORT, NEW_IMPORT, backup_dir, stats, dry_run=True)
            
        for file_path in bazel_files:
            update_bazel_dependency(file_path, OLD_BAZEL_DEP, NEW_BAZEL_DEP, backup_dir, stats, dry_run=True)
            
    elif args.interactive:
        print("\nINTERACTIVE MODE - You will be prompted for each file\n")
        
        # Update Swift files interactively
        if swift_files:
            interactive_update(swift_files, update_swift_import, OLD_IMPORT, NEW_IMPORT, 
                              "Swift", backup_dir, stats)
        
        # Update Bazel files interactively
        if bazel_files:
            interactive_update(bazel_files, update_bazel_dependency, OLD_BAZEL_DEP, NEW_BAZEL_DEP,
                              "Bazel", backup_dir, stats)
    
    elif args.apply_all:
        print("\nAPPLYING ALL CHANGES\n")
        
        # Update all Swift files
        for file_path in swift_files:
            if update_swift_import(file_path, OLD_IMPORT, NEW_IMPORT, backup_dir, stats):
                stats.swift_files_updated += 1
                
        # Update all Bazel files
        for file_path in bazel_files:
            if update_bazel_dependency(file_path, OLD_BAZEL_DEP, NEW_BAZEL_DEP, backup_dir, stats):
                stats.bazel_files_updated += 1
    
    # Generate report
    print("\n" + str(stats))
    
    if args.output_report:
        with open(args.output_report, "w", encoding="utf-8") as f:
            f.write(str(stats))
        print(f"\nReport written to: {args.output_report}")
    
    # Final message
    if not args.dry_run:
        print("\nMigration completed. Please review the changes and test the build.")


if __name__ == "__main__":
    main()
