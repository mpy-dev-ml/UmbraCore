# Swift Module Refactoring Plan

Generated on: 2025-03-06 15:06:40 +0000

## Modules to Refactor

## 1. Core

Complexity: 10/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 10

## 2. SecurityBridge

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 3. XPCProtocolsCore

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 4. CoreTypes

Complexity: 10/10

**Risks:**
- Uses isolation pattern that will need careful refactoring
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 3
- Type Aliases: 11

**Refactoring Steps:**

### Step 1: Replace isolation files with proper adapter modules

Complexity: 7/10

File Changes:
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../SecurityProtocolsCoreAdapter/SecurityProtocolsCoreAdapter.swift
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../SecurityProtocolsCoreAdapter/BUILD.bazel
- Delete: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/SecurityProtocolsCoreIsolation.swift
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../SecurityErrorBase/SecurityErrorBase.swift
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../SecurityErrorBase/BUILD.bazel
- Delete: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/SecurityErrorBase.swift
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../XPCProtocolsCoreAdapter/XPCProtocolsCoreAdapter.swift
- Create: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/../XPCProtocolsCoreAdapter/BUILD.bazel
- Delete: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypes/XPCProtocolsCoreIsolation.swift

## 5. Features

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 6. UmbraCryptoService

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 7. CryptoTypes

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 2

## 8. Services

Complexity: 10/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 4

## 9. SecurityInterfaces

Complexity: 10/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 10. UmbraLogging

Complexity: 10/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 27

## 11. SecurityProtocolsCore

Complexity: 9/10

**Risks:**
- Multiple type aliases increase risk of naming conflicts during refactoring

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 4

## 12. Repositories

Complexity: 9/10

**Risks:**
- High number of dependencies increases chance of circular dependencies

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 3

## 13. UmbraCoreTypes

Complexity: 6/10

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 2

## 14. Resources

Complexity: 5/10

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 15. SecurityInterfacesBase

Complexity: 5/10

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 16. SecureBytes

Complexity: 3/10

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

## 17. SecurityTypes

Complexity: 3/10

**Current Structure:**
- Isolation Files: 0
- Type Aliases: 1

