// DEPRECATED: BaseXPCAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreErrors
import ErrorHandlingDomains
import Foundation
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

    /// Map NSError to XPCSecurityError
    func mapSecurityError(_ error: NSError) -> XPCSecurityError

    /// Handle the XPC connection invalidation
    func setupInvalidationHandler()

    /// Execute a selector on the XPC connection's remote object
    func executeXPCSelector<T>(_ selector: String, withArguments arguments: [Any]) async -> T?
}

/// Default implementations for common adapter functionality
public extension BaseXPCAdapter {
    /// Convert NSData to SecureBytes
    func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let bytes = [UInt8](Data(referencing: data))
        return SecureBytes(bytes: bytes)
    }

    /// Convert SecureBytes to NSData
    func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        let data = Data(Array(secureBytes))
        return data as NSData
    }

    /// Convert regular Data to SecureBytes
    func secureBytes(from data: Data) -> SecureBytes {
        let bytes = [UInt8](data)
        return SecureBytes(bytes: bytes)
    }

    /// Process an XPC result with custom transformation
    func processXPCResult<T>(
        _ result: NSObject?,
        transform: (NSData) -> T
    ) -> Result<T, XPCSecurityError> {
        if let error = result as? NSError {
            .failure(mapSecurityError(error))
        } else if let nsData = result as? NSData {
            .success(transform(nsData))
        } else {
            .failure(.invalidInput(details: "Unexpected result format"))
        }
    }

    /// Set up invalidation handler for the XPC connection
    func setupInvalidationHandler() {
        connection.invalidationHandler = {
            NSLog("XPC connection invalidated")
        }

        connection.interruptionHandler = {
            NSLog("XPC connection interrupted")
        }
    }

    /// Execute a selector on the XPC connection's remote object
    func executeXPCSelector<T>(
        _ selector: String,
        withArguments arguments: [Any] = []
    ) async -> T? {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString(selector)
                let result: Any?

                switch arguments.count {
                case 0:
                    result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                        .takeRetainedValue()
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
                    // Fix the syntax for calling a method with three arguments
                    let target = connection.remoteObjectProxy as AnyObject
                    let methodImp = target.method(for: selector)
                    let methodCall = unsafeBitCast(
                        methodImp,
                        to: (
                            @convention(c) (AnyObject, Selector, AnyObject, AnyObject, AnyObject)
                                -> Unmanaged<AnyObject>?
                        ).self
                    )
                    let resultManaged = methodCall(
                        target,
                        selector,
                        arguments[0] as AnyObject,
                        arguments[1] as AnyObject,
                        arguments[2] as AnyObject
                    )
                    result = resultManaged?.takeRetainedValue()
                default:
                    NSLog("Warning: Cannot execute XPC selector with more than 3 arguments")
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: result as? T)
            }
        }
    }

    /// Map NSError to XPCSecurityError
    func mapSecurityError(_ error: NSError) -> XPCSecurityError {
        if error.domain == "com.umbra.security.xpc" {
            if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
                if message.contains("invalid format") || message.contains("Invalid format") {
                    return .invalidInput(details: message)
                } else if message.contains("encryption failed") {
                    return .cryptographicError(operation: "encryption", details: message)
                } else if message.contains("decryption failed") {
                    return .cryptographicError(operation: "decryption", details: message)
                } else if message.contains("key not found") {
                    return .keyNotFound(identifier: message.components(separatedBy: ": ").last ?? "unknown")
                }
            }

            switch error.code {
            case 1_001:
                return .serviceUnavailable
            case 1_002:
                return .authorizationDenied(operation: "SecurityService operation")
            case 1_003:
                return .operationNotSupported(name: "Invalid operation")
            default:
                return .internalError(
                    reason: "Unknown error (code: \(error.code), message: \(error.localizedDescription))"
                )
            }
        }

        return .internalError(
            reason: "External error (domain: \(error.domain), code: \(error.code), message: \(error.localizedDescription))"
        )
    }

    /// Maps XPCSecurityError to UmbraErrors.Security.Protocols
    func mapToProtocolError(_ error: XPCSecurityError) -> UmbraErrors.Security.Protocols {
        // Map XPC error to Protocol error based on case
        switch error {
        case let .cryptographicError(operation, details):
            if operation == "encryption" {
                .encryptionFailed("\(details)")
            } else if operation == "decryption" {
                .decryptionFailed("\(details)")
            } else {
                .serviceError("Cryptographic operation failed: \(operation) - \(details)")
            }
        case let .keyNotFound(identifier):
            .serviceError("Key not found: \(identifier)")
        case let .invalidInput(details):
            .invalidFormat(reason: details)
        case .serviceUnavailable:
            .serviceError("Service unavailable")
        case let .internalError(reason):
            .internalError(reason)
        case let .operationNotSupported(name):
            .unsupportedOperation(name: name)
        default:
            .internalError("Unknown error: \(error)")
        }
    }
}
