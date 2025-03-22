#!/bin/bash
# Script to automatically discover production targets in the UmbraCore project
# and update the production_config.yml file and production_targets.txt file accordingly

set -e

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Please install it with 'brew install yq'"
    echo "Visit https://github.com/mikefarah/yq for more information."
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="${SCRIPT_DIR}/production_config.yml"
TARGETS_FILE="${SCRIPT_DIR}/production_targets.txt"
TEMP_CONFIG_FILE="${CONFIG_FILE}.tmp"

# Define patterns to exclude (test targets, etc.)
EXCLUDE_PATTERNS=(
    ".*Tests"
    ".*TestHelpers"
    ".*ForTesting"
    ".*_runner"
)

# Ensure the config file exists with necessary structure
if [ ! -f "$CONFIG_FILE" ]; then
    echo "# Production target configuration for UmbraCore" > "$CONFIG_FILE"
    echo "# This file contains the targets to be included in production builds" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# Target configuration" >> "$CONFIG_FILE"
    echo "targets: []" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# Excluded target patterns" >> "$CONFIG_FILE"
    echo "excluded:" >> "$CONFIG_FILE"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        echo "  - pattern: \"$pattern\"" >> "$CONFIG_FILE"
    done
fi

echo "Discovering production targets in the UmbraCore project..."

# Use bazelisk query to find all library and binary targets
echo "Querying production targets with bazelisk..."
ALL_TARGETS=$(bazelisk query 'kind("(swift|objc|cc)_(library|binary) rule", //Sources/...)' 2>/dev/null || echo "Error during query")

if [[ "$ALL_TARGETS" == "Error during query" ]]; then
  echo "Error: Failed to query production targets."
  exit 1
fi

# Create a temporary file to store discovered targets
echo "# Production target configuration for UmbraCore" > "$TEMP_CONFIG_FILE"
echo "# This file contains the targets to be included in production builds" >> "$TEMP_CONFIG_FILE"
echo "" >> "$TEMP_CONFIG_FILE"
echo "# Target configuration" >> "$TEMP_CONFIG_FILE"
echo "targets:" >> "$TEMP_CONFIG_FILE"

# Read the current excluded patterns
if [ -f "$CONFIG_FILE" ]; then
    CURRENT_EXCLUDED=$(yq '.excluded[].pattern' "$CONFIG_FILE" 2>/dev/null || echo "")
else
    CURRENT_EXCLUDED=""
fi

# Process each target from bazelisk query
TARGET_COUNT=0
for TARGET in $ALL_TARGETS; do
    SHOULD_EXCLUDE=false
    
    # Check if target matches any excluded pattern
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$TARGET" =~ $pattern ]]; then
            SHOULD_EXCLUDE=true
            break
        fi
    done
    
    # Check against current excluded patterns in config
    if [ -n "$CURRENT_EXCLUDED" ]; then
        while IFS= read -r excluded_pattern; do
            if [[ "$TARGET" =~ $excluded_pattern ]]; then
                SHOULD_EXCLUDE=true
                break
            fi
        done <<< "$CURRENT_EXCLUDED"
    fi
    
    # Skip excluded targets
    if [ "$SHOULD_EXCLUDE" = true ]; then
        echo "Skipping excluded target: $TARGET"
        continue
    fi
    
    # Extract module and target name
    MODULE_PATH=${TARGET#//}
    MODULE_PATH=${MODULE_PATH%:*}
    TARGET_NAME=${TARGET##*:}
    
    # Add the target to the config
    echo "  - target: \"$TARGET\"" >> "$TEMP_CONFIG_FILE"
    echo "    module: \"$MODULE_PATH\"" >> "$TEMP_CONFIG_FILE"
    echo "    name: \"$TARGET_NAME\"" >> "$TEMP_CONFIG_FILE"
    echo "    enabled: true" >> "$TEMP_CONFIG_FILE"
    
    echo "Found production target: $TARGET"
    TARGET_COUNT=$((TARGET_COUNT + 1))
done

# Add the excluded section
echo "" >> "$TEMP_CONFIG_FILE"
echo "# Excluded target patterns" >> "$TEMP_CONFIG_FILE"
echo "excluded:" >> "$TEMP_CONFIG_FILE"
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    echo "  - pattern: \"$pattern\"" >> "$TEMP_CONFIG_FILE"
done

# Add any additional excluded patterns from existing config
if [ -f "$CONFIG_FILE" ] && [ -n "$CURRENT_EXCLUDED" ]; then
    while IFS= read -r excluded_pattern; do
        # Check if pattern is already in our list
        ALREADY_ADDED=false
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$excluded_pattern" == "$pattern" ]]; then
                ALREADY_ADDED=true
                break
            fi
        done
        
        if [ "$ALREADY_ADDED" = false ]; then
            echo "  - pattern: \"$excluded_pattern\"" >> "$TEMP_CONFIG_FILE"
        fi
    done <<< "$CURRENT_EXCLUDED"
fi

# Replace the config file with the new one
mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
echo "Updated $CONFIG_FILE with $TARGET_COUNT discovered targets."

# Generate production_targets.txt file
echo "Generating $TARGETS_FILE..."
true > "$TARGETS_FILE"

# Extract enabled targets from config and write to targets file
yq '.targets[] | select(.enabled == true) | .target' "$CONFIG_FILE" > "$TARGETS_FILE"

echo "Generated $TARGETS_FILE with $(wc -l < "$TARGETS_FILE" | xargs) enabled production targets."
echo "To build production targets: ./build_production.sh"

echo "Discovery complete!"
