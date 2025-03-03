# Error Analyzer Tool

This tool analyzes Swift error definitions and references across the UmbraCore project to help with the migration to a centralized CoreErrors module.

## Purpose

The Error Analyzer helps to:

1. Identify all error type definitions across the codebase
2. Find duplicated error types that should be consolidated
3. Track references and dependencies between modules
4. Generate a comprehensive migration plan for creating a CoreErrors module

## Usage

```bash
cd /Users/mpy/CascadeProjects/UmbraCore/tools/error_analyzer
go run main.go --dir /Users/mpy/CascadeProjects/UmbraCore/Sources --output error_analysis_report.md
```

### Options

- `--dir`: Root directory to scan (default: current directory)
- `--output`: Path to the output report file (default: error_analysis_report.md)

## Output

The tool generates a Markdown report containing:

1. Summary of modules, error definitions, and references
2. List of all error types and their definitions
3. Analysis of duplicated error types and where they are defined
4. Proposed migration plan to the CoreErrors module
5. Detailed steps for implementation

## CoreErrors Migration Goal

The ultimate goal is to create a dedicated `CoreErrors` module that:

- Serves as a single source of truth for all error types
- Eliminates ambiguity issues with duplicate error types
- Provides consistent error handling across the codebase
- Reduces dependencies between modules
- Improves maintenance by centralizing error definitions

## Implementation Strategy

1. Use this tool to analyze the current state of error definitions
2. Create the CoreErrors module with consolidated error types
3. Update existing modules to use CoreErrors
4. Provide backward compatibility where needed
5. Remove duplicated error definitions once migration is complete
