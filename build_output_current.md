INFO: Invocation ID: 320a320f-c968-4523-9699-6059bddd8be8
Computing main repo mapping: 
Loading: 
Loading: 0 packages loaded
Analyzing: 171 targets (0 packages loaded, 0 targets configured)
Analyzing: 171 targets (0 packages loaded, 0 targets configured)

INFO: Analyzed 171 targets (0 packages loaded, 0 targets configured).
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

Sources/ErrorHandling/Notification/ErrorNotification.swift:135:28: warning: conditional cast from 'any Error' to 'NSError' always succeeds
133 |     let domain: String
134 |     
135 |     if let nsError = error as? NSError {
    |                            `- warning: conditional cast from 'any Error' to 'NSError' always succeeds
136 |       domain = nsError.domain
137 |     } else if let customError = error as? any CustomStringConvertible {

Sources/ErrorHandling/Notification/ErrorNotification.swift:137:39: warning: conditional cast from 'any Error' to 'any CustomStringConvertible' always succeeds
135 |     if let nsError = error as? NSError {
136 |       domain = nsError.domain
137 |     } else if let customError = error as? any CustomStringConvertible {
    |                                       `- warning: conditional cast from 'any Error' to 'any CustomStringConvertible' always succeeds
138 |       domain = String(describing: type(of: customError))
139 |     } else {
[6 / 322] [Prepa] Linking Sources/ErrorHandling/libErrorHandling.a
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
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:42:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 40 | 
 41 |   /// Sample recovery provider for demonstration purposes
 42 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
    |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 43 |     /// Provides recovery options for security errors
 44 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:44:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 42 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
 43 |     /// Provides recovery options for security errors
 44 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
    |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 45 |       // Map to security error if possible
 46 |       if let securityError=error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:165:44: error: cannot find type 'ErrorHandlingNotification' in scope
163 | extension ErrorHandlingExample {
164 |   /// Create an example notification for demonstration
165 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
    |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
166 |     let securityError=SecurityCoreErrorWrapper(
167 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:113:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
111 |     // Try to map to security error
112 |     // Remove the try? since it doesn't throw
113 |     if let securityMapper=SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
114 |       // Check if the map method exists
115 |       if let securityError=securityMapper.mapFromAny(externalError) {
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:42:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 40 | 
 41 |   /// Sample recovery provider for demonstration purposes
 42 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
    |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 43 |     /// Provides recovery options for security errors
 44 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:44:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 42 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
 43 |     /// Provides recovery options for security errors
 44 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
    |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 45 |       // Map to security error if possible
 46 |       if let securityError=error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:165:44: error: cannot find type 'ErrorHandlingNotification' in scope
163 | extension ErrorHandlingExample {
164 |   /// Create an example notification for demonstration
165 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
    |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
166 |     let securityError=SecurityCoreErrorWrapper(
167 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:54:17: error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 52 |               RecoveryOption(title: "Try Backup Key", action: { print("Using backup key...") })
 53 |             ])
 54 |           case .keyNotFound:
    |                 `- error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 55 |             return RecoveryOptions(actions: [
 56 |               RecoveryOption(title: "Create New Key", action: { print("Creating new key...") }),

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:80:43: error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
 78 |     let errorHandler=ErrorHandler.shared
 79 |     errorHandler.setNotificationHandler(SampleNotificationHandler())
 80 |     errorHandler.registerRecoveryProvider(SampleRecoveryProvider())
    |                                           `- error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
 81 | 
 82 |     print("Starting error handling demonstration...")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:92:26: error: value of type 'ErrorHandler' has no member 'reportError'
 90 |     // Report the error
 91 |     Task {
 92 |       await errorHandler.reportError(wrappedError)
    |                          `- error: value of type 'ErrorHandler' has no member 'reportError'
 93 |       print("Security error handled.")
 94 | 

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:113:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
111 |     // Try to map to security error
112 |     // Remove the try? since it doesn't throw
113 |     if let securityMapper=SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
114 |       // Check if the map method exists
115 |       if let securityError=securityMapper.mapFromAny(externalError) {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:143:35: warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
141 |     print("Error code: \(securityError.code)")
142 |     print("Error description: \(securityError.errorDescription)")
143 |     print("Recovery suggestion: \(securityError.recoverySuggestion)")
    |                                   |             |- note: use 'String(describing:)' to silence this warning
    |                                   |             `- note: provide a default value to avoid this warning
    |                                   `- warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
144 | 
145 |     // Add context to the error

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:236:20: error: extra argument 'severity' in call
234 |         title: "Security Alert",
235 |         message: securityError.errorDescription,
236 |         severity: .critical,
    |                    `- error: extra argument 'severity' in call
237 |         recoveryOptions: recoveryOptions?.actions
238 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:237:43: error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
235 |         message: securityError.errorDescription,
236 |         severity: .critical,
237 |         recoveryOptions: recoveryOptions?.actions
    |                                           |- error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
    |                                           |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                           `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
238 |       )
239 |     } else if let securityError=error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:236:20: error: cannot infer contextual base in reference to member 'critical'
234 |         title: "Security Alert",
235 |         message: securityError.errorDescription,
236 |         severity: .critical,
    |                    `- error: cannot infer contextual base in reference to member 'critical'
237 |         recoveryOptions: recoveryOptions?.actions
238 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:245:20: error: extra argument 'severity' in call
243 |         title: "Security Alert",
244 |         message: securityError.errorDescription,
245 |         severity: .critical,
    |                    `- error: extra argument 'severity' in call
246 |         recoveryOptions: recoveryOptions?.actions
247 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:246:43: error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
244 |         message: securityError.errorDescription,
245 |         severity: .critical,
246 |         recoveryOptions: recoveryOptions?.actions
    |                                           |- error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
    |                                           |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                           `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
247 |       )
248 |     } else {

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:245:20: error: cannot infer contextual base in reference to member 'critical'
243 |         title: "Security Alert",
244 |         message: securityError.errorDescription,
245 |         severity: .critical,
    |                    `- error: cannot infer contextual base in reference to member 'critical'
246 |         recoveryOptions: recoveryOptions?.actions
247 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:254:20: error: extra argument 'severity' in call
252 |         title: "Security Alert",
253 |         message: String(describing: error),
254 |         severity: .warning,
    |                    `- error: extra argument 'severity' in call
255 |         recoveryOptions: recoveryOptions?.actions
256 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:255:43: error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
253 |         message: String(describing: error),
254 |         severity: .warning,
255 |         recoveryOptions: recoveryOptions?.actions
    |                                           |- error: value of optional type '[ClosureRecoveryOption]?' must be unwrapped to a value of type '[ClosureRecoveryOption]'
    |                                           |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                           `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
256 |       )
257 |     }

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:254:20: error: cannot infer contextual base in reference to member 'warning'
252 |         title: "Security Alert",
253 |         message: String(describing: error),
254 |         severity: .warning,
    |                    `- error: cannot infer contextual base in reference to member 'warning'
255 |         recoveryOptions: recoveryOptions?.actions
256 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:366:57: error: no type named 'NotificationSeverity' in module 'ErrorHandlingNotification'
364 |   ) -> ErrorHandlingNotification.ErrorNotification {
365 |     // Convert ErrorSeverity to NotificationSeverity
366 |     let notificationSeverity: ErrorHandlingNotification.NotificationSeverity=switch severity {
    |                                                         `- error: no type named 'NotificationSeverity' in module 'ErrorHandlingNotification'
367 |       case .critical:
368 |         .critical

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:387:57: error: extra arguments at positions #4, #6 in call
385 |       let errorTitle="Security Error"
386 | 
387 |       return ErrorHandlingNotification.ErrorNotification(
    |                                                         `- error: extra arguments at positions #4, #6 in call
388 |         error: securityError,
389 |         title: errorTitle,

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Notification/ErrorNotification.swift:63:10: note: 'init(error:title:message:recoveryOptions:)' declared here
 61 |   ///   - message: Message body of the notification
 62 |   ///   - recoveryOptions: Options for recovering from the error
 63 |   public init(
    |          `- note: 'init(error:title:message:recoveryOptions:)' declared here
 64 |     error: Error,
 65 |     title: String,

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:392:26: error: 'nil' is not compatible with expected argument type '[ClosureRecoveryOption]'
390 |         message: errorMessage,
391 |         severity: notificationSeverity,
392 |         recoveryOptions: nil,
    |                          `- error: 'nil' is not compatible with expected argument type '[ClosureRecoveryOption]'
393 |         timestamp: Date()
394 |       )

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:397:57: error: extra arguments at positions #4, #6 in call
395 |     } else {
396 |       // Handle non-security errors
397 |       return ErrorHandlingNotification.ErrorNotification(
    |                                                         `- error: extra arguments at positions #4, #6 in call
398 |         error: error,
399 |         title: "Error",

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Notification/ErrorNotification.swift:63:10: note: 'init(error:title:message:recoveryOptions:)' declared here
 61 |   ///   - message: Message body of the notification
 62 |   ///   - recoveryOptions: Options for recovering from the error
 63 |   public init(
    |          `- note: 'init(error:title:message:recoveryOptions:)' declared here
 64 |     error: Error,
 65 |     title: String,

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:402:26: error: 'nil' is not compatible with expected argument type '[ClosureRecoveryOption]'
400 |         message: String(describing: error),
401 |         severity: notificationSeverity,
402 |         recoveryOptions: nil,
    |                          `- error: 'nil' is not compatible with expected argument type '[ClosureRecoveryOption]'
403 |         timestamp: Date()
404 |       )
[27 / 322] [Sched] Compiling Swift module //Sources/Testing:Testing ... (10 actions, 5 running)
[52 / 322] Compiling Swift module //Sources/UmbraCoreTypes/CoreErrors:UmbraCoreTypesCoreErrors; 0s disk-cache, worker ... (8 actions, 6 running)
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/ResticCLIHelper/Models/BUILD.bazel:4:20: Compiling Swift module //Sources/ResticCLIHelper/Models:ResticCLIHelperModels failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/ResticCLIHelper/Models:ResticCLIHelperModels) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/ResticCLIHelper/Models/ResticCLIHelperModels.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:39: error: unterminated string literal
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:39: error: unterminated string literal
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
177 | 
178 | 

Sources/ResticCLIHelper/Models/RepositoryObject.swift:16:14: warning: stored property 'type' of 'Sendable'-conforming struct 'RepositoryObject' has non-sendable type 'RepositoryObjectType'; this is an error in the Swift 6 language mode
 2 | 
 3 | /// Types of objects stored in a repository
 4 | public enum RepositoryObjectType: String, Codable {
   |             `- note: consider making enum 'RepositoryObjectType' conform to the 'Sendable' protocol
 5 |   case blob
 6 |   case pack
   :
14 | public struct RepositoryObject: Codable, Sendable {
15 |   /// Type of the object
16 |   public let type: RepositoryObjectType
   |              `- warning: stored property 'type' of 'Sendable'-conforming struct 'RepositoryObject' has non-sendable type 'RepositoryObjectType'; this is an error in the Swift 6 language mode
17 | 
18 |   /// Object ID

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:4: error: expected string literal in 'available' attribute
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:38: error: expected declaration
  3 | 
  4 | /// Represents a snapshot in the repository
  5 | public struct SnapshotInfo: Codable, Sendable {
    |               `- note: in declaration of 'SnapshotInfo'
  6 |   /// Timestamp of when the backup was started
  7 |   public let time: Date
    :
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:4: error: expected string literal in 'available' attribute
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
177 | 
178 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:38: error: expected declaration
111 | 
112 | /// Statistics for a snapshot
113 | public struct SnapshotSummary: Codable, Sendable {
    |               `- note: in declaration of 'SnapshotSummary'
114 |   /// Time at which the backup was started
115 |   public let backupStart: Date
    :
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
177 | 
178 | 
Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:4: error: expected string literal in 'available' attribute
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:38: error: expected declaration
  3 | 
  4 | /// Represents a snapshot in the repository
  5 | public struct SnapshotInfo: Codable, Sendable {
    |               `- note: in declaration of 'SnapshotInfo'
  6 |   /// Timestamp of when the backup was started
  7 |   public let time: Date
    :
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:68:39: error: unterminated string literal
 66 | 
 67 | 
 68 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
 69 | 
 70 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:4: error: expected string literal in 'available' attribute
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
177 | 
178 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:38: error: expected declaration
111 | 
112 | /// Statistics for a snapshot
113 | public struct SnapshotSummary: Codable, Sendable {
    |               `- note: in declaration of 'SnapshotSummary'
114 |   /// Time at which the backup was started
115 |   public let backupStart: Date
    :
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
177 | 
178 | 

Sources/ResticCLIHelper/Models/SnapshotInfo.swift:176:39: error: unterminated string literal
174 | 
175 | 
176 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
177 | 
178 | 

Sources/ResticCLIHelper/Models/RepositoryObject.swift:16:14: warning: stored property 'type' of 'Sendable'-conforming struct 'RepositoryObject' has non-sendable type 'RepositoryObjectType'; this is an error in the Swift 6 language mode
 2 | 
 3 | /// Types of objects stored in a repository
 4 | public enum RepositoryObjectType: String, Codable {
   |             `- note: consider making enum 'RepositoryObjectType' conform to the 'Sendable' protocol
 5 |   case blob
 6 |   case pack
   :
14 | public struct RepositoryObject: Codable, Sendable {
15 |   /// Type of the object
16 |   public let type: RepositoryObjectType
   |              `- warning: stored property 'type' of 'Sendable'-conforming struct 'RepositoryObject' has non-sendable type 'RepositoryObjectType'; this is an error in the Swift 6 language mode
17 | 
18 |   /// Object ID
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/UmbraCoreTypes/BUILD.bazel:3:14: Compiling Swift module //Sources/UmbraCoreTypes:UmbraCoreTypes failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/UmbraCoreTypes:UmbraCoreTypes) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/UmbraCoreTypes/UmbraCoreTypes.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:39: error: unterminated string literal
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
339 | 
340 |   public init(from decoder: Decoder) throws {

Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:4: error: expected string literal in 'available' attribute
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
339 | 
340 |   public init(from decoder: Decoder) throws {

Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:38: error: expected declaration
326 | // MARK: - Codable
327 | 
328 | extension SecureBytes {
    | `- note: in extension of 'SecureBytes'
329 |   /// Encodes this SecureBytes into the given encoder.
330 |   public func encode(to encoder: Encoder) throws {
    :
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
339 | 
340 |   public init(from decoder: Decoder) throws {
Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:4: error: expected string literal in 'available' attribute
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
339 | 
340 |   public init(from decoder: Decoder) throws {

Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:38: error: expected declaration
326 | // MARK: - Codable
327 | 
328 | extension SecureBytes {
    | `- note: in extension of 'SecureBytes'
329 |   /// Encodes this SecureBytes into the given encoder.
330 |   public func encode(to encoder: Encoder) throws {
    :
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
339 | 
340 |   public init(from decoder: Decoder) throws {

Sources/UmbraCoreTypes/Sources/SecureBytes.swift:338:39: error: unterminated string literal
336 |   @preconcurrency
337 | 
338 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
339 | 
340 |   public init(from decoder: Decoder) throws {
[145 / 313] [Sched] Compiling Swift module //Sources/SecurityUtils/Protocols:SecurityUtilsProtocols ... (6 actions, 5 running)
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/UmbraBookmarkService/BUILD.bazel:4:20: Compiling Swift module //Sources/UmbraBookmarkService:UmbraBookmarkService failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/UmbraBookmarkService:UmbraBookmarkService) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/UmbraBookmarkService/UmbraBookmarkService.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/UmbraBookmarkService/BookmarkService.swift:118:9: warning: capture of 'connectionToResume' with non-sendable type 'NSXPCConnection' in a `@Sendable` closure; this is an error in the Swift 6 language mode
116 |       // the weak reference without crossing actor boundaries
117 |       if let strongSelf=weakSelf {
118 |         connectionToResume.exportedObject=strongSelf
    |         `- warning: capture of 'connectionToResume' with non-sendable type 'NSXPCConnection' in a `@Sendable` closure; this is an error in the Swift 6 language mode
119 |         connectionToResume.resume()
120 |       }

Foundation.NSXPCConnection:2:12: note: class 'NSXPCConnection' does not conform to the 'Sendable' protocol
 1 | @available(macOS 10.8, *)
 2 | open class NSXPCConnection : NSObject, NSXPCProxyCreating {
   |            `- note: class 'NSXPCConnection' does not conform to the 'Sendable' protocol
 3 |     public init(serviceName: String)
 4 |     open var serviceName: String? { get }

Sources/UmbraBookmarkService/BookmarkService.swift:117:25: warning: reference to captured var 'weakSelf' in concurrently-executing code; this is an error in the Swift 6 language mode
115 |       // Since we're now in a MainActor-isolated context, we can safely access
116 |       // the weak reference without crossing actor boundaries
117 |       if let strongSelf=weakSelf {
    |                         `- warning: reference to captured var 'weakSelf' in concurrently-executing code; this is an error in the Swift 6 language mode
118 |         connectionToResume.exportedObject=strongSelf
119 |         connectionToResume.resume()

Sources/UmbraBookmarkService/BookmarkService.swift:111:7: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
109 |     // Using MainActor.run instead of // TODO: Swift 6 compatibility - refactor actor isolation
110 |       // Using MainActor.run instead of Task { @MainActor in }
111 |       MainActor.run { }
    |       `- error: 'async' call in a function that does not support concurrency
112 |     MainActor.run {}
113 |     MainActor.run {}

Sources/UmbraBookmarkService/BookmarkService.swift:112:5: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
110 |       // Using MainActor.run instead of Task { @MainActor in }
111 |       MainActor.run { }
112 |     MainActor.run {}
    |     `- error: 'async' call in a function that does not support concurrency
113 |     MainActor.run {}
114 |     MainActor.run {

Sources/UmbraBookmarkService/BookmarkService.swift:113:5: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
111 |       MainActor.run { }
112 |     MainActor.run {}
113 |     MainActor.run {}
    |     `- error: 'async' call in a function that does not support concurrency
114 |     MainActor.run {
115 |       // Since we're now in a MainActor-isolated context, we can safely access

Sources/UmbraBookmarkService/BookmarkService.swift:114:5: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
112 |     MainActor.run {}
113 |     MainActor.run {}
114 |     MainActor.run {
    |     `- error: 'async' call in a function that does not support concurrency
115 |       // Since we're now in a MainActor-isolated context, we can safely access
116 |       // the weak reference without crossing actor boundaries
INFO: From Compiling Swift module //Sources/Repositories:Repositories:
Sources/Repositories/FileSystemRepository.swift:145:10: warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
    |          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
146 |     let container=try decoder.container(keyedBy: CodingKeys.self)
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
146 |     let container=try decoder.container(keyedBy: CodingKeys.self)
147 |     // Decode all values before initialising properties for better error handling

Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
  |                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
[292 / 293] [Prepa] Linking Sources/Repositories/libRepositories.a
INFO: Build succeeded for only 82 of 171 top-level targets
INFO: Found 171 targets...
INFO: Elapsed time: 5.826s, Critical Path: 5.49s
INFO: 61 processes: 33 action cache hit, 5 internal, 13 local, 43 worker.
ERROR: Build did NOT complete successfully
