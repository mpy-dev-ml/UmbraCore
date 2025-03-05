#!/bin/bash

# Script to install git hooks for UmbraCore
# Usage: ./scripts/install-git-hooks.sh

HOOKS_DIR=".git/hooks"
SCRIPTS_DIR="scripts"

# Create pre-commit hook
cat > "${HOOKS_DIR}/pre-commit" << 'EOF'
#!/bin/bash

# UmbraCore pre-commit git hook

echo "Running pre-commit checks..."

# Check for formatting issues in staged Swift files
echo "Checking code formatting..."
STAGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep "\.swift$" || echo "")

if [ -n "$STAGED_SWIFT_FILES" ]; then
  # Run SwiftFormat on staged files
  ./scripts/format_code.sh --check --staged-only
  if [ $? -ne 0 ]; then
    echo "❌ SwiftFormat check failed!"
    echo "Run './scripts/format_code.sh --staged-only' to format staged files"
    echo "Or run './scripts/format_code.sh' to format all files"
    exit 1
  fi
  echo "✅ SwiftFormat check passed!"
else
  echo "No Swift files staged, skipping SwiftFormat check"
fi

# Add more checks here as needed
# For example, SwiftLint, unit tests, etc.

echo "✅ All pre-commit checks passed!"
exit 0
EOF

# Make hooks executable
chmod +x "${HOOKS_DIR}/pre-commit"

echo "Git hooks installed successfully!"
echo "Pre-commit hook will now check formatting of Swift files"
