import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesProtocols
import Foundation

/// Utility for mapping between SecurityError and SecurityBridgeError
public enum SecurityBridgeErrorMapper {
    /// Map from SecurityError to SecurityBridgeError
    /// - Parameter error: Original error
    /// - Returns: Mapped bridge error
    public static func mapToBridgeError(_ error: Error) -> SecurityBridgeError {
        if let securityError = error as? SecurityError {
            switch securityError {
            case .internalError(let message):
                return SecurityBridgeError.implementationMissing("Internal error: \(message)")
            default:
                return SecurityBridgeError.implementationMissing("Unknown error: \(securityError.localizedDescription)")
            }
        }
        return SecurityBridgeError.implementationMissing("Non-SecurityError: \(error.localizedDescription)")
    }
    
    /// Map from SecurityBridgeError to SecurityError
    /// - Parameter error: Bridge error
    /// - Returns: Mapped security error
    public static func mapToSecurityError(_ error: SecurityBridgeError) -> Error {
        switch error {
        case .implementationMissing(let message):
            return SecurityError.internalError(message)
        case .bookmarkResolutionFailed:
            return SecurityError.internalError("Bookmark resolution failed")
        }
    }
}
