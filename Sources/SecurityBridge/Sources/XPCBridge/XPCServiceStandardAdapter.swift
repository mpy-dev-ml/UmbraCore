// DEPRECATED: XPCServiceStandardAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreDTOs
import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// XPCServiceStandardAdapter provides an implementation of XPCServiceProtocolStandard
/// to handle the direct XPC communication with the security service.
///
/// This adapter handles low-level XPC operations by delegating to an XPC service,
/// providing a clean Objective-C compatible interface.
@objc
public final class XPCServiceStandardAdapter: NSObject, @unchecked Sendable {
    // MARK: - Properties

    /// Protocol identifier for XPC service protocol identification
    @objc
    public static var protocolIdentifier: String = "com.umbra.xpc.service.standard"

    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection

    // MARK: - Initialisation

    /// Initialise with an XPC connection and service interface protocol type
    ///
    /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
    public init(connection: NSXPCConnection) {
        self.connection = connection

        // Set up the XPC interface - use the XPCServiceProtocolStandard protocol
        let protocolObj = XPCServiceProtocolStandard.self as Any as! Protocol
        connection.remoteObjectInterface = NSXPCInterface(with: protocolObj)

        // Resume the connection
        connection.resume()

        super.init()
        setupInvalidationHandler()
    }

    /// Validate the XPC connection and check for service availability
    public func setupInvalidationHandler() {
        connection.invalidationHandler = { [weak self] in
            if self != nil {
                // Handle connection invalidation
                print("XPC connection invalidated")
            }
        }
    }

    /// Handle common error conditions with XPC services
    ///
    /// - Parameter error: The NSError from the XPC service
    /// - Returns: A SecurityError representation of the error
    private func handleXPCError(_ error: NSError) -> XPCSecurityError {
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }

        // Use different error codes to determine the type of error
        if error.domain == NSCocoaErrorDomain {
            switch error.code {
            case 1_001:
                return .internalError(reason: "Network error: \(error.localizedDescription)")
            case 1_002:
                return .invalidInput(details: error.localizedDescription)
            case 1_003:
                return .serviceUnavailable
            default:
                return .internalError(reason: error.localizedDescription)
            }
        } else {
            return .internalError(reason: error.localizedDescription)
        }
    }

    /// Convert NSData to SecureBytes
    public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let length = data.length
        var bytes = [UInt8](repeating: 0, count: length)
        data.getBytes(&bytes, length: length)
        return SecureBytes(bytes: bytes)
    }

    /// Convert SecureBytes to NSData
    public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        // Access the bytes through the appropriate method or property
        // This needs to be adjusted based on the actual SecureBytes implementation
        let bytes = [UInt8](secureBytes) // Assuming SecureBytes conforms to Sequence
        return NSData(bytes: bytes, length: bytes.count)
    }

    /// Map security errors to UmbraErrors
    public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
        // Check for known error domains and codes
        if error.domain == NSURLErrorDomain {
            return .connectionFailed(reason: error.localizedDescription)
        } else if error.domain == "XPCServiceErrorDomain" {
            // Map specific error codes to appropriate UmbraErrors
            switch error.code {
            case 1_001:
                return .connectionFailed(reason: error.localizedDescription)
            case 1_002:
                return .invalidMessageFormat(reason: error.localizedDescription)
            case 1_003:
                return .serviceUnavailable(serviceName: "XPC Service")
            default:
                return .internalError(error.localizedDescription)
            }
        }

        // Default error mapping
        return .internalError(error.localizedDescription)
    }
}

// MARK: - XPCServiceProtocolStandard Implementation

extension XPCServiceStandardAdapter: XPCServiceProtocolStandard {
    @objc
    public func ping() async -> Bool {
        // Perform the XPC call to ping the service
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolBasic else {
                continuation.resume(returning: false)
                return
            }

            Task {
                let result = await proxy.ping()
                continuation.resume(returning: result)
            }
        }
    }

    // The synchroniseKeys method now uses SecureBytes directly instead of [UInt8]
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Get the bytes from SecureBytes
        var syncBytes = [UInt8]()
        syncData.withUnsafeBytes { buffer in
            syncBytes = Array(buffer)
        }

        // Use a custom completion handler approach
        try await withCheckedThrowingContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolBasic else {
                continuation.resume(throwing: XPCSecurityError.serviceUnavailable)
                return
            }

            // Use the Objective-C compatible method
            proxy.synchroniseKeys(syncBytes) { error in
                if let error = error {
                    let xpcError = self.handleXPCError(error)
                    continuation.resume(throwing: xpcError)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func pingStandard() async -> Result<Bool, XPCSecurityError> {
        let success = await ping()
        return .success(success)
    }

    public func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                // Use the existing method but convert result to Result<SecureBytes, XPCSecurityError>
                if let result = await proxy.generateRandomData(length: length) {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let data = result as? NSData {
                        let secureBytes = self.convertNSDataToSecureBytes(data)
                        continuation.resume(returning: .success(secureBytes))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Convert SecureBytes to NSData for the XPC call
        let nsData = convertSecureBytesToNSData(data)
        
        return await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.encryptData(nsData, keyIdentifier: keyIdentifier) {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let resultData = result as? NSData {
                        let secureBytes = self.convertNSDataToSecureBytes(resultData)
                        continuation.resume(returning: .success(secureBytes))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Convert SecureBytes to NSData for the XPC call
        let nsData = convertSecureBytesToNSData(data)
        
        return await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.decryptData(nsData, keyIdentifier: keyIdentifier) {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let resultData = result as? NSData {
                        let secureBytes = self.convertNSDataToSecureBytes(resultData)
                        continuation.resume(returning: .success(secureBytes))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func sign(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        // Convert SecureBytes to NSData for the XPC call
        let nsData = convertSecureBytesToNSData(data)
        
        return await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.signData(nsData, keyIdentifier: keyIdentifier) {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let resultData = result as? NSData {
                        let secureBytes = self.convertNSDataToSecureBytes(resultData)
                        continuation.resume(returning: .success(secureBytes))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func verify(signature: UmbraCoreTypes.SecureBytes, for data: UmbraCoreTypes.SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityError> {
        // Convert SecureBytes to NSData for the XPC call
        let signatureData = convertSecureBytesToNSData(signature)
        let contentData = convertSecureBytesToNSData(data)
        
        return await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.verifySignature(signatureData, for: contentData, keyIdentifier: keyIdentifier) {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let boolValue = result as? NSNumber {
                        continuation.resume(returning: .success(boolValue.boolValue))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // Standard implementation for a simple call that doesn't return data
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.resetSecurity() {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else {
                        continuation.resume(returning: .success(()))
                    }
                } else {
                    continuation.resume(returning: .failure(.serviceUnavailable))
                }
            }
        }
    }

    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.getServiceVersion() {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let version = result as? NSString {
                        continuation.resume(returning: .success(version as String))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    // Default version if none provided
                    continuation.resume(returning: .success("1.0.0"))
                }
            }
        }
    }

    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.getHardwareIdentifier() {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let identifier = result as? NSString {
                        continuation.resume(returning: .success(identifier as String))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    // Generate a fallback hardware identifier
                    continuation.resume(returning: .success("unknown-hardware"))
                }
            }
        }
    }

    public func status() async -> Result<[String: Any], XPCSecurityError> {
        await withCheckedContinuation { continuation in
            guard let proxy = connection.remoteObjectProxy as? XPCServiceProtocolStandard else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            Task {
                if let result = await proxy.getServiceStatus() {
                    if let error = result as? NSError {
                        continuation.resume(returning: .failure(self.handleXPCError(error)))
                    } else if let statusDict = result as? NSDictionary {
                        let swiftDict = statusDict as? [String: Any] ?? [:]
                        continuation.resume(returning: .success(swiftDict))
                    } else {
                        continuation.resume(returning: .failure(.invalidInput(details: "Unexpected result format")))
                    }
                } else {
                    // Create a basic status dictionary
                    let basicStatus: [String: Any] = [
                        "status": "unknown",
                        "version": "1.0.0",
                        "timestamp": Date().timeIntervalSince1970
                    ]
                    continuation.resume(returning: .success(basicStatus))
                }
            }
        }
    }
    
    // MARK: - Legacy Methods for Backward Compatibility
    
    @objc
    public func generateRandomBytes(length: Int) async -> NSObject? {
        let result = await generateRandomData(length: length)
        switch result {
        case .success(let secureBytes):
            return convertSecureBytesToNSData(secureBytes)
        case .failure(let error):
            return NSError(domain: "com.umbra.xpc.security", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Failed to generate random data: \(error.localizedDescription)"
            ])
        }
    }
    
    @objc
    public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        let secureBytes = convertNSDataToSecureBytes(data)
        let result = await encryptSecureData(secureBytes, keyIdentifier: keyIdentifier)
        switch result {
        case .success(let encryptedBytes):
            return convertSecureBytesToNSData(encryptedBytes)
        case .failure(let error):
            return NSError(domain: "com.umbra.xpc.security", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Encryption failed: \(error.localizedDescription)"
            ])
        }
    }
    
    @objc
    public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        let secureBytes = convertNSDataToSecureBytes(data)
        let result = await decryptSecureData(secureBytes, keyIdentifier: keyIdentifier)
        switch result {
        case .success(let decryptedBytes):
            return convertSecureBytesToNSData(decryptedBytes)
        case .failure(let error):
            return NSError(domain: "com.umbra.xpc.security", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Decryption failed: \(error.localizedDescription)"
            ])
        }
    }
    
    @objc
    public func hashData(_ data: NSData) async -> NSObject? {
        // Implementation using modern SecureBytes interface but returning NSObject for compatibility
        let secureBytes = convertNSDataToSecureBytes(data)
        
        // This is a placeholder - the actual implementation would perform a hash function
        var hashBytes = [UInt8](repeating: 0, count: 32) // SHA-256 size
        let hashResult = SecureBytes(bytes: hashBytes)
        
        return convertSecureBytesToNSData(hashResult)
    }
    
    @objc
    public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        let secureBytes = convertNSDataToSecureBytes(data)
        let result = await sign(secureBytes, keyIdentifier: keyIdentifier)
        switch result {
        case .success(let signatureBytes):
            return convertSecureBytesToNSData(signatureBytes)
        case .failure(let error):
            return NSError(domain: "com.umbra.xpc.security", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Signing failed: \(error.localizedDescription)"
            ])
        }
    }
    
    @objc
    public func verifySignature(_ signature: NSData, for data: NSData, keyIdentifier: String) async -> NSNumber? {
        let signatureBytes = convertNSDataToSecureBytes(signature)
        let dataBytes = convertNSDataToSecureBytes(data)
        let result = await verify(signature: signatureBytes, for: dataBytes, keyIdentifier: keyIdentifier)
        switch result {
        case .success(let isValid):
            return NSNumber(value: isValid)
        case .failure:
            return NSNumber(value: false)
        }
    }
    
    @objc
    public func getServiceStatus() async -> NSDictionary? {
        let result = await status()
        switch result {
        case .success(let statusDict):
            return statusDict as NSDictionary
        case .failure:
            // Return a basic error status
            return ["status": "error", "timestamp": Date().timeIntervalSince1970] as NSDictionary
        }
    }
}
