#!/bin/bash
# Copy theme files from CascadeProjects/themeforest to our docs directory
THEME_SOURCE="/Users/mpy/CascadeProjects/themeforest/doks-theme"
THEME_DEST="/Users/mpy/CascadeProjects/UmbraCore/docs/doks-theme"

# Create theme directory if it doesn't exist
mkdir -p "$THEME_DEST"

# Copy theme files
cp -R "$THEME_SOURCE"/* "$THEME_DEST/"

echo "Theme files copied successfully"
