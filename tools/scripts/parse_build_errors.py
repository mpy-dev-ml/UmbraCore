#!/usr/bin/env python3
"""
Build Error Parser for UmbraCore

Parses a Bazel build output and organizes errors and warnings by target.
Generates a markdown file with well-formatted results.
"""

import re
import sys
from collections import defaultdict
import os

def parse_build_output(filename):
    """Parse the Bazel build output file and extract errors and warnings by target."""
    with open(filename, 'r') as f:
        content = f.read()
    
    # Dictionary to store errors and warnings by target
    targets = defaultdict(lambda: {'errors': [], 'warnings': []})
    
    # Store current target, file, and context for errors/warnings
    current_target = None
    current_file = None
    
    # Regular expressions for matching patterns in Bazel output
    target_pattern = re.compile(r'INFO: From Compiling Swift module (//[^:]+:[^:]+):')
    error_pattern = re.compile(r'([^:]+\.swift):(\d+):(\d+): (error|fatal error): (.+)$', re.MULTILINE)
    warning_pattern = re.compile(r'([^:]+\.swift):(\d+):(\d+): warning: (.+)$', re.MULTILINE)
    
    # Split by lines for processing
    lines = content.split('\n')
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check if the line identifies a target
        target_match = target_pattern.search(line)
        if target_match:
            current_target = target_match.group(1)
            i += 1
            continue
            
        # Check for errors in current line
        error_match = error_pattern.search(line)
        if error_match and current_target:
            file_path = error_match.group(1)
            line_num = error_match.group(2)
            col_num = error_match.group(3)
            error_message = error_match.group(5).strip()
            
            # Get context (5 lines before and after error)
            context = []
            for j in range(max(0, i-5), min(len(lines), i+6)):
                if j != i:  # Skip the error line itself as we already have it
                    context_line = lines[j].strip()
                    if context_line:
                        context.append(context_line)
            
            targets[current_target]['errors'].append({
                'file': file_path,
                'line': line_num,
                'column': col_num,
                'message': error_message,
                'context': context[:8]  # Limit to 8 context lines
            })
            
        # Check for warnings in current line
        warning_match = warning_pattern.search(line)
        if warning_match and current_target:
            file_path = warning_match.group(1)
            line_num = warning_match.group(2)
            col_num = warning_match.group(3)
            warning_message = warning_match.group(4).strip()
            
            # Get context (5 lines before and after warning)
            context = []
            for j in range(max(0, i-5), min(len(lines), i+6)):
                if j != i:  # Skip the warning line itself
                    context_line = lines[j].strip()
                    if context_line:
                        context.append(context_line)
            
            targets[current_target]['warnings'].append({
                'file': file_path,
                'line': line_num,
                'column': col_num,
                'message': warning_message,
                'context': context[:8]  # Limit to 8 context lines
            })
            
        # If none of the patterns match, look for additional error information in non-standard format
        if current_target and "error:" in line and not error_match and not warning_match and not target_match:
            # This could be an error that doesn't follow the standard format
            match = re.search(r'error: (.+)$', line)
            if match:
                error_message = match.group(1).strip()
                
                # Get some context
                context = []
                for j in range(max(0, i-3), min(len(lines), i+4)):
                    if j != i:
                        context_line = lines[j].strip()
                        if context_line:
                            context.append(context_line)
                
                # Add to the last error if it exists, otherwise create a new one
                if targets[current_target]['errors']:
                    targets[current_target]['errors'][-1]['additional_info'] = error_message
                    targets[current_target]['errors'][-1]['context'].extend(context[:5])
                else:
                    targets[current_target]['errors'].append({
                        'file': 'unknown',
                        'line': '0',
                        'column': '0',
                        'message': error_message,
                        'context': context[:8]
                    })
        
        i += 1
        
    # Second pass for errors that don't have a current_target but are associated with a file
    # This is common in Bazel output where errors are reported outside the "Compiling Swift module" sections
    standalone_errors = []
    
    for i, line in enumerate(lines):
        # Only process lines not already assigned to a target
        if "error:" in line and not any(error.get('processed_line') == i for target_info in targets.values() for error in target_info['errors']):
            match = re.search(r'([^:]+\.swift):(\d+):(\d+): error: (.+)$', line)
            if match:
                file_path = match.group(1)
                line_num = match.group(2)
                col_num = match.group(3)
                error_message = match.group(4).strip()
                
                # Try to find which target this file belongs to
                target_for_file = None
                for target, info in targets.items():
                    if any(error.get('file') == file_path for error in info['errors']) or any(warning.get('file') == file_path for warning in info['warnings']):
                        target_for_file = target
                        break
                
                # If we couldn't find a target, create a special "Unassigned" target
                if not target_for_file:
                    target_for_file = "Unassigned"
                
                # Get context
                context = []
                for j in range(max(0, i-5), min(len(lines), i+6)):
                    if j != i:
                        context_line = lines[j].strip()
                        if context_line:
                            context.append(context_line)
                
                targets[target_for_file]['errors'].append({
                    'file': file_path,
                    'line': line_num,
                    'column': col_num,
                    'message': error_message,
                    'context': context[:8],
                    'processed_line': i  # Mark this line as processed
                })
    
    return targets

def generate_markdown(targets, output_filename):
    """Generate a markdown file with the parsed errors and warnings."""
    with open(output_filename, 'w') as f:
        f.write("# UmbraCore Build Analysis\n\n")
        
        # Summary section
        f.write("## Summary\n\n")
        total_errors = sum(len(target_info['errors']) for target_info in targets.values())
        total_warnings = sum(len(target_info['warnings']) for target_info in targets.values())
        targets_with_errors = sum(1 for target_info in targets.values() if target_info['errors'])
        targets_with_warnings = sum(1 for target_info in targets.values() if target_info['warnings'])
        
        f.write(f"- **Total Errors:** {total_errors}\n")
        f.write(f"- **Total Warnings:** {total_warnings}\n")
        f.write(f"- **Targets with Errors:** {targets_with_errors}\n")
        f.write(f"- **Targets with Warnings:** {targets_with_warnings}\n\n")
        
        # Table of Contents
        f.write("## Table of Contents\n\n")
        # First list targets with errors
        if targets_with_errors > 0:
            f.write("### Targets with Errors\n\n")
            for target, info in sorted(targets.items(), key=lambda x: len(x[1]['errors']), reverse=True):
                if info['errors']:
                    f.write(f"- [{target}](#{target.replace('/', '_').replace(':', '_').replace('.', '_')}) - {len(info['errors'])} errors\n")
        
        # Then list targets with warnings only
        if targets_with_warnings > 0:
            f.write("\n### Targets with Warnings Only\n\n")
            for target, info in sorted(targets.items(), key=lambda x: len(x[1]['warnings']), reverse=True):
                if info['warnings'] and not info['errors']:
                    f.write(f"- [{target}](#{target.replace('/', '_').replace(':', '_').replace('.', '_')}) - {len(info['warnings'])} warnings\n")
        
        # Detailed sections for each target
        f.write("\n## Detailed Analysis\n\n")
        for target, info in sorted(targets.items(), key=lambda x: (len(x[1]['errors']), len(x[1]['warnings'])), reverse=True):
            f.write(f"### {target}\n\n")
            anchor = target.replace('/', '_').replace(':', '_').replace('.', '_')
            f.write(f"<a name='{anchor}'></a>\n\n")
            
            if info['errors']:
                f.write("#### Errors\n\n")
                for i, error in enumerate(info['errors']):
                    f.write(f"**Error {i+1}:** {error['message']}\n")
                    f.write(f"- **File:** {error['file']}\n")
                    f.write(f"- **Line:** {error['line']}, **Column:** {error['column']}\n")
                    if 'additional_info' in error:
                        f.write(f"- **Additional Info:** {error['additional_info']}\n")
                    
                    if error['context']:
                        f.write("\n```swift\n")
                        for context_line in error['context']:
                            f.write(f"{context_line}\n")
                        f.write("```\n\n")
                    f.write("\n")
            
            if info['warnings']:
                f.write("#### Warnings\n\n")
                for i, warning in enumerate(info['warnings']):
                    f.write(f"**Warning {i+1}:** {warning['message']}\n")
                    f.write(f"- **File:** {warning['file']}\n")
                    f.write(f"- **Line:** {warning['line']}, **Column:** {warning['column']}\n")
                    
                    if warning['context']:
                        f.write("\n```swift\n")
                        for context_line in warning['context']:
                            f.write(f"{context_line}\n")
                        f.write("```\n\n")
                    f.write("\n")
            
            f.write("---\n\n")

def main():
    """Main function to parse build output and generate markdown."""
    input_filename = 'build_output.md'
    output_filename = 'build_analysis.md'
    
    if not os.path.exists(input_filename):
        print(f"Error: {input_filename} not found.")
        sys.exit(1)
    
    targets = parse_build_output(input_filename)
    generate_markdown(targets, output_filename)
    print(f"Analysis complete. Results written to {output_filename}")

if __name__ == "__main__":
    main()
