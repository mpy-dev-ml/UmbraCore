// Types.swift
// Part of UmbraCore Security Module
// Created on 2025-03-01

import SecureBytes
import SecurityInterfacesBase

// This file contains local types to break dependency cycles
// Note: Most of these types are now defined in SecurityImplementation.swift

// MARK: - Additional Types

/// Foundation-free error type for security operations.
public enum ExtendedSecurityError: Error, Sendable, Equatable {
    case encryptionFailed(reason: String)
    case decryptionFailed(reason: String)
    case keyGenerationFailed(reason: String)
    case invalidKey
    case hashVerificationFailed
    case randomGenerationFailed
    case invalidInput(reason: String)
    case operationFailed(reason: String)
    case unsupportedOperation
    case keyManagementError(reason: String)
    
    public var description: String {
        switch self {
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        case .keyGenerationFailed(let reason):
            return "Key generation failed: \(reason)"
        case .invalidKey:
            return "Invalid key"
        case .hashVerificationFailed:
            return "Hash verification failed"
        case .randomGenerationFailed:
            return "Random generation failed"
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        case .unsupportedOperation:
            return "Unsupported operation"
        case .keyManagementError(let reason):
            return "Key management error: \(reason)"
        }
    }
}
