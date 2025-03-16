import CoreErrors
import CryptoTypes
import CryptoTypesProtocols
import CryptoTypesTypes
import Foundation
import SecurityTypes
import UmbraCoreTypes
import UmbraMocks
import XPCProtocolsCore

// Counter actor to safely manage the incrementing key counter
private actor KeyCounter {
    private var value: Int = 0

    func increment() -> Int {
        value += 1
        return value
    }
}

// Test implementation of CryptoService for the tests
public final class CryptoService: CryptoServiceProtocol, @unchecked Sendable {
    public let config: CryptoConfiguration
    private let counter = KeyCounter()

    public init(config: CryptoConfiguration) {
        self.config = config
    }

    public func generateSecureRandomKey(length: Int) async throws -> Data {
        // Generate a different pattern each time to make random key tests pass
        let currentCounter = await counter.increment()

        // Create a deterministic but different pattern for each call
        var keyData = Data(repeating: 0xA5, count: length)

        // Modify the first few bytes to make each key unique
        let counterBytes = withUnsafeBytes(of: currentCounter) { Data($0) }
        for i in 0 ..< min(counterBytes.count, keyData.count) {
            keyData[i] = counterBytes[i]
        }

        return keyData
    }

    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        if key.count < config.keyLength / 8 {
            throw CryptoError.invalidKeyLength(expected: config.keyLength / 8, actual: key.count)
        }

        // Simple mock encryption - just append the key and IV for verification
        var encrypted = Data()
        encrypted.append(data)
        encrypted.append(iv)
        encrypted.append(key)
        return encrypted
    }

    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        if key.count < config.keyLength / 8 {
            throw CryptoError.invalidKeyLength(expected: config.keyLength / 8, actual: key.count)
        }

        // Check if this is data we "encrypted"
        if data.count > (key.count + iv.count) {
            return data.subdata(in: 0 ..< (data.count - key.count - iv.count))
        }

        // If not our encrypted data, throw an error
        throw CryptoError.decryptionError("Invalid ciphertext format")
    }

    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        // Create a deterministic "key" from the inputs
        guard let passwordData = password.data(using: .utf8) else {
            throw CryptoError.invalidKey(reason: "Invalid password encoding")
        }

        var combined = passwordData
        combined.append(salt)
        let iterData = withUnsafeBytes(of: iterations) { Data($0) }
        combined.append(iterData)

        // Return a hash-like result
        return combined.prefix(32)
    }

    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        // Simply combine the data and key for a predictable result
        var hmac = Data()
        hmac.append(data)
        hmac.append(key)
        return hmac.prefix(32) // Return a fixed size HMAC
    }
}

// Simpler CredentialManager implementation for tests
public actor CredentialManager {
    private let cryptoService: CryptoServiceProtocol
    private let keychain: SecureStorageServiceProtocol

    public init(cryptoService: CryptoServiceProtocol, keychain: SecureStorageServiceProtocol) {
        self.cryptoService = cryptoService
        self.keychain = keychain
    }

    public func store(credential: String, withIdentifier identifier: String) async throws {
        guard let data = credential.data(using: .utf8) else {
            throw CryptoError.encodingError("Failed to encode credential")
        }

        let key = try await generateOrRetrieveMasterKey()
        let iv = try await cryptoService.generateSecureRandomKey(length: 12)
        let encryptedData = try await cryptoService.encrypt(data, using: key, iv: iv)

        // Store IV with the encrypted data
        var dataToStore = iv
        dataToStore.append(encryptedData)

        // Convert to SecureBytes by copying each byte
        var bytes = [UInt8](repeating: 0, count: dataToStore.count)
        dataToStore.copyBytes(to: &bytes, count: dataToStore.count)
        let secureBytes = SecureBytes(bytes: bytes)

        let result = await keychain.storeData(secureBytes, identifier: identifier, metadata: nil)

        if case let .failure(error) = result {
            throw CryptoError.keyStorageError(reason: "Failed to store data: \(error)")
        }
    }

    public func exists(withIdentifier identifier: String) async -> Bool {
        let result = await keychain.retrieveData(identifier: identifier)

        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public func retrieve<T: Decodable>(withIdentifier identifier: String) async throws -> T {
        let result = await keychain.retrieveData(identifier: identifier)

        switch result {
        case let .success(secureBytes):
            // Convert SecureBytes to Data by copying each byte
            var bytes = [UInt8](repeating: 0, count: secureBytes.count)
            for i in 0 ..< secureBytes.count {
                bytes[i] = secureBytes[i]
            }
            let data = Data(bytes)

            let key = try await generateOrRetrieveMasterKey()

            // Extract IV from the beginning of the data
            let iv = data.prefix(12)
            let encryptedData = data.dropFirst(12)

            let decryptedData = try await cryptoService.decrypt(encryptedData, using: key, iv: iv)

            if let string = String(data: decryptedData, encoding: .utf8), T.self is String.Type {
                return string as! T
            }

            throw CryptoError.decodingError("Failed to decode data")

        case .failure:
            throw CryptoError.keyNotFound(identifier: identifier)
        }
    }

    public func delete(withIdentifier identifier: String) async throws {
        let result = await keychain.deleteData(identifier: identifier)

        if case let .failure(error) = result {
            throw CryptoError.keyDeletionError(reason: "Failed to delete data: \(error)")
        }
    }

    private func generateOrRetrieveMasterKey() async throws -> Data {
        let masterKeyID = "master_key"
        let result = await keychain.retrieveData(identifier: masterKeyID)

        switch result {
        case let .success(secureBytes):
            // Convert SecureBytes to Data by copying each byte
            var bytes = [UInt8](repeating: 0, count: secureBytes.count)
            for i in 0 ..< secureBytes.count {
                bytes[i] = secureBytes[i]
            }
            return Data(bytes)

        case .failure:
            // Generate a new master key
            let newKey = try await cryptoService.generateSecureRandomKey(length: 32)

            // Convert to SecureBytes
            var bytes = [UInt8](repeating: 0, count: newKey.count)
            newKey.copyBytes(to: &bytes, count: newKey.count)
            let secureBytes = SecureBytes(bytes: bytes)

            let storeResult = await keychain.storeData(secureBytes, identifier: masterKeyID, metadata: nil)
            if case let .failure(error) = storeResult {
                throw CryptoError.keyGenerationError(reason: "Failed to store master key: \(error)")
            }

            return newKey
        }
    }
}

// Define CryptoError for tests
public enum CryptoError: Error, Equatable {
    case encryptionError(String)
    case decryptionError(String)
    case keyGenerationError(reason: String)
    case invalidKey(reason: String)
    case invalidKeyLength(expected: Int, actual: Int)
    case keyNotFound(identifier: String)
    case keyStorageError(reason: String)
    case keyDeletionError(reason: String)
    case encodingError(String)
    case decodingError(String)
}
