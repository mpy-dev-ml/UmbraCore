#!/bin/bash
# Script to run the UmbraCore module analyser

# Ensure we're in the project root directory
cd "$(dirname "$0")/.." || { echo "Failed to change to project root directory"; exit 1; }

# Set project root environment variable
export PROJECT_ROOT="$(pwd)"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed. Please install Go first."
    echo "You can install it with: brew install go"
    exit 1
fi

# Run the module analyser
echo "Running UmbraCore Module Analyser..."
go run tools/module_analyser.go

echo "Analysis complete!"
