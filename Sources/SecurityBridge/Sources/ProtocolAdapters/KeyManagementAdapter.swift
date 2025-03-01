// KeyManagementAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecureBytes
import SecurityProtocolsCore

/// KeyManagementAdapter provides a bridge between Foundation-based key management implementations
/// and the Foundation-free KeyManagementProtocol.
///
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent
/// KeyManagementProtocol interface.
public final class KeyManagementAdapter: KeyManagementProtocol, Sendable {
    // MARK: - Properties
    
    /// The Foundation-dependent key management implementation
    private let implementation: any FoundationKeyManagement
    
    // MARK: - Initialization
    
    /// Create a new KeyManagementAdapter
    /// - Parameter implementation: The Foundation-dependent key management implementation
    public init(implementation: any FoundationKeyManagement) {
        self.implementation = implementation
    }
    
    // MARK: - KeyManagementProtocol Implementation
    
    public func retrieveKey(withIdentifier identifier: String) async -> Result<SecureBytes, SecurityError> {
        let result = await implementation.retrieveKey(withIdentifier: identifier)
        
        switch result {
        case .success(let keyData):
            return .success(DataAdapter.secureBytes(from: keyData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }
    
    public func storeKey(_ key: SecureBytes, withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        let keyData = DataAdapter.data(from: key)
        let result = await implementation.storeKey(keyData, withIdentifier: identifier)
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(mapError(error))
        }
    }
    
    public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
        let result = await implementation.deleteKey(withIdentifier: identifier)
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(mapError(error))
        }
    }
    
    public func rotateKey(withIdentifier identifier: String,
                         dataToReencrypt: SecureBytes?) async -> Result<(newKey: SecureBytes, reencryptedData: SecureBytes?), SecurityError> {
        // Convert SecureBytes to Data for the Foundation implementation
        let dataToReencryptData = dataToReencrypt.map { DataAdapter.data(from: $0) }
        
        // Call the implementation
        let result = await implementation.rotateKey(withIdentifier: identifier, dataToReencrypt: dataToReencryptData)
        
        // Convert the result back to the protocol's types
        switch result {
        case .success(let rotationResult):
            let newKey = DataAdapter.secureBytes(from: rotationResult.newKey)
            let reencryptedData = rotationResult.reencryptedData.map { DataAdapter.secureBytes(from: $0) }
            return .success((newKey: newKey, reencryptedData: reencryptedData))
        case .failure(let error):
            return .failure(mapError(error))
        }
    }
    
    public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
        let result = await implementation.listKeyIdentifiers()
        
        switch result {
        case .success(let identifiers):
            return .success(identifiers)
        case .failure(let error):
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Map Foundation-specific errors to SecurityError
    private func mapError(_ error: Error) -> SecurityError {
        // If the error is already a SecurityError, return it
        if let securityError = error as? SecurityError {
            return securityError
        }
        
        // Map Foundation-specific errors to SecurityError types
        // This would be expanded based on the specific error types used
        return SecurityError.internalError("Foundation key management error: \(error.localizedDescription)")
    }
}

/// Protocol for Foundation-dependent key management implementations
/// that can be adapted to the Foundation-free KeyManagementProtocol
public protocol FoundationKeyManagement: Sendable {
    func retrieveKey(withIdentifier identifier: String) async -> Result<Data, Error>
    func storeKey(_ key: Data, withIdentifier identifier: String) async -> Result<Void, Error>
    func deleteKey(withIdentifier identifier: String) async -> Result<Void, Error>
    func rotateKey(withIdentifier identifier: String,
                   dataToReencrypt: Data?) async -> Result<(newKey: Data, reencryptedData: Data?), Error>
    func listKeyIdentifiers() async -> Result<[String], Error>
}
