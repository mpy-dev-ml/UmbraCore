# Swift Namespace Resolution Strategy

## Problem: Swift Type Resolution Challenges

In complex Swift projects, particularly those with multiple modules that define similar types, we face several challenges:

1. **Module-level namespace conflicts**: Multiple modules defining types with the same name
2. **Type resolution ambiguity**: The Swift compiler struggles with fully qualified names in certain contexts
3. **Symbol visibility**: Importing multiple modules with conflicting types causes errors
4. **Type erasure complexity**: Converting between similar types in different modules is error-prone

## The "Isolation Pattern" Solution

UmbraCore implements a novel "Isolation Pattern" to address these Swift namespace challenges. The key components are:

### 1. Isolated Import Files

Create dedicated files that only import specific modules to avoid namespace collisions:

```swift
// SecurityProtocolsCoreProvider.swift
import SecurityProtocolsCore
// No conflicting imports here
```

### 2. Type Mapping Functions

Define explicit mapping functions between similar types in different modules:

```swift
// SecurityProtocolsCoreTypeMapping.swift
func mapToSecurityProtocolsCoreOperation(_ operation: SecurityOperation) -> SecurityProtocolsCore.SecurityOperation {
    // Type-safe mapping logic
}
```

### 3. Proxy Layer

Create adapter classes that wrap module-specific implementations:

```swift
// SecurityProtocolsCoreProvider.swift
public class SecurityProtocolsCoreProvider {
    private let provider: SecurityProviderProtocol
    
    func performSecureOperation(/*...*/) {
        // Call through to wrapped implementation with type conversion
    }
}
```

### 4. Factory Methods

Implement factories that handle type erasure and module-specific instantiation:

```swift
// SecurityProviderFactory.swift
public static func createProvider(ofType providerType: String) -> SecurityProvider {
    // Create provider using isolated factory methods
}
```

### 5. Re-export Types

Create a central package file that re-exports types and functions:

```swift
// SPCorePackage.swift
public typealias SPCProvider = SecurityProtocolsCoreProvider
public typealias SPCOperation = SecurityOperation
```

## Enhanced "Isolation Pattern" Implementation

The namespace resolution approach has been enhanced with additional techniques:

### 6. Subpackage Isolation

Create dedicated subpackages with their own module names for conflicting types:

```bazel
# BUILD.bazel
umbra_swift_library(
    name = "SecurityInterfacesSPCore",
    srcs = glob(["SecurityProtocolsCore/**/*.swift"]),
    module_name = "SecurityInterfaces_SecurityProtocolsCore",
    deps = [
        "//Sources/SecurityProtocolsCore",
    ],
)
```

### 7. Type Aliases with Error Migrator

Use the Error Migrator tool to generate appropriate type aliases for error types:

```swift
// SecurityProtocolsCore_Aliases.swift
public typealias CoreSecurityError = CoreErrors.SecurityError
```

### 8. Bidirectional Type Mapping

Implement bidirectional mapping functions between error types:

```swift
// SecurityProtocolsCore_Aliases.swift
public func mapCoreSecurityError(_ error: CoreSecurityError) -> SecurityError {
    switch error {
    case .bookmarkError:
        return SecurityError.internalError("Bookmark error")
    // ...
    }
}

public func mapToCoreSecurity(_ error: SecurityError) -> CoreSecurityError {
    // Default mapping
    return .cryptoError
}
```

### 9. Private Type Aliases

Create private type aliases to clarify which type is being used:

```swift
// SecurityProtocolsCoreProvider.swift
private typealias SPCProviderProtocol = SecurityProtocolsCore.SecurityProviderProtocol
```

## When to Use This Pattern

This pattern is particularly useful when:

1. You have modules with conflicting type names
2. You cannot rename types due to backward compatibility
3. You need to use both modules in the same codebase
4. You require type safety across module boundaries

## Best Practices for Resolving Ambiguities

1. **Never create enums with the same name as modules**: This causes significant type resolution confusion
2. **Use short type alias prefixes** like `SPC` to distinguish between types
3. **Create dedicated mapping files** that only import specific modules
4. **Use private type aliases** in isolated files to clarify type sources
5. **Configure build system with `-Xfrontend -enable-implicit-module-import-name-qualification`**
6. **Create subpackages** with distinct module names for highly conflicting sections

## When to Apply Each Technique

- **Isolation Pattern**: When two modules define similar protocols or types
- **Type Aliases**: For streamlined access to renamed types
- **Proxy Classes**: To isolate implementation details and hide type conversion
- **Subpackages**: For complete isolation of conflicting module imports
- **Error Migrator**: To centralize error definitions while maintaining backward compatibility

## Implementation Details

In UmbraCore, we've isolated the following components:

- **Types**: SecurityOperation, SecurityConfigDTO, SecurityResultDTO, SecurityError
- **Protocols**: SecurityProviderProtocol
- **Factories**: SecurityProviderFactory, SecurityProtocolsCoreProviderFactory

## Error Handling

Error handling is particularly challenging with namespace conflicts. Our solution includes:

1. Isolated error mapping functions
2. Type-safe error conversion
3. Consistent error hierarchy across modules

## Testing

Test the isolation layer thoroughly to ensure:

1. Type mapping correctness
2. Error propagation and translation
3. Functional equivalence with direct module usage

## Maintenance Considerations

When maintaining code using this pattern:

1. Always add new types to the mapping layer
2. Keep isolated files truly isolated (don't mix imports)
3. Update tests when adding new functionality
4. Document type relationships and mappings

## Notes for Future Development

When adding new security-related functionality:

1. Consider which module should own the types
2. Create mapping functions for new types
3. Update type aliasing if needed
4. Document new namespace resolution approaches in this file
