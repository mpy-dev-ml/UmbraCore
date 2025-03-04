// LegacyXPCServiceAdapter.swift
// XPCProtocolsCore
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import UmbraCoreTypes

/// LegacyXPCServiceAdapter
///
/// This adapter class provides a bridge between legacy XPC service implementations
/// and the new XPCProtocolsCore protocols. It allows existing code to continue working
/// while gradually migrating to the new protocol hierarchy.
///
/// Usage:
/// ```swift
/// // Legacy implementation
/// class MyLegacyXPCService: SomeOldProtocol {
///     // Legacy implementation
/// }
///
/// // Adapter usage
/// let adapter = LegacyXPCServiceAdapter(service: MyLegacyXPCService())
/// let result = await adapter.encrypt(data: secureBytes)
/// ```
public final class LegacyXPCServiceAdapter {
    /// The legacy service being adapted
    private let service: Any
    
    /// Type erasure constructor for any legacy XPC service
    /// - Parameter service: The legacy service to adapt
    public init(service: Any) {
        self.service = service
    }
    
    /// Map from legacy error types to XPCSecurityError
    /// - Parameter error: Legacy error
    /// - Returns: Standard XPCSecurityError
    public static func mapError(_ error: Error) -> XPCSecurityError {
        // Handle legacy SecurityError types
        if let legacyError = error as? SecurityError {
            switch legacyError {
            case .notImplemented:
                return .notImplemented
            case .invalidData:
                return .cryptoError
            case .encryptionFailed:
                return .cryptoError
            case .decryptionFailed:
                return .cryptoError
            case .keyGenerationFailed:
                return .cryptoError
            case .hashingFailed:
                return .cryptoError
            case .serviceFailed:
                return .accessError
            case .general(let message):
                return .accessError
            }
        }
        
        // Default mapping for unknown error types
        return .accessError
    }
    
    /// Map from XPCSecurityError to legacy error types
    /// - Parameter error: Standard XPCSecurityError
    /// - Returns: Legacy SecurityError
    public static func mapToLegacyError(_ error: XPCSecurityError) -> SecurityError {
        switch error {
        case .notImplemented:
            return .notImplemented
        case .bookmarkError, .bookmarkCreationFailed, .bookmarkResolutionFailed:
            return .serviceFailed
        case .accessError:
            return .serviceFailed
        case .cryptoError:
            return .encryptionFailed
        }
    }
}

// MARK: - XPCServiceProtocolComplete Conformance Adapter

extension LegacyXPCServiceAdapter: XPCServiceProtocolComplete {
    public static var protocolIdentifier: String {
        return "com.umbra.legacy.adapter.xpc.service"
    }
    
    public func pingComplete() async -> Result<Bool, XPCSecurityError> {
        // If the legacy service supports ping, use it
        if let pingable = service as? { () async -> Result<Bool, Error> } {
            do {
                let result = await pingable()
                switch result {
                case .success(let value):
                    return .success(value)
                case .failure(let error):
                    return .failure(Self.mapError(error))
                }
            } catch {
                return .failure(Self.mapError(error))
            }
        }
        
        // Default implementation always succeeds
        return .success(true)
    }
    
    public func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        // Implementation depends on the legacy service capabilities
        // This is a default implementation that fails with not implemented
        return .failure(.notImplemented)
    }
    
    public func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // Try to adapt to legacy encryption methods if available
        return .failure(.notImplemented)
    }
    
    public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // Try to adapt to legacy decryption methods if available
        return .failure(.notImplemented)
    }
    
    public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        // Try to adapt to legacy key generation methods if available
        return .failure(.notImplemented)
    }
    
    public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // Try to adapt to legacy hashing methods if available
        return .failure(.notImplemented)
    }
}
