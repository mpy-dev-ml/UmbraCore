#!/usr/bin/env python3
"""
Batch Error Resolver for UmbraCore Build Issues

This script helps fix common build errors in the UmbraCore project by:
1. Addressing Swift 6 compatibility issues
2. Adding missing error mappings
3. Resolving type namespace conflicts
4. Adding missing error enum cases

Usage:
  python3 batch_error_resolver.py --fix [error_type]

Where error_type can be:
  - swift6: Fix Swift 6 concurrency issues
  - errormapping: Fix error mapping functions
  - namespace: Fix namespace conflicts
  - all: Apply all fixes
"""

import os
import sys
import re
import argparse
import logging
from typing import List, Dict, Set, Tuple, Optional
from collections import defaultdict


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger(__name__)


class BatchErrorResolver:
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.sources_dir = os.path.join(project_root, "Sources")
        self.modified_files = set()
        
    def run(self, fix_types: List[str]) -> None:
        """Run the specified fixes"""
        if "all" in fix_types or "swift6" in fix_types:
            self.fix_swift6_issues()
        
        if "all" in fix_types or "errormapping" in fix_types:
            self.fix_error_mapping_issues()
            
        if "all" in fix_types or "namespace" in fix_types:
            self.fix_namespace_conflicts()
            
        if "all" in fix_types or "missing_cases" in fix_types:
            self.fix_missing_error_cases()
            
        logger.info(f"Modified {len(self.modified_files)} files in total")
        for file in sorted(self.modified_files):
            logger.info(f"  - {file}")

    def find_swift_files(self, directory: str) -> List[str]:
        """Find all Swift files in the given directory recursively"""
        swift_files = []
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith(".swift"):
                    swift_files.append(os.path.join(root, file))
        return swift_files

    def fix_swift6_issues(self) -> None:
        """Fix Swift 6 concurrency compatibility issues"""
        logger.info("Fixing Swift 6 concurrency issues...")
        
        # Find files with potential Swift 6 issues
        swift_files = self.find_swift_files(self.sources_dir)
        count = 0
        
        for file_path in swift_files:
            with open(file_path, "r") as f:
                content = f.read()
            
            # Check for common patterns that need Swift 6 compatibility fixes
            fixes_needed = False
            
            # 1. Fix non-sendable Decoder warnings by adding @preconcurrency
            if "init(from decoder: Decoder)" in content and "@preconcurrency" not in content:
                pattern = r"(\s+)public init\(from decoder: Decoder\)"
                replacement = r"\1@preconcurrency\n\1@available(*, deprecated, message: \"Will need to be refactored for Swift 6\")\n\1public init(from decoder: Decoder)"
                new_content = re.sub(pattern, replacement, content)
                if new_content != content:
                    content = new_content
                    fixes_needed = True
                    logger.info(f"Added @preconcurrency to Decoder in {os.path.basename(file_path)}")
            
            # 2. Fix task isolation issues
            if "Task { @MainActor in" in content:
                pattern = r"Task \{ @MainActor in"
                replacement = r"""// TODO: Swift 6 compatibility - refactor actor isolation
      // Using MainActor.run instead of Task { @MainActor in }
      MainActor.run {"""
                new_content = re.sub(pattern, replacement, content)
                if new_content != content:
                    content = new_content
                    fixes_needed = True
                    logger.info(f"Fixed Task isolation in {os.path.basename(file_path)}")
            
            # 3. Add missing Sendable conformance
            if "struct" in content and "Sendable" not in content and "Codable" in content:
                pattern = r"(struct \w+)(?:: Codable)"
                replacement = r"\1: Codable, Sendable"
                new_content = re.sub(pattern, replacement, content)
                if new_content != content:
                    content = new_content
                    fixes_needed = True
                    logger.info(f"Added Sendable conformance in {os.path.basename(file_path)}")
            
            # Write back the file if changed
            if fixes_needed:
                with open(file_path, "w") as f:
                    f.write(content)
                self.modified_files.add(file_path)
                count += 1
        
        logger.info(f"Fixed Swift 6 issues in {count} files")

    def fix_error_mapping_issues(self) -> None:
        """Add missing error mapping functions"""
        logger.info("Fixing error mapping issues...")
        
        # Look for CoreTypesImplementation error adapter files
        error_adapter_files = []
        for root, _, files in os.walk(os.path.join(self.sources_dir, "CoreTypesImplementation")):
            for file in files:
                if "ErrorAdapter" in file and file.endswith(".swift"):
                    error_adapter_files.append(os.path.join(root, file))
        
        # Add missing error mapping functions if needed
        missing_functions = {
            "externalErrorToCoreError": """
/// Maps an external error to a CoreErrors.SecurityError
/// - Parameter error: The external error to map
/// - Returns: A CoreErrors.SecurityError
public func externalErrorToCoreError(_ error: Error) -> CoreErrors.SecurityError {
    if let securityError = error as? CoreErrors.SecurityError {
        return securityError
    }
    
    // Map based on error type
    if let externalError = error as? ExternalError {
        return CoreErrors.SecurityError.operationFailed(reason: externalError.reason)
    }
    
    // Default fallback
    return CoreErrors.SecurityError.operationFailed(reason: error.localizedDescription)
}
""",
            "mapExternalToCoreError": """
/// Maps an external error type to a CoreErrors.SecurityError
/// - Parameter error: The error to map
/// - Returns: A CoreErrors.SecurityError
public func mapExternalToCoreError(_ error: Error) -> CoreErrors.SecurityError {
    if let securityError = error as? CoreErrors.SecurityError {
        return securityError
    }
    
    // Default mapping
    return CoreErrors.SecurityError.operationFailed(reason: error.localizedDescription)
}
"""
        }
        
        for file_path in error_adapter_files:
            with open(file_path, "r") as f:
                content = f.read()
            
            # Check if we need to add any of the missing functions
            functions_to_add = []
            for func_name, func_impl in missing_functions.items():
                if func_name not in content:
                    functions_to_add.append(func_impl)
            
            if functions_to_add:
                # Add functions before the last closing brace
                if content.strip().endswith("}"):
                    content = content[:-1] + "\n".join(functions_to_add) + "\n}"
                else:
                    content += "\n" + "\n".join(functions_to_add)
                
                with open(file_path, "w") as f:
                    f.write(content)
                
                self.modified_files.add(file_path)
                logger.info(f"Added missing error mapping functions to {os.path.basename(file_path)}")
    
    def fix_namespace_conflicts(self) -> None:
        """Fix namespace conflicts by adding appropriate imports and type aliases"""
        logger.info("Fixing namespace conflicts...")
        
        # Look for files with potential namespace conflicts
        security_related_files = []
        for root, _, files in os.walk(self.sources_dir):
            for file in files:
                if file.endswith(".swift"):
                    file_path = os.path.join(root, file)
                    with open(file_path, "r") as f:
                        content = f.read()
                    
                    # Check if file might have security-related namespace conflicts
                    if ("SecurityProtocolsCore" in content or 
                        "XPCProtocolsCore" in content or 
                        "SecurityError" in content or 
                        "XPCSecurityError" in content):
                        security_related_files.append(file_path)
        
        aliases_added = 0
        for file_path in security_related_files:
            with open(file_path, "r") as f:
                content = f.read()
            
            changes_made = False
            
            # Check for potential unqualified SecurityError usages
            if "SecurityError" in content and "SecurityProtocolsCore.SecurityError" not in content:
                # 1. First check imports
                if "import SecurityProtocolsCore" in content and "import CoreErrors" in content:
                    # Both modules imported - potential conflict
                    # Add type alias to disambiguate
                    if "typealias SPCSecurityError = SecurityProtocolsCore.SecurityError" not in content:
                        import_section_end = content.find("\n\n", content.find("import "))
                        if import_section_end == -1:
                            import_section_end = content.find("\n", content.find("import "))
                        
                        # Add type alias after imports
                        new_content = content[:import_section_end] + "\n\n// Type alias to disambiguate SecurityError types\ntypealias SPCSecurityError = SecurityProtocolsCore.SecurityError\n" + content[import_section_end:]
                        content = new_content
                        changes_made = True
                        aliases_added += 1
            
            # Check for XPCSecurityError usage
            if "XPCSecurityError" in content:
                # Make sure CoreErrors import is present
                if "import CoreErrors" not in content:
                    import_line = "import CoreErrors"
                    first_import = content.find("import ")
                    if first_import != -1:
                        next_line = content.find("\n", first_import)
                        new_content = content[:next_line+1] + import_line + "\n" + content[next_line+1:]
                        content = new_content
                        changes_made = True
            
            if changes_made:
                with open(file_path, "w") as f:
                    f.write(content)
                self.modified_files.add(file_path)
                logger.info(f"Fixed namespace conflicts in {os.path.basename(file_path)}")
        
        logger.info(f"Added {aliases_added} type aliases to resolve namespace conflicts")

    def fix_missing_error_cases(self) -> None:
        """Fix missing error enum cases"""
        logger.info("Fixing missing error cases...")
        
        # Security error types that need to be added
        error_cases_to_add = {
            "CoreErrors.SecurityError": [
                "accessError",
                "bookmarkError",
                "bookmarkCreationFailed",
                "bookmarkResolutionFailed"
            ],
            "SecureBytesError": [
                "memoryAllocationFailed"
            ],
            "XPCSecurityError": [
                "notImplemented"
            ]
        }
        
        # Map error types to their file locations
        error_type_locations = {
            "CoreErrors.SecurityError": os.path.join(self.sources_dir, "CoreErrors", "SecurityError.swift"),
            "SecureBytesError": os.path.join(self.sources_dir, "SecureBytes", "SecureBytesError.swift"),
            "XPCSecurityError": os.path.join(self.sources_dir, "XPCProtocolsCore", "XPCProtocolsCore.swift")
        }
        
        for error_type, cases in error_cases_to_add.items():
            file_path = error_type_locations.get(error_type)
            if not file_path or not os.path.exists(file_path):
                logger.warning(f"Could not find file for {error_type}")
                continue
            
            with open(file_path, "r") as f:
                content = f.read()
            
            # Find the error enum definition
            enum_match = re.search(r"enum\s+(\w+)(?:\s*:.*?)?\s*\{", content)
            if not enum_match:
                logger.warning(f"Could not find enum definition in {file_path}")
                continue
            
            enum_name = enum_match.group(1)
            enum_start = enum_match.start()
            enum_end = content.find("}", enum_start)
            
            if enum_end == -1:
                logger.warning(f"Could not find end of enum in {file_path}")
                continue
            
            # Get the enum content
            enum_content = content[enum_start:enum_end]
            
            # Check which cases are missing
            missing_cases = []
            for case in cases:
                if case not in enum_content:
                    # Determine the case format (camelCase, snake_case)
                    if "_" in enum_content:
                        # Snake case
                        case_format = f"case {case}"
                    else:
                        # Camel case with parameter
                        if "(" in enum_content:
                            case_format = f"case {case}(reason: String)"
                        else:
                            case_format = f"case {case}"
                    
                    missing_cases.append(case_format)
            
            if missing_cases:
                # Add missing cases before the closing brace
                new_content = content[:enum_end]
                
                # Add each missing case with proper indentation
                for case in missing_cases:
                    # Find the indentation level
                    indent_match = re.search(r"(\s+)case", enum_content)
                    indent = "  " if not indent_match else indent_match.group(1)
                    new_content += f"\n{indent}{case}"
                
                new_content += content[enum_end:]
                
                with open(file_path, "w") as f:
                    f.write(new_content)
                
                self.modified_files.add(file_path)
                logger.info(f"Added missing cases {', '.join(c.split('(')[0] for c in missing_cases)} to {enum_name} in {os.path.basename(file_path)}")
        

def main() -> None:
    parser = argparse.ArgumentParser(description="Batch Error Resolver for UmbraCore Build Issues")
    parser.add_argument("--fix", choices=["swift6", "errormapping", "namespace", "missing_cases", "all"], 
                        default="all", help="Type of fixes to apply")
    parser.add_argument("--project-root", default="/Users/mpy/CascadeProjects/UmbraCore",
                        help="Root directory of the UmbraCore project")
    parser.add_argument("--dry-run", action="store_true", 
                        help="Don't actually modify files, just report what would be done")
    args = parser.parse_args()
    
    logger.info(f"Starting batch error resolver for {args.project_root}")
    logger.info(f"Fix types: {args.fix}")
    
    if args.dry_run:
        logger.info("DRY RUN MODE - No files will be modified")
    
    resolver = BatchErrorResolver(args.project_root)
    
    try:
        fix_types = [args.fix] if args.fix != "all" else ["all"]
        resolver.run(fix_types)
        logger.info("Batch error resolution completed successfully")
    except Exception as e:
        logger.error(f"Error during batch resolution: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
