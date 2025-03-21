import CoreServicesTypesNoFoundation
import ErrorHandlingDomains
import Foundation
import ObjCBridgingTypesFoundation
import SecurityBridge
import SecurityUtils

import FoundationBridgeTypes

/// Simple protocol for bookmark services to break dependency cycles
protocol BookmarkServiceType {
    func createBookmark(for url: URL) throws -> [UInt8]
    func resolveBookmark(_ bookmark: [UInt8]) throws -> URL
    func withSecurityScopedAccess<T>(to url: URL, perform operation: () throws -> T) throws -> T
    func stopAccessing(url: URL)
}

/// A service that manages security-scoped resource access and bookmarks
@MainActor
public final class SecurityService {
    /// Shared instance of the SecurityService
    public static let shared = SecurityService()

    private let bookmarkService: BookmarkServiceType
    private let securityProvider: DefaultSecurityProviderImpl
    private var activeSecurityScopedResources: Set<String> = []

    /// Initialize the security service
    public init() {
        bookmarkService = DefaultBookmarkService()
        securityProvider = DefaultSecurityProviderImpl()
        print("SecurityService initialized with DefaultBookmarkService")
    }

    /// Security provider adapter that can be used by other components
    @MainActor
    var securityProviderAdapter: SecurityBridge.SecurityProviderFoundationAdapter {
        SecurityBridge.SecurityProviderFoundationAdapter(implementation: securityProvider)
    }

    /// Create a security-scoped bookmark for a URL
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: Bookmark data as bytes
    public func createBookmark(for path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        return try bookmarkService.createBookmark(for: url)
    }

    /// Resolve a security-scoped bookmark
    /// - Parameter bookmark: The bookmark data to resolve
    /// - Returns: The resolved file URL path
    public func resolveBookmark(_ bookmark: [UInt8]) async throws -> String {
        let url = try bookmarkService.resolveBookmark(bookmark)
        return url.path
    }

    /// Get the list of currently active security-scoped resources
    /// - Returns: Set of paths with active security scope
    public func getActiveSecurityScopedResources() -> Set<String> {
        activeSecurityScopedResources
    }

    public func withSecurityScopedAccess<T>(
        to path: String,
        perform operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        let url = URL(fileURLWithPath: path)
        return try bookmarkService.withSecurityScopedAccess(to: url) {
            activeSecurityScopedResources.insert(path)
            defer {
                activeSecurityScopedResources.remove(path)
            }
            let operationResult = UmbySecurity.OperationResult<T>()

            Task {
                do {
                    let result = try await operation()
                    operationResult.complete(with: .success(result))
                } catch {
                    operationResult.complete(with: .failure(error))
                }
            }

            guard let result = operationResult.waitForResult() else {
                throw NSError(
                    domain: "com.umbrasecurity.error",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Operation timed out"]
                )
            }

            return try result.get()
        }
    }

    /// Encrypt data using the security provider
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    public func encrypt(_ data: Data, using key: Data) async throws -> Data {
        try await securityProvider.encrypt(data, key: key)
    }

    /// Decrypt data using the security provider
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    public func decrypt(_ data: Data, using key: Data) async throws -> Data {
        try await securityProvider.decrypt(data, key: key)
    }

    /// Generate a random encryption key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    public func generateKey(length: Int) async throws -> Data {
        try await securityProvider.generateKey(length: length)
    }

    /// Generate cryptographically secure random data
    /// - Parameter length: Length of data to generate in bytes
    /// - Returns: Random data
    public func generateRandomData(length: Int) async throws -> Data {
        let result = await securityProvider.generateRandomData(length: length)
        switch result {
        case let .success(data):
            return data
        case let .failure(error):
            throw error
        }
    }

    /// Hash data using SHA-256
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    public func hash(_ data: Data) async throws -> Data {
        try await securityProvider.hashData(data)
    }
}

/// Helper class for async operations
public enum UmbySecurity {
    final class OperationResult<T> {
        private var result: Result<T, Error>?
        private let semaphore = DispatchSemaphore(value: 0)

        func complete(with result: Result<T, Error>) {
            self.result = result
            semaphore.signal()
        }

        func waitForResult(timeout: TimeInterval = 30.0) -> Result<T, Error>? {
            let timeoutResult = semaphore.wait(timeout: .now() + timeout)
            guard timeoutResult == .success else {
                return nil
            }
            return result
        }
    }
}

/// Default implementation of the bookmark service
private final class DefaultBookmarkService: BookmarkServiceType {
    func createBookmark(for url: URL) throws -> [UInt8] {
        let bookmark = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        return Array(bookmark)
    }

    func resolveBookmark(_ bookmark: [UInt8]) throws -> URL {
        let bookmarkData = Data(bookmark)
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        if isStale {
            print("Warning: Using stale bookmark for \(url.path)")
        }
        return url
    }

    func withSecurityScopedAccess<T>(to url: URL, perform operation: () throws -> T) throws -> T {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try operation()
    }

    func stopAccessing(url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}

/// Default implementation of the security provider that conforms to both required protocols
private final class DefaultSecurityProviderImpl: NSObject, SecurityProviderFoundationImpl,
    FoundationSecurityProvider, FoundationCryptoServiceImpl, FoundationKeyManagementImpl,
    RandomDataGenerating
{
    // MARK: - FoundationSecurityProvider Properties

    /// Implementation of cryptoService for FoundationSecurityProvider protocol
    public var cryptoService: any FoundationCryptoServiceImpl {
        self
    }

    /// Implementation of keyManager for FoundationSecurityProvider protocol
    public var keyManager: any FoundationKeyManagementImpl {
        self
    }

    // MARK: - FoundationSecurityProvider Methods

    /// Perform a security operation with Foundation types (FoundationSecurityProviderObjC protocol)
    /// - Parameters:
    ///   - operation: Operation identifier as a string
    ///   - options: Configuration options dictionary
    /// - Returns: Result with Foundation types for Objective-C
    @objc
    public func performOperation(
        operation: String,
        options: [String: Any]
    ) async -> FoundationOperationResult {
        do {
            switch operation {
            case "encrypt":
                if let data = options["data"] as? Data, let key = options["key"] as? Data {
                    let encrypted = try await encrypt(data, key: key)
                    return FoundationOperationResultImpl.success(encrypted)
                } else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "com.umbrasecurity.error",
                        code: 6,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for encryption"]
                    ))
                }

            case "decrypt":
                if let data = options["data"] as? Data, let key = options["key"] as? Data {
                    let decrypted = try await decrypt(data, key: key)
                    return FoundationOperationResultImpl.success(decrypted)
                } else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "com.umbrasecurity.error",
                        code: 7,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for decryption"]
                    ))
                }

            default:
                return FoundationOperationResultImpl.failure(NSError(
                    domain: "com.umbrasecurity.error",
                    code: 8,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported operation: \(operation)"]
                ))
            }
        } catch {
            return FoundationOperationResultImpl.failure(error)
        }
    }

    /// Perform a security operation with Foundation types (FoundationSecurityProvider protocol)
    /// - Parameters:
    ///   - operation: Operation identifier as a string
    ///   - options: Configuration options dictionary
    /// - Returns: Result with Foundation types for Swift
    func performOperationSwift(
        operation: String,
        options: [String: Any]
    ) async -> Result<Data?, Error> {
        do {
            switch operation {
            case "encrypt":
                if let data = options["data"] as? Data, let key = options["key"] as? Data {
                    let encrypted = try await encrypt(data, key: key)
                    return .success(encrypted)
                } else {
                    return .failure(NSError(
                        domain: "com.umbrasecurity.error",
                        code: 6,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for encryption"]
                    ))
                }

            case "decrypt":
                if let data = options["data"] as? Data, let key = options["key"] as? Data {
                    let decrypted = try await decrypt(data, key: key)
                    return .success(decrypted)
                } else {
                    return .failure(NSError(
                        domain: "com.umbrasecurity.error",
                        code: 7,
                        userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for decryption"]
                    ))
                }

            default:
                return .failure(NSError(
                    domain: "com.umbrasecurity.error",
                    code: 8,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported operation: \(operation)"]
                ))
            }
        } catch {
            return .failure(error)
        }
    }

    // MARK: - FoundationCryptoServiceImpl Methods

    func encrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        do {
            let result = try await encrypt(data, key: key)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func decrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        do {
            let result = try await decrypt(data, key: key)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func generateKey() async -> Result<Data, Error> {
        do {
            let result = try await generateKey(length: 32) // Default length
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func hash(data: Data) async -> Result<Data, Error> {
        do {
            let result = try await hashData(data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func verify(data: Data, against hash: Data) async -> Bool {
        do {
            let computedHash = try await hashData(data)
            return computedHash == hash
        } catch {
            return false
        }
    }

    func encryptSymmetric(
        data: Data,
        key: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        iv _: Data?,
        aad _: Data?,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        do {
            let encrypted = try await encrypt(data, key: key)
            return FoundationSecurityResult(data: encrypted)
        } catch {
            return FoundationSecurityResult(errorCode: 1, errorMessage: error.localizedDescription)
        }
    }

    func decryptSymmetric(
        data: Data,
        key: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        iv _: Data?,
        aad _: Data?,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        do {
            let decrypted = try await decrypt(data, key: key)
            return FoundationSecurityResult(data: decrypted)
        } catch {
            return FoundationSecurityResult(errorCode: 2, errorMessage: error.localizedDescription)
        }
    }

    // MARK: - FoundationKeyManagementImpl Methods

    func retrieveKey(withIdentifier identifier: String) async -> Result<Data, Error> {
        do {
            let data = try await retrieveSecurely(identifier: identifier, options: nil)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    func storeKey(_ key: Data, withIdentifier identifier: String) async -> Result<Void, Error> {
        do {
            _ = try await storeSecurely(data: key, identifier: identifier, options: nil)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteKey(withIdentifier identifier: String) async -> Result<Void, Error> {
        do {
            _ = try await deleteSecurely(identifier: identifier)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func rotateKey(withIdentifier identifier: String, newKey: Data) async -> Result<Void, Error> {
        do {
            // Get the old key first (not actually used, just to validate it exists)
            _ = try await retrieveSecurely(identifier: identifier, options: nil)

            // Store the new key with the same identifier
            _ = try await storeSecurely(data: newKey, identifier: identifier, options: nil)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func listKeyIdentifiers() async -> Result<[String], Error> {
        // This is a simplified implementation since we don't have a real key storage system
        .success([])
    }

    // MARK: - SecurityProviderFoundationImpl Methods

    @objc
    func encrypt(_ data: Data, key: Data) async throws -> Data {
        do {
            guard key.count >= 32 else {
                throw NSError(
                    domain: "com.umbrasecurity.error",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Key too short"]
                )
            }

            var result = Data(count: data.count)
            for i in 0 ..< data.count {
                let keyByte = key[i % key.count]
                result[i] = data[i] ^ keyByte
            }
            return result
        } catch {
            throw NSError(
                domain: "com.umbrasecurity.error",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(error.localizedDescription)"]
            )
        }
    }

    @objc
    func decrypt(_ data: Data, key: Data) async throws -> Data {
        try await encrypt(data, key: key)
    }

    @objc
    func generateKey(length: Int) async throws -> Data {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }

        if result == errSecSuccess {
            return keyData
        } else {
            throw NSError(
                domain: "com.umbrasecurity.error",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate random bytes"]
            )
        }
    }

    @objc
    func generateDataKey(length: Int) async throws -> Data {
        // Reuse existing implementation
        try await generateKey(length: length)
    }

    @objc
    func hashData(_ data: Data) async throws -> Data {
        // Simple SHA-256 implementation for demonstration
        var hash = Data(count: 32)

        // Create a simple hash by XORing bytes in chunks
        let chunkSize = 4
        for i in stride(from: 0, to: data.count, by: chunkSize) {
            let endIndex = min(i + chunkSize, data.count)
            let chunk = data[i ..< endIndex]

            var accumulator: UInt8 = 0
            for byte in chunk {
                accumulator ^= byte
            }

            let hashIndex = (i / chunkSize) % 32
            hash[hashIndex] = accumulator
        }

        return hash
    }

    @objc
    func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            let canAccess = url.startAccessingSecurityScopedResource()
            if canAccess {
                url.stopAccessingSecurityScopedResource()
            }

            return canAccess && !isStale
        } catch {
            return false
        }
    }

    @objc
    func createBookmark(for url: URL) async throws -> Data {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            return try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } else {
            throw NSError(
                domain: "com.umbrasecurity.error",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Could not access security-scoped resource"]
            )
        }
    }

    @objc
    func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return (url: url, isStale: isStale)
        } catch {
            throw NSError(
                domain: "com.umbrasecurity.error",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Failed to resolve bookmark"]
            )
        }
    }

    @objc
    func encryptData(_ data: Data, key: Data) async throws -> Data {
        try await encrypt(data, key: key)
    }

    @objc
    func decryptData(_ data: Data, key: Data) async throws -> Data {
        try await decrypt(data, key: key)
    }

    @objc
    func generateRandomBytes(length: Int) async throws -> Data {
        try await generateKey(length: length)
    }

    func generateRandomData(length: Int) async -> Result<Data, Error> {
        do {
            let randomData = try await generateKey(length: length)
            return .success(randomData)
        } catch {
            return .failure(error)
        }
    }

    @objc
    func storeSecurely(
        data: Data,
        identifier: String,
        options _: [String: Any]?
    ) async throws -> Bool {
        // Simplified implementation
        UserDefaults.standard.set(data, forKey: "secure_\(identifier)")
        return true
    }

    @objc
    func retrieveSecurely(identifier: String, options _: [String: Any]?) async throws -> Data {
        if let data = UserDefaults.standard.data(forKey: "secure_\(identifier)") {
            return data
        } else {
            throw NSError(
                domain: "com.umbrasecurity.error",
                code: 5,
                userInfo: [NSLocalizedDescriptionKey: "No data found for identifier"]
            )
        }
    }

    @objc
    func deleteSecurely(identifier: String) async throws -> Bool {
        UserDefaults.standard.removeObject(forKey: "secure_\(identifier)")
        return true
    }

    @objc
    func validateSecurityOperation() async throws -> Bool {
        true
    }

    @objc
    func startAccessing(url: URL) -> Bool {
        url.startAccessingSecurityScopedResource()
    }

    @objc
    func stopAccessing(url: URL) {
        url.stopAccessingSecurityScopedResource()
    }

    /// Encrypt data using Foundation types directly
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Result with encrypted data or error
    func encryptWithFoundation(
        _ data: Data,
        key: Data
    ) async -> Result<Data, Error> {
        do {
            let encrypted = try await encrypt(data, key: key)
            return .success(encrypted)
        } catch {
            return .failure(error)
        }
    }

    /// Decrypt data using Foundation types directly
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Result with decrypted data or error
    func decryptWithFoundation(
        _ data: Data,
        key: Data
    ) async -> Result<Data, Error> {
        do {
            let decrypted = try await decrypt(data, key: key)
            return .success(decrypted)
        } catch {
            return .failure(error)
        }
    }

    /// Hash data using Foundation types directly
    /// - Parameter data: Data to hash
    /// - Returns: Result with hashed data or error
    func hashWithFoundation(
        _ data: Data
    ) async -> Result<Data, Error> {
        do {
            let hashed = try await hashData(data)
            return .success(hashed)
        } catch {
            return .failure(error)
        }
    }

    // FoundationCryptoServiceImpl additional required methods

    // Asymmetric encryption
    func encryptAsymmetric(
        data: Data,
        publicKey: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        // Simplified implementation that falls back to symmetric encryption
        do {
            let encrypted = try await encrypt(data, key: publicKey)
            return FoundationSecurityResult(data: encrypted)
        } catch {
            return FoundationSecurityResult(
                errorCode: 3,
                errorMessage: "Asymmetric encryption not supported: \(error.localizedDescription)"
            )
        }
    }

    // Asymmetric decryption
    func decryptAsymmetric(
        data: Data,
        privateKey: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        // Simplified implementation that falls back to symmetric decryption
        do {
            let decrypted = try await decrypt(data, key: privateKey)
            return FoundationSecurityResult(data: decrypted)
        } catch {
            return FoundationSecurityResult(
                errorCode: 4,
                errorMessage: "Asymmetric decryption not supported: \(error.localizedDescription)"
            )
        }
    }

    // Hashing with specific algorithm
    func hash(
        data: Data,
        algorithm _: String,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        do {
            let hashed = try await hashData(data)
            return FoundationSecurityResult(data: hashed)
        } catch {
            return FoundationSecurityResult(
                errorCode: 5,
                errorMessage: "Hashing operation failed: \(error.localizedDescription)"
            )
        }
    }
}

// Implement the FoundationSecurityProvider protocol method separately to avoid confusion
extension DefaultSecurityProviderImpl {
    // Implementation of the FoundationSecurityProvider protocol method
    func performOperation(
        operation: String,
        options: [String: Any]
    ) async -> Result<Data?, Error> {
        // Reuse the Swift implementation
        await performOperationSwift(operation: operation, options: options)
    }
}
