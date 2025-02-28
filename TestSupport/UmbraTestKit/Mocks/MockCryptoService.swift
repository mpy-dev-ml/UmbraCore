import CryptoTypes
import CryptoTypesProtocols
import Foundation

public actor MockCryptoService: CryptoServiceProtocol {
    private var encryptedData: [String: Data] = [:]
    private var decryptedData: [String: Data] = [:]

    public init() {}

    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        let identifier = "\(key.hashValue):\(iv.hashValue)"
        encryptedData[identifier] = data
        return data // Mock implementation just returns the original data
    }

    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        let identifier = "\(key.hashValue):\(iv.hashValue)"
        decryptedData[identifier] = data
        return data // Mock implementation just returns the original data
    }

    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        // Mock implementation just returns a deterministic key based on inputs
        let combinedData = password.data(using: .utf8)! + salt
        return Data(combinedData.prefix(32))
    }

    public func generateSecureRandomKey(length: Int) async throws -> Data {
        // Mock implementation returns predictable data for testing
        return Data(repeating: 0xAA, count: length)
    }

    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        // Mock implementation returns predictable HMAC for testing
        return Data(repeating: 0xBB, count: 32)
    }

    // Test helper methods
    public func setDecryptedData(_ data: Data, forKey key: Data, initializationVector: Data) async {
        let identifier = "\(key.base64EncodedString()):\(initializationVector.base64EncodedString())"
        decryptedData[identifier] = data
    }

    public func reset() async {
        encryptedData.removeAll()
        decryptedData.removeAll()
    }
}
