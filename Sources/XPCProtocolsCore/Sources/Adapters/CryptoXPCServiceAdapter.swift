// DEPRECATED: CryptoXPCServiceAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

/**
 # Crypto XPC Service Adapter

 This file provides an adapter implementation that bridges between crypto service protocols
 and the XPC protocol hierarchy. It allows existing crypto service implementations
 to be used with the standardised XPC protocol hierarchy without requiring modifications
 to the service itself.

 ## Features

 * Seamless adaptation between crypto service interfaces and modern XPC protocols
 * Transparent conversion between different data types (SecureBytes Data)
 * Error translation between different error domains
 * Full implementation of XPCServiceProtocolComplete interface
 * Protocol-based design to avoid direct dependencies
 */

import Combine
import CoreDTOs
import CoreErrors
import Foundation
import UmbraCoreTypes

// Entire file is deprecated - providing stub definitions

/// Deprecated legacy CryptoXPCServiceAdapter class that should not be used in new code
// DEPRECATED: public final class CryptoXPCServiceAdapter: NSObject,
//     XPCServiceProtocolStandard,
//     XPCServiceProtocolComplete
// {
//     /// The underlying crypto service being adapted
//     private let service: any CryptoXPCServiceProtocol
// 
//     /// Initialises the adapter with a CryptoXPCService
//     /// - Parameter service: The crypto service to adapt
//     public init(service: any CryptoXPCServiceProtocol) {
//         self.service = service
//     }
// }

/// Deprecated legacy CryptoXPCServiceAdapter class that should not be used in new code
public class CryptoXPCServiceAdapter {
    /// This is a stub implementation. The original implementation has been deprecated.
    private var service: Any? = nil
}
