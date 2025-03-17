/**
 # XPC Protocol Migration Guide
 
 This file provides guidance for migrating from legacy XPC service interfaces
 to the modern protocol-based approach. It outlines the key differences between
 the legacy and modern approaches and provides recommendations for migrating
 existing code.
 
 ## Migration Path
 
 1. Replace NSData/NSObject-based APIs with SecureBytes and Result types
 2. Adopt protocol-based abstractions instead of concrete implementation dependencies
 3. Transition from completion-handler based APIs to async/await
 4. Use structured error types with Result return values
 
 ## Deprecation Timeline
 
 * 2025-Q1: Legacy interfaces marked as deprecated
 * 2025-Q3: Legacy interfaces trigger compiler warnings
 * 2026-Q1: Legacy interfaces removed

 ## Key Protocol Changes
 
 * XPCServiceProtocolBasic now conforms to XPCErrorHandlingProtocol and XPCDataHandlingProtocol
 * XPCServiceProtocolStandard now provides parallel modern methods using SecureBytes
 * XPCServiceProtocolComplete now offers comprehensive Result-based error handling
 */

import Foundation

/// Enum containing version constants and migration guidance
public enum XPCProtocolMigration {
    /// Current version of the XPC protocol framework
    public static let currentVersion = "2.0.0"
    
    /// The minimum supported legacy version
    public static let minimumLegacyVersion = "1.5.0"
    
    /// Target version for migration completion
    public static let targetMigrationVersion = "3.0.0"
    
    /// Determine if a legacy version is supported for migration
    /// - Parameter version: The legacy version to check
    /// - Returns: True if the version is supported for migration
    public static func isVersionSupported(for version: String) -> Bool {
        // Simple version comparison logic
        return version >= minimumLegacyVersion
    }
}

// MARK: - Deprecated APIs

/// Namespace for deprecated APIs and transitional types
public enum DeprecatedAPIs {
    /// Deprecated error mapping function
    @available(*, deprecated, message: "Use XPCErrorHandlingProtocol.mapError instead")
    public static func convertToXPCError(_ error: Error) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        } else if let nsError = error as NSError {
            let domain = nsError.domain
            let code = nsError.code
            return .unspecifiedError(description: "\(domain) error \(code): \(nsError.localizedDescription)", code: code)
        } else {
            return .unspecifiedError(description: String(describing: error), code: 0)
        }
    }
    
    /// Deprecated data conversion function
    @available(*, deprecated, message: "Use XPCDataHandlingProtocol.convertDataToSecureBytes instead")
    public static func secureBytes(from data: Data) -> SecureBytes {
        return SecureBytes(bytes: [UInt8](data))
    }
    
    /// Deprecated NSData conversion function
    @available(*, deprecated, message: "Use XPCDataHandlingProtocol.convertNSDataToSecureBytes instead")
    public static func secureBytes(from nsData: NSData) -> SecureBytes {
        return SecureBytes(bytes: [UInt8](Data(referencing: nsData)))
    }
}

// MARK: - Migration Helpers

/// Extension to help bridge legacy interfaces to modern implementations
public extension XPCServiceProtocolComplete {
    /// Bridge from legacy synchronizeKeys to modern implementation
    @available(*, deprecated, message: "Use synchroniseKeysAsync instead")
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        return await synchroniseKeysAsync(syncData.bytes)
    }
    
    /// Bridge from legacy encrypt to modern implementation
    @available(*, deprecated, message: "Use encryptSecureData instead")
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return await encryptSecureData(data, keyIdentifier: nil)
    }
    
    /// Bridge from legacy decrypt to modern implementation
    @available(*, deprecated, message: "Use decryptSecureData instead")
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return await decryptSecureData(data, keyIdentifier: nil)
    }
    
    /// Bridge from legacy hash to modern implementation
    @available(*, deprecated, message: "Use hashSecureData instead")
    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return await hashSecureData(data)
    }
    
    /// Bridge from legacy sign to modern implementation
    @available(*, deprecated, message: "Use signSecureData instead")
    func sign(data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        return await signSecureData(data, keyIdentifier: keyIdentifier)
    }
    
    /// Bridge from legacy verify to modern implementation
    @available(*, deprecated, message: "Use verifySecureSignature instead")
    func verify(signature: SecureBytes, data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        return await verifySecureSignature(signature, for: data, keyIdentifier: keyIdentifier)
    }
    
    /// Bridge from legacy getStatus to modern implementation
    @available(*, deprecated, message: "Use getServiceStatus instead")
    func getStatus() async -> Result<ServiceStatus, XPCSecurityError> {
        let result = await getServiceStatus()
        switch result {
        case .success(let status):
            return .success(ServiceStatus(
                isActive: status.isActive,
                version: status.version,
                serviceType: status.serviceType,
                additionalInfo: status.additionalInfo
            ))
        case .failure(let error):
            return .failure(error)
        }
    }
}

/// Legacy service status type for backward compatibility
@available(*, deprecated, message: "Use XPCServiceStatus instead")
public struct ServiceStatus {
    public let isActive: Bool
    public let version: String
    public let serviceType: String
    public let additionalInfo: [String: String]
    
    public init(isActive: Bool, version: String, serviceType: String, additionalInfo: [String: String] = [:]) {
        self.isActive = isActive
        self.version = version
        self.serviceType = serviceType
        self.additionalInfo = additionalInfo
    }
}
