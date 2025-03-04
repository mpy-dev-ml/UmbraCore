# Swift Namespace Resolution Strategy

This document describes the approach used in SecurityInterfaces to resolve Swift's namespace conflicts when dealing with multiple modules that define types with the same name.

## The Problem

In UmbraCore, we have multiple security-related modules, each defining similar types:

1. `SecurityProtocolsCore` defines `SecurityProviderProtocol`
2. `SecurityInterfacesProtocols` also defines `SecurityProviderProtocol`

When both modules are imported into the same file, Swift cannot disambiguate between these types, leading to compiler errors such as:

```
Reference to 'SecurityProviderProtocol' is ambiguous
```

Adding to the complexity, `SecurityProtocolsCore` has a top-level enum also named `SecurityProtocolsCore`, so the fully qualified syntax `SecurityProtocolsCore.SecurityProviderProtocol` incorrectly looks for the type inside the enum rather than at the module level.

## Our Solution: The Isolation Pattern

We implemented a pattern that isolates imports and creates clean mapping boundaries:

### 1. Isolated Import Files

Each file in the `SecurityProtocolsCore` directory imports only one conflicting module:

- `SecurityProtocolsCoreProvider.swift` imports only `SecurityProtocolsCore`
- `SecurityProtocolsCoreErrorMapping.swift` handles error mapping
- `SecurityProtocolsCoreTypeMapping.swift` handles type mapping

### 2. Proxy Pattern

We use a proxy class `SecurityProtocolsCoreProvider` that wraps the actual `SecurityProviderProtocol` from `SecurityProtocolsCore`. This allows us to:

- Isolate the import to a single file
- Provide a clean API that's not ambiguous
- Handle the mapping of types between modules

### 3. Factory Pattern

The `SecurityProviderFactory` provides a clean way to create a `SecurityProvider` from a `SecurityProtocolsCore` implementation without exposing the complexity to client code.

## Best Practices for Swift Namespace Resolution

1. **Isolation**: Keep imports of conflicting modules separate
2. **Proxies**: Use wrapper/proxy classes to isolate module-specific code
3. **Type Mapping**: Create explicit mapping functions between module types
4. **Factory Methods**: Provide high-level factories that abstract the complexity
5. **Consistent Naming**: Use clear and consistent naming for module-specific types

## When to Use This Approach

Use this approach when:

1. You have multiple modules defining types with the same name
2. You cannot rename the types (due to backward compatibility)
3. You need to use both modules in the same codebase

## Future Swift Language Improvements

This is a workaround for current Swift language limitations. Future improvements to Swift may include:

1. Module aliases (like `import ModuleA as A`)
2. Better module-level namespace disambiguation
3. More explicit type qualification syntax

Until then, this isolation pattern provides a clean and maintainable approach to resolving namespace conflicts.
