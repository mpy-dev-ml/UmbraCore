// FoundationTypeBridge.swift
// UmbraSecurityCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import UmbraCoreTypes
import SecurityProtocolsCore

/// Protocol for bridging between Foundation-free and Foundation-dependent types
/// This is designed to be implemented by types that can convert to/from Foundation types
public protocol FoundationTypeBridging {
    /// The Foundation type this can convert to/from
    associatedtype FoundationType
    
    /// Convert from the Foundation type
    /// - Parameter foundation: The Foundation type to convert from
    /// - Returns: The Foundation-free equivalent
    static func fromFoundation(_ foundation: FoundationType) -> Self
    
    /// Convert to the Foundation type
    /// - Returns: The Foundation type equivalent
    func toFoundation() -> FoundationType
}

/// Errors that can occur during type bridging
public enum TypeBridgingError: Error, Sendable {
    /// Failed to convert to the target type
    case conversionFailed(reason: String)
    /// Invalid input format
    case invalidFormat(reason: String)
    /// Unsupported operation
    case unsupportedOperation(reason: String)
}
