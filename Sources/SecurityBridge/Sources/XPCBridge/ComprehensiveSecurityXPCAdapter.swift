// DEPRECATED: ComprehensiveSecurityXPCAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// ComprehensiveSecurityXPCAdapter provides a comprehensive implementation of security services
/// using XPC for communication with a security service.
///
/// This adapter handles comprehensive security operations by delegating to an XPC service,
/// providing a unified API for service-level operations.
@objc
public final class ComprehensiveSecurityXPCAdapter: NSObject, BaseXPCAdapter,
    XPCServiceProtocolBasic, @unchecked Sendable
{
    // MARK: - Properties

    /// Static identifier for the protocol
    @objc
    public static var protocolIdentifier: String {
        "com.umbracore.security.comprehensive"
    }

    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection

    /// The service proxy for the ComprehensiveSecurityServiceProtocol
    public var serviceProxy: ComprehensiveSecurityServiceProtocol?

    // MARK: - Initialisation

    /// Initialise with an XPC connection
    public init(connection: NSXPCConnection) {
        self.connection = connection

        // Set up the XPC interface using ObjectiveC.Protocol to avoid Swift type errors
        let protocolObj = ComprehensiveSecurityServiceProtocol.self as Any as! Protocol
        let remoteInterface = NSXPCInterface(with: protocolObj)
        connection.remoteObjectInterface = remoteInterface

        // Set the exported interface
        let exportedProtocolObj = XPCServiceProtocolBasic.self as Any as! Protocol
        let exportedInterface = NSXPCInterface(with: exportedProtocolObj)
        connection.exportedInterface = exportedInterface

        // Resume the connection
        connection.resume()

        // Get the remote object proxy
        serviceProxy = connection.remoteObjectProxy as? ComprehensiveSecurityServiceProtocol

        super.init()
        setupInvalidationHandler()
    }

    // MARK: - BaseXPCAdapter Protocol Implementation

    /// Map NSError to UmbraErrors.Security.XPC
    public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
        // Check for known error domains and codes
        switch error.domain {
        case "XPCSecurityService":
            switch error.code {
            case 1: .connectionFailed(reason: error.localizedDescription)
            case 2: .invalidMessageFormat(reason: error.localizedDescription)
            case 3: .timeout(operation: error.localizedDescription, timeoutMs: 30000)
            case 4: .serviceUnavailable(serviceName: "ComprehensiveSecurityService")
            default: .serviceError(code: error.code, reason: error.localizedDescription)
            }
        default:
            .internalError(error.localizedDescription)
        }
    }

    /// Handle the XPC connection invalidation
    public func setupInvalidationHandler() {
        connection.invalidationHandler = {
            // Handle connection invalidation, e.g., by logging or notifying observers
            print("XPC connection invalidated for ComprehensiveSecurityService")
        }
    }

    /// Execute a selector on the XPC connection's remote object
    public func executeXPCSelector<T>(
        _ selector: String,
        withArguments arguments: [Any]
    ) async -> T? {
        let sel = NSSelectorFromString(selector)
        let proxy = connection.remoteObjectProxy as AnyObject

        var result: AnyObject?
        switch arguments.count {
        case 0:
            result = proxy.perform(sel)?.takeUnretainedValue() as AnyObject?
        case 1:
            result = proxy.perform(sel, with: arguments[0])?.takeUnretainedValue() as AnyObject?
        case 2:
            result = proxy.perform(sel, with: arguments[0], with: arguments[1])?
                .takeUnretainedValue() as AnyObject?
        default:
            // For more arguments, we'd need a more complex solution
            return nil
        }

        return result as? T
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
        let bytes = [UInt8](secureBytes)
        return NSData(bytes: bytes, length: bytes.count)
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    @objc
    public func synchroniseKeys(
        _ bytes: [UInt8],
        completionHandler: @escaping (NSError?) -> Void
    ) {
        // Implementation for synchroniseKeys
        // This would typically involve sending the keys to the XPC service for synchronisation
        guard let remoteObject = connection.remoteObjectProxy as? NSObject else {
            let error = NSError(
                domain: "XPCSecurityService",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Service unavailable"]
            )
            completionHandler(error)
            return
        }

        // Convert bytes to NSData
        let data = Data(bytes) as NSData

        // Call the remote method with the appropriate selector
        if remoteObject.responds(to: NSSelectorFromString("synchroniseKeys:completionHandler:")) {
            remoteObject.perform(
                NSSelectorFromString("synchroniseKeys:completionHandler:"),
                with: data,
                with: completionHandler
            )
        } else {
            let error = NSError(
                domain: "XPCSecurityService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Method not available"]
            )
            completionHandler(error)
        }
    }

    /// Ping the service to check availability
    @objc
    public func ping() async -> Bool {
        let proxy = connection.remoteObjectProxy as? NSObject
        return proxy?.responds(to: NSSelectorFromString("ping")) ?? false
    }

    // MARK: - ComprehensiveSecurityServiceProtocol Implementation

    public func getServiceVersion() async -> Result<String, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("getServiceVersion")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                    .takeRetainedValue() as? NSString
                else {
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .serviceUnavailable(serviceName: "ComprehensiveSecurityService")
                        ))
                    return
                }

                continuation.resume(returning: .success(result as String))
            }
        }
    }

    /// Set the service status code
    private func getServiceStatus() async
        -> Result<XPCProtocolTypeDefs.ServiceStatus, UmbraErrors.Security.XPC>
    {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(
                                .serviceUnavailable(serviceName: "Comprehensive Security Service")
                            )
                        )
                    return
                }

                let statusMethod = NSSelectorFromString("getServiceStatusCode")

                guard service.responds(to: statusMethod) else {
                    continuation
                        .resume(returning: .failure(.invalidMessageFormat(reason: "Method not implemented")))
                    return
                }

                typealias GetStatusCallback = @convention(c) (
                    NSObject,
                    Selector,
                    @escaping (NSNumber) -> Void
                ) -> Void
                let getStatus = unsafeBitCast(service.method(for: statusMethod), to: GetStatusCallback.self)

                getStatus(service, statusMethod) { result in
                    // Map the integer value to a valid ServiceStatus case
                    let statusValue = result.intValue

                    // Simple mapping of status codes to ServiceStatus
                    let status: XPCProtocolTypeDefs.ServiceStatus = switch statusValue {
                    case 0:
                        .operational
                    case 1:
                        .degraded
                    case 2:
                        .maintenance
                    case 3:
                        .offline
                    default:
                        .unknown
                    }

                    continuation.resume(returning: .success(status))
                }
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
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidMessageFormat(reason: "Invalid result format")
                        ))
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
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidMessageFormat(reason: "Invalid result format")
                        ))
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
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidMessageFormat(reason: "Invalid result format")
                        ))
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
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidMessageFormat(reason: "Invalid result format")
                        ))
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
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidMessageFormat(reason: "Invalid result format")
                        ))
                }
            }
        }
    }

    // MARK: - KeyManagementServiceProtocol Implementation

    /// Generate a cryptographic key of specified type
    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                // When dealing with multiple parameters for Objective-C methods,
                // we need to use dictionaries or simpler selector signatures
                let paramDict: [String: Any] = [
                    "keyType": keyType.rawValue,
                    "keyIdentifier": keyIdentifier as Any,
                    "metadata": metadata as Any,
                ]

                let selector = NSSelectorFromString("generateKeyWithParams:completionHandler:")

                // Create the completion handler
                let completionHandler: (NSString?, NSError?) -> Void = { keyID, error in
                    if let error {
                        continuation.resume(returning: .failure(.cryptographicError(
                            operation: "generateKey",
                            details: error.localizedDescription
                        )))
                    } else if let keyID = keyID as String? {
                        continuation.resume(returning: .success(keyID))
                    } else {
                        continuation
                            .resume(returning: .failure(.internalError(reason: "Failed to generate key")))
                    }
                }

                // Invoke the method if available
                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: paramDict as NSDictionary,
                        with: completionHandler
                    )
                } else {
                    // Try an alternative method with fewer parameters if available
                    let altSelector = NSSelectorFromString("generateKeyOfType:completion:")
                    if service.responds(to: altSelector) {
                        service.perform(
                            altSelector,
                            with: keyType.rawValue as NSString,
                            with: completionHandler
                        )
                        // Since we can't pass the completion handler, we'll have to poll for results
                        // This is not ideal, but necessary for compatibility
                        continuation
                            .resume(
                                returning: .failure(
                                    .internalError(
                                        reason: "ImportKey implementation requires polling - not supported in this adapter"
                                    )
                                )
                            )
                    } else {
                        continuation.resume(returning: .failure(.operationNotSupported(name: "generateKey")))
                    }
                }
            }
        }
    }

    /// Export a key by its identifier
    public func exportKey(
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                let selector = NSSelectorFromString("exportKey:completionHandler:")
                let completionHandler: (NSData?, NSError?) -> Void = { [self] data, error in
                    if let error {
                        if error.domain.contains("key"), error.code == 1 {
                            continuation.resume(returning: .failure(.keyNotFound(identifier: keyIdentifier)))
                        } else {
                            continuation.resume(returning: .failure(.cryptographicError(
                                operation: "exportKey",
                                details: error.localizedDescription
                            )))
                        }
                    } else if let data {
                        let secureBytes = convertNSDataToSecureBytes(data)
                        continuation.resume(returning: .success(secureBytes))
                    } else {
                        continuation.resume(returning: .failure(.internalError(reason: "Failed to export key")))
                    }
                }

                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: keyIdentifier as NSString,
                        with: completionHandler
                    )
                } else {
                    continuation.resume(returning: .failure(.operationNotSupported(name: "exportKey")))
                }
            }
        }
    }

    /// Import a key with specified type and metadata
    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                // Convert SecureBytes to NSData
                let data = self.convertSecureBytesToNSData(keyData)

                // When dealing with too many parameters, create a dictionary to pass all parameters at once
                let paramDict: [String: Any] = [
                    "data": data,
                    "keyType": keyType.rawValue,
                    "keyIdentifier": keyIdentifier as Any,
                    "metadata": metadata as Any,
                ]

                let selector = NSSelectorFromString("importKeyWithParams:completionHandler:")

                // Create the completion handler
                let completionHandler: (NSString?, NSError?) -> Void = { keyID, error in
                    if let error {
                        continuation.resume(returning: .failure(.cryptographicError(
                            operation: "importKey",
                            details: error.localizedDescription
                        )))
                    } else if let keyID = keyID as String? {
                        continuation.resume(returning: .success(keyID))
                    } else {
                        continuation.resume(returning: .failure(.internalError(reason: "Failed to import key")))
                    }
                }

                // Invoke the method if available
                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: paramDict as NSDictionary,
                        with: completionHandler
                    )
                } else {
                    // Try an alternative method with fewer parameters if available
                    let altSelector = NSSelectorFromString("importKey:withType:completion:")
                    if service.responds(to: altSelector) {
                        service.perform(
                            altSelector,
                            with: data,
                            with: keyType.rawValue as NSString
                        )
                        // Since we can't pass the completion handler, we'll have to poll for results
                        // This is not ideal, but necessary for compatibility
                        continuation
                            .resume(
                                returning: .failure(
                                    .internalError(
                                        reason: "ImportKey implementation requires polling - not supported in this adapter"
                                    )
                                )
                            )
                    } else {
                        continuation.resume(returning: .failure(.operationNotSupported(name: "importKey")))
                    }
                }
            }
        }
    }

    /// Delete a key by its identifier
    public func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                let selector = NSSelectorFromString("deleteKey:completionHandler:")
                let completionHandler: (NSNumber?, NSError?) -> Void = { success, error in
                    if let error {
                        if error.domain.contains("key"), error.code == 1 {
                            continuation.resume(returning: .failure(.keyNotFound(identifier: keyIdentifier)))
                        } else {
                            continuation.resume(returning: .failure(.cryptographicError(
                                operation: "deleteKey",
                                details: error.localizedDescription
                            )))
                        }
                    } else if let success, success.boolValue {
                        continuation.resume(returning: .success(()))
                    } else {
                        continuation.resume(returning: .failure(.internalError(reason: "Failed to delete key")))
                    }
                }

                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: keyIdentifier as NSString,
                        with: completionHandler
                    )
                } else {
                    continuation.resume(returning: .failure(.operationNotSupported(name: "deleteKey")))
                }
            }
        }
    }

    /// List all key identifiers
    public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                let selector = NSSelectorFromString("listKeyIdentifiers:")
                let completionHandler: (NSArray?, NSError?) -> Void = { array, error in
                    if let error {
                        continuation.resume(returning: .failure(.cryptographicError(
                            operation: "listKeyIdentifiers",
                            details: error.localizedDescription
                        )))
                    } else if let array = array as? [String] {
                        continuation.resume(returning: .success(array))
                    } else {
                        continuation
                            .resume(returning: .failure(.internalError(reason: "Failed to list key identifiers")))
                    }
                }

                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: completionHandler
                    )
                } else {
                    continuation
                        .resume(returning: .failure(.operationNotSupported(name: "listKeyIdentifiers")))
                }
            }
        }
    }

    /// Get metadata for a specific key
    public func getKeyMetadata(for keyIdentifier: String) async
        -> Result<[String: String]?, XPCSecurityError>
    {
        await withCheckedContinuation { continuation in
            Task {
                guard let service = connection.remoteObjectProxy as? NSObject else {
                    continuation
                        .resume(
                            returning: .failure(.internalError(reason: "Key Management Service unavailable"))
                        )
                    return
                }

                let selector = NSSelectorFromString("getKeyMetadata:completionHandler:")
                let completionHandler: (NSDictionary?, NSError?) -> Void = { dict, error in
                    if let error {
                        if error.domain.contains("key"), error.code == 1 {
                            continuation.resume(returning: .failure(.keyNotFound(identifier: keyIdentifier)))
                        } else {
                            continuation.resume(returning: .failure(.cryptographicError(
                                operation: "getKeyMetadata",
                                details: error.localizedDescription
                            )))
                        }
                    } else {
                        let metadata = dict as? [String: String]
                        continuation.resume(returning: .success(metadata))
                    }
                }

                if service.responds(to: selector) {
                    service.perform(
                        selector,
                        with: keyIdentifier as NSString,
                        with: completionHandler
                    )
                } else {
                    continuation.resume(returning: .failure(.operationNotSupported(name: "getKeyMetadata")))
                }
            }
        }
    }
}
