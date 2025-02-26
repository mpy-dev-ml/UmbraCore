#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

echo -e "${BLUE}UmbraCore BUILD File Analysis${NC}\n"

# Function to check if module name matches directory structure
check_module_name() {
    local build_file=$1
    local dir_name=$(dirname "$build_file")
    local base_dir=$(basename "$dir_name")
    local parent_dir=$(basename "$(dirname "$dir_name")")
    
    # Extract module_name from BUILD file
    local module_name=$(grep "module_name" "$build_file" | grep -o '"[^"]*"' | head -1 | tr -d '"')
    
    if [ -z "$module_name" ]; then
        echo -e "${RED}ERROR: No module_name found in $build_file${NC}"
        return 1
    fi
    
    # Check if module_name follows convention
    if [[ "$parent_dir" == "Sources" ]]; then
        if [[ "$module_name" != "$base_dir" ]]; then
            echo -e "${RED}ERROR: Module name '$module_name' doesn't match directory name '$base_dir'${NC}"
            return 1
        fi
    else
        local expected_name="${parent_dir}_${base_dir}"
        if [[ "$module_name" != "$expected_name" ]]; then
            echo -e "${RED}ERROR: Module name '$module_name' should be '$expected_name'${NC}"
            return 1
        fi
    fi
    return 0
}

# Function to check standard copts
check_copts() {
    local build_file=$1
    local required_copts=(
        '"-target"'
        '"arm64-apple-macos14.0"'
        '"-strict-concurrency=complete"'
        '"-warn-concurrency"'
        '"-enable-actor-data-race-checks"'
    )
    
    for copt in "${required_copts[@]}"; do
        if ! grep -q "copts.*$copt" "$build_file"; then
            echo -e "${RED}ERROR: Missing required copt: $copt${NC}"
            return 1
        fi
    done
    return 0
}

# Function to check glob usage
check_glob() {
    local build_file=$1
    if grep -q "glob(" "$build_file"; then
        if ! grep -q "allow_empty.*=.*True" "$build_file"; then
            echo -e "${YELLOW}WARNING: glob() used without allow_empty = True in $build_file${NC}"
            return 1
        fi
    fi
    return 0
}

# Function to check visibility
check_visibility() {
    local build_file=$1
    if ! grep -q 'visibility.*=.*\["//visibility:public"\]' "$build_file"; then
        echo -e "${YELLOW}WARNING: No public visibility specified in $build_file${NC}"
        return 1
    fi
    return 0
}

# Main analysis loop
find_cmd="find /Users/mpy/CascadeProjects/UmbraCore/Sources -name BUILD.bazel"
total_files=0
passing_files=0

while IFS= read -r build_file; do
    ((total_files++))
    echo -e "\n${BLUE}Analyzing: $build_file${NC}"
    
    issues=0
    
    # Perform checks
    check_module_name "$build_file" || ((issues++))
    check_copts "$build_file" || ((issues++))
    check_glob "$build_file" || ((issues++))
    check_visibility "$build_file" || ((issues++))
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✓ File passes all checks${NC}"
        ((passing_files++))
    fi
done < <(eval "$find_cmd")

# Print summary
echo -e "\n${BLUE}Analysis Summary:${NC}"
echo -e "Total BUILD files: $total_files"
echo -e "Passing all checks: $passing_files"
echo -e "Files needing updates: $((total_files - passing_files))"

if [ $((total_files - passing_files)) -gt 0 ]; then
    exit 1
fi
exit 0
