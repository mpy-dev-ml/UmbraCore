# Swift Code Analysis Report

Generated: 2025-03-06 15:50:10

## Summary

- Total Modules Analyzed: 1
- Total Swift Files: 9
- Total Isolation Files: 2
- Total Type Aliases: 11

## Modules with Isolation Patterns

- CoreTypes (2 isolation files)

## Common Isolation Patterns

- Files with 'Isolation' in the name are used to manage namespace conflicts
- Type aliases are heavily used to redirect types from other modules
- Error mapping functions follow the pattern 'mapXXXToYYYError'

## Module Analysis

### CoreTypes

- Isolation Files: 2
- Type Aliases: 11
- Error Mapping Functions: 6

Isolation Files:
- SecurityProtocolsCoreIsolation.swift
- XPCProtocolsCoreIsolation.swift

Top Imports:
- UmbraCoreTypes (6 files)
- Foundation (4 files)
- CoreErrors (5 files)
- the (1 files)
- SecurityProtocolsCoreIsolation (1 files)


## Refactoring Recommendations

1. **Create dedicated adapter modules** to replace isolation files
2. **Eliminate type aliases** by using proper namespacing
3. **Standardise error handling** across modules
4. **Reduce circular dependencies** by proper architectural boundaries
