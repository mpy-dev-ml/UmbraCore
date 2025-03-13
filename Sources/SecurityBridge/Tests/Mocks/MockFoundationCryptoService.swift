import Foundation
import SecurityProtocolsCore

/// A mock implementation of FoundationCryptoService for testing
/// This mock provides predetermined responses for testing the adapter
/// pattern without requiring real cryptographic operations.
final class MockFoundationCryptoService: FoundationCryptoServiceImpl, @unchecked Sendable {
    // These properties can be set in tests to control the behavior of the mock

    /// Track method calls for verification
    private let methodCallsLock = NSLock()
    private var _methodCalls: [String] = []
    var methodCalls: [String] {
        methodCallsLock.lock()
        defer { methodCallsLock.unlock() }
        return _methodCalls
    }

    /// When true, functions will fail with a test error
    private let shouldFailLock = NSLock()
    private var _shouldFail = false
    var shouldFail: Bool {
        get {
            shouldFailLock.lock()
            defer { shouldFailLock.unlock() }
            return _shouldFail
        }
        set {
            shouldFailLock.lock()
            defer { shouldFailLock.unlock() }
            _shouldFail = newValue
        }
    }

    /// Specific error to return when shouldFail is true
    private let errorToReturnLock = NSLock()
    private var _errorToReturn: Error = NSError(
        domain: "com.umbra.test",
        code: 999,
        userInfo: [NSLocalizedDescriptionKey: "Test failure"]
    )
    var errorToReturn: Error {
        get {
            errorToReturnLock.lock()
            defer { errorToReturnLock.unlock() }
            return _errorToReturn
        }
        set {
            errorToReturnLock.lock()
            defer { errorToReturnLock.unlock() }
            _errorToReturn = newValue
        }
    }

    /// Data to return for specific operations
    private let encryptedDataLock = NSLock()
    private var _encryptedData: Data?
    var encryptedData: Data? {
        get {
            encryptedDataLock.lock()
            defer { encryptedDataLock.unlock() }
            return _encryptedData
        }
        set {
            encryptedDataLock.lock()
            defer { encryptedDataLock.unlock() }
            _encryptedData = newValue
        }
    }

    private let decryptedDataLock = NSLock()
    private var _decryptedData: Data?
    var decryptedData: Data? {
        get {
            decryptedDataLock.lock()
            defer { decryptedDataLock.unlock() }
            return _decryptedData
        }
        set {
            decryptedDataLock.lock()
            defer { decryptedDataLock.unlock() }
            _decryptedData = newValue
        }
    }

    private let hashedDataLock = NSLock()
    private var _hashedData: Data?
    var hashedData: Data? {
        get {
            hashedDataLock.lock()
            defer { hashedDataLock.unlock() }
            return _hashedData
        }
        set {
            hashedDataLock.lock()
            defer { hashedDataLock.unlock() }
            _hashedData = newValue
        }
    }

    private let keyDataToReturnLock = NSLock()
    private var _keyDataToReturn: Data?
    var keyDataToReturn: Data? {
        get {
            keyDataToReturnLock.lock()
            defer { keyDataToReturnLock.unlock() }
            return _keyDataToReturn
        }
        set {
            keyDataToReturnLock.lock()
            defer { keyDataToReturnLock.unlock() }
            _keyDataToReturn = newValue
        }
    }

    /// Helper function to generate random key data
    private func generateRandomKey() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32)
        for i in 0 ..< bytes.count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return Data(bytes)
    }

    /// Adds a method call to the tracking array
    private func trackMethodCall(_ method: String) {
        methodCallsLock.lock()
        defer { methodCallsLock.unlock() }
        _methodCalls.append(method)
    }

    // MARK: - FoundationCryptoService Protocol Implementation

    func encrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        trackMethodCall("encrypt")
        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return provided encrypted data or generate mock encrypted data
        if let encryptedData {
            return .success(encryptedData)
        } else {
            // Create a simple mock encryption by XORing with the first byte of the key
            if let firstByte = key.first {
                var result = Data(count: data.count)
                for i in 0 ..< data.count {
                    result[i] = data[i] ^ firstByte
                }
                return .success(result)
            } else {
                return .success(data) // Just return the data if no key
            }
        }
    }

    func decrypt(data: Data, using _: Data) async -> Result<Data, Error> {
        trackMethodCall("decrypt")
        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return provided decrypted data or original data
        let result = decryptedData ?? data // For testing, just return data as-is by default
        return .success(result)
    }

    func generateKey() async -> Result<Data, Error> {
        trackMethodCall("generateKey")
        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return provided key data or generate random key
        let resultData = keyDataToReturn ?? generateRandomKey()
        return .success(resultData)
    }

    // MARK: - Hash and Verify

    func hash(data _: Data) async -> Result<Data, Error> {
        trackMethodCall("hash")
        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return provided hashed data or generate mock hash
        let result = hashedData ?? Data([0, 1, 2, 3]) // Simple mock hash
        return .success(result)
    }

    func verify(data: Data, against hash: Data) async -> Bool {
        trackMethodCall("verify")
        if shouldFail {
            return false
        }

        // For simplicity, just compare the first few bytes of the data with the hash
        if data.isEmpty || hash.isEmpty {
            return false
        }

        // Simple verification - compare first byte of data with first byte of hash
        if !data.isEmpty, !hash.isEmpty {
            return data[0] == hash[0]
        }

        return false
    }

    // MARK: - Symmetric Encryption/Decryption

    func encryptSymmetric(
        data: Data,
        key: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        iv _: Data?,
        aad _: Data?,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("encryptSymmetric")
        if shouldFail {
            return FoundationSecurityResult(errorCode: 999, errorMessage: "Test failure")
        }

        // Create mock encrypted data
        var result: Data = if let encryptedData {
            encryptedData
        } else {
            // Simple mock encryption by XORing with the first byte of the key
            if let firstByte = key.first {
                Data(data.map { $0 ^ firstByte })
            } else {
                data // No encryption if no key
            }
        }

        return FoundationSecurityResult(data: result)
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
        trackMethodCall("decryptSymmetric")
        if shouldFail {
            return FoundationSecurityResult(errorCode: 999, errorMessage: "Test failure")
        }

        // Return provided decrypted data or mock decryption
        var result: Data = if let decryptedData {
            decryptedData
        } else {
            // The "decryption" is the same as the encryption for this mock
            if let firstByte = key.first {
                Data(data.map { $0 ^ firstByte })
            } else {
                data // No decryption if no key
            }
        }

        return FoundationSecurityResult(data: result)
    }

    // MARK: - Asymmetric Encryption/Decryption

    func encryptAsymmetric(
        data: Data,
        publicKey: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("encryptAsymmetric")
        if shouldFail {
            return FoundationSecurityResult(errorCode: 999, errorMessage: "Test failure")
        }

        // Create mock encrypted data
        var result: Data = if let encryptedData {
            encryptedData
        } else {
            // Simple mock encryption by XORing with the first byte of the publicKey
            if let firstByte = publicKey.first {
                Data(data.map { $0 ^ firstByte })
            } else {
                data // No encryption if no key
            }
        }

        return FoundationSecurityResult(data: result)
    }

    func decryptAsymmetric(
        data: Data,
        privateKey: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("decryptAsymmetric")
        if shouldFail {
            return FoundationSecurityResult(errorCode: 999, errorMessage: "Test failure")
        }

        // Return provided decrypted data or mock decryption
        var result: Data = if let decryptedData {
            decryptedData
        } else {
            // The "decryption" is the same as the encryption for this mock
            if let firstByte = privateKey.first {
                Data(data.map { $0 ^ firstByte })
            } else {
                data // No decryption if no key
            }
        }

        return FoundationSecurityResult(data: result)
    }

    // MARK: - Hashing and Verification

    func hash(
        data: Data,
        algorithm _: String,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("hash")
        if shouldFail {
            return FoundationSecurityResult(errorCode: 999, errorMessage: "Test failure")
        }

        // Return provided hashed data or mock hash
        var hashData: Data
        if let hashedData {
            hashData = hashedData
        } else {
            // Create a different hash based on the data
            hashData = Data(count: 32) // Default 32 bytes (256 bits)

            // Create a different pattern based on the algorithm
            let seed = "MockHash".utf8.reduce(0) { $0 &+ UInt8($1) }

            for i in 0 ..< hashData.count {
                hashData[i] = data.reduce(seed + UInt8(i)) { $0 &+ $1 }
            }
        }

        return FoundationSecurityResult(data: hashData)
    }

    // MARK: - Utility Methods

    private func generateMockEncryptedData(from data: Data) -> Data {
        // Add a 16-byte IV and a 16-byte auth tag for simulating AES-GCM
        var bytes = [UInt8](repeating: 0, count: data.count + 32)

        // Copy the actual data, slightly modified
        for i in 0 ..< data.count {
            let index = i + 16 // After IV
            bytes[index] = data[i] ^ 0x42 // Simple XOR with a constant
        }

        // Simulated auth tag at the end (just some garbage bytes)
        for i in 0 ..< 16 {
            bytes[data.count + 16 + i] = UInt8(i * 10)
        }

        return Data(bytes)
    }
}
