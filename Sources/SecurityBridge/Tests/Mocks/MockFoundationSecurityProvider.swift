// MockFoundationSecurityProvider.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecureBytes
import SecurityBridge
import SecurityProtocolsCore

/// A mock implementation of FoundationCryptoService for testing
final class MockFoundationCryptoService: FoundationCryptoService, @unchecked Sendable {

    // MARK: - Test Control Properties

    /// Track method calls for verification
    private let methodCallsLock = NSLock()
    private var _methodCalls: [String] = []
    var methodCalls: [String] {
        get {
            methodCallsLock.lock()
            defer { methodCallsLock.unlock() }
            return _methodCalls
        }
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
            _shouldFail = newValue
            shouldFailLock.unlock()
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockCryptoServiceError", code: 200, userInfo: [
        NSLocalizedDescriptionKey: "Mock crypto operation failed"
    ])

    /// Data to return from operations
    var dataToReturn: Data?

    // MARK: - Initialization

    init() {
        self.shouldFail = false
        self.dataToReturn = Data(repeating: 0xCD, count: 32) // Default test data
    }

    // MARK: - Tracking

    private func trackMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - Basic Cryptographic Operations

    func encrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        trackMethodCall("encrypt(data:using:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xFF, count: data.count + 16))
    }

    func decrypt(data: Data, using key: Data) async -> Result<Data, Error> {
        trackMethodCall("decrypt(data:using:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xAA, count: max(data.count - 16, 0)))
    }

    func generateKey() async -> Result<Data, Error> {
        trackMethodCall("generateKey()")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xAB, count: 32))
    }

    func hash(data: Data) async -> Result<Data, Error> {
        trackMethodCall("hash(data:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xBB, count: 32))
    }

    func verify(data: Data, against hash: Data) async -> Bool {
        trackMethodCall("verify(data:against:)")
        if shouldFail {
            return false
        }
        // Simple mock verification - in real implementation would compare hashed data against provided hash
        return true
    }

    // MARK: - Symmetric Cryptography

    func encryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("encryptSymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xCC, count: data.count + 16))
    }

    func decryptSymmetric(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("decryptSymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xDD, count: max(data.count - 16, 0)))
    }

    // MARK: - Asymmetric Cryptography

    func encryptAsymmetric(
        data: Data,
        publicKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("encryptAsymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xEE, count: data.count + 32))
    }

    func decryptAsymmetric(
        data: Data,
        privateKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("decryptAsymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xFF, count: max(data.count - 32, 0)))
    }

    // MARK: - Advanced Hashing

    func hash(
        data: Data,
        algorithm: String,
        options: [String: String]
    ) async -> FoundationSecurityResult {
        trackMethodCall("hash(data:algorithm:options:)")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        // Different hash lengths based on algorithm
        let hashLength: Int
        switch algorithm.lowercased() {
        case "sha256":
            hashLength = 32
        case "sha512":
            hashLength = 64
        default:
            hashLength = 32 // Default to SHA-256 length
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xAA, count: hashLength))
    }
}

/// A mock implementation of FoundationSecurityProvider for testing
final class MockFoundationSecurityProvider: FoundationSecurityProvider, @unchecked Sendable {

    // MARK: - Service Properties

    private let mockKeyManager: MockFoundationKeyManagement
    private let mockCryptoService: MockFoundationCryptoService

    public var cryptoService: any FoundationCryptoService {
        return mockCryptoService
    }

    public var keyManager: any FoundationKeyManagement {
        return mockKeyManager
    }

    // MARK: - Test Control Properties

    /// Track method calls for verification
    private let methodCallsLock = NSLock()
    private var _methodCalls: [String] = []
    var methodCalls: [String] {
        get {
            methodCallsLock.lock()
            defer { methodCallsLock.unlock() }
            return _methodCalls
        }
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
            _shouldFail = newValue
            shouldFailLock.unlock()

            // Also set shouldFail on child services
            mockKeyManager.shouldFail = newValue
            mockCryptoService.shouldFail = newValue
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockSecurityError", code: 100, userInfo: [
        NSLocalizedDescriptionKey: "Mock security operation failed"
    ])

    /// Data to return from operations
    var dataToReturn: Data? {
        didSet {
            // Also update data on child services
            mockCryptoService.dataToReturn = dataToReturn
            mockKeyManager.keyDataToReturn = dataToReturn
        }
    }

    // MARK: - Initialization

    init() {
        self.mockKeyManager = MockFoundationKeyManagement()
        self.mockCryptoService = MockFoundationCryptoService()
    }

    // MARK: - Tracking

    private func trackMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - FoundationSecurityProvider Implementation

    func performOperation(
        operation: String,
        options: [String: Any]
    ) async -> FoundationSecurityProviderResult {
        trackMethodCall("performOperation:\(operation)")

        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return success with the configured data
        return .success(dataToReturn)
    }
}

/// A mock implementation of FoundationKeyManagement for testing
final class MockFoundationKeyManagement: FoundationKeyManagement, @unchecked Sendable {

    // MARK: - Test Control Properties

    /// Track method calls for verification
    private let methodCallsLock = NSLock()
    private var _methodCalls: [String] = []
    var methodCalls: [String] {
        get {
            methodCallsLock.lock()
            defer { methodCallsLock.unlock() }
            return _methodCalls
        }
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
            _shouldFail = newValue
            shouldFailLock.unlock()
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockKeyManagementError", code: 100, userInfo: [
        NSLocalizedDescriptionKey: "Mock key management operation failed"
    ])

    /// Key data to return from operations
    var keyDataToReturn: Data?

    // MARK: - Initialization

    init() {
        self.shouldFail = false
        self.keyDataToReturn = Data(repeating: 0xAB, count: 32) // Default test key
    }

    // MARK: - Tracking

    private func trackMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - FoundationKeyManagement Implementation

    func generateKey(type: String, size: Int) async -> Result<Data, Error> {
        trackMethodCall("generateKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(keyDataToReturn ?? Data(repeating: 0, count: size / 8))
    }

    func storeKey(_ key: Data, withIdentifier identifier: String) async -> Result<Void, Error> {
        trackMethodCall("storeKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(())
    }

    func retrieveKey(withIdentifier identifier: String) async -> Result<Data, Error> {
        trackMethodCall("retrieveKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(keyDataToReturn ?? Data(repeating: 0, count: 32))
    }

    func deleteKey(withIdentifier identifier: String) async -> Result<Void, Error> {
        trackMethodCall("deleteKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(())
    }

    func rotateKey(withIdentifier identifier: String, dataToReencrypt: Data?) async -> Result<(newKey: Data, reencryptedData: Data?), Error> {
        trackMethodCall("rotateKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        let newKey = keyDataToReturn ?? Data(repeating: 0xCD, count: 32)
        return .success((newKey: newKey, reencryptedData: dataToReencrypt))
    }

    func listKeyIdentifiers() async -> Result<[String], Error> {
        trackMethodCall("listKeyIdentifiers")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(["test-key-1", "test-key-2"])
    }
}
