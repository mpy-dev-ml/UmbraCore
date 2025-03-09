INFO: Invocation ID: 44132633-3301-4d66-9646-d0bfd1faec6c
Computing main repo mapping: 
Loading: 
Loading: 0 packages loaded
Analyzing: 171 targets (0 packages loaded, 0 targets configured)
Analyzing: 171 targets (0 packages loaded, 0 targets configured)

INFO: Analyzed 171 targets (0 packages loaded, 0 targets configured).
INFO: From Compiling Swift module //Sources/ErrorHandling/Mapping:ErrorHandlingMapping:
Sources/ErrorHandling/Mapping/UmbraErrorMapper.swift:46:7: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
 44 |     public static func mapProtocolToCore(_ error: UmbraErrors.Security.Protocols) -> UmbraErrors
 45 |     .Security.Core {
 46 |       switch error {
    |       |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |       |- note: add missing case: '.invalidInput(reason: let reason)'
    |       |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |       |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |       |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |       `- note: add missing case: '.notImplemented'
 47 |         case let .invalidFormat(reason):
 48 |           return .invalidInput(reason: "Protocol format error: \(reason)")
[7 / 324] [Prepa] Compiling Swift module //Sources/ErrorHandling:ErrorHandling
INFO: From Compiling Swift module //Sources/ErrorHandling:ErrorHandling:
Sources/ErrorHandling/Extensions/SecurityErrors+UmbraError.swift:242:5: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
240 |   /// A unique code that identifies this error within its domain
241 |   public var code: String {
242 |     switch wrappedError {
    |     |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |     |- note: add missing case: '.invalidInput(reason: let reason)'
    |     |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |     |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |     |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |     |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |     |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |     `- note: add missing case: '.notImplemented'
243 |       case .invalidFormat:
244 |         return "INVALID_FORMAT"

Sources/ErrorHandling/Extensions/SecurityErrors+UmbraError.swift:262:5: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
260 |   /// A human-readable description of the error
261 |   public var errorDescription: String {
262 |     switch wrappedError {
    |     |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |     |- note: add missing case: '.invalidInput(reason: let reason)'
    |     |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |     |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |     |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |     |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |     |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |     `- note: add missing case: '.notImplemented'
263 |       case let .invalidFormat(reason):
264 |         return "Data format does not conform to protocol expectations: \(reason)"
INFO: From Compiling Swift module //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities:
Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift:128:7: warning: no 'async' operations occur within 'await' expression
126 |     // Report the error
127 |     Task {
128 |       await errorHandler.handle(wrappedError)
    |       `- warning: no 'async' operations occur within 'await' expression
129 |       print("Security error handled.")
130 | 

Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:234:19: warning: no 'async' operations occur within 'await' expression
232 |         title: action.title,
233 |         description: action.description,
234 |         action: { await action.perform() }
    |                   `- warning: no 'async' operations occur within 'await' expression
235 |       )
236 |     }
[20 / 324] [Sched] Compiling Swift module //Sources/CoreErrors:CoreErrors ... (12 actions, 5 running)
INFO: From Compiling Swift module //Sources/CoreErrors:CoreErrors:
Sources/CoreErrors/SecurityErrorMapper.swift:39:7: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
 37 |     // Handle UmbraErrors.Security.Protocols
 38 |     if let protocolError=error as? UmbraErrors.Security.Protocols {
 39 |       switch protocolError {
    |       |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |       |- note: add missing case: '.invalidInput(reason: let reason)'
    |       |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |       |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |       |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |       `- note: add missing case: '.notImplemented'
 40 |         case let .invalidFormat(reason):
 41 |           return .invalidInput(reason: "Invalid format: \(reason)")

Sources/CoreErrors/SecurityErrorMapper.swift:174:7: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
172 |     // Handle UmbraErrors.Security.Protocols
173 |     if let protocolError=error as? UmbraErrors.Security.Protocols {
174 |       switch protocolError {
    |       |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |       |- note: add missing case: '.invalidInput(reason: let reason)'
    |       |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |       |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |       |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |       `- note: add missing case: '.notImplemented'
175 |         case let .invalidFormat(reason):
176 |           return .invalidResponse(reason: "Invalid format: \(reason)")
[47 / 324] Compiling Swift module //Sources/Features/Logging/Protocols:FeaturesLoggingProtocols; 0s disk-cache, worker ... (9 actions, 5 running)
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Tests/ErrorHandlingTests/BUILD.bazel:4:17: Compiling Swift module //Tests/ErrorHandlingTests:ErrorHandlingTests failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Tests/ErrorHandlingTests:ErrorHandlingTests) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Tests/ErrorHandlingTests/ErrorHandlingTests.swiftmodule-0.params)
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:4:18: error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
  2 | @testable import ErrorHandlingCore
  3 | @testable import ErrorHandlingDomains
  4 | @testable import ErrorHandlingLogging
    |                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
  5 | @testable import ErrorHandlingMapping
  6 | @testable import ErrorHandlingModels

Tests/ErrorHandlingTests/CoreErrorTests.swift:49:17: error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
   |                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
50 |   var isRecoverable: Bool=false
51 |   var recoverySteps: [String]?

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:18:42: error: cannot find type 'ErrorNotificationHandler' in scope
 16 |   // MARK: - Test Mocks
 17 | 
 18 |   private class MockNotificationHandler: ErrorNotificationHandler {
    |                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
 19 |     var presentedNotifications: [ErrorNotification]=[]
 20 |     var dismissedIds: [UUID]=[]

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:36:39: error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
 34 |   }
 35 | 
 36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
    |                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
 37 |     var requestedErrors: [Error]=[]
 38 |     var optionsToReturn: RecoveryOptions?

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:152:17: note: found this candidate
150 | 
151 | /// Protocol for providing recovery options for errors
152 | public protocol RecoveryOptionsProvider {
    |                 `- note: found this candidate
153 |   /// Get recovery options for a specific error
154 |   /// - Parameter error: The error to get recovery options for

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Recovery/RecoveryOptions.swift:52:17: note: found this candidate
 50 | 
 51 | /// A protocol for error handlers that provide recovery options
 52 | public protocol RecoveryOptionsProvider {
    |                 `- note: found this candidate
 53 |   /// Provides recovery options for the specified error
 54 |   /// - Parameter error: The error to provide recovery options for

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
 45 | 
 46 |   private class MockLogger: ErrorLoggingService {
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
    |                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
 48 | 
 49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:46:29: error: cannot find type 'ErrorLoggingService' in scope
 44 |   }
 45 | 
 46 |   private class MockLogger: ErrorLoggingService {
    |                             `- error: cannot find type 'ErrorLoggingService' in scope
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
 48 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
 48 | 
 49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
    |                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
 50 |       loggedErrors.append((error, severity))
 51 |     }

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:53:37: error: cannot find type 'LogDestination' in scope
 51 |     }
 52 | 
 53 |     func configure(destinations _: [LogDestination]) {
    |                                     `- error: cannot find type 'LogDestination' in scope
 54 |       // No-op for testing
 55 |     }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:222:28: error: cannot find type 'ErrorLoggingService' in scope
220 |   }
221 | 
222 |   func setLogger(_ logger: ErrorLoggingService) {
    |                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:4:18: error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
  2 | @testable import ErrorHandlingCore
  3 | @testable import ErrorHandlingDomains
  4 | @testable import ErrorHandlingLogging
    |                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
  5 | @testable import ErrorHandlingMapping
  6 | @testable import ErrorHandlingModels

Tests/ErrorHandlingTests/CommonErrorTests.swift:43:29: error: cannot use optional chaining on non-optional value of type '[String : String]'
41 |     #expect(context.source == "TestModule")
42 |     #expect(context.message.contains("Service initialization failed"))
43 |     #expect(context.metadata?["operation"] == "serviceInit")
   |                             `- error: cannot use optional chaining on non-optional value of type '[String : String]'
44 |     #expect(error.localizedDescription == "Required dependency unavailable: Test service")
45 |   }

Tests/ErrorHandlingTests/CoreErrorTests.swift:49:17: error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
   |                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
50 |   var isRecoverable: Bool=false
51 |   var recoverySteps: [String]?

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/CoreErrorTests.swift:27:34: error: ambiguous use of 'critical'
25 | 
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
   |                                  `- error: ambiguous use of 'critical'
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:7:8: note: found this candidate in module 'ErrorHandlingModels'
 5 | public enum ErrorSeverity: String, Codable, Sendable {
 6 |   /// Critical errors that require immediate attention
 7 |   case critical
   |        `- note: found this candidate in module 'ErrorHandlingModels'
 8 |   /// Serious errors that affect functionality
 9 |   case error

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:103:8: note: found this candidate in module 'ErrorHandlingProtocols'
101 | public enum ErrorSeverity: String, Comparable, Sendable {
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
    |        `- note: found this candidate in module 'ErrorHandlingProtocols'
104 | 
105 |   /// Error that significantly affects functionality

Tests/ErrorHandlingTests/CoreErrorTests.swift:28:34: error: ambiguous use of 'error'
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
   |                                  `- error: ambiguous use of 'error'
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:9:8: note: found this candidate in module 'ErrorHandlingModels'
 7 |   case critical
 8 |   /// Serious errors that affect functionality
 9 |   case error
   |        `- note: found this candidate in module 'ErrorHandlingModels'
10 |   /// Less severe issues that may affect performance
11 |   case warning

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:106:8: note: found this candidate in module 'ErrorHandlingProtocols'
104 | 
105 |   /// Error that significantly affects functionality
106 |   case error="Error"
    |        `- note: found this candidate in module 'ErrorHandlingProtocols'
107 | 
108 |   /// Warning about potential issues or degraded service

Tests/ErrorHandlingTests/CoreErrorTests.swift:29:34: error: ambiguous use of 'warning'
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
   |                                  `- error: ambiguous use of 'warning'
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
31 |   }

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:11:8: note: found this candidate in module 'ErrorHandlingModels'
 9 |   case error
10 |   /// Less severe issues that may affect performance
11 |   case warning
   |        `- note: found this candidate in module 'ErrorHandlingModels'
12 |   /// Informational issues that don't affect functionality
13 |   case info

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:109:8: note: found this candidate in module 'ErrorHandlingProtocols'
107 | 
108 |   /// Warning about potential issues or degraded service
109 |   case warning="Warning"
    |        `- note: found this candidate in module 'ErrorHandlingProtocols'
110 | 
111 |   /// Informational message about non-critical events

Tests/ErrorHandlingTests/CoreErrorTests.swift:30:34: error: ambiguous use of 'info'
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
   |                                  `- error: ambiguous use of 'info'
31 |   }
32 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:13:8: note: found this candidate in module 'ErrorHandlingModels'
11 |   case warning
12 |   /// Informational issues that don't affect functionality
13 |   case info
   |        `- note: found this candidate in module 'ErrorHandlingModels'
14 | }
15 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:112:8: note: found this candidate in module 'ErrorHandlingProtocols'
110 | 
111 |   /// Informational message about non-critical events
112 |   case info="Information"
    |        `- note: found this candidate in module 'ErrorHandlingProtocols'
113 | 
114 |   /// Debug information for development purposes

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:18:42: error: cannot find type 'ErrorNotificationHandler' in scope
 16 |   // MARK: - Test Mocks
 17 | 
 18 |   private class MockNotificationHandler: ErrorNotificationHandler {
    |                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
 19 |     var presentedNotifications: [ErrorNotification]=[]
 20 |     var dismissedIds: [UUID]=[]

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:36:39: error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
 34 |   }
 35 | 
 36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
    |                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
 37 |     var requestedErrors: [Error]=[]
 38 |     var optionsToReturn: RecoveryOptions?

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:152:17: note: found this candidate
150 | 
151 | /// Protocol for providing recovery options for errors
152 | public protocol RecoveryOptionsProvider {
    |                 `- note: found this candidate
153 |   /// Get recovery options for a specific error
154 |   /// - Parameter error: The error to get recovery options for

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Recovery/RecoveryOptions.swift:52:17: note: found this candidate
 50 | 
 51 | /// A protocol for error handlers that provide recovery options
 52 | public protocol RecoveryOptionsProvider {
    |                 `- note: found this candidate
 53 |   /// Provides recovery options for the specified error
 54 |   /// - Parameter error: The error to provide recovery options for

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
 45 | 
 46 |   private class MockLogger: ErrorLoggingService {
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
    |                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
 48 | 
 49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:46:29: error: cannot find type 'ErrorLoggingService' in scope
 44 |   }
 45 | 
 46 |   private class MockLogger: ErrorLoggingService {
    |                             `- error: cannot find type 'ErrorLoggingService' in scope
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
 48 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
 47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
 48 | 
 49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
    |                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
 50 |       loggedErrors.append((error, severity))
 51 |     }

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
 3 | /// Severity level for service errors
 4 | @frozen
 5 | public enum ErrorSeverity: String, Codable, Sendable {
   |             `- note: found this candidate
 6 |   /// Critical errors that require immediate attention
 7 |   case critical

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift:101:13: note: found this candidate
 99 | 
100 | /// Error severity levels for classification and logging
101 | public enum ErrorSeverity: String, Comparable, Sendable {
    |             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:53:37: error: cannot find type 'LogDestination' in scope
 51 |     }
 52 | 
 53 |     func configure(destinations _: [LogDestination]) {
    |                                     `- error: cannot find type 'LogDestination' in scope
 54 |       // No-op for testing
 55 |     }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:222:28: error: cannot find type 'ErrorLoggingService' in scope
220 |   }
221 | 
222 |   func setLogger(_ logger: ErrorLoggingService) {
    |                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:80:41: error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
 78 | 
 79 |     // Configure the error handler with mocks
 80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
    |                                         `- error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
 81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
 82 |     errorHandler.setLogger(mockLogger)

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:81:43: error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
 79 |     // Configure the error handler with mocks
 80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
 81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
    |                                           `- error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
 82 |     errorHandler.setLogger(mockLogger)
 83 |   }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:82:28: error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
 80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
 81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
 82 |     errorHandler.setLogger(mockLogger)
    |                            `- error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
 83 |   }
 84 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:71:18: error: call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
 69 | 
 70 |     // Create a fresh ErrorHandler instance for each test
 71 |     ErrorHandler.resetSharedInstance()
    |                  `- error: call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
 72 |     errorHandler=ErrorHandler.shared
 73 | 
    :
215 | // Extensions to support testing
216 | extension ErrorHandler {
217 |   static func resetSharedInstance() {
    |               `- note: calls to static method 'resetSharedInstance()' from outside of its actor context are implicitly asynchronous
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:72:31: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
 70 |     // Create a fresh ErrorHandler instance for each test
 71 |     ErrorHandler.resetSharedInstance()
 72 |     errorHandler=ErrorHandler.shared
    |                               `- warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
 73 | 
 74 |     // Set up mocks

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Core/ErrorHandler.swift:12:21: note: class property declared here
 10 |   /// Shared instance of the error handler
 11 |   @MainActor
 12 |   public static let shared=ErrorHandler()
    |                     `- note: class property declared here
 13 | 
 14 |   /// The logger used for error logging

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:101:43: error: type 'ErrorSeverity' has no member 'high'
 99 | 
100 |     // When
101 |     errorHandler.handle(error, severity: .high)
    |                                           `- error: type 'ErrorSeverity' has no member 'high'
102 | 
103 |     // Then

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:105:55: error: type 'Equatable' has no member 'high'
103 |     // Then
104 |     XCTAssertEqual(mockLogger.loggedErrors.count, 1)
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
    |                                                       `- error: type 'Equatable' has no member 'high'
106 | 
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:109:33: error: value of type 'ErrorNotification' has no member 'severity'
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
    |                                 `- error: value of type 'ErrorNotification' has no member 'severity'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:109:44: error: type 'Equatable' has no member 'high'
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
    |                                            `- error: type 'Equatable' has no member 'high'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:125:43: error: type 'ErrorSeverity' has no member 'high'
123 | 
124 |     // When
125 |     errorHandler.handle(error, severity: .high)
    |                                           `- error: type 'ErrorSeverity' has no member 'high'
126 | 
127 |     // Then

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:133:48: error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
    |                                                `- error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
134 |   }
135 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:133:50: error: value of type '[ClosureRecoveryOption]' has no member 'actions'
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
    |                                                  `- error: value of type '[ClosureRecoveryOption]' has no member 'actions'
134 |   }
135 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:151:33: warning: 'is' test is always true
149 |     XCTAssertNotNil(mappedError)
150 |     if let mappedError {
151 |       XCTAssertTrue(mappedError is SecurityError)
    |                                 `- warning: 'is' test is always true
152 | 
153 |       // Verify the error is handled properly

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:154:51: error: type 'ErrorSeverity' has no member 'medium'
152 | 
153 |       // Verify the error is handled properly
154 |       errorHandler.handle(mappedError, severity: .medium)
    |                                                   `- error: type 'ErrorSeverity' has no member 'medium'
155 | 
156 |       XCTAssertEqual(mockLogger.loggedErrors.count, 1)

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:168:17: error: cannot find 'ErrorSource' in scope
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
    |                 `- error: cannot find 'ErrorSource' in scope
169 |           file: #file,
170 |           function: #function,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:166:20: error: extra argument 'description' in call
164 |       domain: "TestDomain",
165 |       code: "test_error",
166 |       description: "Test error description",
    |                    `- error: extra argument 'description' in call
167 |       context: ErrorContext(
168 |         source: ErrorSource(

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:165:25: error: missing argument for parameter 'errorDescription' in call
163 |     let error=GenericUmbraError(
164 |       domain: "TestDomain",
165 |       code: "test_error",
    |                         `- error: missing argument for parameter 'errorDescription' in call
166 |       description: "Test error description",
167 |       context: ErrorContext(

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/GenericUmbraError.swift:38:10: note: 'init(domain:code:errorDescription:underlyingError:source:context:)' declared here
 36 |   ///   - source: Source information about where the error occurred
 37 |   ///   - context: Additional context for the error
 38 |   public init(
    |          `- note: 'init(domain:code:errorDescription:underlyingError:source:context:)' declared here
 39 |     domain: String,
 40 |     code: String,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:167:16: error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
    |                `- error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
168 |         source: ErrorSource(
169 |           file: #file,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:174:7: error: missing argument for parameter 'message' in call
172 |         ),
173 |         metadata: ["key": "value"]
174 |       )
    |       `- error: missing argument for parameter 'message' in call
175 |     )
176 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ErrorContext.swift:33:10: note: 'init(source:code:message:metadata:numberValues:boolValues:)' declared here
 31 |   ///   - numberValues: Optional numeric metadata
 32 |   ///   - boolValues: Optional boolean metadata
 33 |   public init(
    |          `- note: 'init(source:code:message:metadata:numberValues:boolValues:)' declared here
 34 |     source: String,
 35 |     code: String?=nil,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:182:5: error: type of expression is ambiguous without a type annotation
180 |     XCTAssertEqual(error.errorDescription, "Test error description")
181 |     XCTAssertNotNil(error.errorContext)
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
    |     `- error: type of expression is ambiguous without a type annotation
183 |   }
184 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:188:21: error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
188 |     securityHandler.errorHandler=errorHandler
    |                     `- error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
189 | 
190 |     // When - Handle our direct SecurityError

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:192:21: error: call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
183 |   }
184 | 
185 |   func testSecurityErrorHandlerWithMixedErrors() {
    |        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
    :
190 |     // When - Handle our direct SecurityError
191 |     let ourError=SecurityError.permissionDenied("Insufficient privileges")
192 |     securityHandler.handleSecurityError(ourError)
    |                     `- error: call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
193 | 
194 |     // Then

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:81:15: note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
 79 |   ///   - line: Line number (auto-filled by the compiler)
 80 |   @MainActor // Add MainActor to make this function compatible with ErrorHandler
 81 |   public func handleSecurityError(
    |               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
 82 |     _ error: Error,
 83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:207:21: error: call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
183 |   }
184 | 
185 |   func testSecurityErrorHandlerWithMixedErrors() {
    |        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
    :
205 |       userInfo: [NSLocalizedDescriptionKey: "Authorization failed: Access denied to resource"]
206 |     )
207 |     securityHandler.handleSecurityError(externalError)
    |                     `- error: call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
208 | 
209 |     // Then

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift:81:15: note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
 79 |   ///   - line: Line number (auto-filled by the compiler)
 80 |   @MainActor // Add MainActor to make this function compatible with ErrorHandler
 81 |   public func handleSecurityError(
    |               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
 82 |     _ error: Error,
 83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:219:5: error: cannot find '_shared' in scope
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
    |     `- error: cannot find '_shared' in scope
220 |   }
221 | 

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:219:13: error: 'ErrorHandler' initializer is inaccessible due to 'private' protection level
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
    |             `- error: 'ErrorHandler' initializer is inaccessible due to 'private' protection level
220 |   }
221 | 

ErrorHandlingCore.ErrorHandler (private):6:24: note: 'init()' declared here
 4 |     @MainActor private var notificationHandler: (any ErrorHandlingInterfaces.ErrorNotificationProtocol)?
 5 |     @MainActor private var recoveryProviders: [any ErrorHandlingInterfaces.RecoveryOptionsProvider]
 6 |     @MainActor private init()
   |                        `- note: 'init()' declared here
 7 |     @MainActor public func setLogger(_ logger: any ErrorHandlingInterfaces.ErrorLoggingProtocol)
 8 |     @MainActor public func setNotificationHandler(_ handler: any ErrorHandlingInterfaces.ErrorNotificationProtocol)

Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:223:10: error: 'logger' is inaccessible due to 'private' protection level
221 | 
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
    |          `- error: 'logger' is inaccessible due to 'private' protection level
224 |   }
225 | }

ErrorHandlingCore.ErrorHandler (private):3:28: note: 'logger' declared here
 1 | @MainActor final public class ErrorHandler {
 2 |     @MainActor public static let shared: ErrorHandlingCore.ErrorHandler
 3 |     @MainActor private var logger: (any ErrorHandlingInterfaces.ErrorLoggingProtocol)?
   |                            `- note: 'logger' declared here
 4 |     @MainActor private var notificationHandler: (any ErrorHandlingInterfaces.ErrorNotificationProtocol)?
 5 |     @MainActor private var recoveryProviders: [any ErrorHandlingInterfaces.RecoveryOptionsProvider]
[74 / 321] [Sched] Compiling Swift module //Sources/ResticCLIHelper/Protocols:ResticCLIHelperProtocols ... (12 actions, 5 running)
INFO: From Compiling Swift module //Sources/UmbraBookmarkService:UmbraBookmarkService:
Sources/UmbraBookmarkService/BookmarkService.swift:107:10: warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
105 |     // Use a detached task to handle MainActor-isolated work
106 |     // TODO: Swift 6 compatibility - refactor actor isolation
107 |     Task { @MainActor in
    |          `- warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
108 |       // Since we're now in a MainActor-isolated context, we can safely access
109 |       // the weak reference without crossing actor boundaries
[101 / 320] Compiling Swift module //Sources/UmbraCoreTypes:UmbraCoreTypesTests; 0s disk-cache, worker ... (6 actions, 5 running)
INFO: From Compiling Swift module //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests:
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:119:17: warning: 'is' test is always true
117 |       case let .failure(error):
118 |         XCTAssertTrue(
119 |           error is CoreErrors.SecurityError,
    |                 `- warning: 'is' test is always true
120 |           "Error should be mapped to SecurityError"
121 |         )
Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift:119:17: warning: 'is' test is always true
117 |       case let .failure(error):
118 |         XCTAssertTrue(
119 |           error is CoreErrors.SecurityError,
    |                 `- warning: 'is' test is always true
120 |           "Error should be mapped to SecurityError"
121 |         )
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
INFO: From Compiling Swift module //Sources/SecurityProtocolsCore:SecurityProtocolsCore:
Sources/SecurityProtocolsCore/Sources/DTOs/SecurityResultDTO.swift:77:7: warning: switch must be exhaustive; this is an error in the Swift 6 language mode
 75 |     // Derive error code based on error type
 76 |     if let error {
 77 |       switch error {
    |       |- warning: switch must be exhaustive; this is an error in the Swift 6 language mode
    |       |- note: add missing case: '.invalidInput(reason: let reason)'
    |       |- note: add missing case: '.encryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.decryptionFailed(reason: let reason)'
    |       |- note: add missing case: '.randomGenerationFailed(reason: let reason)'
    |       |- note: add missing case: '.storageOperationFailed(reason: let reason)'
    |       |- note: add missing case: '.serviceError(code: let code, reason: let reason)'
    |       `- note: add missing case: '.notImplemented'
 78 |         case .invalidFormat:
 79 |           errorCode=1001
[127 / 318] Compiling Swift module //Sources/ObjCBridgingTypesFoundation:ObjCBridgingTypesFoundationForTesting; 0s disk-cache, worker ... (12 actions, 5 running)
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityCoreAdapters/BUILD.bazel:7:14: Compiling Swift module //Sources/SecurityCoreAdapters:SecurityCoreAdapters failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/SecurityCoreAdapters:SecurityCoreAdapters) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityCoreAdapters/SecurityCoreAdapters.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:68:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 66 |   // MARK: - CryptoServiceProtocol Implementation
 67 | 
 68 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 69 |     data: SecureBytes,
 70 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:75:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 73 |   }
 74 | 
 75 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 76 |     data: SecureBytes,
 77 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:82:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 80 |   }
 81 | 
 82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 83 |     await _hash(data)
 84 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:86:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 84 |   }
 85 | 
 86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 87 |     await _generateKey()
 88 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:90:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 88 |   }
 89 | 
 90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 91 |     await _generateRandomData(length)
 92 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:10:20: error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
  8 | /// Type-erased wrapper for CryptoServiceProtocol
  9 | /// This allows for cleaner interfaces without exposing implementation details
 10 | public final class AnyCryptoService: CryptoServiceProtocol {
    |                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
 11 |   // MARK: - Private Properties
 12 | 
    :
 94 |   // New method implementations
 95 | 
 96 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 97 |     await _verify(data, hash)
 98 |   }
 99 | 
100 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
101 |     data: SecureBytes,
102 |     key: SecureBytes,
    :
106 |   }
107 | 
108 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
109 |     data: SecureBytes,
110 |     key: SecureBytes,
    :
114 |   }
115 | 
116 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
117 |     data: SecureBytes,
118 |     publicKey: SecureBytes,
    :
122 |   }
123 | 
124 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
125 |     data: SecureBytes,
126 |     privateKey: SecureBytes,
    :
130 |   }
131 | 
132 |   public func hash(
    |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
133 |     data: SecureBytes,
134 |     config: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:35:15: error: method cannot be declared public because its result uses an internal type
 33 |   // MARK: - CryptoServiceProtocol Implementation
 34 | 
 35 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 36 |     data: SecureBytes,
 37 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:38:34: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 36 |     data: SecureBytes,
 37 |     using key: SecureBytes
 38 |   ) async -> Result<SecureBytes, SecurityError> {
    |                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                  `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 39 |     let transformedData=transformations.transformInputData?(data) ?? data
 40 |     let transformedKey=transformations.transformInputKey?(key) ?? key

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:47:15: error: method cannot be declared public because its result uses an internal type
 45 |   }
 46 | 
 47 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 48 |     data: SecureBytes,
 49 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:50:34: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 48 |     data: SecureBytes,
 49 |     using key: SecureBytes
 50 |   ) async -> Result<SecureBytes, SecurityError> {
    |                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                  `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 51 |     let transformedData=transformations.transformInputData?(data) ?? data
 52 |     let transformedKey=transformations.transformInputKey?(key) ?? key

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:59:15: error: method cannot be declared public because its result uses an internal type
 57 |   }
 58 | 
 59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 60 |     let transformedData=transformations.transformInputData?(data) ?? data
 61 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:59:68: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 57 |   }
 58 | 
 59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |                                                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                                    `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 60 |     let transformedData=transformations.transformInputData?(data) ?? data
 61 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:67:15: error: method cannot be declared public because its result uses an internal type
 65 |   }
 66 | 
 67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 68 |     let result=await adaptee.generateKey()
 69 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:67:58: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 65 |   }
 66 | 
 67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |                                                          |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                          `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 68 |     let result=await adaptee.generateKey()
 69 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:80:15: error: method cannot be declared public because its result uses an internal type
 78 |   }
 79 | 
 80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 81 |     let result=await adaptee.generateRandomData(length: length)
 82 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:80:76: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 78 |   }
 79 | 
 80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |                                                                            |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                                            `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 81 |     let result=await adaptee.generateRandomData(length: length)
 82 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:16: error: property cannot be declared public because its type uses an internal type
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                `- error: property cannot be declared public because its type uses an internal type
185 | 
186 |     /// Initialize a new set of transformations

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:45: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                                             |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                             `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
185 | 
186 |     /// Initialize a new set of transformations

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:63: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                                                               |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                               `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
185 | 
186 |     /// Initialize a new set of transformations

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:196:12: error: initializer cannot be declared public because its parameter uses an internal type
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
    |            `- error: initializer cannot be declared public because its parameter uses an internal type
197 |       transformInputData: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
198 |       transformInputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:203:36: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
    |                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                    `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
204 |     ) {
205 |       self.transformInputData=transformInputData

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:203:54: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
    |                                                      |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                      `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
204 |     ) {
205 |       self.transformInputData=transformInputData

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:7:15: error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
  5 | /// This allows us to adapt between different implementations of crypto services
  6 | /// without requiring them to directly implement each other's interfaces
  7 | public struct CryptoServiceTypeAdapter<
    |               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
  8 |   Adaptee: CryptoServiceProtocol &
  9 |     Sendable
    :
 71 |   }
 72 | 
 73 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, against: SecureBytes) async -> Bool'
 74 |     let transformedData=transformations.transformInputData?(data) ?? data
 75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
    :
 86 |   // MARK: - New required methods
 87 | 
 88 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
 89 |     data: SecureBytes,
 90 |     key: SecureBytes,
    :
101 |   }
102 | 
103 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
104 |     data: SecureBytes,
105 |     key: SecureBytes,
    :
116 |   }
117 | 
118 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, publicKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
119 |     data: SecureBytes,
120 |     publicKey: SecureBytes,
    :
131 |   }
132 | 
133 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, privateKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
134 |     data: SecureBytes,
135 |     privateKey: SecureBytes,
    :
146 |   }
147 | 
148 |   public func hash(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
149 |     data: SecureBytes,
150 |     config: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:68:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 66 |   // MARK: - CryptoServiceProtocol Implementation
 67 | 
 68 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 69 |     data: SecureBytes,
 70 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:75:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 73 |   }
 74 | 
 75 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 76 |     data: SecureBytes,
 77 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:82:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 80 |   }
 81 | 
 82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 83 |     await _hash(data)
 84 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:86:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 84 |   }
 85 | 
 86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 87 |     await _generateKey()
 88 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:90:15: error: method cannot be declared public because its result uses an internal type
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol
    :
 88 |   }
 89 | 
 90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 91 |     await _generateRandomData(length)
 92 |   }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:10:20: error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
  8 | /// Type-erased wrapper for CryptoServiceProtocol
  9 | /// This allows for cleaner interfaces without exposing implementation details
 10 | public final class AnyCryptoService: CryptoServiceProtocol {
    |                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
 11 |   // MARK: - Private Properties
 12 | 
    :
 94 |   // New method implementations
 95 | 
 96 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 97 |     await _verify(data, hash)
 98 |   }
 99 | 
100 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
101 |     data: SecureBytes,
102 |     key: SecureBytes,
    :
106 |   }
107 | 
108 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
109 |     data: SecureBytes,
110 |     key: SecureBytes,
    :
114 |   }
115 | 
116 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
117 |     data: SecureBytes,
118 |     publicKey: SecureBytes,
    :
122 |   }
123 | 
124 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
125 |     data: SecureBytes,
126 |     privateKey: SecureBytes,
    :
130 |   }
131 | 
132 |   public func hash(
    |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
133 |     data: SecureBytes,
134 |     config: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:50:38: error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
 48 | 
 49 |     // New property initializations
 50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
    |                                      `- error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
 51 |     _encryptSymmetric={ @Sendable [service] in
 52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:52:7: error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
 51 |     _encryptSymmetric={ @Sendable [service] in
 52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
    |       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 53 |     }
 54 |     _decryptSymmetric={ @Sendable [service] in

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:55:7: error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 53 |     }
 54 |     _decryptSymmetric={ @Sendable [service] in
 55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
    |       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 56 |     }
 57 |     _encryptAsymmetric={ @Sendable [service] in

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:58:7: error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 56 |     }
 57 |     _encryptAsymmetric={ @Sendable [service] in
 58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
    |       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 59 |     }
 60 |     _decryptAsymmetric={ @Sendable [service] in

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:61:7: error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 59 |     }
 60 |     _decryptAsymmetric={ @Sendable [service] in
 61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
    |       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 62 |     }
 63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:63:46: error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
 62 |     }
 63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
    |                                              `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
 64 |   }
 65 | 

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:35:15: error: method cannot be declared public because its result uses an internal type
 33 |   // MARK: - CryptoServiceProtocol Implementation
 34 | 
 35 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 36 |     data: SecureBytes,
 37 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:38:34: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 36 |     data: SecureBytes,
 37 |     using key: SecureBytes
 38 |   ) async -> Result<SecureBytes, SecurityError> {
    |                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                  `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 39 |     let transformedData=transformations.transformInputData?(data) ?? data
 40 |     let transformedKey=transformations.transformInputKey?(key) ?? key

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:47:15: error: method cannot be declared public because its result uses an internal type
 45 |   }
 46 | 
 47 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 48 |     data: SecureBytes,
 49 |     using key: SecureBytes

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:50:34: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 48 |     data: SecureBytes,
 49 |     using key: SecureBytes
 50 |   ) async -> Result<SecureBytes, SecurityError> {
    |                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                  `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 51 |     let transformedData=transformations.transformInputData?(data) ?? data
 52 |     let transformedKey=transformations.transformInputKey?(key) ?? key

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:59:15: error: method cannot be declared public because its result uses an internal type
 57 |   }
 58 | 
 59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 60 |     let transformedData=transformations.transformInputData?(data) ?? data
 61 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:59:68: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 57 |   }
 58 | 
 59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |                                                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                                    `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 60 |     let transformedData=transformations.transformInputData?(data) ?? data
 61 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:67:15: error: method cannot be declared public because its result uses an internal type
 65 |   }
 66 | 
 67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 68 |     let result=await adaptee.generateKey()
 69 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:67:58: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 65 |   }
 66 | 
 67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |                                                          |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                          `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 68 |     let result=await adaptee.generateKey()
 69 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:80:15: error: method cannot be declared public because its result uses an internal type
 78 |   }
 79 | 
 80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 81 |     let result=await adaptee.generateRandomData(length: length)
 82 | 

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:80:76: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
 78 |   }
 79 | 
 80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |                                                                            |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                                            `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
 81 |     let result=await adaptee.generateRandomData(length: length)
 82 | 

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:16: error: property cannot be declared public because its type uses an internal type
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                `- error: property cannot be declared public because its type uses an internal type
185 | 
186 |     /// Initialize a new set of transformations

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:45: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                                             |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                             `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
185 | 
186 |     /// Initialize a new set of transformations

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:184:63: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
182 | 
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
    |                                                               |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                               `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
185 | 
186 |     /// Initialize a new set of transformations

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:196:12: error: initializer cannot be declared public because its parameter uses an internal type
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
    |            `- error: initializer cannot be declared public because its parameter uses an internal type
197 |       transformInputData: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
198 |       transformInputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,

Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:6:11: note: type declared here
  4 | 
  5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  6 | typealias SecurityError=UmbraErrors.Security.Protocols
    |           `- note: type declared here
  7 | 
  8 | /// Type-erased wrapper for CryptoServiceProtocol

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:203:36: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
    |                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                    `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
204 |     ) {
205 |       self.transformInputData=transformInputData

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:203:54: warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
    |                                                      |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
    |                                                      `- note: The missing import of module 'ErrorHandlingDomains' will be added implicitly
204 |     ) {
205 |       self.transformInputData=transformInputData

/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Domains/SecurityErrors.swift:70:17: note: type declared here
 68 | 
 69 |     /// Protocol-specific security errors
 70 |     public enum Protocols: Error, Sendable, Equatable {
    |                 `- note: type declared here
 71 |       /// Data format does not conform to protocol expectations
 72 |       case invalidFormat(reason: String)

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:7:15: error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
  5 | /// This allows us to adapt between different implementations of crypto services
  6 | /// without requiring them to directly implement each other's interfaces
  7 | public struct CryptoServiceTypeAdapter<
    |               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
  8 |   Adaptee: CryptoServiceProtocol &
  9 |     Sendable
    :
 71 |   }
 72 | 
 73 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, against: SecureBytes) async -> Bool'
 74 |     let transformedData=transformations.transformInputData?(data) ?? data
 75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
    :
 86 |   // MARK: - New required methods
 87 | 
 88 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
 89 |     data: SecureBytes,
 90 |     key: SecureBytes,
    :
101 |   }
102 | 
103 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, key: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
104 |     data: SecureBytes,
105 |     key: SecureBytes,
    :
116 |   }
117 | 
118 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, publicKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
119 |     data: SecureBytes,
120 |     publicKey: SecureBytes,
    :
131 |   }
132 | 
133 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, privateKey: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
134 |     data: SecureBytes,
135 |     privateKey: SecureBytes,
    :
146 |   }
147 | 
148 |   public func hash(
    |               `- note: candidate has non-matching type '<Adaptee> (data: SecureBytes, config: SecurityConfigDTO) async -> SecurityResultDTO'
149 |     data: SecureBytes,
150 |     config: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:77:12: error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
 75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
 76 | 
 77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
    |            `- error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
 78 |   }
 79 | 

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:96:12: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 94 |     let transformedKey=transformations.transformInputKey?(key) ?? key
 95 | 
 96 |     return await adaptee.encryptSymmetric(
    |            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 97 |       data: transformedData,
 98 |       key: transformedKey,

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:111:12: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
109 |     let transformedKey=transformations.transformInputKey?(key) ?? key
110 | 
111 |     return await adaptee.decryptSymmetric(
    |            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
112 |       data: transformedData,
113 |       key: transformedKey,

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:126:12: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
124 |     let transformedKey=transformations.transformInputKey?(publicKey) ?? publicKey
125 | 
126 |     return await adaptee.encryptAsymmetric(
    |            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
127 |       data: transformedData,
128 |       publicKey: transformedKey,

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:141:12: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
139 |     let transformedKey=transformations.transformInputKey?(privateKey) ?? privateKey
140 | 
141 |     return await adaptee.decryptAsymmetric(
    |            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |       data: transformedData,
143 |       privateKey: transformedKey,

Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift:154:12: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
152 |     let transformedData=transformations.transformInputData?(data) ?? data
153 | 
154 |     return await adaptee.hash(
    |            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
155 |       data: transformedData,
156 |       config: config
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityImplementation/BUILD.bazel:4:33: Compiling Swift module //Sources/SecurityImplementation:SecurityImplementation failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/SecurityImplementation:SecurityImplementation) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityImplementation/SecurityImplementation.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/SecurityImplementation/Sources/CryptoService.swift:196:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 194 |   ///
 195 |   /// The format of the returned data is: [IV (12 bytes)][Encrypted data with authentication tag]
 196 |   public func encrypt(
     |               `- error: method cannot be declared public because its result uses an internal type
 197 |     data: SecureBytes,
 198 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:230:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 228 |   /// AES-GCM validates the integrity of the data during decryption. If the data
 229 |   /// has been tampered with, decryption will fail with an authentication error.
 230 |   public func decrypt(
     |               `- error: method cannot be declared public because its result uses an internal type
 231 |     data: SecureBytes,
 232 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:264:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 262 |   /// suitable for use with AES-256 encryption. The key is returned as a SecureBytes
 263 |   /// object, which provides memory protection for sensitive cryptographic material.
 264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
     |                           `- error: method cannot be declared public because its result uses an internal type
 265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
 266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)

Sources/SecurityImplementation/Sources/CryptoService.swift:277:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 275 |   /// The hash function is one-way (it cannot be reversed) and collision-resistant
 276 |   /// (it's computationally infeasible to find two different inputs that produce the same hash).
 277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
     |                           `- error: method cannot be declared public because its result uses an internal type
 278 |     // Use SHA-256 through CryptoWrapper
 279 |     let hashedData=CryptoWrapper.sha256(data)

Sources/SecurityImplementation/Sources/CryptoService.swift:291:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 289 |   /// This function computes the SHA-256 hash of the input data and compares it
 290 |   /// with the provided hash value. Returns true if they match, false otherwise.
 291 |   public nonisolated func verify(
     |                           `- error: method cannot be declared public because its result uses an internal type
 292 |     data: SecureBytes,
 293 |     againstHash hash: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:322:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 320 |   /// The MAC provides both authentication and integrity verification for the data.
 321 |   /// A valid MAC can only be generated by someone who possesses the same key.
 322 |   public nonisolated func generateMAC(
     |                           `- error: method cannot be declared public because its result uses an internal type
 323 |     for data: SecureBytes,
 324 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:341:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 339 |   /// input data and key, then comparing it with the provided MAC. Returns true
 340 |   /// if they match, indicating the data is authentic and has not been tampered with.
 341 |   public nonisolated func verifyMAC(
     |                           `- error: method cannot be declared public because its result uses an internal type
 342 |     _ mac: SecureBytes,
 343 |     for data: SecureBytes,

Sources/SecurityImplementation/Sources/CryptoService.swift:483:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 481 |    - Using hybrid encryption for large data (encrypt data with symmetric key, then encrypt that key with asymmetric)
 482 |    */
 483 |   public func generateAsymmetricKeyPair() async -> Result<(
     |               `- error: method cannot be declared public because its result uses an internal type
 484 |     publicKey: SecureBytes,
 485 |     privateKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:544:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 542 |    4. Combine the encrypted key and encrypted data
 543 |    */
 544 |   public func encryptAsymmetric(
     |               `- error: method cannot be declared public because its result uses an internal type
 545 |     data: SecureBytes,
 546 |     publicKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:642:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 640 |    Always handle errors appropriately, avoiding information leakage in error messages.
 641 |    */
 642 |   public func decryptAsymmetric(
     |               `- error: method cannot be declared public because its result uses an internal type
 643 |     data: SecureBytes,
 644 |     privateKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:917:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 915 |    - Ed25519 signatures for high performance and security
 916 |    */
 917 |   public nonisolated func sign(
     |                           `- error: method cannot be declared public because its result uses an internal type
 918 |     data: SecureBytes,
 919 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:966:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 964 |    This implementation performs time-constant comparison to prevent timing attacks.
 965 |    */
 966 |   public nonisolated func verify(
     |                           `- error: method cannot be declared public because its result uses an internal type
 967 |     signature: SecureBytes,
 968 |     for data: SecureBytes,

Sources/SecurityImplementation/Sources/CryptoService.swift:987:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 985 |    but it should be reviewed for production use to ensure it meets specific security requirements.
 986 |    */
 987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
     |               `- error: method cannot be declared public because its result uses an internal type
 988 |     // Input validation
 989 |     guard length > 0 else {

Sources/SecurityImplementation/Sources/CryptoService.swift:1059:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
1057 |   /// cryptographic operations like key generation. It uses CryptoWrapper's
1058 |   /// secure random number generation functionality.
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
     |                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count

Sources/SecurityImplementation/Sources/CryptoService.swift:56:20: error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
  54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
  55 | @available(macOS 15.0, iOS 17.0, *)
  56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
     |                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
  57 |   // MARK: - Initialisation
  58 | 
     :
 175 |   /// The hash is deterministic and collision-resistant, making it suitable for
 176 |   /// data integrity verification and identifying content.
 177 |   public func hash(
     |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 178 |     data: SecureBytes,
 179 |     config _: SecurityConfigDTO
     :
 306 |   ///
 307 |   /// Simplified version that returns a boolean directly instead of a Result type.
 308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
     |                           `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 309 |     let computedHash=CryptoWrapper.sha256(data)
 310 |     return computedHash == hash
     :
 366 |   /// Performance note: AES-GCM provides both confidentiality and authenticity
 367 |   /// in a single pass, making it more efficient than modes requiring separate MAC calculation.
 368 |   public func encryptSymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 369 |     data: SecureBytes,
 370 |     key: SecureBytes,
     :
 410 |   ///
 411 |   /// If the data has been tampered with, decryption will fail with an authentication error.
 412 |   public func decryptSymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 413 |     data: SecureBytes,
 414 |     key: SecureBytes,
     :
 576 |   /// This implementation uses a simplified approach for testing only.
 577 |   /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
 578 |   public func encryptAsymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 579 |     data: SecureBytes,
 580 |     publicKey: SecureBytes,
     :
 682 |   /// This implementation uses a simplified approach for testing only.
 683 |   /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
 684 |   public func decryptAsymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 685 |     data: SecureBytes,
 686 |     privateKey: SecureBytes,

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:14:15: error: method cannot be declared public because its result uses an internal type
 12 |   // MARK: - CryptoServiceProtocol Implementation
 13 | 
 14 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 15 |     data: SecureBytes,
 16 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:37:15: error: method cannot be declared public because its result uses an internal type
 35 |   }
 36 | 
 37 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 38 |     data: SecureBytes,
 39 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:60:15: error: method cannot be declared public because its result uses an internal type
 58 |   }
 59 | 
 60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 61 |     // Generate a 256-bit key (32 bytes)
 62 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:66:15: error: method cannot be declared public because its result uses an internal type
 64 |   }
 65 | 
 66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 67 |     let hashedData=CryptoWrapper.sha256(data)
 68 |     return .success(hashedData)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:79:15: error: method cannot be declared public because its result uses an internal type
 77 |   /// - Parameter length: The length of random data to generate in bytes
 78 |   /// - Returns: Result containing random data or error
 79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 80 |     do {
 81 |       var randomBytes=[UInt8](repeating: 0, count: length)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:6:20: error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
  4 | 
  5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
  6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
    |                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
  7 | 
  8 |   // MARK: - Initialization
    :
 69 |   }
 70 | 
 71 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 72 |     let computedHash=CryptoWrapper.sha256(data)
 73 |     return computedHash == hash
    :
100 |   // MARK: - Symmetric Encryption
101 | 
102 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
103 |     data: SecureBytes,
104 |     key: SecureBytes,
    :
133 |   }
134 | 
135 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
136 |     data: SecureBytes,
137 |     key: SecureBytes,
    :
176 |   // MARK: - Asymmetric Encryption
177 | 
178 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
179 |     data _: SecureBytes,
180 |     publicKey _: SecureBytes,
    :
189 |   }
190 | 
191 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
192 |     data _: SecureBytes,
193 |     privateKey _: SecureBytes,
    :
204 |   // MARK: - Hashing
205 | 
206 |   public func hash(
    |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
207 |     data: SecureBytes,
208 |     config _: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:28:15: error: method cannot be declared public because its result uses an internal type
 26 |   // MARK: - KeyManagementProtocol Implementation
 27 | 
 28 |   public func retrieveKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
 29 |   -> Result<SecureBytes, SecurityError> {
 30 |     // If secure storage is available, use it

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:55:15: error: method cannot be declared public because its result uses an internal type
 53 |   }
 54 | 
 55 |   public func storeKey(
    |               `- error: method cannot be declared public because its result uses an internal type
 56 |     _ key: SecureBytes,
 57 |     withIdentifier identifier: String

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:77:15: error: method cannot be declared public because its result uses an internal type
 75 |   }
 76 | 
 77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 78 |     // If secure storage is available, use it
 79 |     if let secureStorage {

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:105:15: error: method cannot be declared public because its result uses an internal type
103 |   }
104 | 
105 |   public func rotateKey(
    |               `- error: method cannot be declared public because its result uses an internal type
106 |     withIdentifier identifier: String,
107 |     dataToReencrypt: SecureBytes?

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:171:15: error: method cannot be declared public because its result uses an internal type
169 |   }
170 | 
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
172 |     // If secure storage is available, it should provide a way to list keys
173 |     // For now, we'll just return the in-memory keys

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:97:15: error: method cannot be declared public because its result uses an internal type
 95 |   /// - Parameter identifier: The identifier of the key to retrieve
 96 |   /// - Returns: The key or an error if the key does not exist
 97 |   public func retrieveKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
 98 |   -> Result<SecureBytes, SecurityError> {
 99 |     if let key=await keyStorage.get(identifier: identifier) {

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:111:15: error: method cannot be declared public because its result uses an internal type
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
    |               `- error: method cannot be declared public because its result uses an internal type
112 |     _ key: SecureBytes,
113 |     withIdentifier identifier: String

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:122:15: error: method cannot be declared public because its result uses an internal type
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
123 |     if await keyStorage.contains(identifier: identifier) {
124 |       await keyStorage.remove(identifier: identifier)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:136:15: error: method cannot be declared public because its result uses an internal type
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
    |               `- error: method cannot be declared public because its result uses an internal type
137 |     withIdentifier identifier: String,
138 |     dataToReencrypt: SecureBytes?

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:213:15: error: method cannot be declared public because its result uses an internal type
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
214 |   -> Result<SecureBytes, SecurityError> {
215 |     // Delegate to the full rotation method

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:229:15: error: method cannot be declared public because its result uses an internal type
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
230 |     let identifiers=await keyStorage.allIdentifiers()
231 |     return .success(identifiers)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:237:15: error: method cannot be declared public because its result uses an internal type
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
238 |     // Basic implementation that delegates to CryptoService
239 |     let crypto=CryptoService()

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
Sources/SecurityImplementation/Sources/CryptoService.swift:196:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 194 |   ///
 195 |   /// The format of the returned data is: [IV (12 bytes)][Encrypted data with authentication tag]
 196 |   public func encrypt(
     |               `- error: method cannot be declared public because its result uses an internal type
 197 |     data: SecureBytes,
 198 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:230:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 228 |   /// AES-GCM validates the integrity of the data during decryption. If the data
 229 |   /// has been tampered with, decryption will fail with an authentication error.
 230 |   public func decrypt(
     |               `- error: method cannot be declared public because its result uses an internal type
 231 |     data: SecureBytes,
 232 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:264:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 262 |   /// suitable for use with AES-256 encryption. The key is returned as a SecureBytes
 263 |   /// object, which provides memory protection for sensitive cryptographic material.
 264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
     |                           `- error: method cannot be declared public because its result uses an internal type
 265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
 266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)

Sources/SecurityImplementation/Sources/CryptoService.swift:277:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 275 |   /// The hash function is one-way (it cannot be reversed) and collision-resistant
 276 |   /// (it's computationally infeasible to find two different inputs that produce the same hash).
 277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
     |                           `- error: method cannot be declared public because its result uses an internal type
 278 |     // Use SHA-256 through CryptoWrapper
 279 |     let hashedData=CryptoWrapper.sha256(data)

Sources/SecurityImplementation/Sources/CryptoService.swift:291:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 289 |   /// This function computes the SHA-256 hash of the input data and compares it
 290 |   /// with the provided hash value. Returns true if they match, false otherwise.
 291 |   public nonisolated func verify(
     |                           `- error: method cannot be declared public because its result uses an internal type
 292 |     data: SecureBytes,
 293 |     againstHash hash: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:322:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 320 |   /// The MAC provides both authentication and integrity verification for the data.
 321 |   /// A valid MAC can only be generated by someone who possesses the same key.
 322 |   public nonisolated func generateMAC(
     |                           `- error: method cannot be declared public because its result uses an internal type
 323 |     for data: SecureBytes,
 324 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:341:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 339 |   /// input data and key, then comparing it with the provided MAC. Returns true
 340 |   /// if they match, indicating the data is authentic and has not been tampered with.
 341 |   public nonisolated func verifyMAC(
     |                           `- error: method cannot be declared public because its result uses an internal type
 342 |     _ mac: SecureBytes,
 343 |     for data: SecureBytes,

Sources/SecurityImplementation/Sources/CryptoService.swift:483:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 481 |    - Using hybrid encryption for large data (encrypt data with symmetric key, then encrypt that key with asymmetric)
 482 |    */
 483 |   public func generateAsymmetricKeyPair() async -> Result<(
     |               `- error: method cannot be declared public because its result uses an internal type
 484 |     publicKey: SecureBytes,
 485 |     privateKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:544:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 542 |    4. Combine the encrypted key and encrypted data
 543 |    */
 544 |   public func encryptAsymmetric(
     |               `- error: method cannot be declared public because its result uses an internal type
 545 |     data: SecureBytes,
 546 |     publicKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:642:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 640 |    Always handle errors appropriately, avoiding information leakage in error messages.
 641 |    */
 642 |   public func decryptAsymmetric(
     |               `- error: method cannot be declared public because its result uses an internal type
 643 |     data: SecureBytes,
 644 |     privateKey: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:917:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 915 |    - Ed25519 signatures for high performance and security
 916 |    */
 917 |   public nonisolated func sign(
     |                           `- error: method cannot be declared public because its result uses an internal type
 918 |     data: SecureBytes,
 919 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:966:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 964 |    This implementation performs time-constant comparison to prevent timing attacks.
 965 |    */
 966 |   public nonisolated func verify(
     |                           `- error: method cannot be declared public because its result uses an internal type
 967 |     signature: SecureBytes,
 968 |     for data: SecureBytes,

Sources/SecurityImplementation/Sources/CryptoService.swift:987:15: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
 985 |    but it should be reviewed for production use to ensure it meets specific security requirements.
 986 |    */
 987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
     |               `- error: method cannot be declared public because its result uses an internal type
 988 |     // Input validation
 989 |     guard length > 0 else {

Sources/SecurityImplementation/Sources/CryptoService.swift:1059:27: error: method cannot be declared public because its result uses an internal type
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
     :
1057 |   /// cryptographic operations like key generation. It uses CryptoWrapper's
1058 |   /// secure random number generation functionality.
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
     |                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count

Sources/SecurityImplementation/Sources/CryptoService.swift:56:20: error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
  54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
  55 | @available(macOS 15.0, iOS 17.0, *)
  56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
     |                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
  57 |   // MARK: - Initialisation
  58 | 
     :
 175 |   /// The hash is deterministic and collision-resistant, making it suitable for
 176 |   /// data integrity verification and identifying content.
 177 |   public func hash(
     |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 178 |     data: SecureBytes,
 179 |     config _: SecurityConfigDTO
     :
 306 |   ///
 307 |   /// Simplified version that returns a boolean directly instead of a Result type.
 308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
     |                           `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 309 |     let computedHash=CryptoWrapper.sha256(data)
 310 |     return computedHash == hash
     :
 366 |   /// Performance note: AES-GCM provides both confidentiality and authenticity
 367 |   /// in a single pass, making it more efficient than modes requiring separate MAC calculation.
 368 |   public func encryptSymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 369 |     data: SecureBytes,
 370 |     key: SecureBytes,
     :
 410 |   ///
 411 |   /// If the data has been tampered with, decryption will fail with an authentication error.
 412 |   public func decryptSymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 413 |     data: SecureBytes,
 414 |     key: SecureBytes,
     :
 576 |   /// This implementation uses a simplified approach for testing only.
 577 |   /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
 578 |   public func encryptAsymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 579 |     data: SecureBytes,
 580 |     publicKey: SecureBytes,
     :
 682 |   /// This implementation uses a simplified approach for testing only.
 683 |   /// WARNING: This is a proof-of-concept implementation and is not secure for production use!
 684 |   public func decryptAsymmetric(
     |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
 685 |     data: SecureBytes,
 686 |     privateKey: SecureBytes,

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityImplementation/Sources/CryptoService.swift:90:45: error: cannot find 'CryptoWrapper' in scope
  88 | 
  89 |       // Default to AES-GCM with a random IV if not specified
  90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
     |                                             `- error: cannot find 'CryptoWrapper' in scope
  91 | 
  92 |       // Encrypt the data

Sources/SecurityImplementation/Sources/CryptoService.swift:93:25: error: cannot find 'CryptoWrapper' in scope
  91 | 
  92 |       // Encrypt the data
  93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
  94 | 
  95 |       // Return IV + encrypted data unless IV is provided in config

Sources/SecurityImplementation/Sources/CryptoService.swift:155:25: error: cannot find 'CryptoWrapper' in scope
 153 | 
 154 |       // Decrypt the data
 155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
 156 | 
 157 |       return SecurityResultDTO(success: true, data: decrypted)

Sources/SecurityImplementation/Sources/CryptoService.swift:182:20: error: cannot find 'CryptoWrapper' in scope
 180 |   ) async -> SecurityResultDTO {
 181 |     // Use SHA-256 through CryptoWrapper
 182 |     let hashedData=CryptoWrapper.sha256(data)
     |                    `- error: cannot find 'CryptoWrapper' in scope
 183 |     return SecurityResultDTO(success: true, data: hashedData)
 184 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:202:14: error: cannot find 'CryptoWrapper' in scope
 200 |     do {
 201 |       // Generate a random IV
 202 |       let iv=CryptoWrapper.generateRandomIVSecure()
     |              `- error: cannot find 'CryptoWrapper' in scope
 203 | 
 204 |       // Encrypt the data using AES-GCM

Sources/SecurityImplementation/Sources/CryptoService.swift:205:25: error: cannot find 'CryptoWrapper' in scope
 203 | 
 204 |       // Encrypt the data using AES-GCM
 205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
 206 | 
 207 |       // Combine IV with encrypted data

Sources/SecurityImplementation/Sources/CryptoService.swift:248:25: error: cannot find 'CryptoWrapper' in scope
 246 | 
 247 |       // Decrypt the data using AES-GCM
 248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
 249 | 
 250 |       return .success(decrypted)

Sources/SecurityImplementation/Sources/CryptoService.swift:266:13: error: cannot find 'CryptoWrapper' in scope
 264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
 265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
 266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
     |             `- error: cannot find 'CryptoWrapper' in scope
 267 |     return .success(key)
 268 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:279:20: error: cannot find 'CryptoWrapper' in scope
 277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
 278 |     // Use SHA-256 through CryptoWrapper
 279 |     let hashedData=CryptoWrapper.sha256(data)
     |                    `- error: cannot find 'CryptoWrapper' in scope
 280 |     return .success(hashedData)
 281 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:295:22: error: cannot find 'CryptoWrapper' in scope
 293 |     againstHash hash: SecureBytes
 294 |   ) async -> Result<Bool, SecurityError> {
 295 |     let computedHash=CryptoWrapper.sha256(data)
     |                      `- error: cannot find 'CryptoWrapper' in scope
 296 |     // Compare the computed hash with the expected hash
 297 |     let result=computedHash == hash

Sources/SecurityImplementation/Sources/CryptoService.swift:309:22: error: cannot find 'CryptoWrapper' in scope
 307 |   /// Simplified version that returns a boolean directly instead of a Result type.
 308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
 309 |     let computedHash=CryptoWrapper.sha256(data)
     |                      `- error: cannot find 'CryptoWrapper' in scope
 310 |     return computedHash == hash
 311 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:327:17: error: cannot find 'CryptoWrapper' in scope
 325 |   ) async -> Result<SecureBytes, SecurityError> {
 326 |     // Use HMAC-SHA256 through CryptoWrapper
 327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
     |                 `- error: cannot find 'CryptoWrapper' in scope
 328 |     return .success(macData)
 329 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:346:21: error: cannot find 'CryptoWrapper' in scope
 344 |     using key: SecureBytes
 345 |   ) async -> Result<Bool, SecurityError> {
 346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
     |                     `- error: cannot find 'CryptoWrapper' in scope
 347 |     let result=computedMAC == mac
 348 |     return .success(result)

Sources/SecurityImplementation/Sources/CryptoService.swift:375:45: error: cannot find 'CryptoWrapper' in scope
 373 |     do {
 374 |       // Use AES-GCM for symmetric encryption
 375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
     |                                             `- error: cannot find 'CryptoWrapper' in scope
 376 | 
 377 |       // Encrypt the data

Sources/SecurityImplementation/Sources/CryptoService.swift:378:25: error: cannot find 'CryptoWrapper' in scope
 376 | 
 377 |       // Encrypt the data
 378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
 379 | 
 380 |       // Return IV + encrypted data unless IV is provided in config

Sources/SecurityImplementation/Sources/CryptoService.swift:440:25: error: cannot find 'CryptoWrapper' in scope
 438 | 
 439 |       // Decrypt the data
 440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
     |                         `- error: cannot find 'CryptoWrapper' in scope
 441 | 
 442 |       return SecurityResultDTO(success: true, data: decrypted)

Sources/SecurityImplementation/Sources/CryptoService.swift:492:14: error: cannot find 'CryptoWrapper' in scope
 490 | 
 491 |     // Generate a seed for the "key pair"
 492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
     |              `- error: cannot find 'CryptoWrapper' in scope
 493 | 
 494 |     // Generate "public" and "private" keys from the seed

Sources/SecurityImplementation/Sources/CryptoService.swift:495:20: error: cannot find 'CryptoWrapper' in scope
 493 | 
 494 |     // Generate "public" and "private" keys from the seed
 495 |     let privateKey=CryptoWrapper.sha256(seed)
     |                    `- error: cannot find 'CryptoWrapper' in scope
 496 |     var publicKeyBytes=privateKey.bytes()
 497 | 

Sources/SecurityImplementation/Sources/CryptoService.swift:500:24: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
 498 |     // Ensure we have bytes to modify
 499 |     guard !publicKeyBytes.isEmpty else {
 500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
     |                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
 501 |     }
 502 | 

Sources/SecurityImplementation/Sources/CryptoService.swift:745:14: error: cannot find 'CryptoWrapper' in scope
 743 | 
 744 |     // Generate a seed for the "key pair"
 745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
     |              `- error: cannot find 'CryptoWrapper' in scope
 746 | 
 747 |     // Generate "public" and "private" keys from the seed

Sources/SecurityImplementation/Sources/CryptoService.swift:748:20: error: cannot find 'CryptoWrapper' in scope
 746 | 
 747 |     // Generate "public" and "private" keys from the seed
 748 |     let privateKey=CryptoWrapper.sha256(seed)
     |                    `- error: cannot find 'CryptoWrapper' in scope
 749 |     var publicKeyBytes=privateKey.bytes()
 750 | 

Sources/SecurityImplementation/Sources/CryptoService.swift:755:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
 753 |       return SecurityResultDTO(
 754 |         success: false,
 755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
     |                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
 756 |       )
 757 |     }

Sources/SecurityImplementation/Sources/CryptoService.swift:810:14: error: cannot find 'CryptoWrapper' in scope
 808 |     }
 809 | 
 810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
     |              `- error: cannot find 'CryptoWrapper' in scope
 811 | 
 812 |     // Get the byte arrays safely

Sources/SecurityImplementation/Sources/CryptoService.swift:864:14: error: cannot find 'CryptoWrapper' in scope
 862 |     }
 863 | 
 864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
     |              `- error: cannot find 'CryptoWrapper' in scope
 865 | 
 866 |     // Get the byte arrays safely

Sources/SecurityImplementation/Sources/CryptoService.swift:923:19: error: cannot find 'CryptoWrapper' in scope
 921 |     // Use HMAC-SHA256 as a basic signing mechanism
 922 |     // In a real implementation, this would use an asymmetric signature algorithm
 923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
     |                   `- error: cannot find 'CryptoWrapper' in scope
 924 |     return .success(signature)
 925 |   }

Sources/SecurityImplementation/Sources/CryptoService.swift:971:27: error: cannot find 'CryptoWrapper' in scope
 969 |     using key: SecureBytes
 970 |   ) async -> Result<Bool, SecurityError> {
 971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
     |                           `- error: cannot find 'CryptoWrapper' in scope
 972 |     let result=computedSignature == signature
 973 |     return .success(result)

Sources/SecurityImplementation/Sources/CryptoService.swift:997:22: error: cannot find 'CryptoWrapper' in scope
 995 | 
 996 |       // Generate random bytes using CryptoKit's secure random number generator
 997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
     |                      `- error: cannot find 'CryptoWrapper' in scope
 998 | 
 999 |       if status {

Sources/SecurityImplementation/Sources/CryptoService.swift:1062:8: error: cannot find 'isEmpty' in scope
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
1062 |     if isEmpty {
     |        `- error: cannot find 'isEmpty' in scope
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
1064 |     }

Sources/SecurityImplementation/Sources/CryptoService.swift:1066:21: error: cannot find 'CryptoWrapper' in scope
1064 |     }
1065 | 
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
     |                     `- error: cannot find 'CryptoWrapper' in scope
1067 |   }
1068 | }

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:14:15: error: method cannot be declared public because its result uses an internal type
 12 |   // MARK: - CryptoServiceProtocol Implementation
 13 | 
 14 |   public func encrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 15 |     data: SecureBytes,
 16 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:37:15: error: method cannot be declared public because its result uses an internal type
 35 |   }
 36 | 
 37 |   public func decrypt(
    |               `- error: method cannot be declared public because its result uses an internal type
 38 |     data: SecureBytes,
 39 |     using key: SecureBytes

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:60:15: error: method cannot be declared public because its result uses an internal type
 58 |   }
 59 | 
 60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 61 |     // Generate a 256-bit key (32 bytes)
 62 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:66:15: error: method cannot be declared public because its result uses an internal type
 64 |   }
 65 | 
 66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 67 |     let hashedData=CryptoWrapper.sha256(data)
 68 |     return .success(hashedData)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:79:15: error: method cannot be declared public because its result uses an internal type
 77 |   /// - Parameter length: The length of random data to generate in bytes
 78 |   /// - Returns: Result containing random data or error
 79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 80 |     do {
 81 |       var randomBytes=[UInt8](repeating: 0, count: length)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift:6:20: error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
  4 | 
  5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
  6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
    |                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
  7 | 
  8 |   // MARK: - Initialization
    :
 69 |   }
 70 | 
 71 |   public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes) async -> Bool'
 72 |     let computedHash=CryptoWrapper.sha256(data)
 73 |     return computedHash == hash
    :
100 |   // MARK: - Symmetric Encryption
101 | 
102 |   public func encryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
103 |     data: SecureBytes,
104 |     key: SecureBytes,
    :
133 |   }
134 | 
135 |   public func decryptSymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
136 |     data: SecureBytes,
137 |     key: SecureBytes,
    :
176 |   // MARK: - Asymmetric Encryption
177 | 
178 |   public func encryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
179 |     data _: SecureBytes,
180 |     publicKey _: SecureBytes,
    :
189 |   }
190 | 
191 |   public func decryptAsymmetric(
    |               `- note: candidate has non-matching type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
192 |     data _: SecureBytes,
193 |     privateKey _: SecureBytes,
    :
204 |   // MARK: - Hashing
205 | 
206 |   public func hash(
    |               `- note: candidate has non-matching type '(SecureBytes, SecurityConfigDTO) async -> SecurityResultDTO'
207 |     data: SecureBytes,
208 |     config _: SecurityConfigDTO

/Users/mpy/.bazel/execroot/_main/Sources/SecurityProtocolsCore/Sources/Protocols/CryptoServiceProtocol.swift:38:8: note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 36 |   ///   - hash: The expected hash value as `SecureBytes`.
 37 |   /// - Returns: Boolean indicating whether the hash matches.
 38 |   func verify(data: SecureBytes, against hash: SecureBytes) async
    |        `- note: protocol requires function 'verify(data:against:)' with type '(SecureBytes, SecureBytes) async -> Result<Bool, UmbraErrors.Security.Protocols>'
 39 |     -> Result<Bool, UmbraErrors.Security.Protocols>
 40 | 
    :
 47 |   ///   - config: Configuration options
 48 |   /// - Returns: Result containing encrypted data or error
 49 |   func encryptSymmetric(
    |        `- note: protocol requires function 'encryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 50 |     data: SecureBytes,
 51 |     key: SecureBytes,
    :
 59 |   ///   - config: Configuration options
 60 |   /// - Returns: Result containing decrypted data or error
 61 |   func decryptSymmetric(
    |        `- note: protocol requires function 'decryptSymmetric(data:key:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 62 |     data: SecureBytes,
 63 |     key: SecureBytes,
    :
 73 |   ///   - config: Configuration options
 74 |   /// - Returns: Result containing encrypted data or error
 75 |   func encryptAsymmetric(
    |        `- note: protocol requires function 'encryptAsymmetric(data:publicKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 76 |     data: SecureBytes,
 77 |     publicKey: SecureBytes,
    :
 85 |   ///   - config: Configuration options
 86 |   /// - Returns: Result containing decrypted data or error
 87 |   func decryptAsymmetric(
    |        `- note: protocol requires function 'decryptAsymmetric(data:privateKey:config:)' with type '(SecureBytes, SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
 88 |     data: SecureBytes,
 89 |     privateKey: SecureBytes,
    :
 98 |   ///   - config: Configuration options including algorithm selection
 99 |   /// - Returns: Result containing hash or error
100 |   func hash(
    |        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:28:15: error: method cannot be declared public because its result uses an internal type
 26 |   // MARK: - KeyManagementProtocol Implementation
 27 | 
 28 |   public func retrieveKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
 29 |   -> Result<SecureBytes, SecurityError> {
 30 |     // If secure storage is available, use it

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:55:15: error: method cannot be declared public because its result uses an internal type
 53 |   }
 54 | 
 55 |   public func storeKey(
    |               `- error: method cannot be declared public because its result uses an internal type
 56 |     _ key: SecureBytes,
 57 |     withIdentifier identifier: String

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:77:15: error: method cannot be declared public because its result uses an internal type
 75 |   }
 76 | 
 77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
 78 |     // If secure storage is available, use it
 79 |     if let secureStorage {

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:105:15: error: method cannot be declared public because its result uses an internal type
103 |   }
104 | 
105 |   public func rotateKey(
    |               `- error: method cannot be declared public because its result uses an internal type
106 |     withIdentifier identifier: String,
107 |     dataToReencrypt: SecureBytes?

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:171:15: error: method cannot be declared public because its result uses an internal type
169 |   }
170 | 
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
172 |     // If secure storage is available, it should provide a way to list keys
173 |     // For now, we'll just return the in-memory keys

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:97:15: error: method cannot be declared public because its result uses an internal type
 95 |   /// - Parameter identifier: The identifier of the key to retrieve
 96 |   /// - Returns: The key or an error if the key does not exist
 97 |   public func retrieveKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
 98 |   -> Result<SecureBytes, SecurityError> {
 99 |     if let key=await keyStorage.get(identifier: identifier) {

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:111:15: error: method cannot be declared public because its result uses an internal type
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
    |               `- error: method cannot be declared public because its result uses an internal type
112 |     _ key: SecureBytes,
113 |     withIdentifier identifier: String

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:122:15: error: method cannot be declared public because its result uses an internal type
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
123 |     if await keyStorage.contains(identifier: identifier) {
124 |       await keyStorage.remove(identifier: identifier)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:136:15: error: method cannot be declared public because its result uses an internal type
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
    |               `- error: method cannot be declared public because its result uses an internal type
137 |     withIdentifier identifier: String,
138 |     dataToReencrypt: SecureBytes?

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:213:15: error: method cannot be declared public because its result uses an internal type
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
    |               `- error: method cannot be declared public because its result uses an internal type
214 |   -> Result<SecureBytes, SecurityError> {
215 |     // Delegate to the full rotation method

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:229:15: error: method cannot be declared public because its result uses an internal type
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
230 |     let identifiers=await keyStorage.allIdentifiers()
231 |     return .success(identifiers)

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/KeyManager.swift:237:15: error: method cannot be declared public because its result uses an internal type
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
    |               `- error: method cannot be declared public because its result uses an internal type
238 |     // Basic implementation that delegates to CryptoService
239 |     let crypto=CryptoService()

Sources/SecurityImplementation/Sources/CryptoService.swift:31:11: note: type declared here
  29 | 
  30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
  31 | typealias SecurityError=UmbraErrors.Security.Protocols
     |           `- note: type declared here
  32 | 
  33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations

Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift:52:57: error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
 50 |             return SecurityResultDTO.failure(
 51 |               code: 500,
 52 |               message: "Failed to generate key: \(error.description)"
    |                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
 53 |             )
 54 |           }

Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift:65:16: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 63 | 
 64 |         // Perform encryption
 65 |         return await cryptoService.encryptSymmetric(
    |                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 66 |           data: data,
 67 |           key: key,

Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift:90:16: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 88 | 
 89 |         // Perform hashing
 90 |         return await cryptoService.hash(data: data, config: config)
    |                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
 91 | 
 92 |       case .macGeneration:

Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift:121:65: error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
119 |             return SecurityResultDTO.failure(
120 |               code: 500,
121 |               message: "Failed to generate random data: \(error.description)"
    |                                                                 `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
122 |             )
123 |           }

Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift:139:57: error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
137 |             return SecurityResultDTO.failure(
138 |               code: 500,
139 |               message: "Failed to generate key: \(error.description)"
    |                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
140 |             )
141 |           }

Sources/SecurityImplementation/Sources/SecurityProvider.swift:130:22: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
128 |           switch keyResult {
129 |             case let .success(key):
130 |               return await cryptoService.encryptSymmetric(
    |                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
131 |                 data: config.inputData ?? SecureBytes(bytes: []),
132 |                 key: key,

Sources/SecurityImplementation/Sources/SecurityProvider.swift:141:18: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
139 |           }
140 |         } else if let key=config.key {
141 |           return await cryptoService.encryptSymmetric(
    |                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |             data: config.inputData ?? SecureBytes(bytes: []),
143 |             key: key,

Sources/SecurityImplementation/Sources/SecurityProvider.swift:157:22: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
155 |           switch keyResult {
156 |             case let .success(key):
157 |               return await cryptoService.decryptSymmetric(
    |                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
158 |                 data: config.inputData ?? SecureBytes(bytes: []),
159 |                 key: key,

Sources/SecurityImplementation/Sources/SecurityProvider.swift:168:18: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
166 |           }
167 |         } else if let key=config.key {
168 |           return await cryptoService.decryptSymmetric(
    |                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
169 |             data: config.inputData ?? SecureBytes(bytes: []),
170 |             key: key,

Sources/SecurityImplementation/Sources/SecurityProvider.swift:180:16: error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
178 | 
179 |       case .hashing:
180 |         return await cryptoService.hash(
    |                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
181 |           data: config.inputData ?? SecureBytes(bytes: []),
182 |           config: config
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityBridge/BUILD.bazel:3:14: Compiling Swift module //Sources/SecurityBridge:SecurityBridge failed: (Exit 1): worker failed: error executing SwiftCompile command (from target //Sources/SecurityBridge:SecurityBridge) 
  (cd /Users/mpy/.bazel/execroot/_main && \
  exec env - \
    APPLE_SDK_PLATFORM=MacOSX \
    APPLE_SDK_VERSION_OVERRIDE=15.2 \
    CC=clang \
    PATH=/Users/mpy/Library/Caches/bazelisk/downloads/sha256/ac72ad67f7a8c6b18bf605d8602425182b417de4369715bf89146daf62f7ae48/bin:/Users/mpy/.rbenv/bin:/Users/mpy/.codeium/windsurf/bin:/opt/homebrew/opt/node@18/bin:/opt/homebrew/opt/node@20/bin:/opt/anaconda3/bin:/opt/anaconda3/condabin:/Users/mpy/.docker/bin:/opt/homebrew/opt/openjdk/bin:/Users/mpy/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/go/bin:/Users/mpy/.cargo/bin:/Users/mpy/Library/Python/3.8/bin:/Users/mpy/go/bin:/Users/mpy/.scripts:/Users/mpy/.fzf/bin \
    XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
  bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityBridge/SecurityBridge.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:371:36: error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
 369 | 
 370 |   public func generateKeyPair(
 371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
     |                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
 372 |     keyIdentifier: String? = nil
 373 |   ) async -> Result<

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:572:1: error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
 570 | // MARK: - XPCServiceProtocolStandard Conformance
 571 | 
 572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
     | `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
 573 |   @objc
 574 |   public func generateRandomData(length: Int) async -> NSObject? {

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:32:15: note: add '@objc' to expose this instance method to Objective-C
13 |   /// - Returns: YES if the service is responsive
14 |   @objc
15 |   func ping() async -> Bool
   |        `- note: requirement 'ping()' declared here
16 | 
17 |   /// Basic synchronisation of keys between XPC service and client
   :
30 | 
31 |   /// Default implementation of ping - always succeeds
32 |   public func ping() async -> Bool {
   |               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:572:1: error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
 570 | // MARK: - XPCServiceProtocolStandard Conformance
 571 | 
 572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
     | `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
 573 |   @objc
 574 |   public func generateRandomData(length: Int) async -> NSObject? {

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:981:16: error: invalid redeclaration of 'mapSecurityError'
 979 | extension XPCServiceAdapter {
 980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
 981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
     |                `- error: invalid redeclaration of 'mapSecurityError'
 982 |     if error.domain == "com.umbra.security.xpc" {
 983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:994:16: error: invalid redeclaration of 'processSecurityResult(_:transform:)'
 992 | 
 993 |   /// Process security operation result for Swift-based code
 994 |   private func processSecurityResult<T>(
     |                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
 995 |     _ result: NSObject?,
 996 |     transform: (NSData) -> T

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:1021:8: error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
     |        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
    |                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:168:22: error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
166 |   }
167 | 
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
    |                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:32:15: note: add '@objc' to expose this instance method to Objective-C
13 |   /// - Returns: YES if the service is responsive
14 |   @objc
15 |   func ping() async -> Bool
   |        `- note: requirement 'ping()' declared here
16 | 
17 |   /// Basic synchronisation of keys between XPC service and client
   :
30 | 
31 |   /// Default implementation of ping - always succeeds
32 |   public func ping() async -> Bool {
   |               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:168:22: error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
166 |   }
167 | 
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
    |                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 | 
Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:102:19: warning: no calls to throwing functions occur within 'try' expression
100 | 
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
    |                   `- warning: no calls to throwing functions occur within 'try' expression
103 |       return .success(isValid)
104 |     } catch {

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:104:7: warning: 'catch' block is unreachable because no errors are thrown in 'do' block
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
103 |       return .success(isValid)
104 |     } catch {
    |       `- warning: 'catch' block is unreachable because no errors are thrown in 'do' block
105 |       return .failure(mapError(error))
106 |     }

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:102:19: error: expression is 'async' but is not marked with 'await'
100 | 
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
    |                   |   `- note: call is 'async'
    |                   `- error: expression is 'async' but is not marked with 'await'
103 |       return .success(isValid)
104 |     } catch {

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:135:19: error: cannot find 'cryptoAlgorithmFrom' in scope
133 | 
134 |     // Extract configuration options if present
135 |     let algorithm=cryptoAlgorithmFrom(config)
    |                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
136 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
137 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:161:53: error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
150 | 
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
    |           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
153 |         data: dataToEncrypt,
154 |         key: keyData,
    :
158 |         aad: aadData,
159 |         options: config.options
160 |       ).data
    |         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
161 |       return .success(DataAdapter.secureBytes(from: resultData))
    |                                                     |- error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
    |                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
162 |     } catch {
163 |       return .failure(mapError(error))

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:152:22: warning: no calls to throwing functions occur within 'try' expression
150 | 
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
    |                      `- warning: no calls to throwing functions occur within 'try' expression
153 |         data: dataToEncrypt,
154 |         key: keyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:152:22: error: expression is 'async' but is not marked with 'await'
150 | 
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
    |                      |   `- note: call is 'async'
    |                      `- error: expression is 'async' but is not marked with 'await'
153 |         data: dataToEncrypt,
154 |         key: keyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:176:19: error: cannot find 'cryptoAlgorithmFrom' in scope
174 | 
175 |     // Extract configuration options if present
176 |     let algorithm=cryptoAlgorithmFrom(config)
    |                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
177 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
178 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:202:53: error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
191 | 
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
    |           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
194 |         data: encryptedData,
195 |         key: keyData,
    :
199 |         aad: aadData,
200 |         options: config.options
201 |       ).data
    |         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
202 |       return .success(DataAdapter.secureBytes(from: resultData))
    |                                                     |- error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
    |                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
203 |     } catch {
204 |       return .failure(mapError(error))

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:193:22: warning: no calls to throwing functions occur within 'try' expression
191 | 
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
    |                      `- warning: no calls to throwing functions occur within 'try' expression
194 |         data: encryptedData,
195 |         key: keyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:193:22: error: expression is 'async' but is not marked with 'await'
191 | 
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
    |                      |   `- note: call is 'async'
    |                      `- error: expression is 'async' but is not marked with 'await'
194 |         data: encryptedData,
195 |         key: keyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:218:22: error: cannot find 'cryptoAlgorithmFrom' in scope
216 |     // Configure options
217 |     var options: [String: Any]=[:]
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
    |                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
219 |       options["algorithm"]=algorithm
220 |     }

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:226:36: error: missing argument for parameter 'keySizeInBits' in call
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
226 |         algorithm: config.algorithm,
    |                                    `- error: missing argument for parameter 'keySizeInBits' in call
227 |         options: config.options
228 |       ).data
    :
337 | 
338 |   // Asymmetric encryption
339 |   func encryptAsymmetric(
    |        `- note: 'encryptAsymmetric(data:publicKey:algorithm:keySizeInBits:options:)' declared here
340 |     data: Data,
341 |     publicKey: Data,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:223:22: warning: no calls to throwing functions occur within 'try' expression
221 | 
222 |     do {
223 |       let resultData=try implementation.encryptAsymmetric(
    |                      `- warning: no calls to throwing functions occur within 'try' expression
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:245:22: error: cannot find 'cryptoAlgorithmFrom' in scope
243 |     // Configure options
244 |     var options: [String: Any]=[:]
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
    |                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
246 |       options["algorithm"]=algorithm
247 |     }

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:253:36: error: missing argument for parameter 'keySizeInBits' in call
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
253 |         algorithm: config.algorithm,
    |                                    `- error: missing argument for parameter 'keySizeInBits' in call
254 |         options: config.options
255 |       ).data
    :
346 | 
347 |   // Asymmetric decryption
348 |   func decryptAsymmetric(
    |        `- note: 'decryptAsymmetric(data:privateKey:algorithm:keySizeInBits:options:)' declared here
349 |     data: Data,
350 |     privateKey: Data,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:250:22: warning: no calls to throwing functions occur within 'try' expression
248 | 
249 |     do {
250 |       let resultData=try implementation.decryptAsymmetric(
    |                      `- warning: no calls to throwing functions occur within 'try' expression
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:269:19: error: cannot find 'cryptoAlgorithmFrom' in scope
267 | 
268 |     // Extract hash algorithm if specified
269 |     let algorithm=cryptoAlgorithmFrom(config)
    |                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
270 | 
271 |     // Configure options

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:283:53: error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
276 | 
277 |     do {
278 |       let resultData=try implementation.hash(
    |           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
281 |         options: config.options
282 |       ).data
    |         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
283 |       return .success(DataAdapter.secureBytes(from: resultData))
    |                                                     |- error: value of optional type 'Data?' must be unwrapped to a value of type 'Data'
    |                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
    |                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
284 |     } catch {
285 |       return .failure(mapError(error))

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:278:22: warning: no calls to throwing functions occur within 'try' expression
276 | 
277 |     do {
278 |       let resultData=try implementation.hash(
    |                      `- warning: no calls to throwing functions occur within 'try' expression
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,

Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift:278:22: error: expression is 'async' but is not marked with 'await'
276 | 
277 |     do {
278 |       let resultData=try implementation.hash(
    |                      |   `- note: call is 'async'
    |                      `- error: expression is 'async' but is not marked with 'await'
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:35:27: error: value of type 'Result<Data, any Error>' has no member 'data'
 33 |     let result=await implementation.retrieveKey(withIdentifier: identifier)
 34 | 
 35 |     if let keyData=result.data {
    |                           `- error: value of type 'Result<Data, any Error>' has no member 'data'
 36 |       return .success(DataAdapter.secureBytes(from: keyData))
 37 |     } else {

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:38:32: error: cannot find 'KMError' in scope
 36 |       return .success(DataAdapter.secureBytes(from: keyData))
 37 |     } else {
 38 |       return .failure(mapError(KMError.keyNotFound))
    |                                `- error: cannot find 'KMError' in scope
 39 |     }
 40 |   }

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:49:8: error: enum case 'success' cannot be used as an instance member
 47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
 48 | 
 49 |     if result.success {
    |        `- error: enum case 'success' cannot be used as an instance member
 50 |       return .success(())
 51 |     } else {

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:49:15: error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
 47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
 48 | 
 49 |     if result.success {
    |               `- error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
 50 |       return .success(())
 51 |     } else {

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:52:26: error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
 50 |       return .success(())
 51 |     } else {
 52 |       let message=result.errorMessage ?? "Unknown key storage error"
    |                          `- error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
 53 |       let error=KMError.keyStorageFailed(reason: message)
 54 |       return .failure(mapError(error))

Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift:53:17: error: cannot find 'KMError' in scope
 51 |     } else {
 52 |       let message=result.errorMessage ?? "Unknown key storage error"
 53 |       let error=KMError.keyStorageFailed(reason: message)
    |                 `- error: cannot find 'KMError' in scope
 54 |       return .failure(mapError(error))
 55 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:371:36: error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
 369 | 
 370 |   public func generateKeyPair(
 371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
     |                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
 372 |     keyIdentifier: String? = nil
 373 |   ) async -> Result<

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:572:1: error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
 570 | // MARK: - XPCServiceProtocolStandard Conformance
 571 | 
 572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
     | `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
 573 |   @objc
 574 |   public func generateRandomData(length: Int) async -> NSObject? {

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:32:15: note: add '@objc' to expose this instance method to Objective-C
13 |   /// - Returns: YES if the service is responsive
14 |   @objc
15 |   func ping() async -> Bool
   |        `- note: requirement 'ping()' declared here
16 | 
17 |   /// Basic synchronisation of keys between XPC service and client
   :
30 | 
31 |   /// Default implementation of ping - always succeeds
32 |   public func ping() async -> Bool {
   |               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:572:1: error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
 570 | // MARK: - XPCServiceProtocolStandard Conformance
 571 | 
 572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
     | `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
 573 |   @objc
 574 |   public func generateRandomData(length: Int) async -> NSObject? {

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:981:16: error: invalid redeclaration of 'mapSecurityError'
 979 | extension XPCServiceAdapter {
 980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
 981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
     |                `- error: invalid redeclaration of 'mapSecurityError'
 982 |     if error.domain == "com.umbra.security.xpc" {
 983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:994:16: error: invalid redeclaration of 'processSecurityResult(_:transform:)'
 992 | 
 993 |   /// Process security operation result for Swift-based code
 994 |   private func processSecurityResult<T>(
     |                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
 995 |     _ result: NSObject?,
 996 |     transform: (NSData) -> T

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:1021:8: error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
     |        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:84:61: error: missing argument for parameter 'completionHandler' in call
  82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
  83 |         let nsData=convertSecureBytesToNSData(secureBytes)
  84 |         let result=await serviceProxy.synchroniseKeys(nsData)
     |                                                             `- error: missing argument for parameter 'completionHandler' in call
  85 |         switch result {
  86 |           case .success:

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: 'synchroniseKeys(_:completionHandler:)' declared here
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:84:55: error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
  82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
  83 |         let nsData=convertSecureBytesToNSData(secureBytes)
  84 |         let result=await serviceProxy.synchroniseKeys(nsData)
     |                                                       `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
  85 |         switch result {
  86 |           case .success:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:116:13: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
 114 |       case .keyGenerationFailed:
 115 |         UmbraErrors.Security.Protocols.internalError("Key generation failed")
 116 |       case .invalidData:
     |             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
 117 |         UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data format")
 118 |       case .notImplemented:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:193:50: error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
 191 |       Task {
 192 |         // Use encryptData instead of encrypt
 193 |         let result=await serviceProxy.encryptData(
     |                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
 194 |           data: DataAdapter.data(from: data),
 195 |           key: keyData ?? Data()

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:194:29: error: cannot convert value of type 'Data' to expected argument type 'NSData'
 192 |         // Use encryptData instead of encrypt
 193 |         let result=await serviceProxy.encryptData(
 194 |           data: DataAdapter.data(from: data),
     |                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
 195 |           key: keyData ?? Data()
 196 |         )

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:195:24: error: cannot convert value of type 'Data' to expected argument type 'String?'
 193 |         let result=await serviceProxy.encryptData(
 194 |           data: DataAdapter.data(from: data),
 195 |           key: keyData ?? Data()
     |                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
 196 |         )
 197 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:225:50: error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
 223 |       Task {
 224 |         // Use decryptData instead of decrypt
 225 |         let result=await serviceProxy.decryptData(
     |                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
 226 |           data: DataAdapter.data(from: data),
 227 |           key: keyData ?? Data()

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:226:29: error: cannot convert value of type 'Data' to expected argument type 'NSData'
 224 |         // Use decryptData instead of decrypt
 225 |         let result=await serviceProxy.decryptData(
 226 |           data: DataAdapter.data(from: data),
     |                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
 227 |           key: keyData ?? Data()
 228 |         )

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:227:24: error: cannot convert value of type 'Data' to expected argument type 'String?'
 225 |         let result=await serviceProxy.decryptData(
 226 |           data: DataAdapter.data(from: data),
 227 |           key: keyData ?? Data()
     |                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
 228 |         )
 229 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:253:47: error: extraneous argument label 'data:' in call
 251 |       Task {
 252 |         // Use hashData instead of hash
 253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
     |                                               `- error: extraneous argument label 'data:' in call
 254 | 
 255 |         // Map the XPC result to the protocol result

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:253:66: error: cannot convert value of type 'Data' to expected argument type 'NSData'
 251 |       Task {
 252 |         // Use hashData instead of hash
 253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
     |                                                                  `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
 254 | 
 255 |         // Map the XPC result to the protocol result

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:273:72: error: argument 'success' must precede argument 'data'
 271 |     switch result {
 272 |       case let .success(hashData):
 273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
     |                                                                        `- error: argument 'success' must precede argument 'data'
 274 |       case let .failure(error):
 275 |         return SecurityProtocolsCore.SecurityResultDTO(success: false, error: error)

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:285:41: error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
 283 |     await withCheckedContinuation { continuation in
 284 |       Task {
 285 |         let result = await serviceProxy.verify(
     |                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
 286 |           data: DataAdapter.data(from: data),
 287 |           signature: DataAdapter.data(from: signature)

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:358:52: error: missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
 356 |     await withCheckedContinuation { continuation in
 357 |       Task {
 358 |         let result = await serviceProxy.generateKey()
     |                                                    `- error: missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
 359 |         // Map the XPC result to the protocol result
 360 |         switch result {

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolStandard.swift:97:8: note: 'generateKey(keyType:keyIdentifier:metadata:)' declared here
 95 |   ///   - metadata: Optional metadata to associate with the key
 96 |   /// - Returns: Identifier for the generated key
 97 |   func generateKey(
    |        `- note: 'generateKey(keyType:keyIdentifier:metadata:)' declared here
 98 |     keyType: KeyType,
 99 |     keyIdentifier: String?,

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:379:41: error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
 377 |     await withCheckedContinuation { continuation in
 378 |       Task {
 379 |         let result = await serviceProxy.generateKeyPair(
     |                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
 380 |           type: keyType.rawValue,
 381 |           identifier: keyIdentifier ?? ""

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:442:11: error: cannot convert value of type 'Data' to expected argument type 'SecureBytes'
 440 |         // Use storeSecurely which is the correct XPC method name
 441 |         let result=await serviceProxy.storeSecurely(
 442 |           dataBytes,
     |           `- error: cannot convert value of type 'Data' to expected argument type 'SecureBytes'
 443 |           identifier: identifier,
 444 |           metadata: nil

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:465:35: warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSError' always fails
 463 |         // Handle the result appropriately
 464 |         if let nsObject=result {
 465 |           if let nsError=nsObject as? NSError {
     |                                   `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSError' always fails
 466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
 467 |           } else if let data=nsObject as? NSData {

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:467:39: warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
 465 |           if let nsError=nsObject as? NSError {
 466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
 467 |           } else if let data=nsObject as? NSData {
     |                                       `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
 468 |             // Convert NSData to SecureBytes
 469 |             let dataBytes=[UInt8](Data(referencing: data))

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:464:12: error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
 462 | 
 463 |         // Handle the result appropriately
 464 |         if let nsObject=result {
     |            `- error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
 465 |           if let nsError=nsObject as? NSError {
 466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:520:39: error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
 518 |         let nsData=dataToReencrypt.map { convertSecureBytesToNSData($0) }
 519 | 
 520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
     |                                       `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
 521 | 
 522 |         if let nsObject=result {

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:582:40: error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 580 |           with: NSNumber(value: length)
 581 |         )?.takeRetainedValue()
 582 |         continuation.resume(returning: result)
     |                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 583 |       }
 584 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:597:40: error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 595 |           with: keyIdentifier as NSString?
 596 |         )?.takeRetainedValue()
 597 |         continuation.resume(returning: result)
     |                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 598 |       }
 599 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:612:40: error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 610 |           with: keyIdentifier as NSString?
 611 |         )?.takeRetainedValue()
 612 |         continuation.resume(returning: result)
     |                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 613 |       }
 614 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:624:40: error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 622 |         let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?
 623 |           .takeRetainedValue()
 624 |         continuation.resume(returning: result)
     |                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 625 |       }
 626 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:639:40: error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 637 |           with: keyIdentifier
 638 |         )?.takeRetainedValue()
 639 |         continuation.resume(returning: result)
     |                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
 640 |       }
 641 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:657:17: error: extra argument 'with' in call
 655 |           with: signature,
 656 |           with: data,
 657 |           with: keyIdentifier
     |                 `- error: extra argument 'with' in call
 658 |         )?.takeRetainedValue()
 659 |         continuation.resume(returning: result)

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:731:26: error: extra argument 'with' in call
 729 |           with: nsData,
 730 |           with: identifier,
 731 |           with: metadata as NSObject?
     |                          `- error: extra argument 'with' in call
 732 |         )
 733 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:752:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 750 |             .resume(returning: .failure(
 751 |               UmbraErrors.Security.Protocols
 752 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 753 |             ))
 754 |           return

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:787:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 785 |             .resume(returning: .failure(
 786 |               UmbraErrors.Security.Protocols
 787 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 788 |             ))
 789 |           return

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:826:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 824 |             .resume(returning: .failure(
 825 |               UmbraErrors.Security.Protocols
 826 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 827 |             ))
 828 |         }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:849:26: error: extra argument 'with' in call
 847 |           with: keyType.rawValue,
 848 |           with: keyIdentifier as NSString?,
 849 |           with: metadata as NSDictionary?
     |                          `- error: extra argument 'with' in call
 850 |         )?.takeRetainedValue() as? NSString
 851 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:883:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 881 |             .resume(returning: .failure(
 882 |               UmbraErrors.Security.Protocols
 883 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 884 |             ))
 885 |           return

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:922:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 920 |             .resume(returning: .failure(
 921 |               UmbraErrors.Security.Protocols
 922 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 923 |             ))
 924 |         }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:944:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 942 |             .resume(returning: .failure(
 943 |               UmbraErrors.Security.Protocols
 944 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 945 |             ))
 946 |           return

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:966:18: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 964 |             .resume(returning: .failure(
 965 |               UmbraErrors.Security.Protocols
 966 |                 .invalidFormat(reason: "Invalid data")
     |                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
 967 |             ))
 968 |           return

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
    |                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:168:22: error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
166 |   }
167 | 
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
    |                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:32:15: note: add '@objc' to expose this instance method to Objective-C
13 |   /// - Returns: YES if the service is responsive
14 |   @objc
15 |   func ping() async -> Bool
   |        `- note: requirement 'ping()' declared here
16 | 
17 |   /// Basic synchronisation of keys between XPC service and client
   :
30 | 
31 |   /// Default implementation of ping - always succeeds
32 |   public func ping() async -> Bool {
   |               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:168:22: error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
166 |   }
167 | 
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
    |                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:101:60: error: missing argument for parameter 'completionHandler' in call
 99 | 
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
    |                                                            `- error: missing argument for parameter 'completionHandler' in call
102 | 
103 |         // Process the result

/Users/mpy/.bazel/execroot/_main/Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift:21:8: note: 'synchroniseKeys(_:completionHandler:)' declared here
19 |   /// - Parameter completionHandler: Called with nil if successful, or NSError if failed
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
   |        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 | 

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:101:54: error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
 99 | 
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
    |                                                      `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
102 | 
103 |         // Process the result

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:200:56: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
198 |         return .success(nsNumber.boolValue)
199 |       } else {
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
    |                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
201 |       }
202 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:276:56: error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
274 |         return .success(nsString as String)
275 |       } else {
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
    |                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
277 |       }
278 |     }

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:312:21: error: cannot find 'SecurityProtocolError' in scope
310 |                 returning: .failure(
311 |                   self.mapSecurityProtocolError(
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
    |                     `- error: cannot find 'SecurityProtocolError' in scope
313 |                   )
314 |                 )

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:341:17: error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
    |                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:343:17: error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
    |                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:345:17: error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
    |                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:349:17: error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
    |                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:338:45: error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
336 |         switch securityError {
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
    |                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:340:45: error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
    |                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:342:45: error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
    |                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:344:51: error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
    |                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:346:45: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
    |                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:348:45: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
    |                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:350:45: error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
    |                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:352:51: error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    |                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:354:45: error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
    |                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:356:51: error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    |                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
357 |         }
358 |       } else {

Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:360:47: error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
358 |       } else {
359 |         // Map generic error to appropriate error
360 |         return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
    |                                               `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
361 |       }
362 |     }
INFO: Build succeeded for only 109 of 171 top-level targets
INFO: Found 171 targets...
INFO: Elapsed time: 8.043s, Critical Path: 7.84s
INFO: 89 processes: 64 action cache hit, 5 internal, 13 local, 71 worker.
ERROR: Build did NOT complete successfully
