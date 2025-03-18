import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// CryptoXPCAdapter provides an implementation of CryptoServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles cryptographic operations by delegating to an XPC service,
/// providing a unified API for encryption, decryption, and hashing.
public final class CryptoXPCAdapter: NSObject, BaseXPCAdapter, @unchecked Sendable {
    // MARK: - Properties

    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection

    /// The service proxy for making XPC calls
    private let serviceProxy: (any ComprehensiveSecurityServiceProtocol)?

    // MARK: - Initialisation

    /// Initialise with an NSXPCConnection
    /// - Parameter connection: The connection to the XPC service
    /// - Parameter serviceProxy: The service proxy object for communicating with the XPC service
    public init(
        connection: NSXPCConnection,
        serviceProxy: (any ComprehensiveSecurityServiceProtocol)?
    ) {
        self.connection = connection
        self.serviceProxy = serviceProxy
        super.init()
        setupInvalidationHandler()
    }

    // MARK: - Helper Methods

    /// Maps internal XPC errors to SecurityProtocolsCore error types
    private func mapXPCError(_ error: NSError) -> UmbraErrors.Security.XPC {
        mapSecurityError(error)
    }

    /// Maps NSError objects to UmbraErrors.Security.XPC error types
    public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
        // Check for known error domains and codes
        if error.domain == NSURLErrorDomain {
            return .connectionFailed(reason: error.localizedDescription)
        } else if error.domain == "CryptoErrorDomain" {
            // Map specific crypto error codes to appropriate UmbraErrors
            switch error.code {
            case 1_001:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            case 1_002:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            case 1_003:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            case 1_004:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            default:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            }
        }

        // Default error mapping
        return .internalError(error.localizedDescription)
    }

    /// Sets up the invalidation handler for the XPC connection
    public func setupInvalidationHandler() {
        connection.invalidationHandler = {
            // Log the invalidation
            print("XPC connection to CryptoService was invalidated")
            // Optional: Notify any observers or reset state
        }
    }

    // MARK: - Data Conversion

    /// Convert NSData to SecureBytes
    public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let length = data.length
        var bytes = [UInt8](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return SecureBytes(bytes: bytes)
    }

    /// Convert SecureBytes to NSData
    public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        // Use Array constructor to access the bytes
        let bytes = Array(secureBytes)
        return NSData(bytes: bytes, length: bytes.count)
    }

    public func isServiceAvailable() async -> Bool {
        await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy?.getServiceVersion() ?? ""
                continuation.resume(returning: !result.isEmpty)
            }
        }
    }

    // Helper to map XPC-specific errors to protocol errors
    private func mapToProtocolError(_ error: UmbraErrors.Security.XPC) -> UmbraErrors.Security
        .Protocols {
        // Map XPC error to Protocol error based on case
        switch error {
        case let .connectionFailed(reason):
            return .serviceError(reason)
        case let .serviceError(code, reason):
            return .serviceError("XPC_ERROR_\(code): \(reason)")
        case let .timeout(operation, _):
            return .serviceError("Operation \(operation) timed out")
        case let .serviceUnavailable(serviceName):
            return .serviceError("Service unavailable: \(serviceName)")
        case let .operationCancelled(operation):
            return .serviceError("Operation cancelled: \(operation)")
        case let .insufficientPrivileges(service, privilege):
            return .serviceError("Insufficient privileges for \(service): requires \(privilege)")
        case let .invalidMessageFormat(reason):
            return .invalidFormat(reason: reason)
        case let .internalError(message):
            return .internalError(message)
        @unknown default:
            return .internalError("Unknown XPC error")
        }
    }

    // XPC-specific implementations

    public func encrypt(
        data: SecureBytes,
        key: SecureBytes?
    ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        // Convert SecureBytes to NSData
        let nsData = convertSecureBytesToNSData(data)

        // For key-based encryption, convert the key to a key identifier
        // In a real implementation, this would use a key management service to get an ID
        let keyIdentifier: String? = key.map { secureBytes in
            // This is a simplified implementation - in production, you would look up or generate
            // a proper key identifier based on the key data
            let keyData = convertSecureBytesToNSData(secureBytes)
            return keyData.hash.description
        }

        return await withCheckedContinuation { continuation in
            Task {
                // Use encryptData with the correct signature
                let result = await serviceProxy?.encryptData(nsData, keyIdentifier: keyIdentifier)

                if let encryptedData = result as? NSData {
                    continuation.resume(returning: .success(convertNSDataToSecureBytes(encryptedData)))
                } else {
                    continuation.resume(returning: .failure(.serviceError(
                        code: -1,
                        reason: "Encryption failed"
                    )))
                }
            }
        }
    }

    public func encrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        await encrypt(data: data, key: key)
    }

    public func decrypt(
        data: SecureBytes,
        key: SecureBytes?
    ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        // Convert SecureBytes to NSData
        let nsData = convertSecureBytesToNSData(data)

        // For key-based decryption, convert the key to a key identifier
        // In a real implementation, this would use a key management service to get an ID
        let keyIdentifier: String? = key.map { secureBytes in
            // This is a simplified implementation - in production, you would look up or generate
            // a proper key identifier based on the key data
            let keyData = convertSecureBytesToNSData(secureBytes)
            return keyData.hash.description
        }

        return await withCheckedContinuation { continuation in
            Task {
                // Use decryptData with the correct signature
                let result = await serviceProxy?.decryptData(nsData, keyIdentifier: keyIdentifier)

                if let decryptedData = result as? NSData {
                    continuation.resume(returning: .success(convertNSDataToSecureBytes(decryptedData)))
                } else {
                    continuation.resume(returning: .failure(.serviceError(
                        code: -1,
                        reason: "Decryption failed"
                    )))
                }
            }
        }
    }

    public func decrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        await decrypt(data: data, key: key)
    }

    // XPC-specific implementation
    private func hashDataInternal(data: SecureBytes) async
        -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                // Convert SecureBytes to NSData
                let nsData = convertSecureBytesToNSData(data)

                // Use hashData with the correct signature
                let result = await serviceProxy?.hashData(nsData)

                if let hashData = result as? NSData {
                    continuation.resume(returning: .success(convertNSDataToSecureBytes(hashData)))
                } else {
                    continuation.resume(returning: .failure(.serviceError(
                        code: -1,
                        reason: "Hashing failed"
                    )))
                }
            }
        }
    }
}

// MARK: - CryptoServiceProtocol Implementation

extension CryptoXPCAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
    public func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // Map XPC error type to Protocols error type for protocol compliance
        let result = await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy?.getServiceVersion() ?? ""
                continuation.resume(returning: !result.isEmpty)
            }
        }
        return .success(result)
    }

    public func encrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Convert internal XPC error type to Protocols error type
        let result = await encrypt(data: data, key: key)
        switch result {
        case let .success(data):
            return .success(data)
        case let .failure(error):
            // Map XPC error to Protocol error
            return .failure(mapToProtocolError(error))
        }
    }

    public func decrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Convert internal XPC error type to Protocols error type
        let result = await decrypt(data: data, key: key)
        switch result {
        case let .success(data):
            return .success(data)
        case let .failure(error):
            // Map XPC error to Protocol error
            return .failure(mapToProtocolError(error))
        }
    }

    public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Implement with the required parameters
        let result = await withCheckedContinuation { continuation in
            Task {
                // Use a default key type of symmetric if not specified
                let result = await serviceProxy?.generateKey(
                    keyType: .symmetric,
                    keyIdentifier: nil,
                    metadata: nil
                )

                // Map the result type
                switch result {
                case let .success(keyId):
                    // We need to convert the keyId to SecureBytes
                    // This is just a temporary implementation - in production code,
                    // you would need to retrieve the actual key data using the keyId
                    if let data = keyId.data(using: .utf8) {
                        let secureBytes = SecureBytes(bytes: [UInt8](data))
                        continuation
                            .resume(
                                returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                    .success(secureBytes)
                            )
                    } else {
                        continuation
                            .resume(
                                returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                    .failure(.internalError("Failed to convert key ID to data"))
                            )
                    }
                case let .failure(error):
                    continuation
                        .resume(
                            returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                .failure(mapToProtocolError(error))
                        )
                case .none:
                    continuation
                        .resume(
                            returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                .failure(.unsupportedOperation(name: "generateKey"))
                        )
                }
            }
        }

        return result
    }

    private func performHash(data: SecureBytes) async
        -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Convert internal XPC error type to Protocols error type
        let result = await withCheckedContinuation { continuation in
            Task {
                let nsData = convertSecureBytesToNSData(data)
                let selector = NSSelectorFromString("hashData:completionHandler:")

                let completionHandler: (NSData?, NSError?) -> Void = { [self] hashData, error in
                    if let error {
                        continuation
                            .resume(
                                returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                    .failure(
                                        .serviceError(
                                            "Error code: \(error.code), reason: \(error.localizedDescription)"
                                        )
                                    )
                            )
                    } else if let hashData {
                        let secureBytes = convertNSDataToSecureBytes(hashData)
                        continuation
                            .resume(
                                returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                    .success(secureBytes)
                            )
                    } else {
                        continuation
                            .resume(
                                returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                    .failure(.internalError("Hash operation failed"))
                            )
                    }
                }

                if
                    let service = connection.remoteObjectProxy as? NSObject,
                    service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: nsData,
                        with: completionHandler
                    )
                } else {
                    continuation
                        .resume(
                            returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                .failure(.unsupportedOperation(name: "hash"))
                        )
                }
            }
        }

        return result
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Bridge to our internal hash implementation
        let xpcResult = await hashDataInternal(data: data)

        // Map the XPC error type to the protocol error type
        switch xpcResult {
        case let .success(hashData):
            return .success(hashData)
        case let .failure(error):
            // Map the XPC-specific error to the more general Protocols error
            return .failure(mapToProtocolError(error))
        }
    }

    public func hash(
        data: SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await hash(data: data)
    }

    public func verify(
        data: SecureBytes,
        against hash: SecureBytes
    ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // Implement the verification logic
        let result = await withCheckedContinuation { continuation in
            Task {
                // This would be implemented by calling the appropriate XPC service method
                // For now, we'll just return a placeholder implementation
                let computedHash = await self.performHash(data: data)

                // Compare the computed hash with the provided hash
                switch computedHash {
                case let .success(computedHashData):
                    let matches = computedHashData == hash
                    continuation
                        .resume(returning: Result<Bool, UmbraErrors.Security.Protocols>.success(matches))
                case let .failure(error):
                    continuation
                        .resume(returning: Result<Bool, UmbraErrors.Security.Protocols>.failure(error))
                }
            }
        }

        return result
    }

    public func encryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Bridge to the existing encrypt method
        await encrypt(data: data, using: key)
    }

    public func decryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Bridge to the existing decrypt method
        await decrypt(data: data, using: key)
    }

    public func encryptAsymmetric(
        data _: SecureBytes,
        publicKey _: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // This would typically call a specific asymmetric encryption method
        // For now, returning a not supported error
        .failure(.unsupportedOperation(name: "encryptAsymmetric"))
    }

    public func decryptAsymmetric(
        data _: SecureBytes,
        privateKey _: SecureBytes,
        config _: SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // This would typically call a specific asymmetric decryption method
        // For now, returning a not supported error
        .failure(.unsupportedOperation(name: "decryptAsymmetric"))
    }

    public func generateRandomData(length: Int) async
        -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        let result = await withCheckedContinuation { continuation in
            Task {
                // This would call the appropriate XPC service method
                // For now, implement a basic version
                var randomBytes = [UInt8](repeating: 0, count: length)
                guard
                    SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes) ==
                    errSecSuccess
                else {
                    continuation
                        .resume(
                            returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                                .failure(.internalError("Failed to generate secure random data"))
                        )
                    return
                }

                let secureBytes = SecureBytes(bytes: randomBytes)
                continuation
                    .resume(
                        returning: Result<SecureBytes, UmbraErrors.Security.Protocols>
                            .success(secureBytes)
                    )
            }
        }

        return result
    }
}

// MARK: - DataAdapter for SecureBytes conversions

public enum DataAdapter {
    /// Convert SecureBytes to Data
    static func data(from secureBytes: SecureBytes) -> Data {
        let bytes = Array(secureBytes)
        return Data(bytes)
    }

    /// Convert Data to SecureBytes
    static func secureBytes(from data: Data) -> SecureBytes {
        let bytes = [UInt8](data)
        return SecureBytes(bytes: bytes)
    }
}
