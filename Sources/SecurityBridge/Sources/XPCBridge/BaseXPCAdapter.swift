import Foundation
import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import XPCProtocolsCore

/// Base protocol for XPC adapters that defines common functionality
/// for handling XPC connections and conversions.
public protocol BaseXPCAdapter {
    /// The NSXPCConnection used to communicate with the XPC service
    var connection: NSXPCConnection { get }
    
    /// Convert NSData to SecureBytes
    func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes
    
    /// Convert SecureBytes to NSData
    func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData
    
    /// Map NSError to UmbraErrors.Security.XPC
    func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC
    
    /// Handle the XPC connection invalidation
    func setupInvalidationHandler()
    
    /// Execute a selector on the XPC connection's remote object
    func executeXPCSelector<T>(_ selector: String, withArguments arguments: [Any]) async -> T?
}

/// Default implementations for common adapter functionality
extension BaseXPCAdapter {
    /// Convert NSData to SecureBytes
    public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let bytes = [UInt8](Data(referencing: data))
        return SecureBytes(bytes: bytes)
    }
    
    /// Convert SecureBytes to NSData
    public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        let data = Data(secureBytes.bytes)
        return data as NSData
    }
    
    /// Convert regular Data to SecureBytes
    public func secureBytes(from data: Data) -> SecureBytes {
        let bytes = [UInt8](data)
        return SecureBytes(bytes: bytes)
    }
    
    /// Process an XPC result with custom transformation
    public func processXPCResult<T>(
        _ result: NSObject?,
        transform: (NSData) -> T
    ) -> Result<T, UmbraErrors.Security.XPC> {
        if let error = result as? NSError {
            return .failure(mapSecurityError(error))
        } else if let nsData = result as? NSData {
            return .success(transform(nsData))
        } else {
            return .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Unexpected result format"))
        }
    }
    
    /// Set up invalidation handler for the XPC connection
    public func setupInvalidationHandler() {
        connection.invalidationHandler = {
            NSLog("XPC connection invalidated")
        }
        
        connection.interruptionHandler = {
            NSLog("XPC connection interrupted")
        }
    }
    
    /// Execute a selector on the XPC connection's remote object
    public func executeXPCSelector<T>(_ selector: String, withArguments arguments: [Any] = []) async -> T? {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString(selector)
                let result: Any?
                
                switch arguments.count {
                case 0:
                    result = (connection.remoteObjectProxy as AnyObject).perform(selector)?.takeRetainedValue()
                case 1:
                    result = (connection.remoteObjectProxy as AnyObject).perform(
                        selector,
                        with: arguments[0]
                    )?.takeRetainedValue()
                case 2:
                    result = (connection.remoteObjectProxy as AnyObject).perform(
                        selector,
                        with: arguments[0],
                        with: arguments[1]
                    )?.takeRetainedValue()
                case 3:
                    result = (connection.remoteObjectProxy as AnyObject).perform(
                        selector,
                        with: arguments[0],
                        with: arguments[1],
                        with: arguments[2]
                    )?.takeRetainedValue()
                default:
                    NSLog("Warning: Cannot execute XPC selector with more than 3 arguments")
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: result as? T)
            }
        }
    }
    
    /// Map NSError to UmbraErrors.Security.XPC
    public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
        if error.domain == "com.umbra.security.xpc" {
            if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
                if message.contains("invalid format") || message.contains("Invalid format") {
                    return UmbraErrors.Security.XPC.invalidFormat(reason: message)
                } else if message.contains("encryption failed") {
                    return UmbraErrors.Security.XPC.encryptionFailed(reason: message)
                } else if message.contains("decryption failed") {
                    return UmbraErrors.Security.XPC.decryptionFailed(reason: message)
                } else if message.contains("key not found") {
                    return UmbraErrors.Security.XPC.keyNotFound(identifier: message)
                }
            }
            
            switch error.code {
            case 1001:
                return UmbraErrors.Security.XPC.serviceUnavailable
            case 1002:
                return UmbraErrors.Security.XPC.operationNotPermitted
            case 1003:
                return UmbraErrors.Security.XPC.invalidOperation
            default:
                return UmbraErrors.Security.XPC.unknownError(code: error.code, message: error.localizedDescription)
            }
        }
        
        return UmbraErrors.Security.XPC.unknownError(code: error.code, message: error.localizedDescription)
    }
    
    /// Maps UmbraErrors.Security.XPC to UmbraErrors.Security.Protocols
    public func mapToProtocolError(_ error: UmbraErrors.Security.XPC) -> UmbraErrors.Security.Protocols {
        // Map XPC error to Protocol error based on case
        switch error {
        case .encryptionFailed:
            return .encryptionFailed
        case .decryptionFailed:
            return .decryptionFailed
        case .keyGenerationFailed:
            return .keyGenerationFailed
        case let .invalidFormat(reason):
            return .invalidFormat(reason: reason)
        case .hashingFailed:
            return .hashVerificationFailed
        case .serviceUnavailable:
            return .serviceError
        case let .internalError(message):
            return .internalError(message)
        case .notImplemented:
            return .notImplemented
        case let .unsupportedOperation(name):
            return .unsupportedOperation(name: name)
        default:
            return .internalError("Unknown error: \(error)")
        }
    }
}
