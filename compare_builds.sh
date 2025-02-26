#!/bin/bash
# Compares build performance between different Bazel configurations
# Useful for benchmarking optimization impacts

set -e

OUTPUT_DIR="analysis/comparisons"
mkdir -p "$OUTPUT_DIR"

TARGET=${1:-"//..."}
ITERATIONS=${2:-3}
TIME_CMD="/usr/bin/time -l"

echo "Comparing build performance for $TARGET (${ITERATIONS} iterations each)"
echo "Results will be saved to $OUTPUT_DIR"

# Function to run a build with specific config and calculate average time
run_benchmark() {
  local config=$1
  local output_file="$OUTPUT_DIR/$config.txt"
  
  echo "" > "$output_file"
  echo "Running benchmark with config: $config"
  
  TOTAL_TIME=0
  TOTAL_MEM=0
  
  for i in $(seq 1 $ITERATIONS); do
    echo "  Iteration $i/$ITERATIONS..."
    # Clean first to ensure fair comparison
    bazel clean
    
    # Run the build with timing
    OUTPUT=$($TIME_CMD bazel build $TARGET --config=$config 2>&1)
    
    # Extract time and memory usage
    TIME=$(echo "$OUTPUT" | grep "real" | awk '{print $2}')
    MEM=$(echo "$OUTPUT" | grep "maximum resident set size" | awk '{print $1}')
    
    echo "  - Time: $TIME seconds"
    echo "  - Memory: $MEM KB"
    
    # Log to output file
    echo "Iteration $i: Time=$TIME seconds, Memory=$MEM KB" >> "$output_file"
    
    # Add to totals (strip decimal point for addition)
    TIME_INT=$(echo "$TIME" | sed 's/\..*//')
    TOTAL_TIME=$((TOTAL_TIME + TIME_INT))
    TOTAL_MEM=$((TOTAL_MEM + MEM))
  done
  
  # Calculate averages
  AVG_TIME=$((TOTAL_TIME / ITERATIONS))
  AVG_MEM=$((TOTAL_MEM / ITERATIONS))
  
  echo "Average time: $AVG_TIME seconds" >> "$output_file"
  echo "Average memory: $AVG_MEM KB" >> "$output_file"
  
  echo "Benchmark complete for $config"
  echo "  Average time: $AVG_TIME seconds"
  echo "  Average memory: $AVG_MEM KB"
  echo ""
}

# Create custom configs for comparison
cat > "$OUTPUT_DIR/legacy.bazelrc" <<EOF
# Legacy settings (no optimizations)
build:legacy --disk_cache=~/.cache/bazel
build:legacy --nobuild --compile_one_dependency
EOF

cat > "$OUTPUT_DIR/optimized.bazelrc" <<EOF
# Optimized settings
build:optimized --disk_cache=~/.cache/bazel-disk
build:optimized --repository_cache=~/.cache/bazel-repo
build:optimized --experimental_repository_cache_hardlinks
build:optimized --strategy=SwiftCompile=worker
build:optimized --worker_max_instances=4
build:optimized --worker_sandboxing
build:optimized --experimental_reuse_sandbox_directories
build:optimized --nobuild --compile_one_dependency
EOF

# Run benchmarks
echo "Starting benchmarks..."
run_benchmark "legacy"
run_benchmark "optimized"

# Compare results
LEGACY_TIME=$(grep "Average time:" "$OUTPUT_DIR/legacy.txt" | awk '{print $3}')
OPTIMIZED_TIME=$(grep "Average time:" "$OUTPUT_DIR/optimized.txt" | awk '{print $3}')

LEGACY_MEM=$(grep "Average memory:" "$OUTPUT_DIR/legacy.txt" | awk '{print $3}')
OPTIMIZED_MEM=$(grep "Average memory:" "$OUTPUT_DIR/optimized.txt" | awk '{print $3}')

TIME_DIFF=$((LEGACY_TIME - OPTIMIZED_TIME))
TIME_PERCENT=$(echo "scale=2; ($TIME_DIFF * 100) / $LEGACY_TIME" | bc)

MEM_DIFF=$((LEGACY_MEM - OPTIMIZED_MEM))
MEM_PERCENT=$(echo "scale=2; ($MEM_DIFF * 100) / $LEGACY_MEM" | bc)

echo "======================================="
echo "BENCHMARK RESULTS"
echo "======================================="
echo "Target: $TARGET"
echo "Iterations: $ITERATIONS"
echo ""
echo "Legacy Configuration:"
echo "  Average time: $LEGACY_TIME seconds"
echo "  Average memory: $LEGACY_MEM KB"
echo ""
echo "Optimized Configuration:"
echo "  Average time: $OPTIMIZED_TIME seconds"
echo "  Average memory: $OPTIMIZED_MEM KB"
echo ""
echo "Improvements:"
echo "  Time: $TIME_DIFF seconds (${TIME_PERCENT}%)"
echo "  Memory: $MEM_DIFF KB (${MEM_PERCENT}%)"
echo "======================================="

# Save summary
cat > "$OUTPUT_DIR/summary.txt" <<EOF
BENCHMARK RESULTS
=======================================
Target: $TARGET
Iterations: $ITERATIONS

Legacy Configuration:
  Average time: $LEGACY_TIME seconds
  Average memory: $LEGACY_MEM KB

Optimized Configuration:
  Average time: $OPTIMIZED_TIME seconds
  Average memory: $OPTIMIZED_MEM KB

Improvements:
  Time: $TIME_DIFF seconds (${TIME_PERCENT}%)
  Memory: $MEM_DIFF KB (${MEM_PERCENT}%)
EOF

echo "Complete benchmark results saved to $OUTPUT_DIR/summary.txt"
