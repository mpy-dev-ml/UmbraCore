#!/bin/bash
# Repository Cleanup Script
# This script helps remove unnecessary files from the UmbraCore repository
# Author: UmbraCore Team
# Date: 2025-03-12

# Set default options
DRY_RUN=true
CLEAN_BUILD_ARTIFACTS=true
CLEAN_ANALYSIS_FILES=true
CLEAN_LOGS=true
CLEAN_TEMP_FILES=true
VERBOSE=false

# ANSI color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Print usage information
function print_usage {
    echo -e "${BLUE}UmbraCore Repository Cleanup Script${RESET}"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help               Display this help message"
    echo "  -e, --execute            Execute removal (default is dry-run mode)"
    echo "  --no-build-artifacts     Skip removal of build artifacts"
    echo "  --no-analysis-files      Skip removal of analysis files"
    echo "  --no-logs                Skip removal of log files"
    echo "  --no-temp-files          Skip removal of temporary files"
    echo "  -v, --verbose            Enable verbose output"
    echo
    echo "Examples:"
    echo "  $0                       Run in dry-run mode (no files will be removed)"
    echo "  $0 -e                    Execute removal of all file categories"
    echo "  $0 -e --no-logs          Execute removal of all files except logs"
    echo
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        -e|--execute)
            DRY_RUN=false
            ;;
        --no-build-artifacts)
            CLEAN_BUILD_ARTIFACTS=false
            ;;
        --no-analysis-files)
            CLEAN_ANALYSIS_FILES=false
            ;;
        --no-logs)
            CLEAN_LOGS=false
            ;;
        --no-temp-files)
            CLEAN_TEMP_FILES=false
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${RESET}"
            print_usage
            exit 1
            ;;
    esac
    shift
done

# Function to handle file removal
function remove_file {
    local file=$1
    local category=$2
    
    if [ -f "$file" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}Would remove${RESET} [$category]: $file"
        else
            if [ "$VERBOSE" = true ]; then
                echo -e "${RED}Removing${RESET} [$category]: $file"
            fi
            git rm -f "$file"
        fi
    elif [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}File not found${RESET}: $file"
    fi
}

# File patterns for each category
declare -a BUILD_ARTIFACTS=(
    "build_*.json"
    "build_*.txt"
    "build_*.csv"
    "build_output.*"
    "build_events_*.json"
    "*.cquery.txt"
    "aquery.txt"
    "build-settings.txt"
    "stderr_files.txt"
    "build_reports/*.json"
    "failed_targets.csv"
)

declare -a ANALYSIS_FILES=(
    "analysis/*.json"
    "analysis/*.txt"
    "*_analysis.csv"
    "*_analysis.json"
    "module_*.json"
    "module_*.txt"
    "warning_summary.txt"
    "*_warnings.json"
    "refactoring_plan/bazel_analysis/*.json"
    "refactoring_plan/swift_analysis/*.json"
    "swift_errors_*.csv"
    "swift_build_errors.csv"
    "complexity_analysis.csv"
    "code_size_analysis.csv"
    "repositories_deps.txt"
)

declare -a LOG_FILES=(
    "*_log.txt"
    "backup_cleanup_log.txt"
    "docs_archive_removal_log.txt"
    "script_consolidation_log.txt"
    "test_support_standardisation_log.txt"
    "security_protocols_test_output.txt"
)

declare -a TEMP_FILES=(
    "20250310_*.json"
    "grouped_build_messages.txt"
    "grouped_warnings.json"
    "xpc_migration_progress.json"
    "xpc_protocol_analysis.json"
)

# Display header info
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}DRY RUN MODE${RESET} - No files will be removed"
else
    echo -e "${RED}EXECUTE MODE${RESET} - Files will be permanently removed from the repository"
fi
echo

# Process file categories
echo -e "${BLUE}Scanning repository for unnecessary files...${RESET}"
echo

# Build artifacts
if [ "$CLEAN_BUILD_ARTIFACTS" = true ]; then
    echo -e "${YELLOW}Checking build artifacts:${RESET}"
    for pattern in "${BUILD_ARTIFACTS[@]}"; do
        # Use find to expand the patterns and process each file
        find . -name "$pattern" -type f -not -path "*/\.*" | while read -r file; do
            remove_file "$file" "build artifact"
        done
    done
    echo
fi

# Analysis files
if [ "$CLEAN_ANALYSIS_FILES" = true ]; then
    echo -e "${YELLOW}Checking analysis files:${RESET}"
    for pattern in "${ANALYSIS_FILES[@]}"; do
        find . -name "$pattern" -type f -not -path "*/\.*" | while read -r file; do
            remove_file "$file" "analysis file"
        done
    done
    echo
fi

# Log files
if [ "$CLEAN_LOGS" = true ]; then
    echo -e "${YELLOW}Checking log files:${RESET}"
    for pattern in "${LOG_FILES[@]}"; do
        find . -name "$pattern" -type f -not -path "*/\.*" | while read -r file; do
            remove_file "$file" "log file"
        done
    done
    echo
fi

# Temporary files
if [ "$CLEAN_TEMP_FILES" = true ]; then
    echo -e "${YELLOW}Checking temporary files:${RESET}"
    for pattern in "${TEMP_FILES[@]}"; do
        find . -name "$pattern" -type f -not -path "*/\.*" | while read -r file; do
            remove_file "$file" "temporary file"
        done
    done
    echo
fi

# Summary
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}Dry run complete.${RESET}"
    echo -e "To remove these files, run: $0 -e"
else
    echo -e "${GREEN}Creating commit for removed files...${RESET}"
    git commit -m "Clean up repository by removing unnecessary files"
    echo -e "${GREEN}File removal complete.${RESET}"
    echo -e "Run ${BLUE}git push${RESET} to upload these changes to the remote repository."
fi
