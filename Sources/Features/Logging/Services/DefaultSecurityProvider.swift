import Foundation
import SecurityTypes
import SecurityTypesProtocols
import XPCProtocolsCore

/// Default implementation of SecurityProvider for production use
@available(macOS 14.0, *)
public class DefaultSecurityProvider: XPCProtocolsCore.SecurityProvider {
    /// Dictionary to track accessed URLs and their bookmark data
    private var accessedURLs: [String: (URL, Data)] = [:]

    /// Keeping track of security-scoped resources
    private var securityScopedResources: Set<URL> = []

    public init() {}

    // MARK: - URL-based Security Methods

    public func startAccessing(url: URL) async throws -> Bool {
        let success = url.startAccessingSecurityScopedResource()
        if success {
            securityScopedResources.insert(url)
        }
        return success
    }

    public func stopAccessing(url: URL) async {
        url.stopAccessingSecurityScopedResource()
        securityScopedResources.remove(url)
    }

    public func stopAccessingAllResources() async {
        for url in securityScopedResources {
            url.stopAccessingSecurityScopedResource()
        }
        securityScopedResources.removeAll()
    }

    public func isAccessing(url: URL) async -> Bool {
        return securityScopedResources.contains(url)
    }

    public func getAccessedUrls() async -> Set<URL> {
        return securityScopedResources
    }

    // MARK: - Path-based Security Methods (previously implemented)

    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        let url = URL(fileURLWithPath: path)
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope)
            return Array(bookmarkData)
        } catch {
            throw XPCSecurityError.bookmarkError
        }
    }

    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: Data(bookmarkData),
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &isStale)
            return (url.path, isStale)
        } catch {
            throw XPCSecurityError.bookmarkError
        }
    }

    public func startAccessing(path: String) async throws -> Bool {
        return try await startAccessing(url: URL(fileURLWithPath: path))
    }

    public func stopAccessing(path: String) {
        Task {
            await stopAccessing(url: URL(fileURLWithPath: path))
        }
    }

    // MARK: - Foundation Methods for SecurityProviderFoundation

    public func createBookmark(for url: URL) async throws -> Data {
        do {
            return try url.bookmarkData(options: .withSecurityScope)
        } catch {
            throw XPCSecurityError.bookmarkError
        }
    }

    public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &isStale)
            return (url, isStale)
        } catch {
            throw XPCSecurityError.bookmarkError
        }
    }

    // MARK: - Encryption Methods (required by XPCSecurityProvider)

    public func encrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
        // Simple XOR encryption for demonstration
        return zip(data, key.cycled(to: data.count)).map { $0 ^ $1 }
    }

    public func decrypt(_ data: [UInt8], key: [UInt8]) async throws -> [UInt8] {
        // XOR decryption is the same as encryption
        return try await encrypt(data, key: key)
    }

    public func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        let encryptedBytes = try await encrypt(Array(data), key: Array(key))
        return Data(encryptedBytes)
    }

    public func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        let decryptedBytes = try await decrypt(Array(data), key: Array(key))
        return Data(decryptedBytes)
    }

    public func generateKey(length: Int) async throws -> [UInt8] {
        // Generate a secure random key
        var bytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard result == errSecSuccess else {
            throw XPCSecurityError.keyGenerationError
        }
        return bytes
    }

    public func hash(_ data: [UInt8]) async throws -> [UInt8] {
        // Simple hash function for demonstration
        var hash: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
        for byte in data {
            hash[Int(byte) % hash.count] ^= byte
        }
        return hash
    }
}

// MARK: - Array Extensions

extension Array where Element == UInt8 {
    /// Create a cycled version of the array to the specified length
    fileprivate func cycled(to length: Int) -> [UInt8] {
        guard !isEmpty else { return [] }

        var result = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            result[i] = self[i % count]
        }
        return result
    }
}
