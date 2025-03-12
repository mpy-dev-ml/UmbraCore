#!/bin/bash
# Build all production targets from production_targets.txt
bazelisk build $(cat production_targets.txt | grep -v "^//" | sed 's/^/\/\//' | tr '\n' ' ') --config=prod "$@"
