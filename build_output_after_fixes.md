INFO: Invocation ID: e1c1f76c-e3ec-4424-9f03-a80ef98c885a
Computing main repo mapping: 
Loading: 
Loading: 0 packages loaded
Analyzing: 171 targets (0 packages loaded, 0 targets configured)
Analyzing: 171 targets (0 packages loaded, 0 targets configured)

INFO: Analyzed 171 targets (0 packages loaded, 0 targets configured).
[7 / 322] [Prepa] Compiling Swift module //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/Core/Services/Types/BUILD.bazel:4:20: Compiling Swift module //Sources/Core/Services/Types:CoreServicesTypes failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/Core/Services/Types:CoreServicesTypes) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/Core/Services/Types/CoreServicesTypes.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/Core/Services/Types/KeyStatus.swift:62:39: error: unterminated string literal
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                       `- error: unterminated string literal
63 | 
64 | 

Sources/Core/Services/Types/KeyStatus.swift:62:4: error: expected string literal in 'available' attribute
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |    `- error: expected string literal in 'available' attribute
63 | 
64 | 

Sources/Core/Services/Types/KeyStatus.swift:62:38: error: expected declaration
28 | }
29 | 
30 | extension KeyStatus: Codable {
   | `- note: in extension of 'KeyStatus'
31 |   private enum CodingKeys: String, CodingKey {
32 |     case type
   :
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                      `- error: expected declaration
63 | 
64 | 
Sources/Core/Services/Types/KeyStatus.swift:62:4: error: expected string literal in 'available' attribute
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |    `- error: expected string literal in 'available' attribute
63 | 
64 | 

Sources/Core/Services/Types/KeyStatus.swift:62:38: error: expected declaration
28 | }
29 | 
30 | extension KeyStatus: Codable {
   | `- note: in extension of 'KeyStatus'
31 |   private enum CodingKeys: String, CodingKey {
32 |     case type
   :
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                      `- error: expected declaration
63 | 
64 | 

Sources/Core/Services/Types/KeyStatus.swift:62:39: error: unterminated string literal
60 | 
61 | 
62 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                       `- error: unterminated string literal
63 | 
64 | 
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
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 36 |   
 37 |   /// Sample recovery provider for demonstration purposes
 38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
    |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 39 |     /// Provides recovery options for security errors
 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
 39 |     /// Provides recovery options for security errors
 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
    |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 41 |       // Map to security error if possible
 42 |       if let securityError = error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
    |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
109 |       // Check if the map method exists
110 |       if let securityError = securityMapper.mapFromAny(externalError) {
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:38:65: error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 36 |   
 37 |   /// Sample recovery provider for demonstration purposes
 38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
    |                                                                 `- error: no type named 'ErrorRecoveryProtocol' in module 'ErrorHandlingInterfaces'
 39 |     /// Provides recovery options for security errors
 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:40:78: error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 38 |   private class SampleRecoveryProvider: ErrorHandlingInterfaces.ErrorRecoveryProtocol {
 39 |     /// Provides recovery options for security errors
 40 |     public func recoveryOptions(for error: Error) -> ErrorHandlingInterfaces.RecoveryOptions? {
    |                                                                              `- error: no type named 'RecoveryOptions' in module 'ErrorHandlingInterfaces'
 41 |       // Map to security error if possible
 42 |       if let securityError = error as? SecurityCoreErrorWrapper {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:160:44: error: cannot find type 'ErrorHandlingNotification' in scope
158 | extension ErrorHandlingExample {
159 |   /// Create an example notification for demonstration
160 |   private func createDemoNotification() -> ErrorHandlingNotification.ErrorNotification {
    |                                            `- error: cannot find type 'ErrorHandlingNotification' in scope
161 |     let securityError = SecurityCoreErrorWrapper(
162 |       UmbraErrors.Security.Core.invalidKey(reason: "Expired key")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:50:15: error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 48 |             RecoveryOption(title: "Try Backup Key", action: { print("Using backup key...") })
 49 |           ])
 50 |         case .keyNotFound:
    |               `- error: type 'UmbraErrors.Security.Core' has no member 'keyNotFound'
 51 |           return RecoveryOptions(actions: [
 52 |             RecoveryOption(title: "Create New Key", action: { print("Creating new key...") }),

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:75:43: error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
 73 |     let errorHandler = ErrorHandler.shared
 74 |     errorHandler.setNotificationHandler(SampleNotificationHandler())
 75 |     errorHandler.registerRecoveryProvider(SampleRecoveryProvider())
    |                                           `- error: argument type 'ErrorHandlingExample.SampleRecoveryProvider' does not conform to expected type 'RecoveryOptionsProvider'
 76 |     
 77 |     print("Starting error handling demonstration...")

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:87:26: error: value of type 'ErrorHandler' has no member 'reportError'
 85 |     // Report the error
 86 |     Task {
 87 |       await errorHandler.reportError(wrappedError)
    |                          `- error: value of type 'ErrorHandler' has no member 'reportError'
 88 |       print("Security error handled.")
 89 |       

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:108:8: error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
106 |     // Try to map to security error
107 |     // Remove the try? since it doesn't throw
108 |     if let securityMapper = SecurityErrorMapper() {
    |        `- error: initializer for conditional binding must have Optional type, not 'SecurityErrorMapper'
109 |       // Check if the map method exists
110 |       if let securityError = securityMapper.mapFromAny(externalError) {

Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:138:35: warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
136 |     print("Error code: \(securityError.code)")
137 |     print("Error description: \(securityError.errorDescription)")
138 |     print("Recovery suggestion: \(securityError.recoverySuggestion)")
    |                                   |             |- note: use 'String(describing:)' to silence this warning
    |                                   |             `- note: provide a default value to avoid this warning
    |                                   `- warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?
139 |     
140 |     // Add context to the error

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:234:14: error: type of expression is ambiguous without a type annotation
232 |       // Wrap the core error in our conforming wrapper
233 |       let securityError = SecurityCoreErrorWrapper(coreError)
234 |       return ErrorHandlingNotification.ErrorNotification(
    |              `- error: type of expression is ambiguous without a type annotation
235 |         error: securityError,
236 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:243:14: error: type of expression is ambiguous without a type annotation
241 |     } else if let securityError = error as? SecurityCoreErrorWrapper {
242 |       // Already a wrapped error
243 |       return ErrorHandlingNotification.ErrorNotification(
    |              `- error: type of expression is ambiguous without a type annotation
244 |         error: securityError,
245 |         title: "Security Alert",

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:252:14: error: type of expression is ambiguous without a type annotation
250 |     } else {
251 |       // Not a security error, or couldn't be mapped
252 |       return ErrorHandlingNotification.ErrorNotification(
    |              `- error: type of expression is ambiguous without a type annotation
253 |         error: error,
254 |         title: "Security Alert",
[27 / 322] [Sched] Compiling Swift module //Sources/TestUtils:TestUtils ... (10 actions, 5 running)
[54 / 322] Compiling Swift module //Tests/ResticTypesTests:ResticTypesTests; 0s disk-cache, worker ... (12 actions, 6 running)
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
[239 / 302] Compiling Swift module //Sources/ResticCLIHelper/Models:ResticCLIHelperModels; 0s disk-cache, worker ... (6 actions running)
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
Sources/UmbraBookmarkService/BookmarkService.swift:114:9: warning: capture of 'connectionToResume' with non-sendable type 'NSXPCConnection' in a `@Sendable` closure; this is an error in the Swift 6 language mode
112 |       // the weak reference without crossing actor boundaries
113 |       if let strongSelf = weakSelf {
114 |         connectionToResume.exportedObject = strongSelf
    |         `- warning: capture of 'connectionToResume' with non-sendable type 'NSXPCConnection' in a `@Sendable` closure; this is an error in the Swift 6 language mode
115 |         connectionToResume.resume()
116 |       }

Foundation.NSXPCConnection:2:12: note: class 'NSXPCConnection' does not conform to the 'Sendable' protocol
 1 | @available(macOS 10.8, *)
 2 | open class NSXPCConnection : NSObject, NSXPCProxyCreating {
   |            `- note: class 'NSXPCConnection' does not conform to the 'Sendable' protocol
 3 |     public init(serviceName: String)
 4 |     open var serviceName: String? { get }

Sources/UmbraBookmarkService/BookmarkService.swift:113:27: warning: reference to captured var 'weakSelf' in concurrently-executing code; this is an error in the Swift 6 language mode
111 |       // Since we're now in a MainActor-isolated context, we can safely access
112 |       // the weak reference without crossing actor boundaries
113 |       if let strongSelf = weakSelf {
    |                           `- warning: reference to captured var 'weakSelf' in concurrently-executing code; this is an error in the Swift 6 language mode
114 |         connectionToResume.exportedObject = strongSelf
115 |         connectionToResume.resume()

Sources/UmbraBookmarkService/BookmarkService.swift:109:7: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
107 |       // Using MainActor.run instead of // TODO: Swift 6 compatibility - refactor actor isolation
108 |       // Using MainActor.run instead of Task { @MainActor in }
109 |       MainActor.run { }
    |       `- error: 'async' call in a function that does not support concurrency
110 |       MainActor.run {
111 |       // Since we're now in a MainActor-isolated context, we can safely access

Sources/UmbraBookmarkService/BookmarkService.swift:110:7: error: 'async' call in a function that does not support concurrency
 91 | 
 92 | extension BookmarkService: NSXPCListenerDelegate {
 93 |   public nonisolated func listener(
    |                           `- note: add 'async' to function 'listener(_:shouldAcceptNewConnection:)' to make it asynchronous
 94 |     _: NSXPCListener,
 95 |     shouldAcceptNewConnection newConnection: NSXPCConnection
    :
108 |       // Using MainActor.run instead of Task { @MainActor in }
109 |       MainActor.run { }
110 |       MainActor.run {
    |       `- error: 'async' call in a function that does not support concurrency
111 |       // Since we're now in a MainActor-isolated context, we can safely access
112 |       // the weak reference without crossing actor boundaries
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/Repositories/Types/BUILD.bazel:4:20: Compiling Swift module //Sources/Repositories/Types:RepositoriesTypes failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/Repositories/Types:RepositoriesTypes) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/Repositories/Types/RepositoriesTypes.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/Repositories/Types/RepositoryError.swift:142:39: error: unterminated string literal
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
143 | 
144 | 

Sources/Repositories/Types/RepositoryState.swift:59:39: error: unterminated string literal
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                       `- error: unterminated string literal
60 | 
61 | 

Sources/Repositories/Types/RepositoryState.swift:59:4: error: expected string literal in 'available' attribute
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |    `- error: expected string literal in 'available' attribute
60 | 
61 | 

Sources/Repositories/Types/RepositoryState.swift:59:38: error: expected declaration
 6 | /// This enum represents the various states a repository can be in during
 7 | /// its lifecycle, from initialization through active use.
 8 | public enum RepositoryState: Equatable, Sendable, Codable {
   |             `- note: in declaration of 'RepositoryState'
 9 |   /// The repository has not been initialized.
10 |   case uninitialized
   :
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                      `- error: expected declaration
60 | 
61 | 

Sources/Repositories/Types/RepositoryError.swift:142:4: error: expected string literal in 'available' attribute
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
143 | 
144 | 

Sources/Repositories/Types/RepositoryError.swift:142:38: error: expected declaration
  3 | 
  4 | /// Errors that can occur during repository operations.
  5 | public enum RepositoryError: LocalizedError, Equatable, Sendable, Codable {
    |             `- note: in declaration of 'RepositoryError'
  6 |   /// The repository was not found at the specified location.
  7 |   case notFound(identifier: String)
    :
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
143 | 
144 | 
Sources/Repositories/Types/RepositoryError.swift:142:4: error: expected string literal in 'available' attribute
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |    `- error: expected string literal in 'available' attribute
143 | 
144 | 

Sources/Repositories/Types/RepositoryError.swift:142:38: error: expected declaration
  3 | 
  4 | /// Errors that can occur during repository operations.
  5 | public enum RepositoryError: LocalizedError, Equatable, Sendable, Codable {
    |             `- note: in declaration of 'RepositoryError'
  6 |   /// The repository was not found at the specified location.
  7 |   case notFound(identifier: String)
    :
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                      `- error: expected declaration
143 | 
144 | 

Sources/Repositories/Types/RepositoryError.swift:142:39: error: unterminated string literal
140 | 
141 | 
142 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
    |                                       `- error: unterminated string literal
143 | 
144 | 

Sources/Repositories/Types/RepositoryState.swift:59:4: error: expected string literal in 'available' attribute
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |    `- error: expected string literal in 'available' attribute
60 | 
61 | 

Sources/Repositories/Types/RepositoryState.swift:59:38: error: expected declaration
 6 | /// This enum represents the various states a repository can be in during
 7 | /// its lifecycle, from initialization through active use.
 8 | public enum RepositoryState: Equatable, Sendable, Codable {
   |             `- note: in declaration of 'RepositoryState'
 9 |   /// The repository has not been initialized.
10 |   case uninitialized
   :
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                      `- error: expected declaration
60 | 
61 | 

Sources/Repositories/Types/RepositoryState.swift:59:39: error: unterminated string literal
57 | 
58 | 
59 |   @available(*, deprecated, message: \"Will need to be refactored for Swift 6\")
   |                                       `- error: unterminated string literal
60 | 
61 | 
INFO: Build succeeded for only 78 of 171 top-level targets
INFO: Found 171 targets...
INFO: Elapsed time: 4.851s, Critical Path: 4.57s
INFO: 53 processes: 35 action cache hit, 7 internal, 7 local, 39 worker.
ERROR: Build did NOT complete successfully
