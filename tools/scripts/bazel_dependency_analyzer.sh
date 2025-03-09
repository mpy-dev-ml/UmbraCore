#!/bin/bash
# bazel_dependency_analyzer.sh
# A script to analyze Swift module dependencies using Bazel query tools
# This helps ensure that refactoring doesn't break the build structure

set -e

# Configuration
OUTPUT_DIR="refactoring_plan/bazel_analysis"
TARGETS_FILE="$OUTPUT_DIR/targets.txt"
MODULE_DEPS_DIR="$OUTPUT_DIR/module_deps"
MODULE_RDEPS_DIR="$OUTPUT_DIR/module_rdeps"
BUILD_ACTIONS_DIR="$OUTPUT_DIR/build_actions"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$MODULE_DEPS_DIR"
mkdir -p "$MODULE_RDEPS_DIR"
mkdir -p "$BUILD_ACTIONS_DIR"

# Step 1: Find all Swift targets in the codebase
echo "Finding all Swift targets..."
bazel query 'kind("swift_library", //...)' > "$TARGETS_FILE"
echo "Found $(wc -l < "$TARGETS_FILE") Swift targets"

# Step 2: For each target, analyze its dependencies
echo "Analyzing dependencies for each target..."
while read -r target; do
    target_name=$(basename "$target" | sed 's/://g')
    echo "Processing $target_name"
    
    # Forward dependencies
    echo "  Finding dependencies..."
    bazel query "deps($target)" --output=label > "$MODULE_DEPS_DIR/${target_name}_deps.txt"
    
    # Reverse dependencies
    echo "  Finding reverse dependencies..."
    bazel query "rdeps(//..., $target)" --output=label > "$MODULE_RDEPS_DIR/${target_name}_rdeps.txt"
    
    # Direct dependencies only
    echo "  Finding direct dependencies..."
    bazel query "deps($target, 1)" --output=label > "$MODULE_DEPS_DIR/${target_name}_direct_deps.txt"
    
    # Build actions
    echo "  Analyzing build actions..."
    bazel aquery "mnemonic('SwiftCompile', inputs('$target/...'))" --output=text > "$BUILD_ACTIONS_DIR/${target_name}_actions.txt"
done < "$TARGETS_FILE"

# Step 3: Generate a dependency graph visualization
echo "Generating dependency graph..."
bazel query "deps(//Sources/CoreTypes:CoreTypes)" --output graph > "$OUTPUT_DIR/CoreTypes_graph.dot"
echo "You can convert the generated DOT file to an image using: dot -Tpng $OUTPUT_DIR/CoreTypes_graph.dot -o CoreTypes_graph.png"

# Step 4: Check for circular dependencies
echo "Checking for circular dependencies..."
circular_deps=$(bazel query 'allpaths(//Sources/CoreTypes:CoreTypes, //Sources/CoreTypes:CoreTypes)')
if [ -n "$circular_deps" ]; then
    echo "Warning: Circular dependencies detected!" > "$OUTPUT_DIR/circular_deps.txt"
    echo "$circular_deps" >> "$OUTPUT_DIR/circular_deps.txt"
    echo "Circular dependencies found. See $OUTPUT_DIR/circular_deps.txt for details."
else
    echo "No circular dependencies found."
fi

# Step 5: Generate a summary report
echo "Generating summary report..."
{
    echo "# Bazel Dependency Analysis Report"
    echo "Generated: $(date)"
    echo
    echo "## Summary"
    echo "- Total Swift targets: $(wc -l < "$TARGETS_FILE")"
    
    echo
    echo "## Top 10 Most Depended Upon Modules"
    # Count the number of reverse dependencies for each module
    most_depended=$(for f in "$MODULE_RDEPS_DIR"/*_rdeps.txt; do
        module=$(basename "$f" | sed 's/_rdeps.txt//')
        count=$(wc -l < "$f")
        echo "$count $module"
    done | sort -nr | head -10)
    echo "$most_depended" | while read -r line; do
        count=$(echo "$line" | cut -d' ' -f1)
        module=$(echo "$line" | cut -d' ' -f2)
        echo "- $module: $count dependent modules"
    done
    
    echo
    echo "## Modules with Most Dependencies"
    # Count the number of dependencies for each module
    most_deps=$(for f in "$MODULE_DEPS_DIR"/*_deps.txt; do
        module=$(basename "$f" | sed 's/_deps.txt//')
        count=$(wc -l < "$f")
        echo "$count $module"
    done | sort -nr | head -10)
    echo "$most_deps" | while read -r line; do
        count=$(echo "$line" | cut -d' ' -f1)
        module=$(echo "$line" | cut -d' ' -f2)
        echo "- $module: $count dependencies"
    done
    
    echo
    echo "## Focus on CoreTypes Module"
    echo "- Direct dependencies: $(wc -l < "$MODULE_DEPS_DIR/CoreTypes_direct_deps.txt") modules"
    echo "- Total dependencies: $(wc -l < "$MODULE_DEPS_DIR/CoreTypes_deps.txt") modules"
    echo "- Depended upon by: $(wc -l < "$MODULE_RDEPS_DIR/CoreTypes_rdeps.txt") modules"
    
} > "$OUTPUT_DIR/dependency_summary.md"

echo "Dependency analysis complete. Results in $OUTPUT_DIR/"
echo "Key files:"
echo "- Summary report: $OUTPUT_DIR/dependency_summary.md"
echo "- Dependency graph: $OUTPUT_DIR/CoreTypes_graph.dot"
echo "- Individual module dependencies in $MODULE_DEPS_DIR/ and $MODULE_RDEPS_DIR/"
