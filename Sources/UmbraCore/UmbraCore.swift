@_exported import CryptoTypes
@_exported import CryptoTypes_Types
@_exported import CryptoTypes_Protocols
@_exported import SecurityTypes
@_exported import UmbraLogging

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

// Re-export logging types
public typealias LogEntry = UmbraLogging.LogEntry
public typealias LogLevel = UmbraLogging.LogLevel
public typealias LoggingError = UmbraLogging.LoggingError
public typealias LoggingProtocol = UmbraLogging.LoggingProtocol
public typealias LoggingService = UmbraLogging.LoggingService

// Re-export crypto types
public typealias CryptoError = CryptoTypes_Types.CryptoError
public typealias CryptoService = CryptoTypes_Protocols.CryptoService
