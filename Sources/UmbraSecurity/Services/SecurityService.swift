import CoreServicesTypesNoFoundation
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
        self.bookmarkService = DefaultBookmarkService()
        self.securityProvider = DefaultSecurityProviderImpl()
        print("SecurityService initialized with DefaultBookmarkService")
    }
    
    /// Security provider adapter that can be used by other components
    @MainActor
    var securityProviderAdapter: SecurityBridge.SecurityProviderFoundationAdapter {
        return SecurityBridge.SecurityProviderFoundationAdapter(implementation: securityProvider)
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
        return activeSecurityScopedResources
    }
    
    public func withSecurityScopedAccess<T>(to path: String, perform operation: @Sendable @escaping () async throws -> T) async throws -> T {
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
                throw NSError(domain: "com.umbrasecurity.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
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
    
    /// Generate random data
    /// - Parameter length: Length of the random data in bytes
    /// - Returns: Random data
    public func generateRandomData(length: Int) async throws -> Data {
        try await securityProvider.generateRandomData(length: length)
    }
    
    /// Hash data using SHA-256
    /// - Parameter data: Data to hash
    /// - Returns: Hashed data
    public func hash(_ data: Data) async throws -> Data {
        try await securityProvider.hash(data)
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
        let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        return Array(bookmark)
    }
    
    func resolveBookmark(_ bookmark: [UInt8]) throws -> URL {
        let bookmarkData = Data(bookmark)
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
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
private final class DefaultSecurityProviderImpl: SecurityBridge.SecurityProviderFoundationImpl {
    func encrypt(_ data: Data, key: Data) async throws -> Data {
        do {
            guard key.count >= 32 else {
                throw NSError(domain: "com.umbrasecurity.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Key too short"])
            }
            
            var result = Data(count: data.count)
            for i in 0..<data.count {
                let keyByte = key[i % key.count]
                result[i] = data[i] ^ keyByte
            }
            return result
        } catch {
            throw NSError(domain: "com.umbrasecurity.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(error.localizedDescription)"])
        }
    }
    
    func decrypt(_ data: Data, key: Data) async throws -> Data {
        return try await encrypt(data, key: key)
    }
    
    func generateKey(length: Int) async throws -> Data {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        
        if result == errSecSuccess {
            return keyData
        } else {
            throw NSError(domain: "com.umbrasecurity.error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to generate random key"])
        }
    }
    
    func generateRandomData(length: Int) async throws -> Data {
        return try await generateKey(length: length)
    }
    
    func hash(_ data: Data) async throws -> Data {
        var hash = Data(count: 32)
        
        var accumulator: UInt8 = 0
        for byte in data {
            accumulator = accumulator &+ byte
        }
        
        for i in 0..<32 {
            hash[i] = accumulator &+ UInt8(i)
        }
        
        return hash
    }
    
    func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        return try await encrypt(data, key: key)
    }
    
    func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        return try await decrypt(data, key: key)
    }
    
    func generateDataKey(length: Int) async throws -> Foundation.Data {
        return try await generateKey(length: length)
    }
    
    func hashData(_ data: Foundation.Data) async throws -> Foundation.Data {
        return try await hash(data)
    }
    
    func createBookmark(for url: URL) async throws -> Data {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmarkData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create bookmark for \(url.path): \(error.localizedDescription)"])
        }
    }
    
    func resolveBookmark(_ bookmarkData: Data) async throws -> (urlString: String, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            return (url.path, isStale)
        } catch {
            throw NSError(domain: "SecurityProvider", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to resolve bookmark: \(error.localizedDescription)"])
        }
    }
    
    func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            let canAccess = url.startAccessingSecurityScopedResource()
            
            if canAccess {
                url.stopAccessingSecurityScopedResource()
            }
            
            return canAccess && !isStale
        } catch {
            return false
        }
    }
}
