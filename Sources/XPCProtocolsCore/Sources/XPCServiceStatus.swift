import Foundation

/// Status information about an XPC service
///
/// This struct provides detailed information about the current state of an XPC service,
/// including its operational status, version information, and other metadata.
public struct XPCServiceStatus: Codable, Hashable, Sendable {
    /// Whether the service is currently active and responding
    public let isActive: Bool
    
    /// Version string of the service
    public let version: String
    
    /// Type of service (e.g., "Encryption Service", "Authentication Service")
    public let serviceType: String
    
    /// Additional service-specific information and metadata
    public let additionalInfo: [String: String]
    
    /// Creates a new service status object
    /// - Parameters:
    ///   - isActive: Whether the service is active
    ///   - version: Service version
    ///   - serviceType: Type of service
    ///   - additionalInfo: Additional metadata
    public init(
        isActive: Bool,
        version: String,
        serviceType: String,
        additionalInfo: [String: String] = [:]
    ) {
        self.isActive = isActive
        self.version = version
        self.serviceType = serviceType
        self.additionalInfo = additionalInfo
    }
    
    /// Creates a status with common failure information
    /// - Parameters:
    ///   - errorReason: Reason for the failure
    ///   - serviceType: Type of service
    /// - Returns: Status object indicating failure
    public static func failure(
        errorReason: String,
        serviceType: String
    ) -> XPCServiceStatus {
        XPCServiceStatus(
            isActive: false,
            version: "unknown",
            serviceType: serviceType,
            additionalInfo: ["errorReason": errorReason]
        )
    }
    
    /// Status indicating the service is in an operational state
    public var isOperational: Bool {
        isActive && (additionalInfo["status"] != "degraded")
    }
}
