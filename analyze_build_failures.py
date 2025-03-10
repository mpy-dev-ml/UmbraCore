#!/usr/bin/env python3
"""
Build Failure Analysis Script

This script analyzes the Bazel build output JSON file to identify and rank targets
by the number of failures they experienced during the build.
"""

import json
import pandas as pd
import os
from collections import defaultdict

def analyze_build_failures(json_file_path):
    """
    Analyze build failures from a Bazel build event JSON file.
    
    Args:
        json_file_path: Path to the build_output.json file
    
    Returns:
        DataFrame with targets ranked by number of failures
    """
    print(f"Analyzing build failures from {json_file_path}...")
    
    # Check if file exists
    if not os.path.exists(json_file_path):
        print(f"Error: File {json_file_path} does not exist.")
        return None
    
    # Parse the JSON file line by line (Bazel Build Event Protocol format)
    failed_targets = defaultdict(list)
    error_messages = defaultdict(list)
    
    with open(json_file_path, 'r') as f:
        for line in f:
            try:
                event = json.loads(line)
                
                # Check for targetComplete events with failed status
                if 'id' in event and 'targetCompleted' in event['id']:
                    target_label = event['id']['targetCompleted']['label']
                    
                    # Check if this target failed
                    if 'completed' in event and 'success' in event['completed'] and not event['completed']['success']:
                        failed_targets[target_label].append(1)
                
                # Check for action completed events with errors
                if 'id' in event and 'actionCompleted' in event['id'] and 'stderr' in event:
                    action_id = event['id']['actionCompleted']['primaryOutput']
                    stderr = event['stderr']
                    if stderr and len(stderr) > 0:
                        # Try to associate with a target
                        for target in failed_targets.keys():
                            if target in action_id:
                                error_messages[target].append(stderr)
                                break
            except json.JSONDecodeError:
                continue
            except Exception as e:
                print(f"Error processing event: {e}")
                continue
    
    # Create a DataFrame for analysis
    if not failed_targets:
        print("No build failures found in the Build Event Protocol format.")
        
        # Try a different approach - look for error messages directly
        print("Searching for error messages directly...")
        
        with open(json_file_path, 'r') as f:
            content = f.read()
            
        # Look for common error patterns
        error_patterns = [
            "error:", "ERROR:", "failed", "FAILED", "exception"
        ]
        
        found_errors = False
        for pattern in error_patterns:
            if pattern in content.lower():
                found_errors = True
                print(f"Found potential errors matching pattern: {pattern}")
        
        if not found_errors:
            print("No obvious error patterns found. The build might have succeeded.")
            
        # Try to extract build summary
        try:
            with open(json_file_path, 'r') as f:
                for line in f:
                    event = json.loads(line)
                    if 'id' in event and 'buildFinished' in event['id'] and 'buildFinished' in event:
                        result = event['buildFinished']
                        if 'exitCode' in result and result['exitCode'] != 0:
                            print(f"Build failed with exit code: {result['exitCode']}")
                            if 'failureDetail' in result:
                                print(f"Failure detail: {result['failureDetail']}")
                        else:
                            print("Build appears to have completed successfully.")
                        break
        except Exception as e:
            print(f"Error extracting build summary: {e}")
        
        return pd.DataFrame(columns=['Target', 'Failures', 'Error Messages'])
    
    results = []
    for target, failures in failed_targets.items():
        errors = error_messages.get(target, ["No specific error message captured"])
        results.append({
            'Target': target,
            'Failures': len(failures),
            'Error Messages': '\n'.join(errors[:3]) + (f"\n... and {len(errors) - 3} more" if len(errors) > 3 else "")
        })
    
    df = pd.DataFrame(results)
    df = df.sort_values('Failures', ascending=False).reset_index(drop=True)
    
    return df

def main():
    """Main function to run the analysis"""
    json_file_path = 'build_output.json'
    
    # Analyze build failures
    failures_df = analyze_build_failures(json_file_path)
    
    if failures_df is not None and not failures_df.empty:
        print("\n=== Build Failures Analysis ===")
        print(f"Total Failed Targets: {len(failures_df)}")
        print("\n=== Targets Ranked by Number of Failures ===")
        
        # Display the results
        pd.set_option('display.max_colwidth', 100)
        print(failures_df[['Target', 'Failures']].to_string(index=False))
        
        # Save detailed results to CSV
        csv_file = 'build_failures_analysis.csv'
        failures_df.to_csv(csv_file, index=False)
        print(f"\nDetailed analysis saved to {csv_file}")
        
        # Group by directory/module
        print("\n=== Failures Grouped by Module ===")
        module_failures = failures_df['Target'].apply(lambda x: x.split(':')[0].split('/')[-1] if '/' in x else x.split(':')[0])
        module_counts = module_failures.value_counts().reset_index()
        module_counts.columns = ['Module', 'Failures']
        print(module_counts.to_string(index=False))
        
        # Save module analysis to CSV
        module_csv = 'module_failures_analysis.csv'
        module_counts.to_csv(module_csv, index=False)
        print(f"\nModule analysis saved to {module_csv}")
    
if __name__ == "__main__":
    main()
