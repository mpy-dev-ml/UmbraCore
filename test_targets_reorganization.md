# UmbraCore Test Targets Reorganisation

This document identifies all test targets in the UmbraCore project and proposes a reorganisation plan to move them from the `//Sources` directory structure to a dedicated `//Tests` directory structure for better visibility and maintainability.

## Current Test Targets

### Foundation-Free Core Modules

- `//Sources/SecureBytes:SecureBytesTests`
- `//Sources/CoreTypesInterfaces:CoreTypesInterfacesTests`
- `//Sources/XPCProtocolsCore:XPCProtocolsCoreTests` (Temporarily disabled)
- `//Sources/SecurityProtocolsCore:SecurityProtocolsCoreTests`

### Security and Cryptography Modules

- `//Sources/SecurityBridge:SecurityBridgeTests`
- `//Sources/SecurityBridge:SecurityBridgeMigrationTests`
- `//Sources/SecurityBridge:SecurityBridgeSanityTests`
- `//Sources/SecurityBridge:SecurityProviderAdapterTests`
- `//Sources/SecurityBridge:CryptoServiceAdapterTests`
- `//Sources/SecurityBridge:RandomDataTests`
- `//Sources/SecurityBridge:SanityTests`
- `//Sources/SecurityBridge:TemporaryTests`
- `//Sources/SecurityImplementation:SecurityImplementationTests`
- `//Sources/SecurityImplementation:SecurityImplementationTests_runner`
- `//Sources/SecurityInterfaces:SecurityInterfacesTests`
- `//Sources/SecurityInterfaces:SecurityInterfacesTests_empty_src`
- `//Sources/SecurityInterfaces/Tests:SecurityProviderTests`
- `//Sources/UmbraSecurityCore:UmbraSecurityCoreTests`

### Testing-Specific Modules

- `//Sources/KeyManagementTypes/Tests:KeyManagementTypesTests`
- `//Sources/SecureString:SecureStringTests`

### ForTesting Variants (Test Utilities)

- `//Sources/SecurityInterfaces:SecurityInterfacesForTesting`
- `//Sources/SecurityInterfacesBase:SecurityInterfacesBaseForTesting`
- `//Sources/SecurityInterfacesFoundation:SecurityInterfacesFoundationForTesting`
- `//Sources/SecurityInterfacesProtocols:SecurityInterfacesProtocolsForTesting`
- `//Sources/SecurityInterfacesXPC:SecurityInterfacesXPCForTesting`
- `//Sources/FoundationBridgeTypes:FoundationBridgeTypesForTesting`
- `//Sources/ObjCBridgingTypes:ObjCBridgingTypesForTesting`
- `//Sources/ObjCBridgingTypesFoundation:ObjCBridgingTypesFoundationForTesting`

### Dedicated Test Support Modules

- `//Sources/TestUtils:TestUtils`
- `//Sources/Testing:Testing`
- `//Sources/TestingMacros:TestingMacros`
- `//Sources/UmbraMocks:UmbraMocks`

## Proposed Reorganisation

### Directory Structure

The proposed new structure would create a parallel `//Tests` directory alongside `//Sources`:

```
UmbraCore/
|-- Sources/
|   |-- SecureBytes/
|   |-- CoreTypesInterfaces/
|   |-- ...
|
|-- Tests/
|   |-- SecureBytes/
|   |-- CoreTypesInterfaces/
|   |-- ...
|
|-- BUILD.bazel
|-- WORKSPACE
|-- ...
```

### Mapping Strategy

1. **Direct Test Targets**: Move test code from `//Sources/X:XTests` to `//Tests/X:XTests`
   - Example: `//Sources/SecureBytes:SecureBytesTests` -> `//Tests/SecureBytes:SecureBytesTests`

2. **ForTesting Variants**: Move test utilities to `//Tests/Utilities/X:XForTesting`
   - Example: `//Sources/SecurityInterfaces:SecurityInterfacesForTesting` -> `//Tests/Utilities/SecurityInterfaces:SecurityInterfacesForTesting`

3. **Test Support Modules**: Keep in Sources but consider moving to `//Tests/Support`
   - Example: `//Sources/TestUtils:TestUtils` -> `//Tests/Support/TestUtils:TestUtils`

### Implementation Plan

1. **Phase 1: Analysis**
   - Review each test module's dependencies
   - Document import relationships
   - Identify potential circular dependencies

2. **Phase 2: Bazel Configuration**
   - Create `//Tests` directory structure
   - Set up appropriate visibility rules
   - Configure build settings for test targets

3. **Phase 3: Module Migration**
   - Migrate one module at a time, starting with the least dependent ones
   - Update import paths in all affected files
   - Fix any build issues that arise

4. **Phase 4: Validation**
   - Ensure all tests run successfully in the new structure
   - Verify that build times haven't significantly increased
   - Document any changes to test execution patterns

## Benefits of Reorganisation

1. **Improved Code Navigation**
   - Clear separation between production and test code
   - Easier to find test code for a specific module

2. **Build Optimization**
   - Production builds can more easily exclude test code
   - Potential for faster incremental builds

3. **Dependency Management**
   - Clearer boundaries between test and production dependencies
   - Prevention of accidental dependencies on test code

4. **Developer Experience**
   - Better IDE integration with standard test directory patterns
   - Easier onboarding for new team members

## Potential Challenges

1. **Build System Complexity**
   - May require significant changes to Bazel configuration
   - Need to maintain correct visibility rules

2. **Refactoring Effort**
   - Large codebase with many interconnected modules
   - Risk of breaking existing test workflows

3. **Circular Dependencies**
   - Tests often need access to internal module details
   - May require exposing more internals or using different testing approaches

## Next Steps

1. Review this proposal and gather feedback
2. Start with a pilot migration of one simple module
3. Develop migration scripts for automating the process
4. Create a prioritized migration schedule based on module complexity
