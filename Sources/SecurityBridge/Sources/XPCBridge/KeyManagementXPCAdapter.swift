// DEPRECATED: KeyManagementXPCAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import CoreErrors
import ErrorHandlingDomains
import Foundation
import ObjectiveC
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// KeyManagementXPCAdapter provides an implementation of KeyManagementServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles key management operations by delegating to an XPC service,
/// providing a unified API for key-related operations.
@objc
public final class KeyManagementXPCAdapter: NSObject, KeyManagementServiceProtocol,
    BaseXPCAdapter, @unchecked Sendable {
    // MARK: - Properties

    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection

    // MARK: - Initialisation

    /// Initialise with an XPC connection and service interface protocol type
    ///
    /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
    public init(connection: NSXPCConnection) {
        self.connection = connection

        // Set up the XPC interface - use the KeyManagementServiceProtocol
        let protocolObj = KeyManagementServiceProtocol.self as Any as! Protocol
        connection.remoteObjectInterface = NSXPCInterface(with: protocolObj)

        // Set the exported interface
        let exportedProtocolObj = XPCServiceProtocolBasic.self as Any as! Protocol
        connection.exportedInterface = NSXPCInterface(with: exportedProtocolObj)

        // Resume the connection
        connection.resume()

        super.init()
        setupInvalidationHandler()
    }

    /// Set up an invalidation handler for the XPC connection
    public func setupInvalidationHandler() {
        connection.invalidationHandler = {
            // Handle connection invalidation
            print("XPC connection to KeyManagementService was invalidated")
            // Optional: Take recovery action or notify observers
        }
    }

    /// Convert NSData to SecureBytes
    public func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let bytes = [UInt8](Data(referencing: data))
        return SecureBytes(bytes: bytes)
    }

    /// Convert SecureBytes to NSData
    public func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        let bytes = Array(secureBytes)
        return NSData(bytes: bytes, length: bytes.count)
    }

    /// Execute an XPC selector with arguments
    public func executeXPCSelector<T>(
        _ selector: String,
        withArguments arguments: [Any] = []
    ) async -> T? {
        await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? NSObject else {
                continuation.resume(returning: nil)
                return
            }

            // Check if the selector is supported
            let sel = NSSelectorFromString(selector)
            guard proxy.responds(to: sel) else {
                continuation.resume(returning: nil)
                return
            }

            // Perform the selector with the provided arguments
            let result = proxy.perform(sel, with: arguments)
            continuation.resume(returning: result?.takeUnretainedValue() as? T)
        }
    }

    /// Check if the XPC service is available
    private func isServiceAvailable() async -> Bool {
        // Check if the connection is valid
        guard let proxy = connection.remoteObjectProxy as? NSObject else {
            return false
        }

        // Check if the service responds to a basic method
        let selector = NSSelectorFromString("listKeyIdentifiers")
        return proxy.responds(to: selector)
    }

    // MARK: - KeyManagementServiceProtocol Implementation

    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the generateKey method asynchronously
            Task {
                let result = await proxy.generateKey(
                    keyType: keyType,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                continuation.resume(returning: result)
            }
        }
    }

    public func exportKey(
        keyIdentifier: String
    ) async -> Result<SecureBytes, XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the exportKey method asynchronously
            Task {
                let result = await proxy.exportKey(keyIdentifier: keyIdentifier)
                continuation.resume(returning: result)
            }
        }
    }

    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the importKey method asynchronously
            Task {
                let result = await proxy.importKey(
                    keyData: keyData,
                    keyType: keyType,
                    keyIdentifier: keyIdentifier,
                    metadata: metadata
                )
                continuation.resume(returning: result)
            }
        }
    }

    public func deleteKey(
        keyIdentifier: String
    ) async -> Result<Void, XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the deleteKey method asynchronously
            Task {
                let result = await proxy.deleteKey(keyIdentifier: keyIdentifier)
                continuation.resume(returning: result)
            }
        }
    }

    public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the listKeyIdentifiers method asynchronously
            Task {
                let result = await proxy.listKeyIdentifiers()
                continuation.resume(returning: result)
            }
        }
    }

    public func getKeyMetadata(
        for keyIdentifier: String
    ) async -> Result<[String: String]?, XPCSecurityError> {
        // First check if the service is available
        guard await isServiceAvailable() else {
            return .failure(.serviceUnavailable)
        }

        // Create a completion handler wrapper
        return await withCheckedContinuation { continuation in
            // Get the proxy object
            guard let proxy = connection.remoteObjectProxy as? KeyManagementServiceProtocol else {
                continuation.resume(returning: .failure(.serviceUnavailable))
                return
            }

            // Call the getKeyMetadata method asynchronously
            Task {
                let result = await proxy.getKeyMetadata(for: keyIdentifier)
                continuation.resume(returning: result)
            }
        }
    }
}
