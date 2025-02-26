#!/bin/bash

set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
OUTPUT_DIR="bazel-analysis"
FORMAT="text"
QUERY_TYPE="all"
TARGET="//..."

print_help() {
    echo "Bazel Analysis Tool"
    echo
    echo "Usage: $0 [options] [target]"
    echo
    echo "Options:"
    echo "  -h, --help                Show this help message"
    echo "  -o, --output-dir DIR      Output directory (default: bazel-analysis)"
    echo "  -f, --format FORMAT       Output format: text, json, graph (default: text)"
    echo "  -t, --type TYPE          Query type: all, deps, actions, config (default: all)"
    echo
    echo "Examples:"
    echo "  $0 //Sources/UmbraCore/..."
    echo "  $0 -f json //Sources/UmbraCryptoService/..."
    echo "  $0 -t deps //..."
}

run_query() {
    local target=$1
    echo -e "${BLUE}Running dependency query for $target${NC}"
    
    # Basic deps query
    echo -e "${GREEN}Direct dependencies:${NC}"
    bazel query "deps($target, 1)" --output label 2>/dev/null | tee "$OUTPUT_DIR/direct_deps.txt"
    
    # Find all source files
    echo -e "\n${GREEN}Source files:${NC}"
    bazel query "kind(source file, deps($target))" --output label 2>/dev/null | tee "$OUTPUT_DIR/source_files.txt"
    
    # Generate dependency graph
    if [ "$FORMAT" = "graph" ]; then
        echo -e "\n${GREEN}Generating dependency graph...${NC}"
        bazel query "deps($target)" --output graph 2>/dev/null > "$OUTPUT_DIR/deps.dot"
        dot -Tsvg "$OUTPUT_DIR/deps.dot" -o "$OUTPUT_DIR/deps.svg"
    fi
}

run_aquery() {
    local target=$1
    echo -e "${BLUE}Running action query for $target${NC}"
    
    # Basic action query
    echo -e "${GREEN}Build actions:${NC}"
    bazel aquery "$target" --output=text 2>/dev/null | tee "$OUTPUT_DIR/actions.txt"
    
    if [ "$FORMAT" = "json" ]; then
        bazel aquery "$target" --output=jsonproto 2>/dev/null > "$OUTPUT_DIR/actions.json"
    fi
}

run_cquery() {
    local target=$1
    echo -e "${BLUE}Running configuration query for $target${NC}"
    
    # Configuration information
    echo -e "${GREEN}Target configurations:${NC}"
    bazel cquery "$target" --output=changes 2>/dev/null | tee "$OUTPUT_DIR/config.txt"
    
    if [ "$FORMAT" = "json" ]; then
        bazel cquery "$target" --output=jsonproto 2>/dev/null > "$OUTPUT_DIR/config.json"
    fi
}

analyze_swift_targets() {
    local target=$1
    echo -e "${BLUE}Analyzing Swift targets${NC}"
    
    # Find all Swift targets
    echo -e "${GREEN}Swift libraries:${NC}"
    bazel query "kind(swift_library, $target)" --output label 2>/dev/null | tee "$OUTPUT_DIR/swift_libs.txt"
    
    # Find test targets
    echo -e "\n${GREEN}Swift tests:${NC}"
    bazel query "kind(swift_test, $target)" --output label 2>/dev/null | tee "$OUTPUT_DIR/swift_tests.txt"
}

generate_report() {
    echo -e "${BLUE}Generating HTML report${NC}"
    
    cat << EOF > "$OUTPUT_DIR/report.html"
<!DOCTYPE html>
<html>
<head>
    <title>UmbraCore Bazel Analysis Report</title>
    <style>
        body { font-family: -apple-system, sans-serif; margin: 2em; }
        pre { background: #f5f5f5; padding: 1em; border-radius: 4px; }
        .section { margin-bottom: 2em; }
    </style>
</head>
<body>
    <h1>UmbraCore Bazel Analysis Report</h1>
    <div class="section">
        <h2>Direct Dependencies</h2>
        <pre>$(cat "$OUTPUT_DIR/direct_deps.txt")</pre>
    </div>
    <div class="section">
        <h2>Source Files</h2>
        <pre>$(cat "$OUTPUT_DIR/source_files.txt")</pre>
    </div>
    <div class="section">
        <h2>Build Actions</h2>
        <pre>$(cat "$OUTPUT_DIR/actions.txt")</pre>
    </div>
    <div class="section">
        <h2>Configuration</h2>
        <pre>$(cat "$OUTPUT_DIR/config.txt")</pre>
    </div>
    <div class="section">
        <h2>Swift Libraries</h2>
        <pre>$(cat "$OUTPUT_DIR/swift_libs.txt")</pre>
    </div>
    <div class="section">
        <h2>Swift Tests</h2>
        <pre>$(cat "$OUTPUT_DIR/swift_tests.txt")</pre>
    </div>
</body>
</html>
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -t|--type)
            QUERY_TYPE="$2"
            shift 2
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run appropriate queries based on type
case $QUERY_TYPE in
    "deps")
        run_query "$TARGET"
        ;;
    "actions")
        run_aquery "$TARGET"
        ;;
    "config")
        run_cquery "$TARGET"
        ;;
    "all")
        run_query "$TARGET"
        run_aquery "$TARGET"
        run_cquery "$TARGET"
        analyze_swift_targets "$TARGET"
        generate_report
        ;;
esac

echo -e "${GREEN}Analysis complete! Results are in $OUTPUT_DIR${NC}"
