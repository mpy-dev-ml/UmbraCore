# Security Modules Migration Plan

## Current Status (2025-03-13)

The security modules in UmbraCore are currently in a transitional state with several deprecation warnings but no build errors. All security modules are successfully building and included in the production targets list.

### Identified Issues

1. **Deprecation Warnings in SecurityInterfaces**:
   - `StandardSecurityProviderFactory` is marked as deprecated with message: "Use SecurityProtocolsCore.StandardSecurityProviderFactory instead"
   - `SecurityProviderFactory` is marked as deprecated with message: "Use SecurityProtocolsCore.SecurityProviderFactoryProtocol instead"

2. **Namespace Confusion**:
   The suggested replacement types in the deprecation messages (e.g., `SecurityProtocolsCore.StandardSecurityProviderFactory`) don't seem to exist in the exact form indicated, suggesting an incomplete migration or namespace reorganisation.

### Security Module Structure

Based on our analysis of the codebase, security-related functionality is distributed across multiple modules with the following organisation:

1. **Core Protocol Modules**:
   - SecurityProtocolsCore - Contains foundation-independent security protocols
   - SecurityBridge - Provides bridging between different security implementations
   - SecurityInterfaces - Defines high-level interfaces for security operations

2. **Implementation Modules**:
   - SecurityUtils - Contains utility functions and helpers
   - UmbraSecurity - Provides the main security implementation
   - Various specialised modules (SecurityTypeConverters, SecurityImplementation, etc.)

## Migration Strategy

### Short-term (Immediate)

1. **Keep Current Implementation**: 
   - Since all modules are building successfully and included in production targets, no immediate code changes are needed.
   - The deprecation warnings are not affecting functionality and can be addressed in a planned manner.

### Medium-term (Next Sprint)

1. **Clarify Namespace Structure**:
   - Conduct a thorough review of the security namespace design
   - Document the intended structure in a security architecture document
   - Create a mapping between deprecated types and their modern equivalents

2. **Gradual Replacement**:
   - Starting with test modules, gradually replace deprecated types with their modern equivalents
   - Ensure backward compatibility with existing code

### Long-term (Future Release)

1. **Complete Migration**:
   - Remove all deprecated types and usages
   - Update documentation to reflect the new structure
   - Consider merging related security modules for simplification

## Best Practices

When working with the security modules, follow these guidelines:

1. **Type References**:
   - Use module-qualified names (e.g., `SecurityProtocolsCore.SecurityProviderProtocol`)
   - Be aware of similar type names across different modules

2. **Error Handling**:
   - Ensure all switch statements on security error types are exhaustive
   - Use consistent error handling patterns

3. **Data Conversion**:
   - For `CoreTypesInterfaces.BinaryData` (SecureData), use `.rawBytes` property to access raw bytes
   - When creating BinaryData, use `CoreTypesInterfaces.BinaryData(bytes: byteArray)`

## Next Steps

1. Complete this plan with input from the security module owners
2. Prioritise migration tasks based on project timeline
3. Create specific tickets for each migration step
