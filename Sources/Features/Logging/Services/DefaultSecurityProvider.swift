import Foundation
import CoreTypes
@preconcurrency import SecurityInterfaces
import SecurityInterfacesFoundation
import SecurityInterfacesProtocols
import SecurityTypes
import SecurityTypesProtocols

/// Private actor for managing shared state
private actor SecurityResourceManager {
    var securityScopedResources: Set<URL> = []
    
    func addResource(_ url: URL) {
        securityScopedResources.insert(url)
    }
    
    func removeResource(_ url: URL) {
        securityScopedResources.remove(url)
    }
    
    func clearResources() {
        securityScopedResources.removeAll()
    }
    
    func containsResource(_ url: URL) -> Bool {
        return securityScopedResources.contains(url)
    }
    
    func getAllResources() -> Set<URL> {
        return securityScopedResources
    }
}

/// Default implementation of SecurityProvider for production use
@available(macOS 14.0, *)
public class DefaultSecurityProvider: SecurityInterfaces.SecurityProviderFoundation {
    /// Dictionary to track accessed URLs and their bookmark data
    private var accessedURLs: [String: (URL, Data)] = [:]

    /// Actor for managing security-scoped resources
    private let resourceManager = SecurityResourceManager()

    public init() {}

    // MARK: - URL-based Security Methods

    public nonisolated func startAccessing(url: URL) async throws -> Bool {
        let success = url.startAccessingSecurityScopedResource()
        if success {
            await resourceManager.addResource(url)
        }
        return success
    }

    public nonisolated func stopAccessing(url: URL) async {
        url.stopAccessingSecurityScopedResource()
        await resourceManager.removeResource(url)
    }

    public nonisolated func stopAccessingAllResources() async {
        let resources = await resourceManager.getAllResources()
        for url in resources {
            url.stopAccessingSecurityScopedResource()
        }
        await resourceManager.clearResources()
    }

    public nonisolated func isAccessing(url: URL) async -> Bool {
        return await resourceManager.containsResource(url)
    }

    public nonisolated func getAccessedUrls() async -> Set<URL> {
        return await resourceManager.getAllResources()
    }

    // MARK: - Path-based Security Methods (previously implemented)

    public nonisolated func createBookmark(forPath path: String) async throws -> CoreTypes.BinaryData {
        let url = URL(fileURLWithPath: path)
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope)
            return CoreTypes.BinaryData(Array(bookmarkData))
        } catch {
            throw SecurityInterfaces.SecurityError.bookmarkError("Failed to create bookmark for \(path): \(error.localizedDescription)")
        }
    }

    public nonisolated func resolveBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (path: String, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: Data(bookmarkData.bytes),
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &isStale)
            return (url.path, isStale)
        } catch {
            throw SecurityInterfaces.SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
        }
    }

    public nonisolated func startAccessing(path: String) async throws -> Bool {
        return try await startAccessing(url: URL(fileURLWithPath: path))
    }

    public nonisolated func stopAccessing(path: String) async {
        await stopAccessing(url: URL(fileURLWithPath: path))
    }

    // MARK: - Foundation Methods for SecurityProviderFoundation

    public nonisolated func createBookmark(for identifier: String) async throws -> CoreTypes.BinaryData {
        let url = URL(fileURLWithPath: identifier)
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope)
            return CoreTypes.BinaryData(Array(bookmarkData))
        } catch {
            throw SecurityInterfaces.SecurityError.bookmarkError("Failed to create bookmark for \(identifier): \(error.localizedDescription)")
        }
    }

    public nonisolated func resolveBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (identifier: String, isStale: Bool) {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: Data(bookmarkData.bytes),
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &isStale)
            return (url.path, isStale)
        } catch {
            throw SecurityInterfaces.SecurityError.bookmarkError("Failed to resolve bookmark: \(error.localizedDescription)")
        }
    }

    public nonisolated func validateBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool {
        do {
            var isStale = false
            _ = try URL(resolvingBookmarkData: Data(bookmarkData.bytes),
                       options: .withSecurityScope,
                       relativeTo: nil,
                       bookmarkDataIsStale: &isStale)
            return !isStale
        } catch {
            return false
        }
    }

    // MARK: - Resource Access Control

    public nonisolated func startAccessingResource(identifier: String) async throws -> Bool {
        return try await startAccessing(url: URL(fileURLWithPath: identifier))
    }

    public nonisolated func stopAccessingResource(identifier: String) async {
        await stopAccessing(url: URL(fileURLWithPath: identifier))
    }

    public nonisolated func isAccessingResource(identifier: String) async -> Bool {
        return await isAccessing(url: URL(fileURLWithPath: identifier))
    }

    public nonisolated func getAccessedResourceIdentifiers() async -> Set<String> {
        let urls = await getAccessedUrls()
        return Set(urls.map { $0.path })
    }

    // MARK: - Resource Bookmarks

    public nonisolated func createResourceBookmark(for identifier: String) async throws -> CoreTypes.BinaryData {
        return try await createBookmark(for: identifier)
    }

    public nonisolated func resolveResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> (identifier: String, isStale: Bool) {
        return try await resolveBookmark(bookmarkData)
    }

    public nonisolated func validateResourceBookmark(_ bookmarkData: CoreTypes.BinaryData) async throws -> Bool {
        return try await validateBookmark(bookmarkData)
    }

    // MARK: - Keychain Methods

    public nonisolated func storeInKeychain(data: CoreTypes.BinaryData, service: String, account: String) async throws {
        // Implementation would use Keychain API to store data
        throw SecurityInterfaces.SecurityError.operationFailed("Keychain storage not implemented")
    }

    public nonisolated func retrieveFromKeychain(service: String, account: String) async throws -> CoreTypes.BinaryData {
        // Implementation would use Keychain API to retrieve data
        throw SecurityInterfaces.SecurityError.operationFailed("Keychain retrieval not implemented")
    }

    public nonisolated func deleteFromKeychain(service: String, account: String) async throws {
        // Implementation would use Keychain API to delete data
        throw SecurityInterfaces.SecurityError.operationFailed("Keychain deletion not implemented")
    }

    // MARK: - Foundation Data Methods

    public nonisolated func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        let encryptedBytes = try await encrypt(CoreTypes.BinaryData(Array(data)), key: CoreTypes.BinaryData(Array(key)))
        return Data(encryptedBytes.bytes)
    }

    public nonisolated func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        let decryptedBytes = try await decrypt(CoreTypes.BinaryData(Array(data)), key: CoreTypes.BinaryData(Array(key)))
        return Data(decryptedBytes.bytes)
    }

    public nonisolated func generateDataKey(length: Int) async throws -> Foundation.Data {
        let keyBytes = try await generateKey(length: length)
        return Data(keyBytes.bytes)
    }

    public nonisolated func hashData(_ data: Foundation.Data) async throws -> Foundation.Data {
        let hashBytes = try await hash(CoreTypes.BinaryData(Array(data)))
        return Data(hashBytes.bytes)
    }

    // MARK: - Binary Data Methods

    public nonisolated func encrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Implementation of encryption
        return data // Placeholder: actual implementation would encrypt the data
    }

    public nonisolated func decrypt(_ data: CoreTypes.BinaryData, key: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Implementation of decryption
        return data // Placeholder: actual implementation would decrypt the data
    }

    public nonisolated func generateKey(length: Int) async throws -> CoreTypes.BinaryData {
        // Generate a random key of specified length
        var keyData = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, keyData.count, &keyData)
        if result == errSecSuccess {
            return CoreTypes.BinaryData(keyData)
        } else {
            throw SecurityInterfaces.SecurityError.randomGenerationFailed
        }
    }

    public nonisolated func hash(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Simple implementation for hashing
        return data // Placeholder: actual implementation would hash the data
    }

    // MARK: - SecurityProviderBase methods

    public nonisolated func resetSecurityData() async throws {
        // Implementation for resetting security data
    }

    public nonisolated func getHostIdentifier() async throws -> String {
        return "host-identifier-placeholder"
    }

    public nonisolated func registerClient(bundleIdentifier: String) async throws -> Bool {
        return true
    }

    public nonisolated func requestKeyRotation(keyId: String) async throws {
        // Implementation for key rotation
    }

    public nonisolated func notifyKeyCompromise(keyId: String) async throws {
        // Implementation for key compromise notification
    }
}
