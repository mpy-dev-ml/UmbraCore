import CoreErrors
import CoreTypesInterfaces
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining Foundation-dependent XPC security service.
/// This protocol is designed for use with Foundation-based security implementations.
///
/// **Migration Notice:**
/// This protocol is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolComplete` from the XPCProtocolsCore module instead.
///
/// Migration steps:
/// 1. Replace implementations of FoundationXPCSecurityService with XPCServiceProtocolComplete
/// 2. Use XPCProtocolMigrationFactory.createCompleteAdapter() to create a service instance
///
/// See `XPCProtocolMigrationGuide` in XPCProtocolsCore for comprehensive migration guidance.
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
@objc
public protocol FoundationXPCSecurityService: NSObjectProtocol, Sendable {
    // MARK: - Crypto Operations

    /// Encrypt data using XPC
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - completion: Completion handler called with encrypted data or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.encrypt instead")
    func encryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)

    /// Decrypt data using XPC
    /// - Parameters:
    ///   - data: The data to decrypt
    ///   - completion: Completion handler called with decrypted data or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.decrypt instead")
    func decryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)

    /// Generate random data using XPC
    /// - Parameters:
    ///   - length: Length of random data to generate
    ///   - completion: Completion handler called with generated data or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.generateRandomData instead")
    func generateRandomDataXPC(
        _ length: Int,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    )

    /// Hash data using XPC
    /// - Parameters:
    ///   - data: The data to hash
    ///   - completion: Completion handler called with hash data or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.hash instead")
    func hashDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)

    /// Sign data using XPC
    /// - Parameters:
    ///   - data: The data to sign
    ///   - algorithm: The algorithm to use for signing
    ///   - completion: Completion handler called with signature or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.sign instead")
    func signDataXPC(
        _ data: Data,
        algorithm: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    )

    /// Verify data against signature using XPC
    /// - Parameters:
    ///   - data: The data to verify
    ///   - signature: The signature to verify against
    ///   - algorithm: The algorithm used for signing
    ///   - completion: Completion handler called with verification result
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.verify instead")
    func verifyDataXPC(
        _ data: Data,
        signature: Data,
        algorithm: String,
        completion: @escaping (NSNumber?, NSNumber?, String?) -> Void
    )

    // MARK: - Key Management

    /// Retrieve a key by ID using XPC
    /// - Parameters:
    ///   - identifier: The key identifier
    ///   - completion: Completion handler called with key data or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.retrieveKey instead")
    func retrieveKeyXPC(
        withIdentifier identifier: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    )

    /// Store a key with ID using XPC
    /// - Parameters:
    ///   - key: The key data to store
    ///   - identifier: The key identifier
    ///   - completion: Completion handler called with result
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.storeKey instead")
    func storeKeyXPC(
        _ key: Data,
        withIdentifier identifier: String,
        completion: @escaping (NSNumber?, String?) -> Void
    )

    /// List all key identifiers using XPC
    /// - Parameter completion: Completion handler called with list of identifiers or error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.listKeyIdentifiers instead")
    func listKeyIdentifiers(completion: @escaping ([String]?, Error?) -> Void)
}

/// Protocol defining Foundation-dependent XPC service interface.
/// This protocol is designed to work with the Objective-C runtime and NSXPCConnection.
///
/// **Migration Notice:**
/// This protocol is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolComplete` from the XPCProtocolsCore module instead.
///
/// Migration steps:
/// 1. Replace implementations of XPCServiceProtocolFoundationBridge with XPCServiceProtocolComplete
/// 2. Use XPCProtocolMigrationFactory.createCompleteAdapter() to create a service instance
///
/// See `XPCProtocolMigrationGuide` in XPCProtocolsCore for comprehensive migration guidance.
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
@objc
// REMOVED: // REMOVED: public protocol XPCServiceProtocolFoundationBridge: NSObjectProtocol { (Removed by deprecation_remover) (Removed by deprecation_remover)
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test connectivity with a Foundation-based reply
    /// - Parameter reply: Reply block that is called with result and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.ping instead")
    func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)

    /// Synchronize keys across processes with a Foundation-based reply
    /// - Parameters:
    ///   - syncData: The key data to synchronize
    ///   - reply: Reply block that is called when the operation completes
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.synchroniseKeys instead")
    func synchroniseKeysFoundation(
        _ syncData: Data,
        withReply reply: @escaping @Sendable (Error?) -> Void
    )

    /// Encrypt data using Foundation types
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - reply: Reply block with encrypted data and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.encrypt instead")
    func encryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)

    /// Decrypt data using Foundation types
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - reply: Reply block with decrypted data and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.decrypt instead")
    func decryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)

    /// Generate random data using Foundation types
    /// - Parameters:
    ///   - length: Length of random data to generate
    ///   - reply: Reply block with generated data and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.generateRandomData instead")
    func generateRandomDataFoundation(
        _ length: Int,
        withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    )

    /// Reset security data with a Foundation-based reply
    /// - Parameter reply: Reply block that is called with optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.resetSecurityData instead")
    func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void)

    /// Get version with a Foundation-based reply
    /// - Parameter reply: Reply block that is called with version string and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.getVersion instead")
    func getVersionFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)

    /// Get host identifier with a Foundation-based reply
    /// - Parameter reply: Reply block that is called with identifier string and optional error
    @available(*, deprecated, message: "Use XPCServiceProtocolComplete.getHostIdentifier instead")
    func getHostIdentifierFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)
}

/// Adapter to convert between Core and Foundation XPC service protocols
///
/// **Migration Notice:**
/// This adapter is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolComplete` from XPCProtocolsCore module directly.
///
/// Migration steps:
/// 1. Replace usage of this adapter with direct use of XPCServiceProtocolComplete
/// 2. Update client code to use async/await patterns
///
/// See `XPCProtocolMigrationGuide` in XPCProtocolsCore for comprehensive migration guidance.
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
public final class CoreTypesToFoundationBridgeAdapter: NSObject,
    XPCServiceProtocolFoundationBridge, @unchecked Sendable {
    public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.foundation.outgoing"

    private let coreService: any ComprehensiveSecurityServiceProtocol

    public init(wrapping coreService: any ComprehensiveSecurityServiceProtocol) {
        self.coreService = coreService
        super.init()
    }

    public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        Task {
            // Check if the service is available by requesting a version
            _ = await coreService.getServiceVersion()
            // If we got here without crashing, the service is available
            reply(true, nil)
        }
    }

    public func synchroniseKeysFoundation(
        _ syncData: Data,
        withReply reply: @escaping @Sendable (Error?) -> Void
    ) {
        Task {
            // Convert Data to NSData for processing
            let nsData = syncData as NSData

            // Extract bytes from NSData to conform to protocol
            let length = nsData.length
            var bytes = [UInt8](repeating: 0, count: length)
            nsData.getBytes(&bytes, length: length)

            // Use the @objc compatible version that takes NSData
            var errorToReturn: NSError?
            coreService.synchroniseKeys(bytes) { error in
                errorToReturn = error
            }

            // Process the result
            reply(errorToReturn)
        }
    }

    public func generateRandomDataFoundation(
        _: Int,
        withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'generateRandomData' not available in XPCServiceProtocolBasic"
        ])
        reply(nil, error)
    }

    public func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'resetSecurityData' not available in XPCServiceProtocolBasic"
        ])
        reply(error)
    }

    public func getVersionFoundation(
        withReply reply: @escaping @Sendable (String?, Error?) -> Void
    ) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'getVersion' not available in XPCServiceProtocolBasic"
        ])
        reply(nil, error)
    }

    public func getHostIdentifierFoundation(
        withReply reply: @escaping @Sendable (String?, Error?) -> Void
    ) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'getHostIdentifier' not available in XPCServiceProtocolBasic"
        ])
        reply(nil, error)
    }

    public func encryptFoundation(
        data _: Data,
        withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'encrypt' not available in XPCServiceProtocolBasic"
        ])
        reply(nil, error)
    }

    public func decryptFoundation(
        data _: Data,
        withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
        let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Method 'decrypt' not available in XPCServiceProtocolBasic"
        ])
        reply(nil, error)
    }
}

/// Adapter to bridge from Foundation protocol to core service protocol.
/// Allows Foundation XPC protocol to be used with the core service implementations.
///
/// **Migration Notice:**
/// This adapter is deprecated and will be removed in a future release.
/// Please use `XPCServiceProtocolComplete` from XPCProtocolsCore module directly.
///
/// Migration steps:
/// 1. Replace usage of this adapter with direct use of XPCServiceProtocolComplete
/// 2. Update client code to use async/await patterns
///
/// See `XPCProtocolMigrationGuide` in XPCProtocolsCore for comprehensive migration guidance.
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
    @unchecked Sendable {
    public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.foundation.bridge"

    private let foundation: any XPCServiceProtocolFoundationBridge

    public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
        self.foundation = foundation
        super.init()
    }

    @objc
    public func ping() async -> Bool {
        await withCheckedContinuation { continuation in
            foundation.pingFoundation { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    @objc
    public func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Convert [UInt8] to Data
        let data = Data(bytes)

        foundation.synchroniseKeysFoundation(data) { error in
            completionHandler(error as NSError?)
        }
    }

    // Swift-friendly ping that returns Result
    public func pingWithResult() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
        let success = await ping()
        return .success(success)
    }

    // Swift-friendly SecureBytes version
    public func synchroniseKeys(_ syncData: SecureBytes) async
        -> Result<Void, XPCProtocolsCore.SecurityError> {
        await withCheckedContinuation { continuation in
            // Convert SecureBytes to [UInt8]
            let bytes = [UInt8](syncData)

            synchroniseKeys(bytes) { error in
                if let error {
                    continuation.resume(returning: .failure(self.mapXPCError(error)))
                } else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }

    @objc
    public func resetSecurityData() async -> NSObject? {
        await withCheckedContinuation { continuation in
            foundation.resetSecurityDataFoundation { error in
                if let error {
                    continuation.resume(returning: error as NSError)
                } else {
                    continuation.resume(returning: NSNull())
                }
            }
        }
    }

    @objc
    public func getServiceVersion() async -> NSObject? {
        await withCheckedContinuation { continuation in
            foundation.getVersionFoundation { versionString, error in
                if let error {
                    continuation.resume(returning: error as NSError)
                } else if let versionString {
                    continuation.resume(returning: versionString as NSString)
                } else {
                    let error = NSError(
                        domain: "XPCErrorDomain",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Version not available"]
                    )
                    continuation.resume(returning: error)
                }
            }
        }
    }

    // Swift-friendly version with Result type
    public func getVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        let result = await getServiceVersion()
        if let nsError = result as? NSError {
            return .failure(mapXPCError(nsError))
        } else if let nsString = result as? NSString {
            return .success(nsString as String)
        } else {
            return .failure(
                XPCProtocolsCore.SecurityError
                    .internalError(reason: "Invalid version format")
            )
        }
    }

    @objc
    public func getHostIdentifier() async -> NSObject? {
        await withCheckedContinuation { continuation in
            foundation.getHostIdentifierFoundation { hostIdentifier, error in
                if let error {
                    continuation.resume(returning: error as NSError)
                } else if let hostIdentifier {
                    continuation.resume(returning: hostIdentifier as NSString)
                } else {
                    let error = NSError(
                        domain: "XPCErrorDomain",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Host identifier not available"]
                    )
                    continuation.resume(returning: error)
                }
            }
        }
    }

    public func generateRandomData(length: Int) async
        -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
        await withCheckedContinuation { continuation in
            self.foundation.generateRandomDataFoundation(length) { data, error in
                if let error {
                    continuation.resume(returning: .failure(self.mapXPCError(error)))
                } else if let data {
                    continuation.resume(returning: .success(XPCDataAdapter.secureBytes(from: data)))
                } else {
                    continuation
                        .resume(
                            returning: .failure(
                                XPCProtocolsCore.SecurityError
                                    .internalError(reason: "Random data generation failed")
                            )
                        )
                }
            }
        }
    }

    // MARK: - Error Handling

    /// Maps any error to the XPCProtocolsCore.SecurityError domain
    ///
    /// This helper method provides a standardised way of handling errors throughout the XPC bridge.
    /// It delegates to the centralised mapper for consistent error handling across the codebase.
    ///
    /// - Parameter error: The error to map
    /// - Returns: A properly mapped XPCProtocolsCore.SecurityError
    private func mapXPCError(_ error: Error) -> XPCProtocolsCore.SecurityError {
        if let securityError = error as? XPCProtocolsCore.SecurityError {
            return securityError
        } else if let securityError = error as? UmbraErrors.Security.Protocols {
            // Convert from UmbraErrors.Security.Protocols to XPCProtocolsCore.SecurityError
            switch securityError {
            case .encryptionFailed:
                return .cryptographicError(
                    operation: "encryption",
                    details: "Encryption operation failed"
                )
            case .decryptionFailed:
                return .cryptographicError(
                    operation: "decryption",
                    details: "Decryption operation failed"
                )
            case let .internalError(message):
                return .internalError(reason: message)
            case .invalidFormat, .invalidInput:
                return .invalidInput(details: "Invalid data format or input")
            case .missingProtocolImplementation, .unsupportedOperation, .notImplemented:
                return .operationNotSupported(name: "The requested operation")
            case .incompatibleVersion, .invalidState, .randomGenerationFailed, .serviceError,
                 .storageOperationFailed:
                return .serviceNotReady(reason: "Service is not in correct state")
            @unknown default:
                return .internalError(reason: error.localizedDescription)
            }
        } else if let xpcSecurityError = error as? XPCSecurityError {
            switch xpcSecurityError {
            case .serviceUnavailable:
                return .serviceUnavailable
            case .connectionInterrupted:
                return .serviceNotReady(reason: "Connection interrupted")
            case let .connectionInvalidated(reason):
                return .serviceNotReady(reason: "Connection invalidated: \(reason)")
            case let .invalidState(details):
                return .serviceNotReady(reason: "Invalid state: \(details)")
            case let .invalidKeyType(expected, received):
                return .invalidInput(details: "Expected key type \(expected), received \(received)")
            case let .keyNotFound(identifier):
                return .invalidInput(details: "Key not found: \(identifier)")
            case let .cryptographicError(operation, details):
                return .invalidInput(details: "Cryptographic operation failed: \(operation) - \(details)")
            case let .internalError(reason):
                return .internalError(reason: reason)
            case let .operationNotSupported(name):
                return .operationNotSupported(name: name)
            case let .invalidInput(details):
                return .invalidInput(details: details)
            case let .serviceNotReady(reason):
                return .serviceNotReady(reason: reason)
            case let .timeout(after):
                return .timeout(after: after)
            case let .authenticationFailed(reason):
                return .authenticationFailed(reason: reason)
            case let .authorizationDenied(operation):
                return .authorizationDenied(operation: operation)
            @unknown default:
                return .internalError(reason: "Unknown XPC security error")
            }
        } else {
            // Map generic error to appropriate error
            return .internalError(reason: error.localizedDescription)
        }
    }

    /// Maps a SecurityProtocolError to XPCProtocolsCore.SecurityError domain
    ///
    /// This helper method ensures consistent handling of protocol-specific errors.
    /// It delegates to the centralised mapper for consistent error handling.
    ///
    /// - Parameter error: The protocol error to map
    /// - Returns: A properly mapped XPCProtocolsCore.SecurityError
    private func mapSecurityProtocolError(_ error: Error) -> XPCProtocolsCore.SecurityError {
        // If SecurityProtocolError is unavailable, we use a general mapping approach
        if let xpcError = error as? XPCProtocolsCore.SecurityError {
            xpcError
        } else {
            .internalError(reason: error.localizedDescription)
        }
    }
}

// Helper adapter to convert between SecureBytes and Data for XPC
private enum XPCDataAdapter {
    static func data(from secureBytes: SecureBytes) -> Data {
        // Use available properties from SecureBytes
        secureBytes.withUnsafeBytes { Data($0) }
    }

    static func secureBytes(from data: Data) -> SecureBytes {
        data.withUnsafeBytes { bytes -> SecureBytes in
            let bufferPointer = bytes.bindMemory(to: UInt8.self)
            return SecureBytes(bytes: Array(bufferPointer))
        }
    }
}

// MARK: - Migration Extensions

/// Extension to provide migration assistance for Foundation-based XPC services
@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
public extension XPCServiceProtocolFoundationBridge {
    /// Convert this legacy Foundation-based service to a modern XPCServiceProtocolComplete
    ///
    /// This helper method simplifies the migration from legacy to modern protocols
    ///
    /// Example:
    /// ```swift
    /// // Legacy code:
    /// let legacyService: XPCServiceProtocolFoundationBridge = getLegacyService()
    ///
    /// // Migration:
    /// let modernService = legacyService.asModernXPCService()
    /// ```
    func asModernXPCService() -> any XPCProtocolsCore.XPCServiceProtocolComplete {
        // Use the migration factory to create a properly wrapped service
        XPCProtocolMigrationFactory.createCompleteAdapter(service: self)
    }
}

/// Migration guide for SecurityBridge XPC protocols
public enum SecurityBridgeXPCMigrationGuide {
    /// Comprehensive guide for migrating from Foundation-based bridges to XPCProtocolsCore
    public static var migrationSteps: String {
        """
        # SecurityBridge XPC Migration Guide

        ## Overview

        This guide provides steps to migrate from Foundation-based XPC bridges to the modern
        XPCProtocolsCore protocol hierarchy.

        ## Migration Steps

        1. Replace all usages of `XPCServiceProtocolFoundationBridge` with
           `XPCServiceProtocolComplete` from XPCProtocolsCore.

        2. For existing services:
           ```swift
           // Instead of:
           let legacyService = getFoundationBridgeService()

           // Use:
           let modernService = legacyService.asModernXPCService()
           ```

        3. For adapter patterns:
           ```swift
           // Instead of creating custom adapter classes:
           // let adapter = CustomFoundationBridgeAdapter(service: someService)

           // Use XPCProtocolMigrationFactory:
           let adapter = XPCProtocolMigrationFactory.createCompleteAdapter()
           ```

        4. Update all method calls to use async/await syntax and Result types:
           ```swift
           // Instead of using explicit Objective-C style callbacks:
           foundationService.encryptFoundation(data: someData) { data, error in
               // Handle callback
           }

           // Use async/await with results:
           let result = await modernService.encrypt(data: someData)
           switch result {
           case .success(let encryptedData):
               // Handle success
           case .failure(let error):
               // Handle error
           }
           ```

        ## Complete Documentation

        For more detailed migration guidance, refer to the `XPCProtocolMigrationGuide` in
        XPCProtocolsCore.
        """
    }
}
