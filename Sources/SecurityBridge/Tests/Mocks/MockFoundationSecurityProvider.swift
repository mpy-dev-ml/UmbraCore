import Foundation
import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes

/// A mock implementation of FoundationCryptoServiceImpl for testing
final class MockFoundationCryptoService: FoundationCryptoServiceImpl, @unchecked Sendable {
    // MARK: - Test Control Properties

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
            _shouldFail = newValue
            shouldFailLock.unlock()
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockCryptoServiceError", code: 200, userInfo: [
        NSLocalizedDescriptionKey: "Mock crypto operation failed",
    ])

    /// Data to return from operations
    var dataToReturn: Data?

    /// Random data to return from generateRandomData
    var randomDataToReturn: Data?

    // MARK: - Initialization

    init() {
        shouldFail = false
        dataToReturn = Data(repeating: 0xCD, count: 32) // Default test data
    }

    // MARK: - Tracking

    private func recordMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - Basic Cryptographic Operations

    func encrypt(data: Data, using _: Data) async -> Result<Data, Error> {
        recordMethodCall("encrypt(data:using:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xFF, count: data.count + 16))
    }

    func decrypt(data: Data, using _: Data) async -> Result<Data, Error> {
        recordMethodCall("decrypt(data:using:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xAA, count: max(data.count - 16, 0)))
    }

    func generateKey() async -> Result<Data, Error> {
        recordMethodCall("generateKey()")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(dataToReturn ?? Data(repeating: 0xAB, count: 32))
    }

    func hash(data: Data) async -> Result<Data, Error> {
        recordMethodCall("hash(data:)")
        if shouldFail {
            return .failure(errorToReturn)
        }
        // Return specific data if configured
        if let dataToReturn {
            return .success(dataToReturn)
        }

        // Default hash implementation (just return data for test purposes)
        return .success(data)
    }

    func generateRandomData(length: Int) async -> Result<Data, Error> {
        recordMethodCall("generateRandomData(length: \(length))")

        if shouldFail {
            return .failure(errorToReturn)
        }

        // Return specific data if configured
        if let randomData = randomDataToReturn {
            return .success(randomData)
        }

        // Default implementation: create a Data object filled with repeating pattern
        var randomData = Data(count: length)
        for i in 0 ..< randomData.count {
            randomData[i] = UInt8(i % 256)
        }
        return .success(randomData)
    }

    func verify(data _: Data, against _: Data) async -> Bool {
        recordMethodCall("verify(data:against:)")
        if shouldFail {
            return false
        }
        // Simple mock verification - in real implementation would compare hashed data against provided
        // hash
        return true
    }

    // MARK: - Symmetric Cryptography

    func encryptSymmetric(
        data: Data,
        key _: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        iv _: Data?,
        aad _: Data?,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        recordMethodCall("encryptSymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(
            repeating: 0xCC,
            count: data.count + 16
        ))
    }

    func decryptSymmetric(
        data: Data,
        key _: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        iv _: Data?,
        aad _: Data?,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        recordMethodCall("decryptSymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(
            repeating: 0xDD,
            count: max(data.count - 16, 0)
        ))
    }

    // MARK: - Asymmetric Cryptography

    func encryptAsymmetric(
        data: Data,
        publicKey _: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        recordMethodCall("encryptAsymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(
            repeating: 0xEE,
            count: data.count + 32
        ))
    }

    func decryptAsymmetric(
        data: Data,
        privateKey _: Data,
        algorithm _: String,
        keySizeInBits _: Int,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        recordMethodCall("decryptAsymmetric()")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(
            repeating: 0xFF,
            count: max(data.count - 32, 0)
        ))
    }

    // MARK: - Advanced Hashing

    func hash(
        data _: Data,
        algorithm: String,
        options _: [String: String]
    ) async -> FoundationSecurityResult {
        recordMethodCall("hash(data:algorithm:options:)")

        if shouldFail {
            return FoundationSecurityResult(
                errorCode: (errorToReturn as NSError).code,
                errorMessage: (errorToReturn as NSError).localizedDescription
            )
        }

        // Different hash lengths based on algorithm
        let hashLength = switch algorithm.lowercased() {
        case "sha256":
            32
        case "sha512":
            64
        default:
            32 // Default to SHA-256 length
        }

        return FoundationSecurityResult(data: dataToReturn ?? Data(repeating: 0xAA, count: hashLength))
    }
}

/// A mock implementation of FoundationSecurityProvider for testing
final class MockFoundationSecurityProvider: FoundationSecurityProvider, @unchecked Sendable {
    // MARK: - Service Properties

    private let mockKeyManager: MockFoundationKeyManagement
    private let mockCryptoService: MockFoundationCryptoService

    public var cryptoService: any FoundationCryptoServiceImpl {
        mockCryptoService
    }

    public var keyManager: any FoundationKeyManagementImpl {
        mockKeyManager
    }

    // MARK: - Test Control Properties

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
            _shouldFail = newValue
            shouldFailLock.unlock()

            // Also set shouldFail on child services
            mockKeyManager.shouldFail = newValue
            mockCryptoService.shouldFail = newValue
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockSecurityError", code: 100, userInfo: [
        NSLocalizedDescriptionKey: "Mock security operation failed",
    ])

    /// Data to return from operations
    var dataToReturn: Data? {
        didSet {
            // Also update data on child services
            mockCryptoService.dataToReturn = dataToReturn
            mockKeyManager.keyDataToReturn = dataToReturn
        }
    }
    
    /// Flag to control test behaviour for config creation
    var configCreationCompleted = true

    // MARK: - Initialization

    init() {
        mockKeyManager = MockFoundationKeyManagement()
        mockCryptoService = MockFoundationCryptoService()
    }

    // MARK: - Tracking

    private func recordMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - FoundationSecurityProvider Implementation

    func performOperation(
        operation: String,
        options _: [String: Any]
    ) async -> Result<Data?, Error> {
        recordMethodCall("performOperation:\(operation)")

        // Ensure we don't hang by forcing immediate return
        // This helps avoid deadlocks in tests
        return await withTaskCancellationHandler {
            if shouldFail {
                return .failure(errorToReturn)
            }

            // Return success with the configured data
            return .success(dataToReturn)
        } onCancel: {
            // If task is cancelled, ensure we have a way to clean up
            print("Security operation task was cancelled")
        }
    }
}

/// A mock implementation of FoundationKeyManagementImpl for testing
final class MockFoundationKeyManagement: FoundationKeyManagementImpl, @unchecked Sendable {
    // MARK: - Test Control Properties

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
            _shouldFail = newValue
            shouldFailLock.unlock()
        }
    }

    /// Test error to return when shouldFail is true
    var errorToReturn: Error = NSError(domain: "MockKeyManagementError", code: 100, userInfo: [
        NSLocalizedDescriptionKey: "Mock key management operation failed",
    ])

    /// Key data to return from operations
    var keyDataToReturn: Data?

    // MARK: - Initialization

    init() {
        shouldFail = false
        keyDataToReturn = Data(repeating: 0xAB, count: 32) // Default test key
    }

    // MARK: - Tracking

    private func recordMethodCall(_ method: String) {
        methodCallsLock.lock()
        _methodCalls.append(method)
        methodCallsLock.unlock()
    }

    // MARK: - FoundationKeyManagement Implementation

    func generateKey(type _: String, size: Int) async -> Result<Data, Error> {
        recordMethodCall("generateKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(keyDataToReturn ?? Data(repeating: 0, count: size / 8))
    }

    func storeKey(_: Data, withIdentifier _: String) async -> Result<Void, Error> {
        recordMethodCall("storeKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(())
    }

    func retrieveKey(withIdentifier _: String) async -> Result<Data, Error> {
        recordMethodCall("retrieveKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(keyDataToReturn ?? Data(repeating: 0, count: 32))
    }

    func deleteKey(withIdentifier _: String) async -> Result<Void, Error> {
        recordMethodCall("deleteKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(())
    }

    func rotateKey(withIdentifier _: String, newKey _: Data) async -> Result<Void, Error> {
        recordMethodCall("rotateKey")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(())
    }

    func listKeyIdentifiers() async -> Result<[String], Error> {
        recordMethodCall("listKeyIdentifiers")
        if shouldFail {
            return .failure(errorToReturn)
        }
        return .success(["test-key-1", "test-key-2"])
    }
}
