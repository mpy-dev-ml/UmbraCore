import XCTest
import UmbraTestKit

final class MockCryptoServiceTests: CryptoTestCase {
    var cryptoService: MockCryptoService!
    
    override func setUp() async throws {
        try await super.setUp()
        cryptoService = MockCryptoService()
    }
    
    override func tearDown() async throws {
        cryptoService.reset()
        cryptoService = nil
        try await super.tearDown()
    }
    
    func testEncryptDecryptRoundTrip() throws {
        // Arrange
        let originalData = "Hello, World!".data(using: .utf8)!
        let key = createTestEncryptionKey()
        
        // Act & Assert
        try verifyEncryptionRoundTrip(
            original: originalData,
            encrypt: { try self.cryptoService.encrypt($0, with: key) },
            decrypt: { try self.cryptoService.decrypt($0, with: key) }
        )
        
        // Verify call counts
        XCTAssertEqual(cryptoService.encryptCallCount, 1)
        XCTAssertEqual(cryptoService.decryptCallCount, 1)
    }
    
    func testCustomEncryptHandler() throws {
        // Arrange
        let originalData = "Hello, World!".data(using: .utf8)!
        let key = createTestEncryptionKey()
        var encryptCalled = false
        
        cryptoService.encryptHandler = { data, encryptKey in
            encryptCalled = true
            XCTAssertEqual(data, originalData)
            XCTAssertEqual(encryptKey, key)
            return Data(repeating: 0xFF, count: data.count) // Custom encrypted data
        }
        
        // Act
        let encrypted = try cryptoService.encrypt(originalData, with: key)
        
        // Assert
        XCTAssertTrue(encryptCalled)
        XCTAssertEqual(encrypted, Data(repeating: 0xFF, count: originalData.count))
        XCTAssertEqual(cryptoService.encryptCallCount, 1)
    }
    
    func testEncryptError() throws {
        // Arrange
        let originalData = "Hello, World!".data(using: .utf8)!
        let key = createTestEncryptionKey()
        let expectedError = NSError(domain: "Test", code: 123, userInfo: nil)
        cryptoService.encryptError = expectedError
        
        // Act & Assert
        XCTAssertThrowsError(try cryptoService.encrypt(originalData, with: key)) { error in
            XCTAssertEqual((error as NSError).domain, expectedError.domain)
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        
        XCTAssertEqual(cryptoService.encryptCallCount, 1)
    }
    
    func testGenerateKey() throws {
        // Arrange
        let keySize = 32
        
        // Act
        let key = try cryptoService.generateKey(size: keySize)
        
        // Assert
        XCTAssertEqual(key.count, keySize)
        XCTAssertEqual(cryptoService.generateKeyCallCount, 1)
    }
    
    func testHashData() throws {
        // Arrange
        let data1 = "Hello".data(using: .utf8)!
        let data2 = "Hello".data(using: .utf8)!
        let data3 = "World".data(using: .utf8)!
        
        // Act
        let hash1 = try cryptoService.hashData(data1)
        let hash2 = try cryptoService.hashData(data2)
        let hash3 = try cryptoService.hashData(data3)
        
        // Assert
        XCTAssertEqual(hash1, hash2, "Same data should produce same hash")
        XCTAssertNotEqual(hash1, hash3, "Different data should produce different hash")
        XCTAssertEqual(cryptoService.hashDataCallCount, 3)
    }
}
