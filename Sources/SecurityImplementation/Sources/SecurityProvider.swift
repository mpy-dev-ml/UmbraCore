// SecurityProvider.swift
// Part of UmbraCore Security Module
// Created on 2025-03-01

import SecureBytes
import SecurityInterfacesBase

/// A concrete implementation of `SecurityProviderProtocol` that provides a unified
/// interface for security operations. This class acts as a facade for the different
/// security services.
public final class SecurityProvider: SecurityProviderProtocol {
    // MARK: - Properties
    
    /// The crypto service
    public let cryptoService: CryptoServiceProtocol
    
    /// The key manager
    public let keyManager: KeyManagementProtocol
    
    // MARK: - Initialisation
    
    /// Creates a new instance with default services
    public init() {
        self.cryptoService = CryptoService()
        self.keyManager = KeyManager()
    }
    
    /// Creates a new instance with the specified services
    /// - Parameters:
    ///   - cryptoService: The crypto service to use
    ///   - keyManager: The key manager to use
    public init(cryptoService: CryptoServiceProtocol, keyManager: KeyManagementProtocol) {
        self.cryptoService = cryptoService
        self.keyManager = keyManager
    }
    
    // MARK: - SecurityProviderProtocol
    
    /// Perform a security operation
    /// - Parameter operation: The operation to perform
    /// - Returns: Result of the operation
    public func performOperation(operation: SecurityOperation) -> SecurityResultDTO {
        switch operation.type {
        case .encrypt:
            return cryptoService.encrypt(data: operation.data, config: operation.config)
        case .decrypt:
            return cryptoService.decrypt(data: operation.data, config: operation.config)
        case .hash:
            return cryptoService.hash(data: operation.data, config: operation.config)
        case .generateMAC:
            return cryptoService.generateMAC(data: operation.data, config: operation.config)
        case .verifyMAC:
            // This is a placeholder implementation, as verifyMAC requires two data inputs
            return SecurityResultDTO(success: false, error: .invalidInput)
        default:
            // Unknown operation type
            return SecurityResultDTO(success: false, error: .invalidInput)
        }
    }
}
