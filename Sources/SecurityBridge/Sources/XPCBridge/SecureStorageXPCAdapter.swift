import CoreErrors
import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// SecureStorageXPCAdapter provides an implementation of SecureStorageServiceProtocol
/// using XPC for communication with the security service.
///
/// This adapter handles secure storage operations by delegating to an XPC service,
/// while managing the type conversions between Foundation types and SecureBytes.
public final class SecureStorageXPCAdapter: NSObject, BaseXPCAdapter, @unchecked Sendable {
    // MARK: - Properties

    /// The NSXPCConnection used to communicate with the XPC service
    public let connection: NSXPCConnection

    /// The proxy for making XPC calls
    private let serviceProxy: any SecureStorageServiceProtocol

    // MARK: - Initialisation

    /// Initialise with an XPC connection and service interface protocol type
    ///
    /// - Parameter connection: The NSXPCConnection to use for communicating with the XPC service
    public init(connection: NSXPCConnection) {
        self.connection = connection
        let protocolObj = SecureStorageServiceProtocol.self as Any as! Protocol
        connection.remoteObjectInterface = NSXPCInterface(with: protocolObj)

        // Set the exported interface
        let exportedProtocolObj = XPCServiceProtocolBasic.self as Any as! Protocol
        let exportedInterface = NSXPCInterface(with: exportedProtocolObj)
        connection.exportedInterface = exportedInterface

        // Resume the connection
        connection.resume()

        // Get the remote object proxy
        serviceProxy = connection.remoteObjectProxy as! any SecureStorageServiceProtocol

        super.init()

        // Set up invalidation handler
        setupInvalidationHandler()
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
        let bytes = Array(secureBytes)
        return NSData(bytes: bytes, length: bytes.count)
    }

    /// Convert NSData to SecureBytes
    public func convertToSecureBytes(_ data: NSData) -> SecureBytes {
        convertNSDataToSecureBytes(data)
    }

    /// Check if the service is available
    public func isServiceAvailable() async -> Bool {
        let result = await listDataIdentifiers()
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    // MARK: - Invalidation Handling

    /// Handler called when the XPC connection is invalidated
    public var invalidationHandler: (() -> Void)?

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
            continuation
                .resume(returning: .failure(
                    UmbraErrors.Security.XPC
                        .invalidMessageFormat(reason: "Unexpected result format")
                ))
        }
    }

    /// Map security errors to UmbraErrors
    public func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.XPC {
        // Check for known error domains and codes
        if error.domain == NSURLErrorDomain {
            return .connectionFailed(reason: error.localizedDescription)
        } else if error.domain == "SecureStorageErrorDomain" {
            // Map specific storage error codes to appropriate UmbraErrors
            switch error.code {
            case 1001:
                return .insufficientPrivileges(service: "SecureStorage", requiredPrivilege: "read")
            case 1002:
                return .serviceError(
                    code: error.code,
                    reason: error.userInfo["identifier"] as? String ?? "unknown"
                )
            case 1003:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            case 1004:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            case 1005:
                return .serviceError(code: error.code, reason: error.localizedDescription)
            default:
                return .internalError(error.localizedDescription)
            }
        }

        // Default error mapping
        return .internalError(error.localizedDescription)
    }

    /// Setup invalidation handler for the XPC connection
    public func setupInvalidationHandler() {
        connection.invalidationHandler = { [weak self] in
            guard let self else { return }

            // Log the invalidation
            print("XPC connection invalidated for SecureStorageXPCAdapter")

            // Call the custom invalidation handler if set
            invalidationHandler?()
        }
    }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension SecureStorageXPCAdapter: SecureStorageServiceProtocol {
    public func storeData(
        _ data: UmbraCoreTypes.SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, XPCSecurityError> {
        // First check if service is available
        let serviceAvailable = await isServiceAvailable()
        if !serviceAvailable {
            return .failure(.serviceUnavailable)
        }

        return await withCheckedContinuation { continuation in
            Task {
                let nsData = convertSecureBytesToNSData(data)
                let result = await serviceProxy.storeData(
                    convertToSecureBytes(nsData),
                    identifier: identifier,
                    metadata: metadata
                )
                continuation.resume(returning: result)
            }
        }
    }

    public func retrieveData(identifier: String) async
        -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError>
    {
        // First check if service is available
        let serviceAvailable = await isServiceAvailable()
        if !serviceAvailable {
            return .failure(.serviceUnavailable)
        }

        return await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy.retrieveData(identifier: identifier)
                switch result {
                case let .success(data):
                    continuation.resume(returning: .success(data))
                case let .failure(error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }

    public func deleteData(identifier: String) async -> Result<Void, XPCSecurityError> {
        // First check if service is available
        let serviceAvailable = await isServiceAvailable()
        if !serviceAvailable {
            return .failure(.serviceUnavailable)
        }

        return await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy.deleteData(identifier: identifier)
                continuation.resume(returning: result)
            }
        }
    }

    public func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
        await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy.listDataIdentifiers()
                continuation.resume(returning: result)
            }
        }
    }

    public func getDataMetadata(for identifier: String) async
        -> Result<[String: String]?, XPCSecurityError>
    {
        // First check if service is available
        let serviceAvailable = await isServiceAvailable()
        if !serviceAvailable {
            return .failure(.serviceUnavailable)
        }

        return await withCheckedContinuation { continuation in
            Task {
                let result = await serviceProxy.getDataMetadata(for: identifier)
                continuation.resume(returning: result)
            }
        }
    }
}
