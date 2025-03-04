#!/bin/bash
# Error Migration Application Script

# Set the base directory
UMBRA_ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
GENERATED_DIR="$UMBRA_ROOT_DIR/tools/error_migrator/generated_code"
TARGET_DIR="$UMBRA_ROOT_DIR/Sources"

# Ensure CoreErrors module directory exists
CORE_ERRORS_MODULE_DIR="$TARGET_DIR/CoreErrors"
mkdir -p "$CORE_ERRORS_MODULE_DIR"

# Copy the CoreErrors module files
echo "Copying CoreErrors module files..."
cp -r "$GENERATED_DIR/CoreErrors/"* "$CORE_ERRORS_MODULE_DIR/"

# Module mapping - maps generated module names to actual directory paths
# Format: "module_name|path"
MODULE_MAPPINGS=(
  "Core|Core"
  "Services|Services"
  "Types|Core/Types"
  "SecurityTypes|SecurityTypes"
  "SecurityInterfacesBase|SecurityInterfacesBase"
  "SecurityProtocolsCore|SecurityProtocolsCore/Sources"
  "CryptoTypes|CryptoTypes"
  "CryptoService|CryptoService"
  "UmbraCryptoService|UmbraCryptoService"
  "Resources|Resources"
  "Protocols|Protocols"
  "Repositories|Repositories"
  "Features|Features"
  "Errors|Errors"
  "UmbraLogging|UmbraLogging"
)

# Copy module-specific alias files
echo "Copying module alias files..."
for module_dir in "$GENERATED_DIR"/*/ ; do
  if [ "$(basename "$module_dir")" != "CoreErrors" ]; then
    module_name=$(basename "$module_dir")
    target_path=""
    
    # Find the mapping for this module
    for mapping in "${MODULE_MAPPINGS[@]}"; do
      IFS="|" read -r map_name map_path <<< "$mapping"
      if [ "$map_name" = "$module_name" ]; then
        target_path="$map_path"
        break
      fi
    done
    
    if [ -n "$target_path" ]; then
      target_module_dir="$TARGET_DIR/$target_path"
      
      if [ -d "$target_module_dir" ]; then
        echo "  - Copying aliases for $module_name to $target_module_dir"
        cp -r "$module_dir"* "$target_module_dir/"
      else
        echo "  - Warning: Target directory for $module_name not found at $target_module_dir"
      fi
    else
      echo "  - Warning: No mapping found for module $module_name"
    fi
  fi
done

# Create BUILD file for CoreErrors module
echo "Creating BUILD file for CoreErrors module..."
cat > "$CORE_ERRORS_MODULE_DIR/BUILD" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "CoreErrors",
    srcs = glob(["*.swift"]),
    copts = ["-enable-library-evolution"],
    module_name = "CoreErrors",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "CoreErrorsSources",
    srcs = glob(["*.swift"]),
    visibility = ["//visibility:public"],
)
EOF

echo "Migration application complete!"
echo "Please review the changes and run tests to ensure everything works correctly."
echo ""
echo "IMPORTANT: You must update all module BUILD files that now depend on CoreErrors to include it as a dependency:"
echo "    deps = ["
echo "        \"//Sources/CoreErrors\","
echo "        # other dependencies..."
echo "    ],"
