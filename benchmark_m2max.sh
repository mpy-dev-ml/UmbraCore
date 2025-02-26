#!/bin/bash
# Quick performance benchmark for M2 Max optimizations
# Compares build times with and without optimization

set -e

OUTPUT_DIR="analysis/benchmarks"
mkdir -p "${OUTPUT_DIR}"
timestamp=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="${OUTPUT_DIR}/benchmark_results_${timestamp}.txt"

# Default to a smaller target for quicker benchmarking
TARGET=${1:-"//Sources/UmbraLogging"}
echo "Running benchmark with target: ${TARGET}"
echo "Results will be saved to: ${RESULTS_FILE}"

# Create backup of current user.bazelrc
if [ -f user.bazelrc ]; then
  cp user.bazelrc user.bazelrc.benchmark_backup
fi

echo "=== M2 Max Bazel Performance Benchmark ===" | tee "${RESULTS_FILE}"
echo "Target: ${TARGET}" | tee -a "${RESULTS_FILE}"
echo "System: MacBook Pro M2 Max (96GB RAM)" | tee -a "${RESULTS_FILE}"
echo "Date: $(date)" | tee -a "${RESULTS_FILE}"
echo "" | tee -a "${RESULTS_FILE}"

# Function to measure build time
run_build() {
  config_name=$1
  config_file=$2
  
  echo "Testing ${config_name} configuration..." | tee -a "${RESULTS_FILE}"
  
  # Apply the configuration
  cp "${config_file}" user.bazelrc
  
  # Clear caches for fair comparison
  echo "  Cleaning Bazel cache..."
  bazel clean --expunge >/dev/null 2>&1
  
  # Run the build with timing
  echo "  Building ${TARGET}..."
  build_time=$( { time -p bazel build "${TARGET}" >/dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}' )
  
  echo "  Build time: ${build_time} seconds" | tee -a "${RESULTS_FILE}"
  
  # Run a second build to measure cache impact
  echo "  Building again (cached)..."
  cached_time=$( { time -p bazel build "${TARGET}" >/dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}' )
  
  echo "  Cached build time: ${cached_time} seconds" | tee -a "${RESULTS_FILE}"
  
  echo "" | tee -a "${RESULTS_FILE}"
  
  # Return the times
  echo "${build_time},${cached_time}"
}

# Create basic configuration
cat > "${OUTPUT_DIR}/basic.bazelrc" << EOF
# Basic configuration with minimal settings
build --disk_cache=~/.cache/bazel
build --jobs=4
EOF

# Prepare the configurations to test
cp user.bazelrc.m2max "${OUTPUT_DIR}/optimized.bazelrc"

# Run the benchmarks
echo "Running benchmarks..."
BASIC_TIMES=$(run_build "Basic" "${OUTPUT_DIR}/basic.bazelrc")
OPTIMIZED_TIMES=$(run_build "M2 Max Optimized" "${OUTPUT_DIR}/optimized.bazelrc")

# Parse results
BASIC_BUILD_TIME=$(echo "${BASIC_TIMES}" | cut -d',' -f1)
BASIC_CACHED_TIME=$(echo "${BASIC_TIMES}" | cut -d',' -f2)

OPTIMIZED_BUILD_TIME=$(echo "${OPTIMIZED_TIMES}" | cut -d',' -f1)
OPTIMIZED_CACHED_TIME=$(echo "${OPTIMIZED_TIMES}" | cut -d',' -f2)

# Calculate improvements (using printf for math to avoid bc dependency)
BUILD_IMPROVEMENT=$(printf "%.2f" $(echo "(${BASIC_BUILD_TIME} - ${OPTIMIZED_BUILD_TIME}) / ${BASIC_BUILD_TIME} * 100" | bc -l))
CACHED_IMPROVEMENT=$(printf "%.2f" $(echo "(${BASIC_CACHED_TIME} - ${OPTIMIZED_CACHED_TIME}) / ${BASIC_CACHED_TIME} * 100" | bc -l))

# Summarize results
echo "=== BENCHMARK SUMMARY ===" | tee -a "${RESULTS_FILE}"
echo "" | tee -a "${RESULTS_FILE}"
echo "Clean Build Times:" | tee -a "${RESULTS_FILE}"
echo "  Basic config:     ${BASIC_BUILD_TIME} seconds" | tee -a "${RESULTS_FILE}"
echo "  M2 Max optimized: ${OPTIMIZED_BUILD_TIME} seconds" | tee -a "${RESULTS_FILE}"
echo "  Improvement:      ${BUILD_IMPROVEMENT}%" | tee -a "${RESULTS_FILE}"
echo "" | tee -a "${RESULTS_FILE}"
echo "Cached Build Times:" | tee -a "${RESULTS_FILE}"
echo "  Basic config:     ${BASIC_CACHED_TIME} seconds" | tee -a "${RESULTS_FILE}"
echo "  M2 Max optimized: ${OPTIMIZED_CACHED_TIME} seconds" | tee -a "${RESULTS_FILE}"
echo "  Improvement:      ${CACHED_IMPROVEMENT}%" | tee -a "${RESULTS_FILE}"
echo "" | tee -a "${RESULTS_FILE}"

# Restore original user.bazelrc
if [ -f user.bazelrc.benchmark_backup ]; then
  cp user.bazelrc.benchmark_backup user.bazelrc
  rm user.bazelrc.benchmark_backup
fi

echo "Benchmark complete! Results saved to ${RESULTS_FILE}"
