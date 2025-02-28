# UmbraCore Phase 1 Implementation Plan

This document outlines the specific steps for implementing Phase 1 of the UmbraCore refactoring plan: the restructuring of protocol definitions with a clear separation between Sources and Tests.

## 1. Create SecurityInterfacesBase Module in Sources

### 1.1 Create Directory Structure

```bash
mkdir -p Sources/SecurityInterfacesBase
```

### 1.2 Create BUILD.bazel for SecurityInterfacesBase

Create a new BUILD.bazel file in the SecurityInterfacesBase directory with minimal dependencies:

```python
load("//:bazel/macros/swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "SecurityInterfacesBase",
    srcs = [
        "XPCServiceBaseProtocol.swift",
        "XPCServiceProtocolDefinition.swift",
    ],
    additional_copts = [],
    deps = [
        "//Sources/CoreTypes",
    ],
    visibility = ["//visibility:public"],
)
```

### 1.3 Create Base XPC Protocol

Create a new file called `XPCServiceBaseProtocol.swift` in SecurityInterfacesBase:

```swift
import Foundation

/// Base protocol for XPC service interfaces
/// Provides minimal Foundation dependencies
@objc public protocol XPCServiceBaseProtocol: NSObjectProtocol, Sendable {
    // Basic functionality all XPC services need
}

// Use extensions to provide NSObjectProtocol conformance
extension XPCServiceBaseProtocol {
    // Extension methods to aid conformance
}
```

### 1.4 Move XPCServiceProtocolDefinition

Create `XPCServiceProtocolDefinition.swift` in SecurityInterfacesBase with a cleaner definition that inherits from XPCServiceBaseProtocol:

```swift
import Foundation

/// Protocol defining the XPC service interface for key management
@objc public protocol XPCServiceProtocolDefinition: XPCServiceBaseProtocol {
    /// Base method to test connectivity
    @objc func ping(withReply reply: @escaping (Bool, Error?) -> Void)

    /// Synchronize keys across processes with raw bytes using NSData
    /// - Parameter data: The key data to synchronize
    @objc func synchroniseKeys(_ data: NSData, withReply reply: @escaping (Error?) -> Void)

    /// Reset all security data
    @objc func resetSecurityData(withReply reply: @escaping (Error?) -> Void)

    /// Get the XPC service version
    @objc func getVersion(withReply reply: @escaping (NSString?, Error?) -> Void)

    /// Get the host identifier
    @objc func getHostIdentifier(withReply reply: @escaping (NSString?, Error?) -> Void)
    
    /// Register a client application
    @objc func registerClient(clientId: NSString, withReply reply: @escaping (Bool, Error?) -> Void)

    /// Deregister a client application
    @objc func deregisterClient(clientId: NSString, withReply reply: @escaping (Bool, Error?) -> Void)

    /// Check if a client is registered
    @objc func isClientRegistered(clientId: NSString, withReply reply: @escaping (Bool, Error?) -> Void)
}
```

## 2. Update SecurityInterfaces Module in Sources

### 2.1 Update SecurityInterfaces BUILD.bazel

Modify the existing SecurityInterfaces BUILD.bazel to depend on the new SecurityInterfacesBase:

```python
load("//:bazel/macros/swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "SecurityInterfaces",
    srcs = [
        "SecurityInterfaces.swift",
        "SecurityProvider.swift",
        "SecurityProviderBase.swift",
        "SecurityProviderFoundation.swift",
        "XPCServiceProtocol.swift",
    ],
    additional_copts = [],
    deps = [
        "//Sources/CoreTypes",
        "//Sources/SecurityInterfacesBase",
        "//Sources/SecurityTypes",
    ],
    visibility = ["//visibility:public"],
)
```

### 2.2 Update XPCServiceProtocol.swift

Update the protocol to use the new base:

```swift
import Foundation
import SecurityInterfacesBase

/// The protocol for the XPC service
public typealias XPCServiceProtocol = XPCServiceProtocolDefinition
```

### 2.3 Remove Obsolete Files from Sources

- Remove Sources/SecurityInterfaces/XPCServiceProtocolBase.swift
- Remove Sources/SecurityInterfaces/XPCServiceProtocolDefinitionBase.swift

## 3. Update Core Services in Sources

### 3.1 Update XPCServiceProtocolAlias.swift

```swift
import Foundation
import SecurityInterfacesBase

/// Alias for the XPC service protocol
public typealias XPCServiceProtocol = XPCServiceProtocolDefinition
```

### 3.2 Update Core/Services BUILD.bazel Dependencies

Make sure Core/Services BUILD.bazel references SecurityInterfacesBase instead of SecurityInterfaces for protocol definitions:

```python
load("//:bazel/macros/swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "CoreServices",
    srcs = glob([
        "*.swift",
        "TypeAliases/*.swift",
    ]),
    additional_copts = [],
    deps = [
        "//Sources/CoreServicesTypes",
        "//Sources/CoreTypes",
        "//Sources/SecurityInterfacesBase",  # Updated dependency
        # Other dependencies as needed
    ],
    visibility = ["//visibility:public"],
)
```

## 4. Create Umbrella Targets

### 4.1 Add to Root BUILD.bazel

Add umbrella targets to the root BUILD.bazel for building Sources and Tests separately:

```python
umbrella_target(
    name = "umbracore_sources",
    deps = [
        "//Sources/API",
        "//Sources/Core",
        "//Sources/CoreServicesTypes",
        "//Sources/CoreTypes",
        "//Sources/SecurityInterfaces",
        "//Sources/SecurityInterfacesBase",
        # Other production modules
    ],
)

umbrella_target(
    name = "umbracore_tests",
    deps = [
        "//Tests/CoreTests",
        "//Tests/UmbraSecurityTests",
        # Other test modules
    ],
)
```

## 5. Test the Changes

### 5.1 Build Production Code Only

```bash
# Build just the new module
bazel build //Sources/SecurityInterfacesBase --platforms=//:macos_arm64

# Build affected modules
bazel build //Sources/SecurityInterfaces --platforms=//:macos_arm64
bazel build //Sources/Core/Services:CoreServices --platforms=//:macos_arm64

# Build all Sources
bazel build //Sources/... --platforms=//:macos_arm64
```

### 5.2 Verify Tests Still Work with New Structure

```bash
# Run relevant tests
bazel test //Tests/CoreTests --platforms=//:macos_arm64
bazel test //Tests/UmbraSecurityTests --platforms=//:macos_arm64

# Or run all tests
bazel test //Tests/... --platforms=//:macos_arm64
```

### 5.3 Verify No Circular Dependencies

```bash
# Check for circular dependencies between critical modules
bazel query "allpaths(//Sources/SecurityInterfacesBase, //Sources/SecurityInterfaces)"
bazel query "allpaths(//Sources/SecurityInterfaces, //Sources/SecurityInterfacesBase)"
```

## 6. Commit Changes

Once verified that both Sources and Tests build properly, commit the changes with a clear description of the architectural improvements made.
