#!/bin/bash
# Build UmbraCore documentation locally

# Ensure we have the tools needed
pip install -r requirements.txt

# Build the documentation
mkdocs build

# Output the result
echo "Documentation built in ./site directory"
echo "To view locally, run: mkdocs serve"
