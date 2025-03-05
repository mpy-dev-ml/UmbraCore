import Foundation

@testable import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

// MARK: - Result Extension

extension Result {
  var isSuccess: Bool {
    switch self {
      case .success: true
      case .failure: false
    }
  }

  var isFailure: Bool {
    !isSuccess
  }
}

// MARK: - Extensions to SecurityResultDTO for Testing

extension SecurityResultDTO {
  var isSuccess: Bool {
    success
  }

  var isFailure: Bool {
    !success
  }
}

// MARK: - Mock NSXPCConnection

/// A mock NSXPCConnection that returns our mock service as the remoteObjectProxy
class MockXPCConnection: NSXPCConnection {
  private let mockService: MockFoundationXPCSecurityService
  private var _interface: NSXPCInterface?

  init(mockService: MockFoundationXPCSecurityService) {
    self.mockService=mockService
    super.init()
  }

  // Override the remoteObjectInterface property
  override var remoteObjectInterface: NSXPCInterface? {
    get { _interface }
    set { _interface=newValue }
  }

  // Override the remoteObjectProxy property
  override var remoteObjectProxy: Any {
    mockService
  }
}

// MARK: - Error Connection

/// A mock NSXPCConnection that throws an error when accessed
class ErrorConnection: NSXPCConnection {
  enum TestError: Error {
    case testConnectionError
  }

  override var remoteObjectProxy: Any {
    // Create and return an NSObject that will cause an error when used
    NSError(
      domain: "com.umbracore.test",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: "Test connection error"]
    )
  }

  // Instead of making remoteObjectProxy throwing, we'll make a simulated method that causes any
  // remoteObjectProxyWithErrorHandler to immediately call the error handler
  override func remoteObjectProxyWithErrorHandler(_ handler: @escaping (Error) -> Void) -> Any {
    handler(TestError.testConnectionError)
    return NSObject()
  }
}

final class XPCServiceAdapterTests: XCTestCase {

  // MARK: - Properties

  var mockService: MockFoundationXPCSecurityService!
  var adapter: XPCServiceAdapter!

  // MARK: - Setup and Teardown

  override func setUp() {
    super.setUp()
    mockService=MockFoundationXPCSecurityService()

    // Use try/catch to handle potential initialization errors
    do {
      let connection=MockXPCConnection(mockService: mockService)
      adapter=XPCServiceAdapter(connection: connection)
    } catch {
      XCTFail("Failed to initialize XPCServiceAdapter: \(error)")
    }
  }

  override func tearDown() {
    adapter=nil
    mockService=nil
    super.tearDown()
  }

  // MARK: - Adapter Factory Methods Tests

  func testCreateCryptoService() async {
    guard adapter != nil else {
      XCTFail("Adapter is nil")
      return
    }

    // Act
    let cryptoService=adapter.createCryptoService()

    // Assert
    XCTAssertNotNil(cryptoService)
    // Avoid direct type casting which might cause issues if implementation changes
    XCTAssertTrue(
      cryptoService is CryptoServiceProtocol,
      "Crypto service should implement CryptoServiceProtocol"
    )
  }

  func testCreateKeyManagement() async {
    guard adapter != nil else {
      XCTFail("Adapter is nil")
      return
    }

    // Act
    let keyManagement=adapter.createKeyManagement()

    // Assert
    XCTAssertNotNil(keyManagement)
    // Avoid direct type casting which might cause issues if implementation changes
    XCTAssertTrue(
      keyManagement is KeyManagementProtocol,
      "Key management should implement KeyManagementProtocol"
    )
  }

  // MARK: - Error Connection Tests

  func testCreateCryptoServiceWithConnectionError() async {
    // Arrange: We're injecting a connection that will cause errors
    let errorConnection=ErrorConnection()
    let errorAdapter=XPCServiceAdapter(connection: errorConnection)

    // Act: Create crypto service
    // This should not throw but will likely return an adapter that will fail when used
    let cryptoService=errorAdapter.createCryptoService()

    // Assert: The service should be created but will fail when used
    XCTAssertNotNil(cryptoService)
    // Further testing would be performed by trying to use the cryptoService
  }

  func testCreateKeyManagementWithConnectionError() async {
    // Arrange: We're injecting a connection that will cause errors
    let errorConnection=ErrorConnection()
    let errorAdapter=XPCServiceAdapter(connection: errorConnection)

    // Act: Create key management service
    // This should not throw but will likely return an adapter that will fail when used
    let keyManagement=errorAdapter.createKeyManagement()

    // Assert: The service should be created but will fail when used
    XCTAssertNotNil(keyManagement)
    // Further testing would be performed by trying to use the keyManagement
  }

  // MARK: - KeyManagement Tests

  func testKeyManagementListKeys() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    mockService.keyListResponse=["key1", "key2", "key3"]

    // Act
    let result=await keyManagement.listKeyIdentifiers()

    // Assert
    XCTAssertTrue(result.isSuccess)
    if case let .success(keys)=result {
      XCTAssertEqual(keys.count, 3)
      XCTAssertEqual(keys, ["key1", "key2", "key3"])
    } else {
      XCTFail("Expected success result with keys")
    }
  }

  func testKeyManagementListKeysEmpty() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    mockService.keyListResponse=[]

    // Act
    let result=await keyManagement.listKeyIdentifiers()

    // Assert
    XCTAssertTrue(result.isSuccess)
    if case let .success(keys)=result {
      XCTAssertEqual(keys.count, 0)
    } else {
      XCTFail("Expected success result with empty keys")
    }
  }

  func testKeyManagementListKeysFailure() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    mockService.shouldFail=true

    // Act
    let result=await keyManagement.listKeyIdentifiers()

    // Assert
    switch result {
      case .success:
        XCTFail("Should have failed")
      case .failure:
        XCTAssertTrue(true) // Expected failure
    }
  }

  func testKeyManagementRetrieveKey() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="test-key-1"
    let expectedKeyData=Data([UInt8](keyIdentifier.utf8) + [0, 1, 2, 3, 4])
    mockService.keyDataToReturn=expectedKeyData

    // Act
    let result=await keyManagement.retrieveKey(withIdentifier: keyIdentifier)

    // Assert
    XCTAssertTrue(result.isSuccess)
    if case let .success(key)=result {
      XCTAssertEqual(key.bytes(), [UInt8](keyIdentifier.utf8) + [0, 1, 2, 3, 4])
    } else {
      XCTFail("Expected successful key retrieval")
    }
  }

  func testKeyManagementRetrieveKeyFailure() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="non-existent-key"
    mockService.shouldFail=true

    // Act
    let result=await keyManagement.retrieveKey(withIdentifier: keyIdentifier)

    // Assert
    XCTAssertTrue(result.isFailure)
    if case let .failure(error)=result {
      XCTAssertEqual(
        error.localizedDescription.contains("not found") || error.localizedDescription
          .contains("Key not found"),
        true
      )
    } else {
      XCTFail("Expected key retrieval failure")
    }
  }

  func testKeyManagementStoreKey() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="new-test-key"
    let keyToStore=SecureBytes([1, 2, 3, 4, 5])

    // Act
    let result=await keyManagement.storeKey(keyToStore, withIdentifier: keyIdentifier)

    // Assert
    XCTAssertTrue(result.isSuccess)
    if case .success=result {
      // Test passed
    } else {
      XCTFail("Expected store key success")
    }
  }

  func testKeyManagementStoreKeyFailure() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="fail-key"
    let keyToStore=SecureBytes([1, 2, 3, 4, 5])
    mockService.shouldFail=true

    // Act
    let result=await keyManagement.storeKey(keyToStore, withIdentifier: keyIdentifier)

    // Assert
    if case let .failure(error)=result {
      XCTAssertTrue(
        error.localizedDescription.contains("Failed") || error.localizedDescription
          .contains("failed")
      )
    } else {
      XCTFail("Expected store key failure")
    }
  }

  func testKeyManagementDeleteKey() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="delete-test-key"

    // Act
    let result=await keyManagement.deleteKey(withIdentifier: keyIdentifier)

    // Assert
    XCTAssertTrue(result.isSuccess)
    if case .success=result {
      // Test passed
    } else {
      XCTFail("Expected delete key success")
    }
  }

  func testKeyManagementDeleteKeyFailure() async {
    // Arrange
    let keyManagement=adapter.createKeyManagement()
    let keyIdentifier="protected-key"
    mockService.shouldFail=true

    // Act
    let result=await keyManagement.deleteKey(withIdentifier: keyIdentifier)

    // Assert
    if case let .failure(error)=result {
      XCTAssertTrue(
        error.localizedDescription.contains("Cannot") || error.localizedDescription
          .contains("cannot")
      )
    } else {
      XCTFail("Expected delete key failure")
    }
  }

  // MARK: - CryptoService Tests

  func testCryptoServiceSymmetricEncryption() async {
    // Arrange
    let cryptoService=adapter.createCryptoService()
    let inputData=SecureBytes([1, 2, 3, 4, 5])
    let key=SecureBytes([10, 20, 30, 40, 50])

    // Act
    let result=await cryptoService.encryptSymmetric(
      data: inputData,
      key: key,
      config: SecurityConfigDTO(
        algorithm: "AES-GCM",
        keySizeInBits: 256,
        initializationVector: nil,
        additionalAuthenticatedData: nil,
        options: [:]
      )
    )

    // Assert
    XCTAssertTrue(result.success)
    XCTAssertNotNil(result.data)
  }

  func testCryptoServiceSymmetricDecryption() async {
    // Arrange
    let cryptoService=adapter.createCryptoService()
    let ciphertext=SecureBytes([10, 20, 1, 2, 3, 4, 5])
    let key=SecureBytes([10, 20, 30, 40, 50])

    // Act
    let result=await cryptoService.decryptSymmetric(
      data: ciphertext,
      key: key,
      config: SecurityConfigDTO(
        algorithm: "AES-GCM",
        keySizeInBits: 256,
        initializationVector: nil,
        additionalAuthenticatedData: nil,
        options: [:]
      )
    )

    // Assert
    XCTAssertTrue(result.success)
    XCTAssertNotNil(result.data)
  }
}
