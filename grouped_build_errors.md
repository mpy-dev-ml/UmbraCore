# Grouped Build Errors

## Summary

- **Swift 6 Language Mode Warnings**: 6 issues
- **Missing Function Errors**: 8 issues
- **Type Conformance Issues**: 10 issues
- **Missing Member Errors**: 24 issues
- **Other Errors**: 27 issues

## Swift 6 Language Mode Warnings

### Actor Isolation (2 issues)

Sample of 2 issues:

**File**: `Sources/UmbraBookmarkService/BookmarkService.swift`
**Message**: Sources/UmbraBookmarkService/BookmarkService.swift:106:10: warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode

```
Analyzing: 171 targets (0 packages loaded, 0 targets configured)

INFO: From Compiling Swift module //Sources/UmbraBookmarkService:UmbraBookmarkService:
Sources/UmbraBookmarkService/BookmarkService.swift:106:10: warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
104 |
105 |     // Use a proper actor-isolated approach
106 |     Task { @MainActor in
```

**File**: `Unknown`
**Message**: |          `- warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode

```
104 |
105 |     // Use a proper actor-isolated approach
106 |     Task { @MainActor in
|          `- warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
107 |       // Since we're now in a MainActor-isolated context, we can safely access
108 |       // the weak reference without crossing actor boundaries
INFO: From Compiling Swift module //Sources/Repositories:Repositories:
```

### Non-Sendable Type (4 issues)

Sample of 3 issues:

**File**: `Sources/Repositories/FileSystemRepository.swift`
**Message**: Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode

```
107 |       // Since we're now in a MainActor-isolated context, we can safely access
108 |       // the weak reference without crossing actor boundaries
INFO: From Compiling Swift module //Sources/Repositories:Repositories:
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
```

**File**: `Unknown`
**Message**: |          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode

```
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
|          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
146 |     let container = try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

```

**File**: `Sources/Repositories/FileSystemRepository.swift`
**Message**: Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode

```
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
```

**Other affected files**:

- `Unknown`

## Missing Function Errors

### Missing Function: `Unknown` (4 issues)

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope

```
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
```

**File**: `Unknown`
**Message**: |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope

```
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
|                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope

```
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
```

**File**: `Unknown`
**Message**: |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope

```
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
|                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

```


### Missing Function: `externalErrorToCoreError` (4 issues)

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope

```
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope
13 |
14 |     let externalError = ExternalError(reason: "API call failed")
15 |     let mappedError = externalErrorToCoreError(externalError)
```

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: |                       `- error: cannot find 'externalErrorToCoreError' in scope

```
13 |
14 |     let externalError = ExternalError(reason: "API call failed")
15 |     let mappedError = externalErrorToCoreError(externalError)
|                       `- error: cannot find 'externalErrorToCoreError' in scope
16 |
17 |     // Check that we can convert the error to a string instead of checking for specific case
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope
```

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope

```
|                       `- error: cannot find 'externalErrorToCoreError' in scope
16 |
17 |     // Check that we can convert the error to a string instead of checking for specific case
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope
13 |
14 |     let externalError = ExternalError(reason: "API call failed")
15 |     let mappedError = externalErrorToCoreError(externalError)
```

**File**: `Unknown`
**Message**: |                       `- error: cannot find 'externalErrorToCoreError' in scope

```
13 |
14 |     let externalError = ExternalError(reason: "API call failed")
15 |     let mappedError = externalErrorToCoreError(externalError)
|                       `- error: cannot find 'externalErrorToCoreError' in scope
16 |
17 |     // Check that we can convert the error to a string instead of checking for specific case

```


## Type Conformance Issues

**File**: `Unknown`
**Message**: Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol

```
146 |     let container = try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
```

**File**: `Sources/Repositories/FileSystemRepository.swift`
**Message**: |                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol

```

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
```

**File**: `Unknown`
**Message**: Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol

```
146 |     let container = try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
```

**File**: `Unknown`
**Message**: |                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol

```

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/XPCProtocolsCore/BUILD.bazel:5:33: Compiling Swift module //Sources/XPCProtocolsCore:XPCProtocolsCore failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/XPCProtocolsCore:XPCProtocolsCore)
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:75:43: error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'

```
51 |           return RecoveryOptions(actions: [
52 |             RecoveryOption(title: "Create New Key", action: { print("Creating new key...") }),

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:75:43: error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
73 |     let errorHandler = ErrorHandler.shared
74 |     errorHandler.setNotificationHandler(SampleNotificationHandler())
75 |     errorHandler.registerRecoveryProvider(SampleRecoveryProvider())
```

**File**: `Unknown`
**Message**: |                                           `- error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'

```
73 |     let errorHandler = ErrorHandler.shared
74 |     errorHandler.setNotificationHandler(SampleNotificationHandler())
75 |     errorHandler.registerRecoveryProvider(SampleRecoveryProvider())
|                                           `- error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
76 |
77 |     print("Starting error handling demonstration...")

```

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:25:44: error: argument type '(String) -> UmbraErrors.Security.Core' does not conform to expected type 'Error'

```
16 |
17 |     // Check that we can convert the error to a string instead of checking for specific case

Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:25:44: error: argument type '(String) -> UmbraErrors.Security.Core' does not conform to expected type 'Error'
23 |     // When passing a CoreErrors.SecurityError, it should be returned unchanged
24 |     let originalError=CoreErrors.SecurityError.encryptionFailed
25 |     let mappedError=mapExternalToCoreError(originalError)
```

**File**: `Unknown`
**Message**: |                                            `- error: argument type '(String) -> UmbraErrors.Security.Core' does not conform to expected type 'Error'

```
23 |     // When passing a CoreErrors.SecurityError, it should be returned unchanged
24 |     let originalError=CoreErrors.SecurityError.encryptionFailed
25 |     let mappedError=mapExternalToCoreError(originalError)
|                                            `- error: argument type '(String) -> UmbraErrors.Security.Core' does not conform to expected type 'Error'
26 |
27 |     XCTAssertEqual(

```

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:27:5: error: type '(String) -> UmbraErrors.Security.Core' cannot conform to 'Equatable'

```
26 |
27 |     XCTAssertEqual(

Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:27:5: error: type '(String) -> UmbraErrors.Security.Core' cannot conform to 'Equatable'
25 |     let mappedError=mapExternalToCoreError(originalError)
26 |
27 |     XCTAssertEqual(
```

**File**: `Unknown`
**Message**: |     |- error: type '(String) -> UmbraErrors.Security.Core' cannot conform to 'Equatable'

```
25 |     let mappedError=mapExternalToCoreError(originalError)
26 |
27 |     XCTAssertEqual(
|     |- error: type '(String) -> UmbraErrors.Security.Core' cannot conform to 'Equatable'
|     |- note: only concrete types such as structs, enums and classes can conform to protocols
|     `- note: required by global function 'XCTAssertEqual(_:_:_:file:line:)' where 'T' = '(String) -> UmbraErrors.Security.Core'
28 |       originalError,
```


## Missing Member Errors

### XPCSecurityError -> notImplemented (16 issues)

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:74:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/XPCProtocolsCore/XPCProtocolsCore.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:74:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
72 |   /// Default implementation that returns a not implemented error
73 |   public func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
74 |     .failure(.notImplemented(reason: "Key synchronisation not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
72 |   /// Default implementation that returns a not implemented error
73 |   public func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
74 |     .failure(.notImplemented(reason: "Key synchronisation not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
75 |   }
76 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:79:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
75 |   }
76 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:79:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
77 |   /// Default implementation that returns a not implemented error
78 |   public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
79 |     .failure(.notImplemented(reason: "Encryption not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
77 |   /// Default implementation that returns a not implemented error
78 |   public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
79 |     .failure(.notImplemented(reason: "Encryption not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
80 |   }
81 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:84:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
80 |   }
81 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:84:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
82 |   /// Default implementation that returns a not implemented error
83 |   public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
84 |     .failure(.notImplemented(reason: "Decryption not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
82 |   /// Default implementation that returns a not implemented error
83 |   public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
84 |     .failure(.notImplemented(reason: "Decryption not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
85 |   }
86 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:89:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
85 |   }
86 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:89:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
87 |   /// Default implementation that returns a not implemented error
88 |   public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
89 |     .failure(.notImplemented(reason: "Key generation not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
87 |   /// Default implementation that returns a not implemented error
88 |   public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
89 |     .failure(.notImplemented(reason: "Key generation not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
90 |   }
91 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:97:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
90 |   }
91 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:97:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
95 |     bits _: Int
96 |   ) async -> Result<SecureBytes, XPCSecurityError> {
97 |     .failure(.notImplemented(reason: "Key generation with parameters not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
95 |     bits _: Int
96 |   ) async -> Result<SecureBytes, XPCSecurityError> {
97 |     .failure(.notImplemented(reason: "Key generation with parameters not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
98 |   }
99 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:102:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
98 |   }
99 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:102:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
100 |   /// Default implementation that returns a not implemented error
101 |   public func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
102 |     .failure(.notImplemented(reason: "Hashing not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
100 |   /// Default implementation that returns a not implemented error
101 |   public func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
102 |     .failure(.notImplemented(reason: "Hashing not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
103 |   }
104 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:107:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
103 |   }
104 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:107:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
105 |   /// Default implementation that returns a not implemented error
106 |   public func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
107 |     .failure(.notImplemented(reason: "Key export not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
105 |   /// Default implementation that returns a not implemented error
106 |   public func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
107 |     .failure(.notImplemented(reason: "Key export not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
108 |   }
109 |

```

**File**: `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift`
**Message**: Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:115:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
108 |   }
109 |

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:115:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
113 |     identifier _: String?
114 |   ) async -> Result<String, XPCSecurityError> {
115 |     .failure(.notImplemented(reason: "Key import not implemented"))
```

**File**: `Unknown`
**Message**: |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'

```
113 |     identifier _: String?
114 |   ) async -> Result<String, XPCSecurityError> {
115 |     .failure(.notImplemented(reason: "Key import not implemented"))
|               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'notImplemented'
116 |   }
117 |
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/ErrorHandling/Utilities/BUILD.bazel:3:20: Compiling Swift module //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities)
```


### UmbraErrors.Security.Core -> keyNotFound (2 issues)

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:50:15: error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'

```
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:50:15: error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
48 |             RecoveryOption(title: "Try Backup Key", action: { print("Using backup key...") })
49 |           ])
50 |         case .keyNotFound:
```

**File**: `Unknown`
**Message**: |               `- error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'

```
48 |             RecoveryOption(title: "Try Backup Key", action: { print("Using backup key...") })
49 |           ])
50 |         case .keyNotFound:
|               `- error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
51 |           return RecoveryOptions(actions: [
52 |             RecoveryOption(title: "Create New Key", action: { print("Creating new key...") }),

```


### ErrorHandler -> reportError (2 issues)

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:87:26: error: value of type 'ErrorHandler' has no member 'reportError'

```
76 |
77 |     print("Starting error handling demonstration...")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:87:26: error: value of type 'ErrorHandler' has no member 'reportError'
85 |     // Report the error
86 |     Task {
87 |       await errorHandler.reportError(wrappedError)
```

**File**: `Unknown`
**Message**: |                          `- error: value of type 'ErrorHandler' has no member 'reportError'

```
85 |     // Report the error
86 |     Task {
87 |       await errorHandler.reportError(wrappedError)
|                          `- error: value of type 'ErrorHandler' has no member 'reportError'
88 |       print("Security error handled.")
89 |

```


### SecurityError -> accessError (2 issues)

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:36:44: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'accessError'

```
28 |       originalError,
29 |       mappedError,

Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:36:44: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'accessError'
34 |   func testCoreToExternalErrorMapping() {
35 |     // Test mapping from CoreErrors.SecurityError back to a generic Error
36 |     let coreError=CoreErrors.SecurityError.accessError
```

**File**: `Unknown`
**Message**: |                                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'accessError'

```
34 |   func testCoreToExternalErrorMapping() {
35 |     // Test mapping from CoreErrors.SecurityError back to a generic Error
36 |     let coreError=CoreErrors.SecurityError.accessError
|                                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'accessError'
37 |     let mappedError=mapCoreToExternalError(coreError)
38 |

```


### SecureBytesError -> memoryAllocationFailed (2 issues)

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:57:39: error: type 'SecureBytesError' has no member 'memoryAllocationFailed'

```
37 |     let mappedError=mapCoreToExternalError(coreError)
38 |

Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:57:39: error: type 'SecureBytesError' has no member 'memoryAllocationFailed'
55 |
56 |     // Memory allocation failure
57 |     let allocError = SecureBytesError.memoryAllocationFailed
```

**File**: `Unknown`
**Message**: |                                       `- error: type 'SecureBytesError' has no member 'memoryAllocationFailed'

```
55 |
56 |     // Memory allocation failure
57 |     let allocError = SecureBytesError.memoryAllocationFailed
|                                       `- error: type 'SecureBytesError' has no member 'memoryAllocationFailed'
58 |     let mappedAllocError = mapSecureBytesToCoreError(allocError)
59 |
Analyzing: 171 targets (2 packages loaded, 329 targets configured)
```


## Other Errors

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: error: emit-module command failed with exit code 1 (use -v to see invocation)

```
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/ErrorHandling/Utilities/ErrorHandlingUtilities.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
36 |
37 |   /// Sample recovery provider for demonstration purposes
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'

```
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
36 |
37 |   /// Sample recovery provider for demonstration purposes
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
```

**File**: `Unknown`
**Message**: |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'

```
36 |
37 |   /// Sample recovery provider for demonstration purposes
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
|                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
|                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'

```
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
|                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {
```

**File**: `Unknown`
**Message**: |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'

```
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
|                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {

```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'

```
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'

```
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
|        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
109 |       // Check if the map method exists
110 |       if let securityError = securityMapper.mapFromAny(externalError) {
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'

```
|        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
109 |       // Check if the map method exists
110 |       if let securityError = securityMapper.mapFromAny(externalError) {
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
36 |
37 |   /// Sample recovery provider for demonstration purposes
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
```

**File**: `Unknown`
**Message**: |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'

```
36 |
37 |   /// Sample recovery provider for demonstration purposes
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
|                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
|                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'

```
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

```
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
|                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {
```

**File**: `Unknown`
**Message**: |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'

```
38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
39 |     /// Provides recovery options for security errors
40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
|                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
41 |       // Map to security error if possible
42 |       if let securityError = error as? SecurityCoreErrorWrapper {

```

**File**: `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift`
**Message**: Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'

```
88 |       print("Security error handled.")
89 |

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
```

**File**: `Unknown`
**Message**: |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'

```
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
|        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
109 |       // Check if the map method exists
110 |       if let securityError = securityMapper.mapFromAny(externalError) {

```

**File**: `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift`
**Message**: Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:234:14: error: type of expression is ambiguous without a type annotation

```
139 |
140 |     // Add context to the error

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:234:14: error: type of expression is ambiguous without a type annotation
232 |       // Wrap the core error in our conforming wrapper
233 |       let securityError = SecurityCoreErrorWrapper(coreError)
234 |       return ErrorHandlingNotification.ErrorNotification(
```

**File**: `Unknown`
**Message**: |              `- error: type of expression is ambiguous without a type annotation

```
232 |       // Wrap the core error in our conforming wrapper
233 |       let securityError = SecurityCoreErrorWrapper(coreError)
234 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
235 |         error: securityError,
236 |         title: "Security Alert",

```

**File**: `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift`
**Message**: 235 |         error: securityError,

```
233 |       let securityError = SecurityCoreErrorWrapper(coreError)
234 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
235 |         error: securityError,
236 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:243:14: error: type of expression is ambiguous without a type annotation
```

**File**: `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift`
**Message**: Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:243:14: error: type of expression is ambiguous without a type annotation

```
235 |         error: securityError,
236 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:243:14: error: type of expression is ambiguous without a type annotation
241 |     } else if let securityError = error as? SecurityCoreErrorWrapper {
242 |       // Already a wrapped error
243 |       return ErrorHandlingNotification.ErrorNotification(
```

**File**: `Unknown`
**Message**: |              `- error: type of expression is ambiguous without a type annotation

```
241 |     } else if let securityError = error as? SecurityCoreErrorWrapper {
242 |       // Already a wrapped error
243 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
244 |         error: securityError,
245 |         title: "Security Alert",

```

**File**: `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift`
**Message**: 244 |         error: securityError,

```
242 |       // Already a wrapped error
243 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
244 |         error: securityError,
245 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:252:14: error: type of expression is ambiguous without a type annotation
```

**File**: `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift`
**Message**: Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:252:14: error: type of expression is ambiguous without a type annotation

```
244 |         error: securityError,
245 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:252:14: error: type of expression is ambiguous without a type annotation
250 |     } else {
251 |       // Not a security error, or couldn't be mapped
252 |       return ErrorHandlingNotification.ErrorNotification(
```

**File**: `Unknown`
**Message**: |              `- error: type of expression is ambiguous without a type annotation

```
250 |     } else {
251 |       // Not a security error, or couldn't be mapped
252 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
253 |         error: error,
254 |         title: "Security Alert",
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypesImplementation/Tests/BUILD.bazel:4:17: Compiling Swift module //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests)
```

**File**: `Unknown`
**Message**: 253 |         error: error,

```
251 |       // Not a security error, or couldn't be mapped
252 |       return ErrorHandlingNotification.ErrorNotification(
|              `- error: type of expression is ambiguous without a type annotation
253 |         error: error,
254 |         title: "Security Alert",
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypesImplementation/Tests/BUILD.bazel:4:17: Compiling Swift module //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests)
(cd /Users/mpy/.bazel/execroot/_main && \
```

**File**: `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift`
**Message**: error: emit-module command failed with exit code 1 (use -v to see invocation)

```
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/CoreTypesImplementation/Tests/Sources_CoreTypesImplementation_Tests_CoreTypesImplementationTests.swiftmodule-0.params)
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:15:23: error: cannot find 'externalErrorToCoreError' in scope
13 |
14 |     let externalError = ExternalError(reason: "API call failed")
```


