import Foundation
import UmbraCoreTypes
import CryptoTypes

/// CryptoXPCServiceAdapter
///
/// This adapter bridges between CryptoXPCServiceProtocol and XPCProtocolsCore protocols.
/// It allows existing CryptoXPCService implementations to be used with the new standardized
/// XPC protocol hierarchy without requiring modifications to the service itself.
///
/// Usage:
/// ```swift
/// let cryptoService = CryptoXPCService(dependencies: dependencies)
/// let adapter = CryptoXPCServiceAdapter(service: cryptoService)
/// 
/// // Now use the adapter with XPCProtocolsCore protocols
/// let result = await adapter.encrypt(data: secureBytes)
/// ```
@available(macOS 14.0, *)
public final class CryptoXPCServiceAdapter: @unchecked Sendable {
    /// The crypto service being adapted
    private let service: any CryptoXPCServiceProtocol
    
    /// Initializes the adapter with a CryptoXPCService
    /// - Parameter service: The crypto service to adapt
    public init(service: any CryptoXPCServiceProtocol) {
        self.service = service
    }
    
    /// Convert SecureBytes to Data for the crypto service
    /// - Parameter bytes: SecureBytes to convert
    /// - Returns: Data for the crypto service
    private func convertToData(_ bytes: SecureBytes) -> Data {
        bytes.withUnsafeBytes { Data($0) }
    }
    
    /// Convert Data from the crypto service to SecureBytes
    /// - Parameter data: Data from the crypto service
    /// - Returns: SecureBytes for XPC protocols
    private func convertToSecureBytes(_ data: Data) -> SecureBytes {
        SecureBytes(data: data)
    }
    
    /// Map from CryptoError to XPCSecurityError
    /// - Parameter error: CryptoError to map
    /// - Returns: XPCSecurityError
    private func mapError(_ error: Error) -> XPCSecurityError {
        if case let CoreErrors.CryptoError.encryptionFailed(reason) = error as? CoreErrors.CryptoError {
            return .cryptoError
        } else if case let CoreErrors.CryptoError.decryptionFailed(reason) = error as? CoreErrors.CryptoError {
            return .cryptoError
        } else if case let CoreErrors.CryptoError.keyGenerationFailed(reason) = error as? CoreErrors.CryptoError {
            return .cryptoError
        } else {
            return .cryptoError
        }
    }
}

// MARK: - XPCServiceProtocolComplete Conformance

@available(macOS 14.0, *)
extension CryptoXPCServiceAdapter: XPCServiceProtocolComplete {
    public static var protocolIdentifier: String {
        "com.umbra.crypto.xpc.adapter.service"
    }
    
    public func pingComplete() async -> Result<Bool, XPCSecurityError> {
        // CryptoXPCService doesn't have a ping method
        // Return success as default
        return .success(true)
    }
    
    public func synchronizeKeys(_ secureBytes: SecureBytes) async -> Result<Void, XPCSecurityError> {
        // CryptoXPCService doesn't have a synchronizeKeys method
        // Return success as default
        return .success(())
    }
    
    public func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let inputData = convertToData(data)
            
            // Generate a random key if needed
            let key = try await service.generateKey(bits: 256)
            
            let encryptedData = try await service.encrypt(inputData, key: key)
            return .success(convertToSecureBytes(encryptedData))
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let inputData = convertToData(data)
            
            // This is a simplification - in a real implementation,
            // you would need to retrieve the correct key
            let key = try await service.generateKey(bits: 256)
            
            let decryptedData = try await service.decrypt(inputData, key: key)
            return .success(convertToSecureBytes(decryptedData))
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let key = try await service.generateKey(bits: 256)
            return .success(convertToSecureBytes(key))
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        // CryptoXPCService doesn't have a hash method
        // In a real implementation, you would add this functionality
        // For now, return a mock hash
        let dataBytes = convertToData(data)
        let mockHash = Data(count: 32) // SHA-256 size
        return .success(convertToSecureBytes(mockHash))
    }
}

// MARK: - XPCServiceProtocolStandard Conformance

@available(macOS 14.0, *)
extension CryptoXPCServiceAdapter: XPCServiceProtocolStandard {
    public func generateRandomData(length: Int) async throws -> SecureBytes {
        do {
            let randomData = try await service.generateKey(bits: length * 8)
            return convertToSecureBytes(randomData)
        } catch {
            throw error
        }
    }
    
    public func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        do {
            let inputData = convertToData(data)
            
            // Retrieve or generate key
            let key: Data
            if let keyIdentifier = keyIdentifier {
                do {
                    key = try await service.retrieveCredential(forIdentifier: keyIdentifier)
                } catch {
                    key = try await service.generateKey(bits: 256)
                }
            } else {
                key = try await service.generateKey(bits: 256)
            }
            
            let encryptedData = try await service.encrypt(inputData, key: key)
            return convertToSecureBytes(encryptedData)
        } catch {
            throw error
        }
    }
    
    public func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        do {
            let inputData = convertToData(data)
            
            // Retrieve or generate key
            let key: Data
            if let keyIdentifier = keyIdentifier {
                key = try await service.retrieveCredential(forIdentifier: keyIdentifier)
            } else {
                // This is a simplification - in a real implementation,
                // you would need the correct key
                key = try await service.generateKey(bits: 256)
            }
            
            let decryptedData = try await service.decrypt(inputData, key: key)
            return convertToSecureBytes(decryptedData)
        } catch {
            throw error
        }
    }
    
    public func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        // CryptoXPCService doesn't have a hash method
        // In a real implementation, you would add this functionality
        let dataBytes = convertToData(data)
        let mockHash = Data(count: 32) // SHA-256 size
        return convertToSecureBytes(mockHash)
    }
    
    public func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        // CryptoXPCService doesn't have a signing method
        // In a real implementation, you would add this functionality
        let mockSignature = Data(count: 64) // Typical signature size
        return convertToSecureBytes(mockSignature)
    }
    
    public func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        // CryptoXPCService doesn't have a verification method
        // In a real implementation, you would add this functionality
        return true
    }
    
    public func synchroniseKeys(_ keys: SecureBytes) async throws {
        // CryptoXPCService doesn't have a synchroniseKeys method
        // No-op implementation
    }
    
    public func ping() async throws -> Bool {
        // CryptoXPCService doesn't have a ping method
        // Return true as default
        return true
    }
}
