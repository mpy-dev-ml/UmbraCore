#!/usr/bin/env python3

import os
import re
from pathlib import Path

# ANSI color codes
GREEN = '\033[0;32m'
BLUE = '\033[0;34m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'

def fix_build_file(build_file):
    path = Path(build_file)
    dir_name = path.parent
    base_dir = dir_name.name
    parent_dir = dir_name.parent.name
    
    print(f"Fixing {build_file}...")
    
    # Read the file
    if not path.exists():
        print(f"{RED}File not found: {build_file}{NC}")
        return False
    
    with open(build_file, 'r') as f:
        content = f.read()
    
    # Skip if this is not a swift_library
    if 'swift_library(' not in content:
        print(f"{YELLOW}Skipping non-swift_library file: {build_file}{NC}")
        return True
    
    # Split the file into lines for easier manipulation
    lines = content.splitlines()
    new_lines = []
    in_swift_library = False
    found_module_name = False
    found_copts = False
    found_visibility = False
    
    # Process each line
    for line in lines:
        stripped = line.strip()
        
        # Start of swift_library
        if 'swift_library(' in line:
            in_swift_library = True
            new_lines.append(line)
            # Add name and module_name right after swift_library
            indent = line.index('swift_library')
            if parent_dir == "Sources":
                new_name = base_dir
            else:
                new_name = f"{parent_dir}_{base_dir}"
            new_lines.append(f"{' ' * indent}    module_name = \"{new_name}\",")
            found_module_name = True
            continue
        
        # Skip old module_name, copts, and visibility lines
        if in_swift_library and any(x in line for x in ['module_name =', 'copts =', 'visibility =']):
            if 'copts =' in line:
                found_copts = True
                # Skip until we find the closing bracket
                continue
            if 'visibility =' in line:
                found_visibility = True
                continue
            if 'module_name =' in line:
                found_module_name = True
                continue
        
        # Skip lines in a copts block we're removing
        if found_copts and '],' in line:
            found_copts = False
            continue
        
        # Add copts block before the closing parenthesis
        if in_swift_library and stripped == ')':
            indent = line.index(')')
            if not found_visibility:
                new_lines.append(f"{' ' * indent}    visibility = [\"//visibility:public\"],")
            if not found_copts:
                new_lines.append(f"{' ' * indent}    copts = [")
                new_lines.append(f"{' ' * indent}        \"-target\",")
                new_lines.append(f"{' ' * indent}        \"arm64-apple-macos14.0\",")
                new_lines.append(f"{' ' * indent}        \"-strict-concurrency=complete\",")
                new_lines.append(f"{' ' * indent}        \"-warn-concurrency\",")
                new_lines.append(f"{' ' * indent}        \"-enable-actor-data-race-checks\",")
                new_lines.append(f"{' ' * indent}    ],")
            new_lines.append(line)
            in_swift_library = False
            continue
        
        # Keep all other lines
        if not found_copts:
            new_lines.append(line)
    
    # Write the changes back
    with open(build_file, 'w') as f:
        f.write('\n'.join(new_lines))
    
    print(f"{GREEN}✓ Fixed {build_file}{NC}")
    return True

def main():
    print(f"{BLUE}UmbraCore BUILD File Fixer{NC}\n")
    
    # Find all BUILD.bazel files
    source_dir = "/Users/mpy/CascadeProjects/UmbraCore/Sources"
    build_files = []
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file == "BUILD.bazel":
                build_files.append(os.path.join(root, file))
    
    # Fix each BUILD file
    success_count = 0
    for build_file in build_files:
        if fix_build_file(build_file):
            success_count += 1
    
    print(f"\n{BLUE}Summary:{NC}")
    print(f"Total BUILD files processed: {len(build_files)}")
    print(f"Successfully fixed: {success_count}")
    print(f"Failed: {len(build_files) - success_count}")

if __name__ == "__main__":
    main()
