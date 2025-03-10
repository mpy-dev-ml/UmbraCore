import pandas as pd
import json
import os

# First, let's ensure we have proper column names by reprocessing the CSV
with open('build_results.csv', 'r') as f:
    lines = f.readlines()

# Write back with header
with open('build_results_with_header.csv', 'w') as f:
    f.write('target,status\n')
    for line in lines:
        f.write(line)

# Load the CSV file
df = pd.read_csv('build_results_with_header.csv')

# Basic statistics
print("=== Basic Build Statistics ===")
print(f"Total number of targets: {len(df)}")
print(f"Success count: {df[df['status'] == 'SUCCESS'].shape[0]}")
print(f"Failure count: {df[df['status'] == 'FAILED'].shape[0]}")
print("\n=== First 10 targets ===")
print(df.head(10))

# List failed targets if any
if df[df['status'] == 'FAILED'].shape[0] > 0:
    print("\n=== Failed Targets ===")
    print(df[df['status'] == 'FAILED'])

# Analyse targets by module/directory
df['module'] = df['target'].apply(lambda x: x.split(':')[0].replace('//', ''))
module_stats = df.groupby(['module', 'status']).size().unstack(fill_value=0)
if 'FAILED' not in module_stats.columns:
    module_stats['FAILED'] = 0
module_stats['total'] = module_stats['SUCCESS'] + module_stats['FAILED']
module_stats['success_rate'] = module_stats['SUCCESS'] / module_stats['total'] * 100

print("\n=== Module Statistics ===")
print(module_stats.sort_values('total', ascending=False).head(20))

# Let's also calculate the modules with the most failures
if 'FAILED' in module_stats.columns and module_stats['FAILED'].sum() > 0:
    print("\n=== Modules With Most Failures ===")
    print(module_stats.sort_values('FAILED', ascending=False).head(10))

# Now let's examine files in the problematic modules to understand what needs to be fixed
print("\n=== Recommended Focus Areas ===")
# Look at the modules with highest failure counts
failed_modules = []
if 'FAILED' in module_stats.columns:
    failed_modules = module_stats[module_stats['FAILED'] > 0].sort_values('FAILED', ascending=False).head(5).index.get_level_values(0).tolist()

if failed_modules:
    print(f"Based on the build results, here are the top modules to focus on:")
    for i, module in enumerate(failed_modules, 1):
        failed_count = module_stats.loc[module, 'FAILED'] if 'FAILED' in module_stats.columns else 0
        print(f"{i}. {module} - {failed_count} failed targets")
else:
    print("All targets built successfully. No focus areas needed.")
