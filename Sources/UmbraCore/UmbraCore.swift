@_exported import CryptoTypes
@_exported import SecurityTypes

/// Main entry point for UmbraCore functionality
public enum UmbraCore {
    /// Version of UmbraCore
    public static let version = "1.0.0"

    /// Initialize UmbraCore with default configuration
    public static func initialize() {
        // Initialize core services
    }
}

// Re-export main types and protocols
public typealias SecurityProvider = SecurityTypes.SecurityProvider
public typealias SecurityError = SecurityTypes.SecurityError
