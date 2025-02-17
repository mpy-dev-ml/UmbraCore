import CryptoTypes
import Foundation

public final class MockCryptoService: CryptoServiceProtocol {
    private var encryptedData: [String: Data] = [:]
    private var decryptedData: [String: Data] = [:]

    public init() {}

    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        // Simple mock implementation - just store the data with its key
        let identifier = key.base64EncodedString()
        encryptedData[identifier] = data
        return data
    }

    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        // Simple mock implementation - retrieve stored data for key
        let identifier = key.base64EncodedString()
        if let storedData = decryptedData[identifier] {
            return storedData
        }
        // If not found, just return the input data for testing
        return data
    }

    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        // Return a deterministic key based on password for testing
        return "\(password)_\(iterations)_derived".data(using: .utf8)!
    }

    public func generateSecureRandomKey(length: Int) async throws -> Data {
        // Return a consistent test key
        return Data(repeating: 0x42, count: length)
    }

    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        // Simple mock implementation - just concatenate data and key
        var result = Data()
        result.append(data)
        result.append(key)
        return result
    }

    // Test helper methods
    public func setDecryptedData(_ data: Data, forKey key: Data) {
        let identifier = key.base64EncodedString()
        decryptedData[identifier] = data
    }

    public func reset() {
        encryptedData.removeAll()
        decryptedData.removeAll()
    }
}
