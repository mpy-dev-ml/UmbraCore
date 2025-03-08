#!/usr/bin/env python3
"""
Parse Bazel build errors from a markdown file and group them by error type.
This helps identify patterns that can be addressed in batches.
"""

import re
import sys
import os
from collections import defaultdict

def parse_build_output(file_path):
    error_groups = defaultdict(list)
    swift_6_warnings = []
    missing_function_errors = []
    type_conformance_errors = []
    missing_member_errors = []
    other_errors = []
    
    current_module = "Unknown"
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Track current module being compiled
        if line.startswith("INFO: From Compiling Swift module"):
            current_module = line.split("//")[1].split(":")[0]
        
        # Swift 6 language mode warnings
        if "this is an error in the Swift 6 language mode" in line:
            context_lines = []
            # Get a few lines before and after for context
            for j in range(max(0, i-3), min(len(lines), i+4)):
                context_lines.append(lines[j].strip())
            
            swift_6_warnings.append({
                "module": current_module,
                "message": line,
                "context": "\n".join(context_lines),
                "file": get_file_from_context(context_lines)
            })
        
        # Missing function errors
        elif "cannot find" in line and "in scope" in line:
            context_lines = []
            for j in range(max(0, i-3), min(len(lines), i+4)):
                context_lines.append(lines[j].strip())
            
            missing_function_errors.append({
                "module": current_module,
                "message": line,
                "context": "\n".join(context_lines),
                "file": get_file_from_context(context_lines),
                "missing_item": extract_missing_item(line)
            })
        
        # Type conformance issues
        elif "does not conform to" in line or "cannot conform to" in line:
            context_lines = []
            for j in range(max(0, i-3), min(len(lines), i+4)):
                context_lines.append(lines[j].strip())
            
            type_conformance_errors.append({
                "module": current_module,
                "message": line,
                "context": "\n".join(context_lines),
                "file": get_file_from_context(context_lines)
            })
        
        # Missing members in types
        elif "has no member" in line:
            context_lines = []
            for j in range(max(0, i-3), min(len(lines), i+4)):
                context_lines.append(lines[j].strip())
            
            missing_member_errors.append({
                "module": current_module,
                "message": line,
                "context": "\n".join(context_lines),
                "file": get_file_from_context(context_lines),
                "type": extract_type(line),
                "missing_member": extract_missing_member(line)
            })
        
        # Other compilation errors
        elif "error:" in line and not line.startswith("INFO:") and not line.startswith("ERROR:"):
            context_lines = []
            for j in range(max(0, i-3), min(len(lines), i+4)):
                context_lines.append(lines[j].strip())
            
            other_errors.append({
                "module": current_module,
                "message": line,
                "context": "\n".join(context_lines),
                "file": get_file_from_context(context_lines)
            })
        
        i += 1
    
    error_groups["Swift 6 Language Mode Warnings"] = swift_6_warnings
    error_groups["Missing Function Errors"] = missing_function_errors
    error_groups["Type Conformance Issues"] = type_conformance_errors
    error_groups["Missing Member Errors"] = missing_member_errors
    error_groups["Other Errors"] = other_errors
    
    return error_groups

def get_file_from_context(context_lines):
    for line in context_lines:
        if re.search(r'Sources/[A-Za-z0-9_/]+\.swift:', line):
            match = re.search(r'(Sources/[A-Za-z0-9_/]+\.swift):', line)
            if match:
                return match.group(1)
    return "Unknown"

def extract_missing_item(line):
    match = re.search(r"cannot find '([^']+)' in scope", line)
    if match:
        return match.group(1)
    return "Unknown"

def extract_type(line):
    match = re.search(r"type '([^']+)'", line)
    if match:
        return match.group(1)
    return "Unknown"

def extract_missing_member(line):
    match = re.search(r"has no member '([^']+)'", line)
    if match:
        return match.group(1)
    return "Unknown"

def write_grouped_errors(error_groups, output_file):
    with open(output_file, 'w') as f:
        f.write("# Grouped Build Errors\n\n")
        
        # Write summary counts
        f.write("## Summary\n\n")
        for group, errors in error_groups.items():
            f.write(f"- **{group}**: {len(errors)} issues\n")
        f.write("\n")
        
        # Write details for each group
        for group, errors in error_groups.items():
            f.write(f"## {group}\n\n")
            
            if group == "Swift 6 Language Mode Warnings":
                # Group Swift 6 warnings by pattern
                pattern_groups = defaultdict(list)
                for error in errors:
                    if "task or actor isolated value cannot be sent" in error["message"]:
                        pattern_groups["Actor Isolation"].append(error)
                    elif "non-sendable type" in error["message"]:
                        pattern_groups["Non-Sendable Type"].append(error)
                    else:
                        pattern_groups["Other Swift 6"].append(error)
                
                for pattern, pattern_errors in pattern_groups.items():
                    f.write(f"### {pattern} ({len(pattern_errors)} issues)\n\n")
                    
                    # Sample a few errors
                    sample_size = min(3, len(pattern_errors))
                    f.write(f"Sample of {sample_size} issues:\n\n")
                    
                    for i in range(sample_size):
                        error = pattern_errors[i]
                        f.write(f"**File**: `{error['file']}`\n")
                        f.write(f"**Message**: {error['message']}\n\n")
                        f.write("```\n" + error['context'] + "\n```\n\n")
                    
                    # List the remaining files
                    if len(pattern_errors) > sample_size:
                        f.write("**Other affected files**:\n\n")
                        for i in range(sample_size, len(pattern_errors)):
                            f.write(f"- `{pattern_errors[i]['file']}`\n")
                        f.write("\n")
            
            elif group == "Missing Function Errors":
                # Group by missing function
                function_groups = defaultdict(list)
                for error in errors:
                    function_groups[error["missing_item"]].append(error)
                
                for function, function_errors in function_groups.items():
                    f.write(f"### Missing Function: `{function}` ({len(function_errors)} issues)\n\n")
                    
                    for error in function_errors:
                        f.write(f"**File**: `{error['file']}`\n")
                        f.write(f"**Message**: {error['message']}\n\n")
                        f.write("```\n" + error['context'] + "\n```\n\n")
                    
                    f.write("\n")
            
            elif group == "Missing Member Errors":
                # Group by type and missing member
                member_groups = defaultdict(list)
                for error in errors:
                    key = f"{error['type']} -> {error['missing_member']}"
                    member_groups[key].append(error)
                
                for key, member_errors in member_groups.items():
                    f.write(f"### {key} ({len(member_errors)} issues)\n\n")
                    
                    for error in member_errors:
                        f.write(f"**File**: `{error['file']}`\n")
                        f.write(f"**Message**: {error['message']}\n\n")
                        f.write("```\n" + error['context'] + "\n```\n\n")
                    
                    f.write("\n")
            
            else:
                # Other error types
                for error in errors:
                    f.write(f"**File**: `{error['file']}`\n")
                    f.write(f"**Message**: {error['message']}\n\n")
                    f.write("```\n" + error['context'] + "\n```\n\n")
                
                f.write("\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python parse_build_errors.py <build_output_file> [output_file]")
        sys.exit(1)
    
    build_output_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "grouped_build_errors.md"
    
    if not os.path.exists(build_output_file):
        print(f"Error: File {build_output_file} not found")
        sys.exit(1)
    
    error_groups = parse_build_output(build_output_file)
    write_grouped_errors(error_groups, output_file)
    
    print(f"Grouped errors written to {output_file}")
    
    # Print summary
    print("\nError Summary:")
    for group, errors in error_groups.items():
        print(f"- {group}: {len(errors)} issues")

if __name__ == "__main__":
    main()
