#!/bin/bash
# Update BUILD files to include CoreErrors dependency

# Set the base directory
UMBRA_ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
TARGET_DIR="$UMBRA_ROOT_DIR/Sources"

# Modules that need CoreErrors dependency
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

# Check each module for BUILD file and update it
for mapping in "${MODULE_MAPPINGS[@]}"; do
  IFS="|" read -r module_name module_path <<< "$mapping"
  build_file="$TARGET_DIR/$module_path/BUILD"
  
  if [ -f "$build_file" ]; then
    echo "Updating BUILD file for $module_name at $module_path..."
    
    # Check if the file already has a CoreErrors dependency
    if grep -q "//Sources/CoreErrors" "$build_file"; then
      echo "  - CoreErrors dependency already exists"
    else
      # Create a backup of the original BUILD file
      cp "$build_file" "$build_file.bak"
      
      # Add the CoreErrors dependency
      sed -i '' -e '/deps = \[/a\
        "//Sources/CoreErrors",
' "$build_file"
      
      # Check if we actually made changes
      if diff -q "$build_file" "$build_file.bak" >/dev/null; then
        echo "  - Failed to update BUILD file, no 'deps = [' pattern found"
        echo "  - You will need to manually add CoreErrors as a dependency"
      else
        echo "  - Successfully added CoreErrors dependency"
      fi
    fi
  else
    echo "No BUILD file found for $module_name at $module_path"
  fi
done

echo "BUILD file updates complete."
echo "Please review all changes before building the project."
