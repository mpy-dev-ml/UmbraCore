import CoreTypes

/// Minimal protocol that can be used by both Foundation and SecurityInterfacesFoundationBridge
/// This protocol does not import Foundation to avoid circular dependencies
public protocol XPCServiceProtocolMinimalBridge: Sendable {
    /// Protocol identifier
    static var protocolIdentifier: String { get }

    /// Test connectivity with minimal types
    func ping() async throws -> Bool

    /// Synchronize keys across processes with minimal types
    func synchroniseKeysMinimal(_ data: [UInt8]) async throws
}

/// Custom error for minimal bridge that doesn't require Foundation
public enum XPCServiceProtocolMinimalError: Error, Sendable {
    case implementationMissing(String)
    case conversionFailed(String)
}

/// Extension to provide default implementations
public extension XPCServiceProtocolMinimalBridge {
    static var protocolIdentifier: String {
        return "XPCServiceProtocolMinimalBridge"
    }
}
