import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// For protocol compatibility - bridging between error types
// This allows us to implement protocols that require Protocols error type
// while maintaining XPC error type internally
extension UmbraErrors.Security {
    typealias ProtocolErrorType = UmbraErrors.Security.Protocols
}

/// Constants for XPC service configuration
public enum XPCServiceConstants {
    public static let defaultServiceName = "com.umbra.security.xpcservice"
}

/// XPCServiceAdapter provides a bridge for XPC service communication that requires Foundation
/// types.
///
/// This adapter connects to an XPC service and acts as a bridge to
/// Foundation-independent security protocols. It handles the serialisation/deserialisation
/// needed for XPC communication while maintaining the domain-specific type system.
@objc
public final class XPCServiceAdapter: NSObject, @unchecked Sendable {
    // MARK: - Properties

    public static var protocolIdentifier: String = "com.umbra.security.xpc.bridge"

    public let connection: NSXPCConnection

    // Specialised adapters for each protocol
    private let serviceStandardAdapter: XPCServiceStandardAdapter
    private let secureStorageAdapter: SecureStorageXPCAdapter
    private let cryptoAdapter: CryptoXPCAdapter
    private let keyManagementAdapter: KeyManagementXPCAdapter
    private let comprehensiveSecurityAdapter: ComprehensiveSecurityXPCAdapter

    // MARK: - Initialization

    public init(connection: NSXPCConnection) {
        self.connection = connection

        let interface = NSXPCInterface(with: XPCServiceProtocolBasic.self)
        connection.remoteObjectInterface = interface

        // Start the connection
        connection.resume()

        // Create child adapters
        serviceStandardAdapter = XPCServiceStandardAdapter(connection: connection)
        secureStorageAdapter = SecureStorageXPCAdapter(connection: connection)
        cryptoAdapter = CryptoXPCAdapter(
            connection: connection,
            serviceProxy: connection.remoteObjectProxy as? any ComprehensiveSecurityServiceProtocol
        )
        keyManagementAdapter = KeyManagementXPCAdapter(connection: connection)
        comprehensiveSecurityAdapter = ComprehensiveSecurityXPCAdapter(connection: connection)

        super.init()
        setupInvalidationHandler()
    }

    deinit {
        connection.invalidate()
    }

    /// Sets up the invalidation handler for the XPC connection
    public func setupInvalidationHandler() {
        connection.invalidationHandler = {
            // Log the invalidation
            print("XPC connection to service was invalidated")
            // Optional: Notify observers of service unavailability
        }
    }
}

// MARK: - Helper Methods

// MARK: - XPCServiceProtocolBasic Conformance

extension XPCServiceAdapter: XPCServiceProtocolBasic {
    public func convertNSDataToSecureBytes(_ nsData: NSData) -> UmbraCoreTypes.SecureBytes {
        let bytes = [UInt8](Data(referencing: nsData))
        return SecureBytes(bytes: bytes)
    }

    public func convertSecureBytesToNSData(_ secureBytes: UmbraCoreTypes.SecureBytes) -> NSData {
        let data = Data(Array(secureBytes))
        return data as NSData
    }

    public func convertDataToNSData(_ data: Data) -> NSData {
        data as NSData
    }
}

// MARK: - XPCServiceProtocolStandard Conformance

extension XPCServiceAdapter: XPCServiceProtocolStandard {
    // Forward all methods to serviceStandardAdapter

    @objc
    public func generateRandomData(length: Int) async -> NSObject? {
        await serviceStandardAdapter.generateRandomBytes(length: length)
    }

    @objc
    public func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        await serviceStandardAdapter.encryptData(data, keyIdentifier: keyIdentifier)
    }

    @objc
    public func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
        await serviceStandardAdapter.decryptData(data, keyIdentifier: keyIdentifier)
    }

    @objc
    public func hashData(_ data: NSData) async -> NSObject? {
        await serviceStandardAdapter.hashData(data)
    }

    @objc
    public func signData(_ data: NSData, keyIdentifier: String) async -> NSObject? {
        await serviceStandardAdapter.signData(data, keyIdentifier: keyIdentifier)
    }

    @objc
    public func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier: String
    ) async -> NSNumber? {
        // Convert to NSNumber since we need to return NSNumber?
        await serviceStandardAdapter.verifySignature(
            signature,
            for: data,
            keyIdentifier: keyIdentifier
        ) as NSNumber?
    }

    @objc
    public func ping() async -> Bool {
        await serviceStandardAdapter.ping()
    }

    @objc
    public func synchroniseKeys(_: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // This method doesn't have a matching implementation in serviceStandardAdapter
        // Implementing it with a more appropriate error handling approach
        Task {
            completionHandler(NSError(domain: "com.umbra.security.xpc", code: 501, userInfo: [
                NSLocalizedDescriptionKey: "Operation not supported: synchroniseKeys"
            ]))
        }
    }

    public func listKeys() async -> Result<[String], XPCSecurityError> {
        // Use the keyManagementAdapter implementation to ensure consistent return type
        await keyManagementAdapter.listKeyIdentifiers()
    }

    @objc
    public func getServiceStatus() async -> NSDictionary? {
        await serviceStandardAdapter.getServiceStatus()
    }
}

// MARK: - SecurityProtocolsCore.CryptoServiceProtocol Conformance

extension XPCServiceAdapter: SecurityProtocolsCore.CryptoServiceProtocol {
    // Forward all methods to cryptoAdapter

    public func ping() async -> Result<Bool, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.ping()
    }

    public func encrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.encrypt(data: data, using: key)
    }

    public func decrypt(
        data: SecureBytes,
        using key: SecureBytes
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.decrypt(data: data, using: key)
    }

    public func generateKey() async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.generateKey()
    }

    public func hash(data: SecureBytes) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.hash(data: data)
    }

    public func verify(
        data: SecureBytes,
        against hash: SecureBytes
    ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // Calculate the hash of the provided data
        let hashResult = await cryptoAdapter.hash(data: data)

        // Compare the calculated hash with the provided hash
        switch hashResult {
        case let .success(calculatedHash):
            // Compare the byte arrays
            let sameLength = calculatedHash.count == hash.count
            var allBytesMatch = true

            if sameLength {
                for (idx, element) in calculatedHash.enumerated() {
                    if element != hash[idx] {
                        allBytesMatch = false
                        break
                    }
                }
            } else {
                allBytesMatch = false
            }

            return .success(sameLength && allBytesMatch)

        case let .failure(error):
            return .failure(error)
        }
    }

    public func hashWithConfig(
        data: SecureBytes,
        config _: [String: String]
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Convert the config to a proper configuration
        let result = await cryptoAdapter.hash(data: data)

        // Just return the standard hash result since we don't support custom config
        return result
    }

    public func encryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.encryptSymmetric(data: data, key: key, config: config)
    }

    public func decryptSymmetric(
        data: SecureBytes,
        key: SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.decryptSymmetric(data: data, key: key, config: config)
    }

    public func encryptAsymmetric(
        data: SecureBytes,
        publicKey: SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.encryptAsymmetric(data: data, publicKey: publicKey, config: config)
    }

    public func decryptAsymmetric(
        data: SecureBytes,
        privateKey: SecureBytes,
        config: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        await cryptoAdapter.decryptAsymmetric(data: data, privateKey: privateKey, config: config)
    }

    public func sign(
        data _: SecureBytes,
        privateKey _: SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // For now, return unsupported operation since this needs to be implemented
        .failure(.unsupportedOperation(name: "sign"))
    }

    public func verifySignature(
        signature: SecureBytes,
        data: SecureBytes,
        publicKey: SecureBytes,
        config _: SecurityProtocolsCore.SecurityConfigDTO
    ) async -> Result<Bool, UmbraErrors.Security.Protocols> {
        // Since CryptoXPCAdapter doesn't directly have verifySignature, implement it here
        // This is a simple implementation that could be improved with actual verification logic

        // First verify that we have all the data we need
        if signature.isEmpty || data.isEmpty || publicKey.isEmpty {
            return .failure(.invalidFormat(reason: "Signature, data, or public key is empty"))
        }

        // We could call different adapter methods here or implement the verification directly
        // For now, we'll implement a simple placeholder that assumes valid signatures
        // In a real implementation, you'd use cryptographic functions to verify

        // Convert to NSData for compatibility with XPC
        let signatureData = nsData(from: signature)
        let messageData = nsData(from: data)

        // Call the standard adapter methods for verification
        let result = await serviceStandardAdapter.verifySignature(
            signatureData,
            for: messageData,
            keyIdentifier: UUID().uuidString
        )

        // Return success if the adapter returned a truthy value
        if let boolResult = result as NSNumber?, boolResult.boolValue {
            return .success(true)
        }

        // Otherwise return failure
        return .failure(.internalError("Signature verification failed"))
    }

    public func generateRandomData(length: Int) async
        -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Convert from NSObject to SecureBytes
        let randomDataResult = await serviceStandardAdapter.generateRandomBytes(length: length)
        if let randomData = randomDataResult as? NSData {
            let bytes = [UInt8](Data(referencing: randomData))
            return .success(SecureBytes(bytes: bytes))
        } else {
            return .failure(.internalError("Failed to generate random data"))
        }
    }

    // Required for CryptoServiceProtocol conformance
    public func hash(
        data: SecureBytes,
        config _: SecurityProtocolsCore
            .SecurityConfigDTO
    ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
        // Pass the request to the crypto adapter, ignoring the config for now
        await cryptoAdapter.hash(data: data)
    }
}

// MARK: - SecureStorageServiceProtocol Conformance

extension XPCServiceAdapter: SecureStorageServiceProtocol {
    // Forward all methods to secureStorageAdapter

    @objc
    public func storeData(_ data: NSData, withKey key: String) async -> NSObject? {
        // Convert NSData to SecureBytes and call the adapter
        let secureBytes = secureBytes(from: Data(referencing: data))
        let result = await secureStorageAdapter.storeData(secureBytes, identifier: key, metadata: nil)

        // Return a success/failure indicator
        switch result {
        case .success:
            return NSNumber(value: true)
        case .failure:
            return nil
        }
    }

    @objc
    public func retrieveData(withKey key: String) async -> NSObject? {
        // Call the adapter with the correct parameter name
        let result = await secureStorageAdapter.retrieveData(identifier: key)

        // Convert SecureBytes to NSData if successful
        switch result {
        case let .success(secureBytes):
            return nsData(from: secureBytes)
        case .failure:
            return nil
        }
    }

    @objc
    public func deleteData(withKey key: String) async -> NSObject? {
        // Call the adapter with the correct parameter name
        let result = await secureStorageAdapter.deleteData(identifier: key)

        // Return a success/failure indicator
        switch result {
        case .success:
            return NSNumber(value: true)
        case .failure:
            return nil
        }
    }

    // Protocol conformance methods

    public func storeData(
        _ data: SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, XPCSecurityError> {
        // Convert SecureBytes to NSData
        _ = nsData(from: data)

        // Call the standard adapter store method
        let result = await secureStorageAdapter.storeData(
            data,
            identifier: identifier,
            metadata: metadata
        )

        return result
    }

    public func retrieveData(identifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        let result = await secureStorageAdapter.retrieveData(identifier: identifier)

        return result
    }

    public func deleteData(identifier: String) async -> Result<Void, XPCSecurityError> {
        let result = await secureStorageAdapter.deleteData(identifier: identifier)

        return result
    }

    public func listStoredItems() async -> Result<[String], XPCSecurityError> {
        // Since the adapter may not implement this method directly, we may need to use a different
        // approach
        // For now, return a reasonable error
        .failure(.operationNotSupported(name: "listStoredItems"))
    }

    public func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
        // Reuse the implementation of listStoredItems
        await listStoredItems()
    }

    public func getDataMetadata(for _: String) async -> Result<[String: String]?, XPCSecurityError> {
        // If there's no specific metadata implementation, return empty metadata
        .success([:])
    }
}

// MARK: - KeyManagementServiceProtocol Conformance

extension XPCServiceAdapter: KeyManagementServiceProtocol {
    // Forward all methods to keyManagementAdapter

    public func generateKey(
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // Call the key management adapter to generate the key
        await keyManagementAdapter.generateKey(
            keyType: keyType,
            keyIdentifier: keyIdentifier,
            metadata: metadata
        )
    }

    public func importKey(
        keyData: SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        // Call the key management adapter to import the key
        await keyManagementAdapter.importKey(
            keyData: keyData,
            keyType: keyType,
            keyIdentifier: keyIdentifier,
            metadata: metadata
        )
    }

    public func exportKey(keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityError> {
        // Call the key management adapter to export the key
        await keyManagementAdapter.exportKey(keyIdentifier: keyIdentifier)
    }

    public func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
        await keyManagementAdapter.deleteKey(keyIdentifier: keyIdentifier)
    }

    public func listKeyIdentifiers() async -> Result<[String], XPCSecurityError> {
        await keyManagementAdapter.listKeyIdentifiers()
    }

    public func getKeyMetadata(for keyIdentifier: String) async
        -> Result<[String: String]?, XPCSecurityError> {
        // If there's no specific metadata implementation, return from the adapter
        await keyManagementAdapter.getKeyMetadata(for: keyIdentifier)
    }
}

// MARK: - ComprehensiveSecurityServiceProtocol Conformance

extension XPCServiceAdapter: ComprehensiveSecurityServiceProtocol {
    // Protocol conformance implementations - changed to match the required types

    public func getServiceVersion() async -> String {
        // Return a simple version string directly
        "1.0.0"
    }

    public func isFeatureSupported(featureIdentifier: String) async -> Bool {
        // For now, just report basic features as supported
        let supportedFeatures = ["encryption", "decryption", "hashing", "verification"]
        return supportedFeatures.contains(featureIdentifier.lowercased())
    }

    public func encryptData(
        data: Data,
        key: Data
    ) async -> Result<Data, XPCSecurityError> {
        // Convert the result from UmbraErrors.Security.XPC to XPCSecurityError
        let result = await comprehensiveSecurityAdapter.encryptData(data: data, key: key)

        switch result {
        case let .success(encryptedData):
            return .success(encryptedData)
        case let .failure(error):
            // Map error to XPCSecurityError
            return .failure(XPCSecurityError.internalError(reason: "Encryption failed: \(error)"))
        }
    }

    public func decryptData(
        data: Data,
        key: Data
    ) async -> Result<Data, XPCSecurityError> {
        // Convert the result from UmbraErrors.Security.XPC to XPCSecurityError
        let result = await comprehensiveSecurityAdapter.decryptData(data: data, key: key)

        switch result {
        case let .success(decryptedData):
            return .success(decryptedData)
        case let .failure(error):
            // Map error to XPCSecurityError
            return .failure(XPCSecurityError.internalError(reason: "Decryption failed: \(error)"))
        }
    }

    public func hashData(data: Data) async -> Result<Data, XPCSecurityError> {
        // Convert the result from UmbraErrors.Security.XPC to XPCSecurityError
        let result = await comprehensiveSecurityAdapter.hashData(data: data)

        switch result {
        case let .success(hashedData):
            return .success(hashedData)
        case let .failure(error):
            // Map error to XPCSecurityError
            return .failure(XPCSecurityError.internalError(reason: "Hashing failed: \(error)"))
        }
    }

    public func verify(
        data: Data,
        signature: Data
    ) async -> Result<Bool, XPCSecurityError> {
        // Convert the result from UmbraErrors.Security.XPC to XPCSecurityError
        let result = await comprehensiveSecurityAdapter.verify(data: data, signature: signature)

        switch result {
        case let .success(verified):
            return .success(verified)
        case let .failure(error):
            // Map error to XPCSecurityError
            return .failure(XPCSecurityError.internalError(reason: "Verification failed: \(error)"))
        }
    }

    public func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        // Convert the result from UmbraErrors.Security.XPC to XPCSecurityError
        let result = await comprehensiveSecurityAdapter.generateKey()

        switch result {
        case let .success(key):
            return .success(key)
        case let .failure(error):
            // Map error to XPCSecurityError
            return .failure(XPCSecurityError.internalError(reason: "Key generation failed: \(error)"))
        }
    }
}

// MARK: - Helper Functions for Security Operations

extension XPCServiceAdapter {
    /// Maps NSError to XPCSecurityError
    private func mapNSErrorToSecurityError(_ error: NSError) -> XPCSecurityError {
        // Check for standard error domains
        if error.domain == NSURLErrorDomain {
            .invalidInput(details: "Network error: \(error.localizedDescription)")
        } else if error.domain.contains("security") {
            .internalError(reason: "Security error: \(error.localizedDescription)")
        } else {
            .internalError(reason: error.localizedDescription)
        }
    }

    /// Process result from NSObject to Result<T, XPCSecurityError>
    private func processXPCResult<T>(
        _ result: NSObject?,
        transform: (NSObject) -> T
    ) -> Result<T, XPCSecurityError> {
        if let error = result as? NSError {
            .failure(mapNSErrorToSecurityError(error))
        } else if let nsData = result as? NSData {
            .success(transform(nsData))
        } else if let nsObject = result {
            .success(transform(nsObject))
        } else {
            .failure(.internalError(reason: "Invalid result from XPC service"))
        }
    }
}

extension XPCServiceAdapter {
    // Helper method to convert Data to SecureBytes
    private func secureBytes(from data: Data) -> SecureBytes {
        let bytes = [UInt8](data)
        return SecureBytes(bytes: bytes)
    }

    // Helper method to convert SecureBytes to NSData
    private func nsData(from secureBytes: SecureBytes) -> NSData {
        let count = secureBytes.count
        var byteArray = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            byteArray[i] = secureBytes[i]
        }
        let data = Data(byteArray)
        return data as NSData
    }

    /// Helper to compare two SecureBytes instances for equality
    private func compareSecureBytes(_ left: SecureBytes, _ right: SecureBytes) -> Bool {
        let leftBytes = Array(left)
        let rightBytes = Array(right)

        guard leftBytes.count == rightBytes.count else {
            return false
        }

        for i in 0 ..< leftBytes.count {
            if leftBytes[i] != rightBytes[i] {
                return false
            }
        }

        return true
    }
}

// MARK: - BaseXPCAdapter Conformance

extension XPCServiceAdapter: BaseXPCAdapter {
    // Use default implementations from BaseXPCAdapter extension
}
