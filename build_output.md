INFO: Invocation ID: a20de4b1-f408-4750-8b7a-f7caf99c1f10
Computing main repo mapping: 
Loading: 
Loading: 0 packages loaded
Analyzing: 171 targets (0 packages loaded, 0 targets configured)
Analyzing: 171 targets (0 packages loaded, 0 targets configured)

Analyzing: 171 targets (3 packages loaded, 2484 targets configured)
[419 / 733] Compiling Swift module //Sources/CoreServicesTypes:CoreServicesTypes; 0s disk-cache, worker ... (7 actions, 5 running)
INFO: Analyzed 171 targets (3 packages loaded, 2496 targets configured).
INFO: From Compiling Swift module //Sources/ErrorHandling/Notification:ErrorHandlingNotification:
Sources/ErrorHandling/Notification/ErrorNotification.swift:16:15: warning: stored property 'action' of 'Sendable'-conforming struct 'ClosureRecoveryOption' has non-sendable type '() async throws -> Void'; this is an error in the Swift 6 language mode
 14 | 
 15 |   /// The action to perform for recovery
 16 |   private let action: () async throws -> Void
    |               |- warning: stored property 'action' of 'Sendable'-conforming struct 'ClosureRecoveryOption' has non-sendable type '() async throws -> Void'; this is an error in the Swift 6 language mode
    |               `- note: a function type must be marked '@Sendable' to conform to 'Sendable'
 17 | 
 18 |   /// Creates a new recovery option
Sources/ErrorHandling/Notification/ErrorNotification.swift:16:15: warning: stored property 'action' of 'Sendable'-conforming struct 'ClosureRecoveryOption' has non-sendable type '() async throws -> Void'; this is an error in the Swift 6 language mode
 14 | 
 15 |   /// The action to perform for recovery
 16 |   private let action: () async throws -> Void
    |               |- warning: stored property 'action' of 'Sendable'-conforming struct 'ClosureRecoveryOption' has non-sendable type '() async throws -> Void'; this is an error in the Swift 6 language mode
    |               `- note: a function type must be marked '@Sendable' to conform to 'Sendable'
 17 | 
 18 |   /// Creates a new recovery option

Sources/ErrorHandling/Notification/ErrorNotification.swift:135:49: warning: conditional cast from 'any Error' to 'NSError' always succeeds
133 |     recoveryOptions: [ClosureRecoveryOption]
134 |   ) async {
135 |     let domain: String = if let nsError = error as? NSError {
    |                                                 `- warning: conditional cast from 'any Error' to 'NSError' always succeeds
136 |       nsError.domain
137 |     } else if let customError = error as? any CustomStringConvertible {

Sources/ErrorHandling/Notification/ErrorNotification.swift:137:39: warning: conditional cast from 'any Error' to 'any CustomStringConvertible' always succeeds
135 |     let domain: String = if let nsError = error as? NSError {
136 |       nsError.domain
137 |     } else if let customError = error as? any CustomStringConvertible {
    |                                       `- warning: conditional cast from 'any Error' to 'any CustomStringConvertible' always succeeds
138 |       String(describing: type(of: customError))
139 |     } else {
[446 / 739] Compiling Swift module //Sources/ErrorHandling/Mapping:ErrorHandlingMapping; 0s disk-cache, worker ... (2 actions, 1 running)
[473 / 739] Compiling Swift module //Sources/Testing:Testing; 0s disk-cache, worker ... (9 actions, 5 running)
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/ErrorHandling/Utilities/BUILD.bazel:3:20: Compiling Swift module //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/ErrorHandling/Utilities/ErrorHandlingUtilities.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:43:65: error: no type named 'ErrorNotificationHandler' in module 'ErrorHandlingInterfaces'
 41 | 
 42 |   /// Sample recovery provider for demonstration purposes
 43 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorNotificationHandler {
    |                                                                 `- error: no type named 'ErrorNotificationHandler' in module 'ErrorHandlingInterfaces'
 44 |     /// Provides recovery options for security errors
 45 |     public func recoveryOptions(for error: Error)

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:136:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
134 |     // Try to map to security error
135 |     // Remove the try? since it doesn't throw
136 |     if let securityMapper = SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
137 |       // Check if the map method exists
138 |       if let securityError = securityMapper.mapFromAny(externalError) {
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:43:65: error: no type named 'ErrorNotificationHandler' in module 'ErrorHandlingInterfaces'
 41 | 
 42 |   /// Sample recovery provider for demonstration purposes
 43 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorNotificationHandler {
    |                                                                 `- error: no type named 'ErrorNotificationHandler' in module 'ErrorHandlingInterfaces'
 44 |     /// Provides recovery options for security errors
 45 |     public func recoveryOptions(for error: Error)

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:62:17: error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 60 |               )
 61 |             ]
 62 |           case .keyNotFound:
    |                 `- error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 63 |             return [
 64 |               ErrorHandlingNotification.ClosureRecoveryOption(

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:103:43: error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
101 |     let errorHandler = ErrorHandler.shared
102 |     errorHandler.setNotificationHandler(SampleNotificationHandler())
103 |     errorHandler.registerRecoveryProvider(SampleRecoveryProvider())
    |                                           `- error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
104 | 
105 |     print("Starting error handling demonstration...")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:115:26: error: value of type 'ErrorHandler' has no member 'reportError'
113 |     // Report the error
114 |     Task {
115 |       await errorHandler.reportError(wrappedError)
    |                          `- error: value of type 'ErrorHandler' has no member 'reportError'
116 |       print("Security error handled.")
117 | 

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:136:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
134 |     // Try to map to security error
135 |     // Remove the try? since it doesn't throw
136 |     if let securityMapper = SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
137 |       // Check if the map method exists
138 |       if let securityError = securityMapper.mapFromAny(externalError) {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:166:35: warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
164 |     print("Error code: \(securityError.code)")
165 |     print("Error description: \(securityError.errorDescription)")
166 |     print("Recovery suggestion: \(securityError.recoverySuggestion)")
    |                                   |             |- note: use 'String(describing:)' to silence this warning
    |                                   |             `- note: provide a default value to avoid this warning
    |                                   `- warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
167 | 
168 |     // Add context to the error

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:222:27: error: cannot find 'createRecoveryOptions' in scope
220 |   func createNotificationForUI(for error: Error) -> ErrorHandlingNotification.ErrorNotification {
221 |     // Create recovery options based on the error type
222 |     let recoveryOptions = createRecoveryOptions(for: error)
    |                           `- error: cannot find 'createRecoveryOptions' in scope
223 | 
224 |     // Use a conditional cast with explicit type to avoid ambiguity

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:225:38: error: cannot find type 'SecurityExternalError' in scope
223 | 
224 |     // Use a conditional cast with explicit type to avoid ambiguity
225 |     if let securityError = error as? SecurityExternalError {
    |                                      `- error: cannot find type 'SecurityExternalError' in scope
226 |       return ErrorHandlingNotification.ErrorNotification(
227 |         error: securityError,

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:388:9: warning: initialization of immutable value 'recoveryOptions' was never used; consider replacing with assignment to '_' or removing it
386 |   public static func handleExampleError(_ error: Error) {
387 |     // Create recovery options
388 |     let recoveryOptions = shared.addSecurityRecoveryOptions(
    |         `- warning: initialization of immutable value 'recoveryOptions' was never used; consider replacing with assignment to '_' or removing it
389 |       for: error,
390 |       retryAction: {
[505 / 739] Compiling Swift module //Sources/ResticCLIHelper/Models:ResticCLIHelperModels; 0s disk-cache, worker ... (5 actions running)
[537 / 739] [Sched] Compiling Swift module //Sources/XPCProtocolsCore:XPCProtocolsCore ... (9 actions, 5 running)
INFO: From Compiling Swift module //Sources/UmbraBookmarkService:UmbraBookmarkService:
Sources/UmbraBookmarkService/BookmarkService.swift:107:10: warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
105 |     // Use a detached task to handle MainActor-isolated work
106 |     // TODO: Swift 6 compatibility - refactor actor isolation
107 |     Task { @MainActor in
    |          `- warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
108 |       // Since we're now in a MainActor-isolated context, we can safely access
109 |       // the weak reference without crossing actor boundaries
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreTypesImplementation/BUILD.bazel:5:20: Compiling Swift module //Sources/CoreTypesImplementation:CoreTypesImplementation failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/CoreTypesImplementation:CoreTypesImplementation) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/CoreTypesImplementation/CoreTypesImplementation.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift:93:1: error: extraneous '}' at top level
91 | }
92 | 
93 | }
   | `- error: extraneous '}' at top level
Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift:93:1: error: extraneous '}' at top level
91 | }
92 | 
93 | }
   | `- error: extraneous '}' at top level

Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift:85:38: error: cannot find type 'ExternalError' in scope
83 |     
84 |     // Map based on error type
85 |     if let externalError = error as? ExternalError {
   |                                      `- error: cannot find type 'ExternalError' in scope
86 |         return CoreErrors.SecurityError.operationFailed(reason: externalError.reason)
87 |     }

Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift:86:41: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'operationFailed'
84 |     // Map based on error type
85 |     if let externalError = error as? ExternalError {
86 |         return CoreErrors.SecurityError.operationFailed(reason: externalError.reason)
   |                                         `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'operationFailed'
87 |     }
88 |     

Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift:90:37: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'operationFailed'
88 |     
89 |     // Default fallback
90 |     return CoreErrors.SecurityError.operationFailed(reason: error.localizedDescription)
   |                                     `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'operationFailed'
91 | }
92 | 
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/XPCProtocolsCore/BUILD.bazel:5:33: Compiling Swift module //Sources/XPCProtocolsCore:XPCProtocolsCore failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/XPCProtocolsCore:XPCProtocolsCore) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/XPCProtocolsCore/XPCProtocolsCore.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:75:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 73 |   /// Default implementation that returns a not implemented error
 74 |   public func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
 75 |     .failure(.operationFailed(reason: "Key synchronisation not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 76 |   }
 77 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:80:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 78 |   /// Default implementation that returns a not implemented error
 79 |   public func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
 80 |     .failure(.operationFailed(reason: "Encryption not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 81 |   }
 82 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:85:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 83 |   /// Default implementation that returns a not implemented error
 84 |   public func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
 85 |     .failure(.operationFailed(reason: "Decryption not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 86 |   }
 87 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:90:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 88 |   /// Default implementation that returns a not implemented error
 89 |   public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
 90 |     .failure(.operationFailed(reason: "Key generation not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 91 |   }
 92 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:98:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 96 |     bits _: Int
 97 |   ) async -> Result<SecureBytes, XPCSecurityError> {
 98 |     .failure(.operationFailed(reason: "Key generation with parameters not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
 99 |   }
100 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:103:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
101 |   /// Default implementation that returns a not implemented error
102 |   public func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
103 |     .failure(.operationFailed(reason: "Hashing not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
104 |   }
105 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:108:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
106 |   /// Default implementation that returns a not implemented error
107 |   public func exportKey(keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
108 |     .failure(.operationFailed(reason: "Key export not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
109 |   }
110 | 

Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift:116:15: error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
114 |     identifier _: String?
115 |   ) async -> Result<String, XPCSecurityError> {
116 |     .failure(.operationFailed(reason: "Key import not implemented"))
    |               `- error: type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC') has no member 'operationFailed'
117 |   }
118 | 
INFO: From Compiling Swift module //Sources/Repositories:Repositories:
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
    |          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
146 |     let container = try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
  |                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
    |          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
146 |     let container = try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
  |                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
[738 / 739] [Prepa] Linking Sources/Repositories/libRepositories.a
INFO: Build succeeded for only 89 of 171 top-level targets
INFO: Found 171 targets...
INFO: Elapsed time: 6.664s, Critical Path: 6.29s
INFO: 190 processes: 265 action cache hit, 53 disk cache hit, 42 internal, 44 local, 51 worker.
ERROR: Build did NOT complete successfully
