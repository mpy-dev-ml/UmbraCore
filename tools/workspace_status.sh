#!/bin/bash
# Workspace status script for build stamping
# This script will be called by Bazel when building with --workspace_status_command

set -e

# Get git information
GIT_HASH=$(git rev-parse HEAD)
GIT_STATUS=$(git status --porcelain | wc -l | xargs)
BUILD_TIMESTAMP=$(date +%s)

# Set version (modify as needed)
# Consider extracting from a VERSION file or git tags
VERSION="0.2.0"
if [ $GIT_STATUS -ne 0 ]; then
  VERSION="${VERSION}-dirty"
fi

# Output build information
echo "BUILD_SCM_REVISION ${GIT_HASH}"
echo "BUILD_SCM_STATUS ${GIT_STATUS}"
echo "BUILD_TIMESTAMP ${BUILD_TIMESTAMP}"
echo "BUILD_VERSION ${VERSION}"

# Add Swift-specific info
SWIFT_VERSION=$(swift --version | head -n 1 | cut -d '(' -f 2 | cut -d ')' -f 1)
echo "BUILD_SWIFT_VERSION ${SWIFT_VERSION}"

# Add host information
echo "BUILD_HOST $(uname -a)"
