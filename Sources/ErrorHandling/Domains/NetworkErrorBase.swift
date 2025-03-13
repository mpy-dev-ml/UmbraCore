import ErrorHandlingInterfaces
import Foundation

public extension UmbraErrors {
    /// Network error domain
    enum Network {
        // This namespace contains the various network error types
        // Implementation in separate files:
        // - NetworkCoreErrors.swift - Core network errors
        // - NetworkHTTPErrors.swift - HTTP-specific errors
        // - NetworkSocketErrors.swift - Socket communication errors
    }
}
