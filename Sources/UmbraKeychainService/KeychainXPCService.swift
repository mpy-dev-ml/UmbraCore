import CoreErrors
import Foundation
import UmbraCoreTypes
import UmbraLogging
import XPCProtocolsCore

/// XPC service for secure keychain operations
@objc
public protocol KeychainXPCProtocol {
    /// Add a new item to the keychain
    func addItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data,
        reply: @escaping @Sendable (Error?) -> Void
    )

    /// Update an existing item in the keychain
    func updateItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data,
        reply: @escaping @Sendable (Error?) -> Void
    )

    /// Remove an item from the keychain
    func removeItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Error?) -> Void
    )

    /// Check if an item exists in the keychain
    func containsItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Bool, Error?) -> Void
    )

    /// Retrieve an item from the keychain
    func retrieveItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Data?, Error?) -> Void
    )
}

extension KeychainXPCProtocol {
    func addItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            addItem(
                account: account,
                service: service,
                accessGroup: accessGroup,
                data: data
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func updateItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            updateItem(
                account: account,
                service: service,
                accessGroup: accessGroup,
                data: data
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func removeItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            removeItem(
                account: account,
                service: service,
                accessGroup: accessGroup
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func containsItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            containsItem(
                account: account,
                service: service,
                accessGroup: accessGroup
            ) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    func retrieveItem(
        account: String,
        service: String,
        accessGroup: String?
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            retrieveItem(
                account: account,
                service: service,
                accessGroup: accessGroup
            ) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: KeychainError.itemNotFound)
                }
            }
        }
    }
}

/// An error that can occur during keychain operations
public enum KeychainError: Error, LocalizedError {
    case duplicateItem
    case itemNotFound
    case authenticationFailed
    case unhandledError(status: OSStatus)
    case other(String)

    public var errorDescription: String? {
        switch self {
        case .duplicateItem:
            "A duplicate item was found"
        case .itemNotFound:
            "The item could not be found"
        case .authenticationFailed:
            "Authentication failed"
        case let .unhandledError(status):
            "Unhandled error with status: \(status)"
        case let .other(message):
            message
        }
    }
}

@available(macOS 14.0, *)
final class KeychainXPCService: NSObject, XPCServiceProtocolStandard, KeychainXPCProtocol {
    // MARK: - Properties

    /// Static protocol identifier for the service
    public static var protocolIdentifier: String {
        "com.umbracore.xpc.keychain"
    }

    private(set) var listener: NSXPCListener
    private let exportedObject: KeychainXPCProtocol
    private let startupSemaphore = DispatchSemaphore(value: 0)

    private let stateQueue = DispatchQueue(label: "com.umbracore.xpc.state")
    private var _isStarted = false

    private var isStarted: Bool {
        get { stateQueue.sync { _isStarted } }
        set { stateQueue.sync { _isStarted = newValue } }
    }

    // MARK: - Initialization

    override init() {
        listener = NSXPCListener.anonymous()
        exportedObject = KeychainXPCImplementation()
        super.init()
        listener.delegate = self
    }

    // MARK: - Service Lifecycle Methods

    func start() {
        guard !isStarted else { return }
        isStarted = true
        listener.resume()
        startupSemaphore.signal()
    }

    func stop() {
        guard isStarted else { return }
        isStarted = false
        listener.invalidate()
    }

    func waitForStartup(timeout: TimeInterval) -> Bool {
        startupSemaphore.wait(timeout: .now() + timeout) == .success
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    /// Basic ping method to test if service is responsive
    /// - Returns: True if service is available
    @objc
    public func ping() async -> Bool {
        isStarted
    }

    /// Synchronize keys between XPC service and client
    /// - Parameter syncData: Secure bytes for key synchronization
    /// - Throws: XPCSecurityError if synchronization fails
    public func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // In a keychain service, we don't need key synchronization
        // This is a placeholder implementation for protocol conformance
        if syncData.isEmpty {
            throw XPCSecurityError.invalidInput(details: "Empty synchronization data")
        }
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    /// Generate random data of specified length
    /// - Parameter length: Length in bytes of random data to generate
    /// - Returns: Result with SecureBytes on success or error on failure
    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)

        guard status == errSecSuccess else {
            return .failure(.cryptographicError(
                operation: "random-generation",
                details: "Failed to generate random data with status: \(status)"
            ))
        }

        return .success(SecureBytes(bytes: bytes))
    }

    /// Reset the security state of the service
    /// - Returns: Result with void on success or error on failure
    public func resetSecurity() async -> Result<Void, XPCSecurityError> {
        // For a keychain service, resetting would mean clearing keychain items
        // This is a simplified version for demonstration
        .success(())
    }

    /// Get the service version
    /// - Returns: Result with version string on success or error on failure
    public func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0")
    }

    /// Get the hardware identifier
    /// - Returns: Result with identifier string on success or error on failure
    public func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        .success("keychain-xpc-service-hardware-id")
    }

    /// Store secure data by key
    /// - Parameters:
    ///   - key: The key to store the data under
    ///   - data: The secure data to store
    /// - Returns: Result with success or error
    public func storeSecureData(key: String, data: SecureBytes) async -> Result<Void, XPCSecurityError> {
        do {
            // Use the account as the key and a fixed service identifier
            try await exportedObject.addItem(
                account: key,
                service: "com.umbracore.securexpc",
                accessGroup: nil,
                data: Data(data.bytes)
            )
            return .success(())
        } catch let error as KeychainError {
            return .failure(mapKeychainErrorToXPCSecurityError(error, operation: "store"))
        } catch {
            return .failure(.secureStorageError(
                operation: "store",
                details: error.localizedDescription
            ))
        }
    }

    /// Retrieve secure data by key
    /// - Parameter key: The key to retrieve data for
    /// - Returns: Result with the secure data or error
    public func retrieveSecureData(key: String) async -> Result<SecureBytes, XPCSecurityError> {
        do {
            let data = try await exportedObject.retrieveItem(
                account: key,
                service: "com.umbracore.securexpc",
                accessGroup: nil
            )
            return .success(SecureBytes(bytes: [UInt8](data)))
        } catch let error as KeychainError {
            return .failure(mapKeychainErrorToXPCSecurityError(error, operation: "retrieve"))
        } catch {
            return .failure(.secureStorageError(
                operation: "retrieve",
                details: error.localizedDescription
            ))
        }
    }

    /// Delete secure data by key
    /// - Parameter key: The key to delete data for
    /// - Returns: Result with success or error
    public func deleteSecureData(key: String) async -> Result<Void, XPCSecurityError> {
        do {
            try await exportedObject.removeItem(
                account: key,
                service: "com.umbracore.securexpc",
                accessGroup: nil
            )
            return .success(())
        } catch let error as KeychainError {
            if case .itemNotFound = error {
                // It's not an error if the item was already removed
                return .success(())
            }
            return .failure(mapKeychainErrorToXPCSecurityError(error, operation: "delete"))
        } catch {
            return .failure(.secureStorageError(
                operation: "delete",
                details: error.localizedDescription
            ))
        }
    }

    /// The service status returns a dictionary with information about the service's status
    /// - Returns: Result with status dictionary or error
    public func status() async -> Result<[String: Any], XPCSecurityError> {
        let statusInfo: [String: Any] = [
            "available": isStarted,
            "version": "1.0.0",
            "protocol": Self.protocolIdentifier
        ]
        return .success(statusInfo)
    }

    // MARK: - KeychainXPCProtocol Delegation

    /// Add a new item to the keychain
    public func addItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data,
        reply: @escaping @Sendable (Error?) -> Void
    ) {
        exportedObject.addItem(
            account: account,
            service: service,
            accessGroup: accessGroup,
            data: data,
            reply: reply
        )
    }

    /// Update an existing item in the keychain
    public func updateItem(
        account: String,
        service: String,
        accessGroup: String?,
        data: Data,
        reply: @escaping @Sendable (Error?) -> Void
    ) {
        exportedObject.updateItem(
            account: account,
            service: service,
            accessGroup: accessGroup,
            data: data,
            reply: reply
        )
    }

    /// Remove an item from the keychain
    public func removeItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Error?) -> Void
    ) {
        exportedObject.removeItem(
            account: account,
            service: service,
            accessGroup: accessGroup,
            reply: reply
        )
    }

    /// Check if an item exists in the keychain
    public func containsItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Bool, Error?) -> Void
    ) {
        exportedObject.containsItem(
            account: account,
            service: service,
            accessGroup: accessGroup,
            reply: reply
        )
    }

    /// Retrieve an item from the keychain
    public func retrieveItem(
        account: String,
        service: String,
        accessGroup: String?,
        reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
        exportedObject.retrieveItem(
            account: account,
            service: service,
            accessGroup: accessGroup,
            reply: reply
        )
    }

    // MARK: - Helper Methods

    /// Maps keychain errors to XPC security errors
    /// - Parameters:
    ///   - error: The keychain error
    ///   - operation: The operation that failed
    /// - Returns: The corresponding XPC security error
    private func mapKeychainErrorToXPCSecurityError(_ error: KeychainError, operation: String) -> XPCSecurityError {
        switch error {
        case .duplicateItem:
            .secureStorageError(operation: operation, details: "Duplicate item exists")
        case .itemNotFound:
            .itemNotFound(itemType: "keychain", identifier: operation)
        case .authenticationFailed:
            .authenticationFailed(reason: "Keychain authentication failed")
        case let .unhandledError(status):
            .secureStorageError(operation: operation, details: "Unhandled error with status: \(status)")
        case let .other(message):
            .secureStorageError(operation: operation, details: message)
        }
    }

    // MARK: - Default Implementations for XPCServiceProtocolStandard

    /// Encrypt data using the service's encryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to encrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with encrypted SecureBytes on success or error on failure
    public func encryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Keychain service doesn't provide encryption
        .failure(.notImplemented(reason: "Encryption not implemented in KeychainXPCService"))
    }

    /// Decrypt data using the service's decryption mechanism
    /// - Parameters:
    ///   - data: SecureBytes to decrypt
    ///   - keyIdentifier: Optional identifier for the key to use
    /// - Returns: Result with decrypted SecureBytes on success or error on failure
    public func decryptSecureData(_: SecureBytes, keyIdentifier _: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Keychain service doesn't provide decryption
        .failure(.notImplemented(reason: "Decryption not implemented in KeychainXPCService"))
    }

    /// Sign data using the service's signing mechanism
    /// - Parameters:
    ///   - data: SecureBytes to sign
    ///   - keyIdentifier: Identifier for the signing key
    /// - Returns: Result with signature as SecureBytes on success or error on failure
    public func sign(_: SecureBytes, keyIdentifier _: String) async -> Result<SecureBytes, XPCSecurityError> {
        // Keychain service doesn't provide signing
        .failure(.notImplemented(reason: "Signing not implemented in KeychainXPCService"))
    }

    /// Verify signature for data
    /// - Parameters:
    ///   - signature: SecureBytes containing the signature
    ///   - data: SecureBytes containing the data to verify
    ///   - keyIdentifier: Identifier for the verification key
    /// - Returns: Result with boolean indicating verification result or error on failure
    public func verify(signature _: SecureBytes, for _: SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        // Keychain service doesn't provide signature verification
        .failure(.notImplemented(reason: "Signature verification not implemented in KeychainXPCService"))
    }
}

extension KeychainXPCService: NSXPCListenerDelegate {
    func listener(
        _: NSXPCListener,
        shouldAcceptNewConnection newConnection: NSXPCConnection
    ) -> Bool {
        // This is called on the main thread by XPC
        guard isStarted else { return false }

        newConnection.exportedInterface = NSXPCInterface(with: KeychainXPCProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()

        return true
    }
}

private final class AtomicBool {
    private var _value: Bool
    private let lock = NSLock()

    init(_ value: Bool) {
        _value = value
    }

    var value: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func setValue(_ newValue: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _value = newValue
    }
}
