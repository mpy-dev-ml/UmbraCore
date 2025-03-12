#!/bin/bash
# Build UmbraCore documentation locally

# Ensure docs directory exists
if [ ! -d "docs" ]; then
    echo "Warning: docs directory not found. Creating it."
    mkdir -p docs
fi

# Create roadmap.md if it doesn't exist
if [ ! -f "docs/roadmap.md" ]; then
    echo "Warning: roadmap.md not found. Creating it from ROADMAP.md."
    if [ -f "docs/ROADMAP.md" ]; then
        cp docs/ROADMAP.md docs/roadmap.md
    elif [ -f "team-utils/ROADMAP.md" ]; then
        cp team-utils/ROADMAP.md docs/roadmap.md
    else
        echo "Warning: No ROADMAP.md found. Creating a placeholder."
        cat > docs/roadmap.md << 'ROADMAP_CONTENT'
# UmbraCore Development Roadmap

This document outlines the planned development roadmap for UmbraCore.

## Current Priorities

### XPC Protocol Consolidation (75% Complete)

- Completing client migration
- Adding comprehensive tests
- Documentation updates

### Security Module Refactoring

- Ongoing improvements to security architecture
- Eliminating circular dependencies

*See GitHub project for detailed milestones*
ROADMAP_CONTENT
    fi
fi

# Create a local copy of mkdocs.yml if it's a symlink
if [ -L "mkdocs.yml" ]; then
    echo "mkdocs.yml is a symlink. Creating a local copy..."
    cp -f team-utils/mkdocs.yml ./mkdocs.yml
fi

# Ensure requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo "Warning: requirements.txt not found. Creating it from team-utils."
    if [ -f "team-utils/requirements.txt" ]; then
        cp team-utils/requirements.txt ./requirements.txt
    else
        echo "Creating minimal requirements."
        cat > requirements.txt << 'REQ_CONTENT'
mkdocs==1.5.3
mkdocs-material==9.5.3
pymdown-extensions==10.7
mkdocs-material-extensions==1.3.1
pygments==2.17.2
markdown==3.5.2
REQ_CONTENT
    fi
fi

# Ensure we have the tools needed
pip install -r requirements.txt || {
    echo "Failed to install requirements. Check your Python environment."
    exit 1
}

# Build the documentation with error handling
mkdocs build || {
    echo "Documentation build failed with errors."
    echo "You may need to fix the mkdocs.yml configuration."
    exit 1
}

# Output the result
echo "Documentation built successfully in ./site directory"
echo "To view locally, run: mkdocs serve"
