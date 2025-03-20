/**
 # Basic XPC Service Protocol

 This file defines the most fundamental protocol for XPC services in UmbraCore.
 The basic protocol establishes minimal functionality that all XPC services must implement,
 providing a foundation for the more advanced protocol levels.

 ## Features

 * Protocol identification capability for service discovery
 * Basic connectivity testing (ping)
 * Simplified key synchronisation mechanism
 * Foundation-free interface design
 * Standardised error handling and data conversion

 This protocol serves as the base for all XPC service implementations in UmbraCore
 and ensures a consistent minimum API across all services.
 */

import ErrorHandling
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import CoreErrors

/// Protocol defining the base XPC service interface without Foundation dependencies.
/// This protocol serves as the foundation for all XPC services in UmbraCore and
/// provides the minimal functionality required for service discovery and basic operations.
public protocol XPCServiceProtocolBasic: Sendable {
    /// Protocol identifier - used for protocol negotiation and service discovery.
    /// Each XPC service implementation should provide a unique identifier.
    static var protocolIdentifier: String { get }

    /// Basic ping method to test if service is responsive.
    /// This method can be used for health checks and to verify connectivity.
    /// - Returns: `true` if the service is responsive, `false` otherwise
    func ping() async -> Bool

    /// Basic synchronisation of keys between XPC service and client.
    /// This method allows secure key material to be shared across process boundaries.
    /// - Parameter syncData: Secure bytes for key synchronisation
    /// - Throws: ErrorHandlingDomains.UmbraErrors.Security.Protocols if synchronisation fails
    func synchroniseKeys(_ syncData: SecureBytes) async throws

    /// Get the current status of the XPC service
    /// - Returns: Result containing status information or error
    func status() async -> Result<[String: Any], ErrorHandlingDomains.UmbraErrors.Security.Protocols>
}

/// Default protocol implementation with baseline functionality.
/// These implementations can be overridden by conforming types when needed,
/// but provide sensible defaults for minimal compliance.
public extension XPCServiceProtocolBasic {
    /// Default protocol identifier that uniquely identifies this protocol version.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.basic"
    }

    /// Default implementation of the basic ping method.
    /// - Returns: Always returns true for basic implementations
    func pingBasic() async -> Result<Bool, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
        // Simple implementation that doesn't throw
        let pingResult = await ping()
        return .success(pingResult)
    }

    /// Extended synchronisation implementation with Result type return.
    /// - Parameter syncData: Secure bytes for key synchronisation
    /// - Returns: Result with success or failure with error information
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
        do {
            try await synchroniseKeys(syncData)
            return .success(())
        } catch let error as ErrorHandlingDomains.UmbraErrors.Security.Protocols {
            return .failure(error)
        } catch {
            return .failure(.internalError(error.localizedDescription))
        }
    }
}
