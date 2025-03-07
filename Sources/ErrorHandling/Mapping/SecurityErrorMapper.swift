// SecurityErrorMapper.swift
// Mapping between SecurityError and CoreError
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation

/// Maps between SecurityError and CoreError
public struct SecurityErrorMapper: BidirectionalErrorMapper {
    /// Initialises a new mapper
    public init() {}
    
    /// Maps from SecurityError to CoreError
    /// - Parameter error: The SecurityError to map
    /// - Returns: The equivalent CoreError
    public func mapAtoB(_ error: SecurityError) -> CoreError {
        switch error {
        case .authenticationFailed(let message):
            return .authenticationFailed
            
        case .authorizationFailed(let message):
            return .insufficientPermissions
            
        case .cryptoOperationFailed(let message),
             .invalidCertificate(let message),
             .connectionFailed(let message),
             .storageFailed(let message),
             .tamperedData(let message),
             .policyViolation(let message):
            return .systemError(message)
            
        case .generalError(let message):
            return .systemError(message)
        }
    }
    
    /// Maps from CoreError to SecurityError
    /// - Parameter error: The CoreError to map
    /// - Returns: The equivalent SecurityError
    public func mapBtoA(_ error: CoreError) -> SecurityError {
        switch error {
        case .authenticationFailed:
            return .authenticationFailed("Authentication failed")
            
        case .insufficientPermissions:
            return .authorizationFailed("Insufficient permissions to perform the operation")
            
        case .invalidConfiguration(let details):
            return .generalError("Invalid configuration: \(details)")
            
        case .systemError(let details):
            // Best effort to determine a more specific security error based on the message
            let message = details.lowercased()
            
            if message.contains("crypto") || message.contains("encrypt") || message.contains("decrypt") {
                return .cryptoOperationFailed(details)
            } else if message.contains("certificate") || message.contains("cert") {
                return .invalidCertificate(details)
            } else if message.contains("connect") || message.contains("connection") {
                return .connectionFailed(details)
            } else if message.contains("storage") || message.contains("store") {
                return .storageFailed(details)
            } else if message.contains("tamper") || message.contains("integrity") {
                return .tamperedData(details)
            } else if message.contains("policy") || message.contains("violation") {
                return .policyViolation(details)
            } else {
                return .generalError(details)
            }
        }
    }
    
    /// Maps a SecurityError to a CoreError (implementation of ErrorMapper)
    /// - Parameter error: The SecurityError to map
    /// - Returns: The equivalent CoreError
    public func mapError(_ error: SecurityError) -> CoreError {
        return mapAtoB(error)
    }
}

/// Registers the security error mapper with the error registry
public func registerSecurityErrorMapper() {
    let mapper = SecurityErrorMapper()
    ErrorRegistry.shared.register(mapper: mapper)
}
