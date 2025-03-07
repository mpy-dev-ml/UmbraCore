// SecurityErrorMapper.swift
// Bidirectional mapper between the new SecurityError and the legacy CoreErrors.SecurityError
//
// Copyright © 2025 UmbraCorp. All rights reserved.

import Foundation
import CoreErrors

/// Mapper from the enhanced SecurityError to CoreErrors.SecurityError
public struct EnhancedToCoreSecurityErrorMapper: ErrorMapper {
    public typealias SourceError = SecurityError
    public typealias TargetError = CoreErrors.SecurityError
    
    public init() {}
    
    /// Maps from enhanced SecurityError to CoreErrors.SecurityError
    /// - Parameter error: The enhanced SecurityError to map
    /// - Returns: The equivalent CoreErrors.SecurityError
    public func map(_ error: SecurityError) -> CoreErrors.SecurityError {
        switch error.errorCode {
        case .bookmarkError:
            return .bookmarkError
        case .accessError:
            return .accessError
        case .encryptionFailed:
            return .encryptionFailed
        case .decryptionFailed:
            return .decryptionFailed
        // Map additional cases to their closest equivalents in CoreErrors
        case .invalidKey, .keyGenerationFailed:
            // Since CoreErrors doesn't have these specific cases,
            // map them to the closest conceptual match
            return .encryptionFailed
        case .certificateInvalid:
            return .accessError
        case .unauthorisedAccess:
            return .accessError
        case .secureStorageFailure:
            return .bookmarkError
        }
    }
}

/// Mapper from CoreErrors.SecurityError to the enhanced SecurityError
public struct CoreToEnhancedSecurityErrorMapper: ErrorMapper {
    public typealias SourceError = CoreErrors.SecurityError
    public typealias TargetError = SecurityError
    
    public init() {}
    
    /// Maps from CoreErrors.SecurityError to enhanced SecurityError
    /// - Parameter error: The CoreErrors.SecurityError to map
    /// - Returns: The equivalent enhanced SecurityError
    public func map(_ error: CoreErrors.SecurityError) -> SecurityError {
        switch error {
        case .bookmarkError:
            return SecurityError(code: .bookmarkError)
        case .accessError:
            return SecurityError(code: .accessError)
        case .encryptionFailed:
            return SecurityError(code: .encryptionFailed)
        case .decryptionFailed:
            return SecurityError(code: .decryptionFailed)
        }
    }
}

/// Bidirectional mapper between enhanced SecurityError and CoreErrors.SecurityError
public let securityErrorMapper = BidirectionalErrorMapper<SecurityError, CoreErrors.SecurityError>(
    forwardMap: { EnhancedToCoreSecurityErrorMapper().map($0) },
    reverseMap: { CoreToEnhancedSecurityErrorMapper().map($0) }
)

/// Function to register the SecurityError mapper with the ErrorRegistry
public func registerSecurityErrorMappers() {
    let registry = ErrorRegistry.shared
    
    // Register mapper from enhanced to CoreErrors
    registry.register(targetDomain: "CoreErrors.Security", mapper: EnhancedToCoreSecurityErrorMapper())
    
    // Register mapper from CoreErrors to enhanced
    registry.register(targetDomain: "Security", mapper: CoreToEnhancedSecurityErrorMapper())
}
