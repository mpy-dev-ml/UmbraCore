#!/bin/bash
# Script to build DocC documentation for all modules in UmbraCore using yq

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Please install it with 'brew install yq'"
    echo "Visit https://github.com/mikefarah/yq for more information."
    exit 1
fi

CONFIG_FILE="docc_config.yml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    exit 1
fi

echo "Building DocC documentation for all modules with Bazelisk..."

# Get output directory from config
OUTPUT_DIR=$(yq '.settings.output_dir' "$CONFIG_FILE")
BUILD_ENV=$(yq '.settings.build_environment' "$CONFIG_FILE")

# Print the targets we're going to build
echo "Building the following DocC targets:"
yq '.targets[].target' "$CONFIG_FILE"

# Build targets individually
echo "Building documentation with Bazelisk..."
TARGET_COUNT=$(yq '.targets | length' "$CONFIG_FILE")

for ((i=0; i<$TARGET_COUNT; i++)); do
    TARGET=$(yq ".targets[$i].target" "$CONFIG_FILE")
    
    # Build the target
    echo "Building target: $TARGET"
    bazelisk build --define=build_environment="$BUILD_ENV" --verbose_failures "$TARGET"
done

# Prepare the output directory
echo "Preparing output directory..."
mkdir -p "$OUTPUT_DIR"

# Clean existing documentation files using find to avoid permission issues
if [ -d "$OUTPUT_DIR" ]; then
    echo "Cleaning existing documentation files..."
    find "$OUTPUT_DIR" -mindepth 1 -delete 2>/dev/null || echo "Note: Some files could not be deleted, continuing anyway..."
fi

# Process and copy the documentation
echo "Processing documentation archives..."
for ((i=0; i<$TARGET_COUNT; i++)); do
    TARGET=$(yq ".targets[$i].target" "$CONFIG_FILE")
    BAZEL_PATH=$(yq ".targets[$i].output" "$CONFIG_FILE")
    MODULE_NAME=$(yq ".targets[$i].module" "$CONFIG_FILE")
    
    # Full path to the doccarchive in bazel-bin
    SOURCE_PATH="bazel-bin/$BAZEL_PATH"
    
    echo "Looking for documentation at: $SOURCE_PATH"
    if [ -d "$SOURCE_PATH" ]; then
        # Process the files with rsync which handles permissions better
        echo "Copying $SOURCE_PATH to $OUTPUT_DIR/${MODULE_NAME}.doccarchive"
        
        # Create the destination directory
        mkdir -p "$OUTPUT_DIR/${MODULE_NAME}.doccarchive"
        
        # Use rsync to copy files with proper permissions
        rsync -a "$SOURCE_PATH/" "$OUTPUT_DIR/${MODULE_NAME}.doccarchive/" || {
            echo "Error using rsync, falling back to cp..."
            cp -R "$SOURCE_PATH"/* "$OUTPUT_DIR/${MODULE_NAME}.doccarchive/" 2>/dev/null
        }
        
        echo "✅ Copied documentation for $MODULE_NAME"
    else
        echo "⚠️ Warning: Documentation not found at $SOURCE_PATH"
        
        # List contents of bazel-bin to help troubleshoot
        echo "Contents of bazel-bin/$(dirname "$BAZEL_PATH"):"
        ls -la "bazel-bin/$(dirname "$BAZEL_PATH")" 2>/dev/null || echo "Directory not found"
    fi
done

echo "DocC documentation build complete!"
echo "Documentation archives are available in $OUTPUT_DIR directory"
