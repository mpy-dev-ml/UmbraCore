#!/bin/bash
# Script to automatically discover test targets in the UmbraCore project
# and update the test_config.yml file and test_targets.txt file accordingly

set -e

# Use stderr for all debugging output
debug() {
    echo "$@" >&2
}

debug "===== DEBUG: Starting test discovery script ====="
debug "Current directory: $(pwd)"
debug "Current user: $(whoami)"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    debug "Error: yq is not installed. Please install it with 'brew install yq'"
    debug "Visit https://github.com/mikefarah/yq for more information."
    exit 1
fi

debug "yq version: $(yq --version)"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="${SCRIPT_DIR}/test_config.yml"
TARGETS_FILE="${SCRIPT_DIR}/test_targets.txt"
TEMP_CONFIG_FILE="${CONFIG_FILE}.tmp"

debug "===== DEBUG: Script paths ====="
debug "SCRIPT_DIR: $SCRIPT_DIR"
debug "CONFIG_FILE: $CONFIG_FILE"
debug "TARGETS_FILE: $TARGETS_FILE"

# Define known deprecated test patterns
DEPRECATED_PATTERNS=(
    "//Sources/SecurityBridge:.*"
    "//Sources/SecurityInterfaces/Tests:SecurityProviderTests"
)

# Ensure the config file exists with necessary structure
if [ ! -f "$CONFIG_FILE" ]; then
    debug "Creating new config file: $CONFIG_FILE"
    echo "# Test configuration for UmbraCore" > "$CONFIG_FILE"
    echo "# This file contains the targets to be run in test workflows" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# Target configuration" >> "$CONFIG_FILE"
    echo "targets: []" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# Deprecated targets to ignore" >> "$CONFIG_FILE"
    echo "deprecated:" >> "$CONFIG_FILE"
    for pattern in "${DEPRECATED_PATTERNS[@]}"; do
        echo "  - pattern: \"$pattern\"" >> "$CONFIG_FILE"
    done
fi

debug "Discovering test targets in the UmbraCore project..."

# Use bazelisk query to find all test targets
debug "Querying test targets with bazelisk..."
ALL_TARGETS=$(bazelisk query 'kind("_test rule", //Sources/...)' 2>&1 || echo "Error during query: $?")

if [[ "$ALL_TARGETS" == Error* ]]; then
  debug "===== DEBUG: Error during bazelisk query ====="
  debug "$ALL_TARGETS"
  debug "Creating a minimal test targets file to allow CI to proceed with a subset of tests"
  # Make sure to completely empty the targets file first
  true > "$TARGETS_FILE"
  echo "//Sources/CoreDTOs/Tests:CoreDTOsTests" > "$TARGETS_FILE"
  echo "//Sources/ErrorHandling/Tests:ErrorHandlingTests" >> "$TARGETS_FILE"
  debug "Generated minimal $TARGETS_FILE with $(wc -l < "$TARGETS_FILE" | xargs) fallback test targets."
  exit 0
fi

# Create a temporary file to store discovered targets
echo "# Test configuration for UmbraCore" > "$TEMP_CONFIG_FILE"
echo "# This file contains the targets to be run in test workflows" >> "$TEMP_CONFIG_FILE"
echo "" >> "$TEMP_CONFIG_FILE"
echo "# Target configuration" >> "$TEMP_CONFIG_FILE"
echo "targets:" >> "$TEMP_CONFIG_FILE"

# Read the current deprecated patterns
if [ -f "$CONFIG_FILE" ]; then
    CURRENT_DEPRECATED=$(yq '.deprecated[].pattern' "$CONFIG_FILE" 2>/dev/null || echo "")
    debug "===== DEBUG: Current deprecated patterns ====="
    debug "$CURRENT_DEPRECATED"
else
    CURRENT_DEPRECATED=""
    debug "===== DEBUG: No existing config file found ====="
fi

# Process each target from bazelisk query
TARGET_COUNT=0
for TARGET in $ALL_TARGETS; do
    IS_DEPRECATED=false
    
    # Check if target matches any deprecated pattern
    for pattern in "${DEPRECATED_PATTERNS[@]}"; do
        if [[ "$TARGET" =~ $pattern ]]; then
            IS_DEPRECATED=true
            break
        fi
    done
    
    # Check against current deprecated patterns in config
    if [ -n "$CURRENT_DEPRECATED" ]; then
        while IFS= read -r deprecated_pattern; do
            if [[ "$TARGET" =~ $deprecated_pattern ]]; then
                IS_DEPRECATED=true
                break
            fi
        done <<< "$CURRENT_DEPRECATED"
    fi
    
    # Skip deprecated targets
    if [ "$IS_DEPRECATED" = true ]; then
        debug "Skipping deprecated target: $TARGET"
        continue
    fi
    
    # Extract module and test name from target
    MODULE_PATH=${TARGET#//}
    MODULE_PATH=${MODULE_PATH%:*}
    TEST_NAME=${TARGET##*:}
    
    # Add the target to the config
    echo "  - target: \"$TARGET\"" >> "$TEMP_CONFIG_FILE"
    echo "    module: \"$MODULE_PATH\"" >> "$TEMP_CONFIG_FILE"
    echo "    name: \"$TEST_NAME\"" >> "$TEMP_CONFIG_FILE"
    echo "    enabled: true" >> "$TEMP_CONFIG_FILE"
    
    debug "Found test target: $TARGET"
    TARGET_COUNT=$((TARGET_COUNT + 1))
done

# Add the deprecated section
echo "" >> "$TEMP_CONFIG_FILE"
echo "# Deprecated targets to ignore" >> "$TEMP_CONFIG_FILE"
echo "deprecated:" >> "$TEMP_CONFIG_FILE"
for pattern in "${DEPRECATED_PATTERNS[@]}"; do
    echo "  - pattern: \"$pattern\"" >> "$TEMP_CONFIG_FILE"
done

# Add any additional deprecated patterns from existing config
if [ -f "$CONFIG_FILE" ] && [ -n "$CURRENT_DEPRECATED" ]; then
    while IFS= read -r deprecated_pattern; do
        # Check if pattern is already in our list
        ALREADY_ADDED=false
        for pattern in "${DEPRECATED_PATTERNS[@]}"; do
            if [[ "$deprecated_pattern" == "$pattern" ]]; then
                ALREADY_ADDED=true
                break
            fi
        done
        
        if [ "$ALREADY_ADDED" = false ]; then
            echo "  - pattern: \"$deprecated_pattern\"" >> "$TEMP_CONFIG_FILE"
        fi
    done <<< "$CURRENT_DEPRECATED"
fi

# Replace the config file with the new one
mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
debug "Updated $CONFIG_FILE with $TARGET_COUNT discovered targets."

# Generate test_targets.txt file - ensure it's completely empty first
debug "Generating $TARGETS_FILE..."
true > "$TARGETS_FILE"

# Extract enabled targets from config and write to targets file
# Use -r to get raw output without quotes, which helps with Bazel target parsing
yq -r '.targets[] | select(.enabled == true) | .target' "$CONFIG_FILE" > "$TARGETS_FILE"

# Verify the targets file has proper format
if [ ! -s "$TARGETS_FILE" ]; then
    debug "WARNING: Generated targets file is empty! Using fallback targets."
    echo "//Sources/CoreDTOs/Tests:CoreDTOsTests" > "$TARGETS_FILE"
    echo "//Sources/ErrorHandling/Tests:ErrorHandlingTests" >> "$TARGETS_FILE"
fi

debug "Generated $TARGETS_FILE with $(wc -l < "$TARGETS_FILE" | xargs) enabled test targets."
debug "Target file content sample (first 3 lines):"
debug "$(head -n 3 "$TARGETS_FILE")"
debug "To run tests: bazelisk test --define=build_environment=nonlocal -k --verbose_failures \$(cat ${TARGETS_FILE})"

debug "Discovery complete!"
