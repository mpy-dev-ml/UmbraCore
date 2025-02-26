#!/bin/bash
# Bazel build analysis script
# Generates build profile and analyzes it

set -e

# Default target is all
TARGET=${1:-"//..."}
OUTPUT_DIR="analysis"
PROFILE_NAME="build.profile"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

echo "Building ${TARGET} with profiling..."
bazel build ${TARGET} --profile="${OUTPUT_DIR}/${PROFILE_NAME}"

echo "Analyzing build profile..."
bazel analyze-profile "${OUTPUT_DIR}/${PROFILE_NAME}"

# Optional: Generate JSON output for further processing
bazel analyze-profile --dump=raw "${OUTPUT_DIR}/${PROFILE_NAME}" > "${OUTPUT_DIR}/profile_raw.json"

echo ""
echo "Profile data saved to ${OUTPUT_DIR}/${PROFILE_NAME}"
echo "For custom queries, run: bazel analyze-profile ${OUTPUT_DIR}/${PROFILE_NAME} --xxx"
echo "Raw data available at: ${OUTPUT_DIR}/profile_raw.json"
