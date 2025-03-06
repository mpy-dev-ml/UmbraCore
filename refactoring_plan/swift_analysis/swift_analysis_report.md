# Swift Code Analysis Report

Generated: 2025-03-06 16:08:18

## Summary

- Total Modules Analyzed: 1
- Total Swift Files: 7
- Total Isolation Files: 0
- Total Type Aliases: 0

## Modules with Isolation Patterns


## Common Isolation Patterns

- Files with 'Isolation' in the name are used to manage namespace conflicts
- Type aliases are heavily used to redirect types from other modules
- Error mapping functions follow the pattern 'mapXXXToYYYError'

## Module Analysis


## Refactoring Recommendations

1. **Create dedicated adapter modules** to replace isolation files
2. **Eliminate type aliases** by using proper namespacing
3. **Standardise error handling** across modules
4. **Reduce circular dependencies** by proper architectural boundaries
