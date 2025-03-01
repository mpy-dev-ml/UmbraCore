// SecurityImplementation.swift
// SecurityImplementation
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import SecurityProtocolsCore

/// Primary entry point for the SecurityImplementation module.
/// This module provides Foundation-independent implementations of the security protocols.
/// It serves as a concrete implementation of the security interfaces defined in SecurityProtocolsCore.
public enum SecurityImplementation {
    /// Module version
    public static let version = "1.0.0"
    
    /// Create a default security provider with standard implementations
    /// - Returns: A fully configured security provider
    public static func createDefaultProvider() -> SecurityProviderProtocol {
        return SecurityProviderImpl()
    }
    
    /// Create a custom security provider with specified implementations
    /// - Parameters:
    ///   - cryptoService: Custom crypto service implementation
    ///   - keyManager: Custom key management implementation
    /// - Returns: A configured security provider with custom implementations
    public static func createProvider(
        cryptoService: CryptoServiceProtocol,
        keyManager: KeyManagementProtocol
    ) -> SecurityProviderProtocol {
        return SecurityProviderImpl(
            cryptoService: cryptoService,
            keyManager: keyManager
        )
    }
}
