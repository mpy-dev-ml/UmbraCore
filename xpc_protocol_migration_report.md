# XPC Protocol Migration Report

Generated on: Wed Mar  5 19:08:58 GMT 2025

## Summary

This report identifies files and modules in the UmbraCore project that need to be refactored 
to use the new XPC protocols defined in XPCProtocolsCore.

- **Total files analyzed**: 2656
- **Files with legacy imports**: 40
- **Files with modern imports**: 111
- **Files needing refactoring**: 21
- **Modules to refactor**: 5

## Modules Needing Refactoring

| Module | Files Needing Refactoring | Priority |
|--------|---------------------------|----------|
| CoreTypes | 6 | Medium |
| ObjCBridgingTypes | 2 | Low |
| SecurityInterfaces | 12 | High |
| UmbraCryptoService | 5 | Medium |
| XPCProtocolsCore | 12 | High |

## Files to Refactor

Below is a list of the top files that need to be refactored in priority order:

- **null**: /Users/mpy/CascadeProjects/UmbraCore/TestSupport/Security/MockSecurityProvider.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/TestSupport/Security/SecurityInterfacesForTesting/SecurityInterfacesTestSupport.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/TestSupport/UmbraTestKit/Tests/SecurityErrorTests.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/SecurityInterfacesTest/SecurityInterfacesTest.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraSecurityTests/SecurityProviderTests.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/TestKit/Extensions/SecurityExtensions.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/TestKit/Mocks/MockKeychain.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/TestKit/Mocks/MockRepository.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/TestKit/Mocks/MockSecurityProvider.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/TestKit/Mocks/MockURLProvider.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/Tests/MockSecurityProviderTests.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/Tests/SecurityErrorHandlerTests.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/UmbraTestKit/Tests/SecurityErrorTests.swift
- **null**: /Users/mpy/CascadeProjects/UmbraCore/Tests/XPCTests/MockCryptoXPCServiceDependencies.swift
- **CoreTypes**: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/XPCServiceProtocolBase.swift
- **ObjCBridgingTypes**: /Users/mpy/CascadeProjects/UmbraCore/Sources/ObjCBridgingTypes/XPCServiceProtocolBase.swift
- **ObjCBridgingTypes**: /Users/mpy/CascadeProjects/UmbraCore/Sources/ObjCBridgingTypes/XPCServiceProtocolDefinitionBase.swift
- **SecurityInterfaces**: /Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityInterfaces/XPCServiceProtocolBase.swift
- **UmbraCryptoService**: /Users/mpy/CascadeProjects/UmbraCore/Sources/UmbraCryptoService/CryptoServiceListener.swift
- **UmbraCryptoService**: /Users/mpy/CascadeProjects/UmbraCore/Sources/UmbraCryptoService/CryptoXPCService.swift

## Migration Steps

For each file identified above:

1. Add imports for XPCProtocolsCore and UmbraCoreTypes:
   
Welcome to Swift!

Subcommands:

  swift build      Build Swift packages
  swift package    Create and work on packages
  swift run        Run a program from a package
  swift test       Run package tests
  swift repl       Experiment with Swift code interactively

  Use `swift --version` for Swift version information.

  Use `swift --help` for descriptions of available options and flags.

  Use `swift help <subcommand>` for more information about a subcommand.

2. Replace legacy protocol implementations with modern ones:
   - XPCServiceProtocol → XPCServiceProtocolStandard
   - XPCCryptoServiceProtocol → XPCServiceProtocolComplete
   - SecurityXPCProtocol → XPCServiceProtocolStandard

3. Update error handling to use XPCSecurityError from UmbraCoreTypes

4. Update data types:
   - BinaryData → SecureBytes
   - CryptoData → SecureBytes

5. If needed, use migration adapters from XPCProtocolsMigration.swift for backward compatibility

## Progress Tracking

Track migration progress by running this analysis tool regularly.

## Reference Documentation

For detailed migration guidance, see:
- [XPC_PROTOCOLS_MIGRATION_GUIDE.md](../XPC_PROTOCOLS_MIGRATION_GUIDE.md)
- [UmbraCore_Refactoring_Plan.md](../UmbraCore_Refactoring_Plan.md)

