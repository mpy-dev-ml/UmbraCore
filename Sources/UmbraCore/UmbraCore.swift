@_exported import Core
@_exported import SecurityTypes
@_exported import UmbraSecurity
@_exported import Logging

// Re-export main types and protocols
public typealias SecurityProvider = SecurityTypes.SecurityProvider
public typealias SecurityService = UmbraSecurity.SecurityService
public typealias LoggingService = Logging.LoggingService

// Export error types
public typealias SecurityError = SecurityTypes.SecurityError
public typealias LoggingError = Logging.LoggingError

// Export logging types
public typealias LogEntry = Logging.LogEntry

// Export protocols
public typealias LoggingProtocol = Logging.LoggingProtocol
