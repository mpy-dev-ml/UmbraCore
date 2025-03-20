import Foundation

/// Protocol for Foundation-based security providers with Objective-C compatibility
/// This protocol allows for Foundation operations to be wrapped by bridge adapters
@objc
public protocol FoundationSecurityProviderObjC: NSObjectProtocol, Sendable {
    /// Perform a security operation with the given options
    /// - Parameters:
    ///   - operation: String identifier for the operation to perform
    ///   - options: Dictionary of options for the operation
    /// - Returns: Result containing data or error
    @objc
    func performOperation(operation: String, options: [String: Any]) async
        -> FoundationOperationResult
}

/// Protocol for Foundation-based security implementations
@objc
public protocol SecurityProviderFoundationImpl: FoundationSecurityProviderObjC {
    /// Encrypt data using the given key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    @objc
    func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation
        .Data

    /// Decrypt data using the given key
    /// - Parameters:
    ///   - data: Data to decrypt
    ///   - key: Decryption key
    /// - Returns: Decrypted data
    @objc
    func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation
        .Data

    /// Generate a data key
    /// - Parameter length: Length of the key in bytes
    /// - Returns: Generated key
    @objc
    func generateDataKey(length: Int) async throws -> Foundation.Data

    /// Generate a hash of the provided data
    /// - Parameter data: Data to hash
    /// - Returns: Hash value
    @objc
    func hashData(_ data: Foundation.Data) async throws -> Foundation.Data

    /// Create a bookmark for the specified URL
    /// - Parameter url: URL to create bookmark for
    /// - Returns: Bookmark data
    @objc
    // DEPRECATED: func createBookmark(for url: URL) async throws -> Foundation.Data

    /// Resolve a bookmark to a URL
    /// - Parameter bookmarkData: Bookmark data to resolve
    /// - Returns: URL and stale flag tuple
    @objc
    func resolveBookmark(_ bookmarkData: Foundation.Data) async throws
        -> (url: URL, isStale: Bool)

    /// Validate if a bookmark is still valid
    /// - Parameter bookmarkData: Bookmark data to validate
    /// - Returns: True if valid, false otherwise
    @objc
    func validateBookmark(_ bookmarkData: Foundation.Data) async throws -> Bool
}

/// Result type for Foundation security operations
@objc
public protocol FoundationOperationResult: NSObjectProtocol {
    var isSuccess: Bool { get }
    var resultData: Data? { get }
    // DEPRECATED: var error: Error? { get }
}

/// Objective-C compatible operation result
@objc
public final class FoundationOperationResultImpl: NSObject, FoundationOperationResult {
    private enum ResultType {
        case success(Data?)
        case failure(Error)
    }

    private let result: ResultType

    private init(_ result: ResultType) {
        self.result = result
        super.init()
    }

    public static func success(_ data: Data?) -> FoundationOperationResultImpl {
        FoundationOperationResultImpl(.success(data))
    }

    // DEPRECATED: public static func failure(_ error: Error) -> FoundationOperationResultImpl {
        // DEPRECATED: FoundationOperationResultImpl(.failure(error))
    }

    public var isSuccess: Bool {
        switch result {
        case .success:
            true
        case .failure:
            false
        }
    }

    public var resultData: Data? {
        switch result {
        case let .success(data):
            data
        case .failure:
            nil
        }
    }

    // DEPRECATED: public var error: Error? {
        switch result {
        case .success:
            nil
        // DEPRECATED: case let .failure(error):
            // DEPRECATED: error
        }
    }
}

// Extension to add performOperation implementation to SecurityProviderFoundationImpl
public extension SecurityProviderFoundationImpl {
    func performOperation(
        operation: String,
        options: [String: Any]
    ) async -> FoundationOperationResult {
        do {
            switch operation {
            case "encrypt":
                guard let data = options["data"] as? Data, let key = options["key"] as? Data else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 100,
                        // DEPRECATED: userInfo: [NSLocalizedDescriptionKey: "Invalid parameters for encrypt operation"]
                    ))
                // DEPRECATED: }
                let result = try await encryptData(data, key: key)
                return FoundationOperationResultImpl.success(result)

            case "decrypt":
                guard let data = options["data"] as? Data, let key = options["key"] as? Data else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 101,
                        // DEPRECATED: userInfo: [NSLocalizedDescriptionKey: "Invalid parameters for decrypt operation"]
                    ))
                }
                let result = try await decryptData(data, key: key)
                return FoundationOperationResultImpl.success(result)

            case "generateKey":
                // DEPRECATED: let length = options["length"] as? Int ?? 32 // Default to 32 bytes (256 bits)
                let result = try await generateDataKey(length: length)
                return FoundationOperationResultImpl.success(result)

            case "generateRandomData":
                guard let length = options["length"] as? Int else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 102,
                        userInfo: [
                            // DEPRECATED: NSLocalizedDescriptionKey: "Invalid parameters for generateRandomData operation",
                        ]
                    ))
                }
                let result = try await generateDataKey(length: length)
                return FoundationOperationResultImpl.success(result)

            case "hash":
                guard let data = options["data"] as? Data else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 103,
                        // DEPRECATED: userInfo: [NSLocalizedDescriptionKey: "Invalid parameters for hash operation"]
                    ))
                }
                let result = try await hashData(data)
                return FoundationOperationResultImpl.success(result)

            case "createBookmark":
                guard let urlString = options["url"] as? String, let url = URL(string: urlString) else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 104,
                        userInfo: [
                            // DEPRECATED: NSLocalizedDescriptionKey: "Invalid parameters for createBookmark operation",
                        ]
                    ))
                }
                // DEPRECATED: let result = try await createBookmark(for: url)
                return FoundationOperationResultImpl.success(result)

            case "resolveBookmark":
                guard let bookmarkData = options["bookmarkData"] as? Data else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 105,
                        userInfo: [
                            // DEPRECATED: NSLocalizedDescriptionKey: "Invalid parameters for resolveBookmark operation",
                        ]
                    ))
                }
                let (url, _) = try await resolveBookmark(bookmarkData)
                return FoundationOperationResultImpl.success(url.absoluteString.data(using: .utf8))

            case "validateBookmark":
                guard let bookmarkData = options["bookmarkData"] as? Data else {
                    return FoundationOperationResultImpl.failure(NSError(
                        domain: "SecurityProvider",
                        code: 106,
                        userInfo: [
                            // DEPRECATED: NSLocalizedDescriptionKey: "Invalid parameters for validateBookmark operation",
                        ]
                    ))
                }
                let isValid = try await validateBookmark(bookmarkData)
                let result = isValid ? Data([1]) : Data([0])
                return FoundationOperationResultImpl.success(result)

            default:
                return FoundationOperationResultImpl.failure(NSError(
                    domain: "SecurityProvider",
                    code: 107,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported operation: \(operation)"]
                ))
            }
        } catch {
            // DEPRECATED: return FoundationOperationResultImpl.failure(error)
        }
    }
}
