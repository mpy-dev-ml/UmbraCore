import ErrorHandlingInterfaces
import Foundation

public extension UmbraErrors {
    /// XPC communication error domain
    enum XPC {
        // This namespace contains the various XPC error types
        // Implementation in separate files:
        // - XPCCoreErrors.swift - Core XPC communication errors
        // - XPCProtocolErrors.swift - XPC protocol-specific errors
    }
}
