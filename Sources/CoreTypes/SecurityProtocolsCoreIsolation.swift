// SecurityProtocolsCoreIsolation.swift
//
// This file implements the "Isolation Pattern" described in NAMESPACE_RESOLUTION.md
// Its sole purpose is to isolate imports of SecurityProtocolsCore to avoid namespace conflicts.
// ONLY THIS FILE should import SecurityProtocolsCore directly.

import CoreErrors
import Foundation
import UmbraCoreTypes

// Only import SecurityProtocolsCore in this file to isolate namespace conflicts
import SecurityProtocolsCore

/// Direct access to the SecurityError type in the SecurityProtocolsCore module
/// This approach avoids the namespace conflict with the enum named SecurityProtocolsCore
public typealias SPCSecurityError = SecurityProtocolsCore.SecurityError

/// Map from SecurityProtocolsCore.SecurityError to CoreErrors.SecurityError
/// This provides a clean conversion between error domains
public func mapSPCToCoreError(_ error: SPCSecurityError) -> CoreErrors.SecurityError {
    switch error {
    case let .encryptionFailed(reason):
        return .encryptionError(reason: reason)
    case let .decryptionFailed(reason):
        return .decryptionError(reason: reason)
    case let .keyGenerationFailed(reason):
        return .keyManagementError(reason: reason)
    case .invalidKey:
        return .invalidKey
    case .hashVerificationFailed:
        return .verificationFailure(reason: "Hash verification failed")
    case let .randomGenerationFailed(reason):
        return .randomGenerationError(reason: reason)
    case let .invalidInput(reason):
        return .invalidInput(reason: reason)
    case let .storageOperationFailed(reason):
        return .storageError(reason: reason)
    case .timeout:
        return .timeout
    case let .serviceError(code, reason):
        return .serviceUnavailable(reason: "Code \(code): \(reason)")
    case let .internalError(message):
        return .internalError(reason: message)
    case .notImplemented:
        return .operationNotSupported
    default:
        return .internalError(reason: "Unknown SPC error: \(error)")
    }
}

/// Map from CoreErrors.SecurityError to SecurityProtocolsCore.SecurityError
/// This provides the reverse conversion for round-trip support
public func mapCoreToSPCError(_ error: CoreErrors.SecurityError) -> SPCSecurityError {
    switch error {
    case let .encryptionError(reason):
        return .encryptionFailed(reason: reason)
    case let .decryptionError(reason):
        return .decryptionFailed(reason: reason)
    case let .keyManagementError(reason):
        return .keyGenerationFailed(reason: reason)
    case .invalidKey:
        return .invalidKey
    case let .verificationFailure(reason):
        return .hashVerificationFailed
    case let .randomGenerationError(reason):
        return .randomGenerationFailed(reason: reason)
    case let .invalidInput(reason):
        return .invalidInput(reason: reason)
    case let .storageError(reason):
        return .storageOperationFailed(reason: reason)
    case .timeout:
        return .timeout
    case let .serviceUnavailable(reason):
        return .serviceError(code: -1, reason: reason)
    case let .internalError(reason):
        return .internalError(reason)
    case .operationNotSupported:
        return .notImplemented
    default:
        return .internalError("Unmapped core error: \(error)")
    }
}
