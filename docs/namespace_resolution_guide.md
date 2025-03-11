# UmbraCore Namespace Resolution Guide

## Overview

This document outlines best practices for resolving Swift namespace conflicts in the UmbraCore project, with a specific focus on error handling patterns and the `UmbraErrors` namespace. It is intended to help developers avoid common pitfalls when working with module imports and type references across the codebase.

## The Challenge: Swift Module Namespaces

Swift's module system can sometimes lead to ambiguous references, particularly in a large, modular codebase like UmbraCore. The key challenges include:

1. **Nested namespaces**: Types defined within enums that share the same name as their module
2. **Type aliases**: Different modules may define similar types or use type aliases
3. **Module structure**: The actual definition of a type may be in a submodule rather than the main module
4. **Re-exported types**: Types may be re-exported through parent modules

## UmbraErrors Case Study

### Problem

A common issue encountered is correctly referencing the `UmbraErrors` namespace, which is defined in the `ErrorHandlingDomains` module but often accessed through the parent `ErrorHandling` module. This can lead to build errors such as:

```
error: cannot find type 'UmbraErrors' in scope
```

or 

```
error: 'UmbraErrors' is not a member type of enum 'ErrorHandling.ErrorHandling'
```

### Solution Pattern

To properly reference the `UmbraErrors` namespace and its nested types:

1. **Import the specific module** that actually contains the definition:
   ```swift
   import ErrorHandlingDomains  // Contains UmbraErrors definition
   import ErrorHandling         // May be needed for other functionality
   ```

2. **Use fully qualified type names** when referencing error types:
   ```swift
   // INCORRECT
   func handleError() -> Result<Data, UmbraErrors.GeneralSecurity.Core> { ... }
   
   // CORRECT
   func handleError() -> Result<Data, ErrorHandlingDomains.UmbraErrors.GeneralSecurity.Core> { ... }
   ```

3. **Update BUILD.bazel files** to include explicit dependencies:
   ```starlark
   deps = [
       "//Sources/ErrorHandling",
       "//Sources/ErrorHandling/Domains:ErrorHandlingDomains",  // Add this direct dependency
       // Other dependencies...
   ],
   ```

## Error Handling Structure in UmbraCore

Understanding the organisation of error types in UmbraCore is crucial:

### Namespace Hierarchy

- `UmbraErrors` serves as the root namespace
- Domain-specific errors are nested within (e.g., `UmbraErrors.GeneralSecurity`)
- Specific error categories are nested further (e.g., `UmbraErrors.GeneralSecurity.Core`)

### Common Error Domains

| Domain | Module | Example Usage |
|--------|--------|---------------|
| GeneralSecurity | ErrorHandlingDomains | `ErrorHandlingDomains.UmbraErrors.GeneralSecurity.Core` |
| Security | ErrorHandlingDomains | `ErrorHandlingDomains.UmbraErrors.Security.Protocols` |
| Network | ErrorHandlingDomains | `ErrorHandlingDomains.UmbraErrors.Network.Core` |
| Application | ErrorHandlingDomains | `ErrorHandlingDomains.UmbraErrors.Application.Lifecycle` |

## Best Practices

1. **Always use explicit imports** for modules containing the types you need
2. **Favour fully qualified names** for types that exist in multiple modules
3. **Check BUILD.bazel files** to ensure all necessary module dependencies are included
4. **Create type aliases** for commonly used but verbose type references
5. **Document type references** in comments to help other developers

## Debugging Tips

When encountering namespace resolution issues:

1. Use `grep_search` to find where the type is defined:
   ```bash
   grep -r "extension UmbraErrors" Sources/
   ```

2. Look for example usages in the codebase:
   ```bash
   grep -r "UmbraErrors.GeneralSecurity" Sources/
   ```

3. Check for fully qualified references in error handler code:
   ```bash
   grep -r "ErrorHandlingDomains.UmbraErrors" Sources/
   ```

4. Examine BUILD.bazel dependencies for the module containing your code

## Conclusion

Properly handling Swift namespace resolution in UmbraCore requires understanding the modular structure of the codebase and being explicit about imports and type references. By following the patterns outlined in this guide, you can avoid common errors and ensure your code remains maintainable.

## Further Reading

- [UmbraCore Module Structure Documentation](./module_structure.md)
- [Swift Import Declaration Documentation](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID362)
- [Bazel Dependencies Guide](./bazel_dependencies.md)
