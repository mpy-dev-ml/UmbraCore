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

/// Protocol defining the base XPC service interface without Foundation dependencies.
/// This protocol serves as the foundation for all XPC services in UmbraCore and
/// provides the minimal functionality required for service discovery and basic operations.
@objc
public protocol XPCServiceProtocolBasic: NSObjectProtocol, Sendable {
    /// Protocol identifier - used for protocol negotiation and service discovery.
    /// Each XPC service implementation should provide a unique identifier.
    static var protocolIdentifier: String { get }

    /// Basic ping method to test if service is responsive.
    /// This method can be used for health checks and to verify connectivity.
    /// - Returns: `true` if the service is responsive, `false` otherwise
    func ping() async -> Bool

    /// Basic synchronisation of keys between XPC service and client.
    /// This method allows secure key material to be shared across process boundaries.
    /// - Parameters:
    ///   - bytes: Raw byte array for key synchronisation
    ///   - completionHandler: Called with `nil` if successful, or an NSError if failed
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
}

/// Default protocol implementation with baseline functionality.
/// These implementations can be overridden by conforming types when needed,
/// but provide sensible defaults for minimal compliance.
public extension XPCServiceProtocolBasic {
    /// Default protocol identifier that uniquely identifies this protocol version.
    /// Services should override this with their own unique identifier.
    static var protocolIdentifier: String {
        "com.umbra.xpc.service.protocol.basic"
    }

    /// Default implementation of ping - always succeeds.
    /// In real implementations, this should verify actual service health.
    func ping() async -> Bool {
        true
    }

    /// Convert the completion handler-based synchroniseKeys to a modern async method
    /// - Parameter bytes: Raw byte array for key synchronisation
    /// - Returns: Result indicating success or failure with error details
    func synchroniseKeysAsync(_ bytes: [UInt8]) async -> Result<Void, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            synchroniseKeys(bytes) { error in
                if let error {
                    continuation.resume(returning: .failure(XPCErrorUtilities.convertToXPCError(error)))
                } else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }
}
