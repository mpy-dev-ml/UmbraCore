# Swift Module Analysis Report

Generated on: 2025-03-06 15:06:40 +0000

## Summary

Total modules analyzed: 54
Modules using isolation pattern: 1
Total type aliases found: 72

## Modules Prioritized for Refactoring

### Core

Complexity Score: 10/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `SecurityError` = `CoreErrors.SecurityError`
- `CryptoError` = `CoreErrors.CryptoError`
- `KeyManagerError` = `CoreErrors.KeyManagerError`
- `ServiceError` = `CoreErrors.ServiceError`
- `XPCServiceProtocol` = `XPCProtocolsCore.XPCServiceProtocolStandard`
- `XPCServiceProtocol` = `XPCProtocolsCore.XPCServiceProtocolStandard`
- `XPCServiceProtocolBase` = `XPCProtocolsCore.XPCServiceProtocolBasic`
- `XPCServiceProtocolComplete` = `XPCProtocolsCore.XPCServiceProtocolComplete`
- `XPCSecurityError` = `UmbraCoreTypes.CoreErrors.SecurityError`
- `LegacyXPCServiceProtocol` = `XPCServiceProtocol`

**Dependencies:**
- CoreErrors
- CoreServicesSecurityTypeAliases
- CoreServicesTypeAliases
- CoreServicesTypes
- CoreTypes
- CryptoSwift
- Foundation
- ObjCBridgingTypes
- ObjCBridgingTypesFoundation
- SecurityProtocolsCore
- SecurityTypes
- SecurityTypesProtocols
- UmbraCoreTypes
- UmbraLogging
- UmbraXPC
- XPCProtocolsCore

### SecurityBridge

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `FoundationSecurityProviderResult` = `Result`

**Dependencies:**
- CoreTypes
- Foundation
- FoundationBridgeTypes
- SecurityBridge
- SecurityBridgeProtocolAdapters
- SecurityProtocolsCore
- UmbraCoreTypes
- XCTest
- XPCProtocolsCore

### XPCProtocolsCore

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `XPCSecurityError` = `CoreErrors.SecurityError`

**Dependencies:**
- CoreErrors
- CryptoTypes
- Foundation
- SecurityInterfaces
- SecurityInterfacesBase
- SecurityInterfacesProtocols
- SecurityProtocolsCore
- UmbraCoreTypes
- XCTest
- XPCProtocolsCore
- struct

### CoreTypes

Complexity Score: 10/10

**Risks:**
- Uses isolation pattern that will need careful refactoring
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Isolation Files:**
- SecurityProtocolsCoreIsolation.swift
- SecurityErrorBase.swift
- XPCProtocolsCoreIsolation.swift

**Type Aliases:**
- `SPCSecurityError` = `SecurityProtocolsCore.SecurityError`
- `SPCSecurityError` = `SecurityProtocolsCore.SecurityError`
- `BinaryData` = `SecureBytes`
- `SecureBytes` = `UmbraCoreTypes.SecureBytes`
- `SecureValue` = `UmbraCoreTypes.SecureValue`
- `XPCSecurityError` = `CoreErrors.SecurityError`
- `CoreSecurityError` = `CoreErrors.SecurityError`
- `SPCoreSecurityError` = `SPCSecurityError`
- `XPCoreSecurityError` = `XPCSecurityError`
- `XPCSecurityError` = `XPCProtocolsCore.XPCSecurityError`
- `XPCSecurityErrorType` = `XPCProtocolsCore.XPCSecurityError`

**Dependencies:**
- CoreErrors
- Foundation
- SecurityProtocolsCore
- SecurityProtocolsCoreIsolation
- UmbraCoreTypes
- XPCProtocolsCore
- XPCProtocolsCoreIsolation
- the

### Features

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `LoggingError` = `CoreErrors.LoggingError`

**Dependencies:**
- CoreErrors
- FeaturesLoggingErrors
- FeaturesLoggingModels
- FeaturesLoggingProtocols
- Foundation
- SecurityInterfaces
- SecurityTypes
- SecurityTypesProtocols
- SwiftyBeaver
- UmbraCoreTypes
- UmbraCoreTypesimport
- XPCProtocolsCore
- XPCProtocolsCoreimport

### UmbraSecurity

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Dependencies:**
- CoreServices
- CoreServicesTypesNoFoundation
- CoreTypes
- CryptoKit
- CryptoSwiftFoundationIndependent
- ErrorHandling
- Foundation
- FoundationBridgeTypes
- ObjCBridgingTypesFoundation
- SecurityBridge
- SecurityInterfaces
- SecurityInterfacesBase
- SecurityInterfacesProtocols
- SecurityProtocolsCore
- SecurityUtils
- UmbraCoreTypes
- UmbraCoreTypesimport
- UmbraLogging
- UmbraSecurityCryptoNoFoundation
- XPCProtocolsCoreimport

### UmbraCryptoService

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `CryptoError` = `CoreErrors.CryptoError`

**Dependencies:**
- Core
- CoreErrors
- CryptoSwift
- CryptoTypes
- CryptoTypesServices
- Foundation
- SecurityUtils
- UmbraCoreTypes
- UmbraKeychainService
- UmbraXPC
- XPC
- XPCProtocolsCore

### CryptoTypes

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `CryptoError` = `CoreErrors.CryptoError`
- `DefaultCryptoService` = `DefaultCryptoServiceImpl`

**Dependencies:**
- CommonCrypto
- CoreErrors
- CryptoTypesProtocols
- CryptoTypesTypes
- Foundation
- SecurityTypes
- UmbraCoreTypes
- XPCProtocolsCore
- struct

### Services

Complexity Score: 10/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `SecurityError` = `CoreErrors.SecurityError`
- `CryptoError` = `CoreErrors.CryptoError`
- `KeyManagerError` = `CoreErrors.KeyManagerError`
- `ServiceError` = `CoreErrors.ServiceError`

**Dependencies:**
- CoreErrors
- CryptoTypes
- CryptoTypesProtocols
- CryptoTypesTypes
- Foundation
- Security
- SecurityInterfaces
- SecurityTypes
- SecurityUtilsProtocols
- UmbraCoreTypes
- UmbraCoreTypesimport
- XPCProtocolsCoreimport

### SecurityInterfaces

Complexity Score: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Type Aliases:**
- `SecurityError` = `SecurityInterfacesError`

**Dependencies:**
- CoreErrors
- CoreTypes
- Foundation
- FoundationBridgeTypes
- SecurityBridge
- SecurityInterfaces
- SecurityInterfacesBase
- SecurityInterfacesProtocols
- SecurityProtocolsCore
- UmbraCoreTypes
- UmbraCoreTypesimport
- XPCProtocolsCore
- XPCProtocolsCoreimport
- enum

