// XPCProtocolMigrationFactory.swift
// XPCProtocolsCore
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import UmbraCoreTypes

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
public enum XPCProtocolMigrationFactory {

    /// Create a standard protocol adapter from a legacy XPC service
    /// This allows using legacy implementations with the new protocol APIs
    ///
    /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
    /// - Returns: An adapter that conforms to XPCServiceProtocolStandard
    public static func createStandardAdapter(from legacyService: Any) -> any XPCServiceProtocolStandard {
        return LegacyXPCServiceAdapter(service: legacyService)
    }

    /// Create a complete protocol adapter from a legacy XPC service
    /// This provides all the functionality of the complete XPC service protocol
    ///
    /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
    /// - Returns: An adapter that conforms to XPCServiceProtocolComplete
    public static func createCompleteAdapter(from legacyService: Any) -> any XPCServiceProtocolComplete {
        return LegacyXPCServiceAdapter(service: legacyService)
    }

    /// Create a basic protocol adapter from a legacy XPC service
    /// This provides the minimal functionality of the basic XPC service protocol
    ///
    /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
    /// - Returns: An adapter that conforms to XPCServiceProtocolBasic
    public static func createBasicAdapter(from legacyService: Any) -> any XPCServiceProtocolBasic {
        return LegacyXPCServiceAdapter(service: legacyService)
    }

    /// Convert from XPCSecurityError to legacy SecurityError
    ///
    /// - Parameter error: XPCSecurityError to convert
    /// - Returns: Legacy SecurityError
    @available(*, deprecated, message: "Use XPCSecurityError instead")
    public static func convertToLegacyError(_ error: XPCSecurityError) -> SecurityError {
        return LegacyXPCServiceAdapter.mapToLegacyError(error)
    }

    /// Convert from legacy error to XPCSecurityError
    ///
    /// - Parameter error: Legacy error to convert
    /// - Returns: Standardized XPCSecurityError
    public static func convertToStandardError(_ error: Error) -> XPCSecurityError {
        return LegacyXPCServiceAdapter.mapError(error)
    }
}
