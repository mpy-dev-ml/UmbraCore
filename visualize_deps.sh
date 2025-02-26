#!/bin/bash
# Dependency visualization script
# Generates dependency graphs using Bazel query

set -e

# Default target is all Sources
TARGET=${1:-"//Sources/..."}
OUTPUT_DIR="analysis"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

echo "Generating dependency graph for ${TARGET}..."
bazel query "deps(${TARGET})" --output graph > "${OUTPUT_DIR}/target_deps.dot"
echo "Generated ${OUTPUT_DIR}/target_deps.dot"

# Generate project-wide dependencies
echo "Generating project-wide dependencies..."
bazel query "deps(//Sources/...)" --output graph > "${OUTPUT_DIR}/project_deps.dot"
echo "Generated ${OUTPUT_DIR}/project_deps.dot"

# Generate module dependencies (what depends on what)
echo "Generating reverse dependencies..."
bazel query "rdeps(//..., ${TARGET})" --output graph > "${OUTPUT_DIR}/reverse_deps.dot"
echo "Generated ${OUTPUT_DIR}/reverse_deps.dot"

# Convert to PNG if graphviz is installed
if command -v dot &> /dev/null; then
  echo "Converting graphs to PNG using Graphviz..."
  dot -Tpng "${OUTPUT_DIR}/target_deps.dot" -o "${OUTPUT_DIR}/target_deps.png"
  dot -Tpng "${OUTPUT_DIR}/project_deps.dot" -o "${OUTPUT_DIR}/project_deps.png"
  dot -Tpng "${OUTPUT_DIR}/reverse_deps.dot" -o "${OUTPUT_DIR}/reverse_deps.png"
  echo "Generated PNG visualizations in ${OUTPUT_DIR}/ directory"
else
  echo "Graphviz not found. Install it to generate PNG visualizations:"
  echo "  brew install graphviz"
  echo "Then run: dot -Tpng ${OUTPUT_DIR}/target_deps.dot -o ${OUTPUT_DIR}/target_deps.png"
fi

echo ""
echo "To view a specific module's dependencies, run:"
echo "  ./visualize_deps.sh //Sources/ModuleName"
