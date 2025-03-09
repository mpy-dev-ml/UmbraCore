import Foundation
import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import XPCProtocolsCore

/// SecureStorageXPCAdapter provides an implementation of SecureStorageServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles secure storage operations by delegating to an XPC service,
/// while managing the type conversions between Foundation types and SecureBytes.
public final class SecureStorageXPCAdapter: NSObject, BaseXPCAdapter {
    // MARK: - Properties
    
    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection
    
    // MARK: - Initialisation
    
    /// Initialise with an NSXPCConnection
    /// - Parameter connection: The connection to the XPC service
    public init(connection: NSXPCConnection) {
        self.connection = connection
        super.init()
    }
    
    // MARK: - Helpers
    
    /// Handle a continuation with a standard success/failure pattern
    private func handleContinuation<T>(
        _ continuation: CheckedContinuation<Result<T, UmbraErrors.Security.XPC>, Never>,
        result: NSObject?,
        transform: (NSData) -> T
    ) {
        if let error = result as? NSError {
            continuation.resume(returning: .failure(mapSecurityError(error)))
        } else if let nsData = result as? NSData {
            continuation.resume(returning: .success(transform(nsData)))
        } else if result is NSNull {
            // Some operations return NSNull for success with no data
            // We need to handle this case for operations like delete
            // This is a placeholder that needs to be updated based on the actual type T
            fatalError("Unable to convert NSNull to required return type")
        } else {
            continuation.resume(returning: .failure(UmbraErrors.Security.XPC.invalidFormat(reason: "Unexpected result format")))
        }
    }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension SecureStorageXPCAdapter: SecureStorageServiceProtocol {
    @objc
    public func storeData(_ data: NSData, withKey key: String) async -> NSObject? {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("storeData:withKey:")
                let secureData = convertSecureBytesToNSData(self.secureBytes(from: data as Data))
                _ = (connection.remoteObjectProxy as AnyObject).perform(selector, with: secureData, with: key)
                
                continuation.resume(returning: NSNumber(value: true))
            }
        }
    }
    
    @objc
    public func retrieveData(withKey key: String) async -> NSObject? {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("retrieveDataWithKey:")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(selector, with: key)?
                        .takeRetainedValue() as? NSData
                else {
                    continuation.resume(returning: NSError(
                        domain: "com.umbra.security.xpc",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]
                    ))
                    return
                }
                
                continuation.resume(returning: result)
            }
        }
    }
    
    @objc
    public func deleteData(withKey key: String) async -> NSObject? {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("deleteDataWithKey:")
                _ = (connection.remoteObjectProxy as AnyObject).perform(selector, with: key)
                
                continuation.resume(returning: NSNumber(value: true))
            }
        }
    }
    
    // Swift protocol method implementations
    
    public func storeSecurely(
        _ data: SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let nsData = convertSecureBytesToNSData(data)
                
                let selector = NSSelectorFromString("storeData:withKey:metadata:")
                (connection.remoteObjectProxy as AnyObject).perform(
                    selector,
                    with: nsData,
                    with: identifier,
                    with: metadata as NSObject?
                )
                
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    public func retrieveSecurely(identifier: String) async -> Result<SecureBytes, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("retrieveDataWithKey:")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(
                        selector,
                        with: identifier
                    )?.takeRetainedValue() as? NSData
                else {
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidFormat(reason: "Invalid data")
                        ))
                    return
                }
                
                let secureBytes = convertNSDataToSecureBytes(result)
                continuation.resume(returning: .success(secureBytes))
            }
        }
    }
    
    public func deleteSecurely(identifier: String) async -> Result<Void, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("deleteDataWithKey:")
                _ = (connection.remoteObjectProxy as AnyObject).perform(selector, with: identifier)
                
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    public func listIdentifiers() async -> Result<[String], UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("listIdentifiers")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(selector)?
                        .takeRetainedValue() as? NSArray
                else {
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidFormat(reason: "Invalid data")
                        ))
                    return
                }
                
                let identifiers = result.compactMap { $0 as? String }
                continuation.resume(returning: .success(identifiers))
            }
        }
    }
    
    public func getMetadata(
        for identifier: String
    ) async -> Result<[String: String]?, UmbraErrors.Security.XPC> {
        await withCheckedContinuation { continuation in
            Task {
                let selector = NSSelectorFromString("getMetadataForIdentifier:")
                guard
                    let result = (connection.remoteObjectProxy as AnyObject).perform(
                        selector,
                        with: identifier
                    )?.takeRetainedValue()
                else {
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidFormat(reason: "Invalid metadata format")
                        ))
                    return
                }
                
                if result is NSNull {
                    // No metadata exists
                    continuation.resume(returning: .success(nil))
                    return
                }
                
                guard let dictResult = result as? NSDictionary else {
                    continuation
                        .resume(returning: .failure(
                            UmbraErrors.Security.XPC
                                .invalidFormat(reason: "Invalid metadata dictionary format")
                        ))
                    return
                }
                
                var metadata: [String: String] = [:]
                for (key, value) in dictResult {
                    if let keyString = key as? String,
                       let valueString = value as? String {
                        metadata[keyString] = valueString
                    }
                }
                
                continuation.resume(returning: .success(metadata))
            }
        }
    }
}
