import Foundation

/// Base protocol for all XPC services
@objc public protocol XPCServiceProtocol {
    /// Validates the connection with the service
    func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void)

    /// Gets the service version
    func getServiceVersion(withReply reply: @escaping (String) -> Void)
}

@objc(CryptoXPCServiceProtocol)
public protocol CryptoXPCServiceProtocol {
    func encrypt(_ data: Data, key: Data) async throws -> Data
    func decrypt(_ data: Data, key: Data) async throws -> Data
    func generateKey(bits: Int) async throws -> Data
    func generateSecureRandomKey(length: Int) async throws -> Data
    func generateInitializationVector() async throws -> Data
    func storeCredential(_ credential: Data, identifier: String) async throws
    func retrieveCredential(identifier: String) async throws -> Data
    func deleteCredential(identifier: String) async throws
}

@objc(SecurityXPCServiceProtocol)
public protocol SecurityXPCServiceProtocol: XPCServiceProtocol {
    /// Creates a security-scoped bookmark
    func createBookmark(forPath path: String,
                       withReply reply: @escaping ([UInt8]?, Error?) -> Void)

    /// Resolves a security-scoped bookmark
    func resolveBookmark(_ bookmarkData: [UInt8],
                        withReply reply: @escaping (String?, Bool, Error?) -> Void)

    /// Validates a security-scoped bookmark
    func validateBookmark(_ bookmarkData: [UInt8],
                        withReply reply: @escaping (Bool, Error?) -> Void)

    func validateAccess(forResource resource: String) async throws -> Bool
    func requestPermission(forResource resource: String) async throws -> Bool
    func revokePermission(forResource resource: String) async throws
    func getCurrentPermissions() async throws -> [String: Bool]
}
