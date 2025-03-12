# UmbraCore Build Issues Summary

This document summarizes all targets that had build issues or were marked for revisiting during the build process. It categorises the issues by module type and includes details about the specific problems encountered.

## Foundation-Free Core Modules

| Target | Issue Type | Description |
|--------|------------|-------------|
| `//Sources/XPCProtocolsCore:XPCProtocolsCoreTests` | Disabled | Temporarily disabled due to complex dependency issues |

## Security and Cryptography Modules

| Target | Issue Type | Description |
|--------|------------|-------------|
| `//Sources/SecurityInterfaces/Tests:SecurityProviderTests` | Module Resolution | Build fails due to module resolution issues |
| `//Sources/SecurityUtils:SecurityUtils` | Module Resolution | Build fails due to module resolution issues |
| `//Sources/SecurityUtils/Protocols:SecurityUtilsProtocols` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/UmbraSecurity:UmbraSecurity` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/UmbraSecurity/Extensions:UmbraSecurityExtensions` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/UmbraSecurity/Services:UmbraSecurityServicesCore` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/UmbraCryptoService:UmbraCryptoService` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/UmbraKeychainService:UmbraKeychainService` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/CryptoTypes/Services:CryptoTypesServices` | Missing Dependencies | Build fails due to missing dependencies |

## Core and Service Modules

| Target | Issue Type | Description |
|--------|------------|-------------|
| `//Sources/Core/Services:CoreServices` | Namespace Resolution | Build fails due to namespace resolution issues |
| `//Sources/Core/Services/TypeAliases:CoreServicesSecurityTypeAliases` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/Core/Services/Types:CoreServicesTypes` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/Services/SecurityUtils:SecurityUtils` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/Services/SecurityUtils/Protocols:SecurityUtilsProtocols` | Dependency | Need to be revisited after dependencies are resolved |
| `//Sources/Services/SecurityUtils/Services:SecurityUtilsServices` | Dependency | Need to be revisited after dependencies are resolved |

## Error Handling and Logging Modules

| Target | Issue Type | Description |
|--------|------------|-------------|
| `//Sources/ErrorHandling/Examples:ErrorHandlingExamples` | Dependency | Build issues related to LoggingWrapper dependency |
| `//Sources/Features/Logging/Services:FeaturesLoggingServices` | Syntax Error | Build fails due to import syntax errors |

## Feature and API Modules

| Target | Issue Type | Description |
|--------|------------|-------------|
| `//Sources/API:API` | Not Attempted | Build not attempted yet |
| `//Sources/Features:Features` | Not Attempted | Build not attempted yet |

## Common Issue Patterns

1. **Module Resolution Issues**: Several targets fail because they can't properly resolve module dependencies, particularly in the Security-related modules.

2. **Namespace Resolution**: Some targets have issues with namespace resolution, where the compiler can't locate types due to ambiguous imports or naming conflicts.

3. **Dependency Chains**: Many targets are blocked by unresolved dependencies in other modules they depend on.

4. **Import Syntax Errors**: Some targets have syntax errors in their import statements, particularly in the logging services.

## Next Steps for Resolution

1. **Focus on Foundational Modules First**: Resolve issues in the foundational modules before attempting to build modules that depend on them.

2. **Type Resolution Approach**:
   - Use explicit type aliases where namespace ambiguity exists
   - Ensure consistent import patterns across modules
   - Use fully qualified type names where appropriate

3. **Pattern-Based Fixes**:
   - Apply consistent module import patterns across similar files
   - Use the patterns established in the successfully built modules
   - Pay attention to import ordering and dependencies

4. **Documentation**:
   - Document each fix so that similar issues can be resolved consistently
   - Note any workarounds or temporary fixes for future refactoring
