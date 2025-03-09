import Foundation
import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import SecurityProtocolsCore
import XPCProtocolsCore

/// ComprehensiveSecurityXPCAdapter provides an implementation of ComprehensiveSecurityServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles comprehensive security operations by delegating to an XPC service,
/// providing a unified API for service-level operations.
public final class ComprehensiveSecurityXPCAdapter: NSObject, BaseXPCAdapter {
    // MARK: - Properties
    
    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection
    
    // MARK: - Initialisation
    
    /// Initialise with an NSXPCConnection
    /// - Parameter connection: The connection to the XPC service
    public init(connection: NSXPCConnection) {
        self.connection = connection
        super.init()
        setupInvalidationHandler()
    }
}

// MARK: - ComprehensiveSecurityServiceProtocol Implementation

extension ComprehensiveSecurityXPCAdapter: ComprehensiveSecurityServiceProtocol {
    public func getServiceVersion() async -> Result<String, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("getServiceVersion")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                        .takeRetainedValue() as? NSString
                else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.serviceUnavailable))
                    return
                }
                
                continuation.resume(returning: .success(result as String))
            }
        }
    }
    
    public func getServiceStatus() async -> Result<ServiceStatus, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("getServiceStatus")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                        .takeRetainedValue() as? NSNumber
                else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.serviceUnavailable))
                    return
                }
                
                let status = ServiceStatus(rawValue: result.intValue) ?? .unknown
                continuation.resume(returning: .success(status))
            }
        }
    }
    
    public func encryptData(
        data: Data,
        key: Data
    ) async -> Result<Data, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("encryptData:withKey:")
                let result = (connection.remoteObjectProxy as AnyObject).perform(
                    selector,
                    with: data as NSData,
                    with: key as NSData
                )?.takeRetainedValue()
                
                if let error = result as? NSError {
                    continuation.resume(returning: .failure(mapSecurityError(error)))
                } else if let nsData = result as? NSData {
                    continuation.resume(returning: .success(Data(referencing: nsData)))
                } else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Invalid result format")))
                }
            }
        }
    }
    
    public func decryptData(
        data: Data,
        key: Data
    ) async -> Result<Data, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("decryptData:withKey:")
                let result = (connection.remoteObjectProxy as AnyObject).perform(
                    selector,
                    with: data as NSData,
                    with: key as NSData
                )?.takeRetainedValue()
                
                if let error = result as? NSError {
                    continuation.resume(returning: .failure(mapSecurityError(error)))
                } else if let nsData = result as? NSData {
                    continuation.resume(returning: .success(Data(referencing: nsData)))
                } else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Invalid result format")))
                }
            }
        }
    }
    
    public func hashData(data: Data) async -> Result<Data, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("hashData:")
                let result = (connection.remoteObjectProxy as AnyObject).perform(
                    selector,
                    with: data as NSData
                )?.takeRetainedValue()
                
                if let error = result as? NSError {
                    continuation.resume(returning: .failure(mapSecurityError(error)))
                } else if let nsData = result as? NSData {
                    continuation.resume(returning: .success(Data(referencing: nsData)))
                } else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Invalid result format")))
                }
            }
        }
    }
    
    public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("generateKey")
                let result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                    .takeRetainedValue()
                
                if let error = result as? NSError {
                    continuation.resume(returning: .failure(mapSecurityError(error)))
                } else if let nsData = result as? NSData {
                    let bytes = [UInt8](Data(referencing: nsData))
                    let secureBytes = SecureBytes(bytes: bytes)
                    continuation.resume(returning: .success(secureBytes))
                } else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Invalid result format")))
                }
            }
        }
    }
    
    public func verify(
        data: Data,
        signature: Data
    ) async -> Result<Bool, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("verifyData:withSignature:")
                let result = (connection.remoteObjectProxy as AnyObject).perform(
                    selector,
                    with: data as NSData,
                    with: signature as NSData
                )?.takeRetainedValue()
                
                if let error = result as? NSError {
                    continuation.resume(returning: .failure(mapSecurityError(error)))
                } else if let verified = result as? NSNumber {
                    continuation.resume(returning: .success(verified.boolValue))
                } else {
                    continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Invalid result format")))
                }
            }
        }
    }
}
