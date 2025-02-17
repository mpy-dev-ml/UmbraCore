import XCTest
import Security
@testable import UmbraKeychainService

final class KeychainServiceTests: XCTestCase {
    var keychainService: KeychainService!
    let testService = "com.umbracore.tests"
    let testAccount = "testAccount"
    let testData = "Test data string".data(using: .utf8)!
    
    override func setUp() async throws {
        try await super.setUp()
        keychainService = KeychainService()
        // Clean up any existing test items
        try? await keychainService.deleteItem(account: testAccount, service: testService, accessGroup: nil)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        // Clean up test items
        try? await keychainService.deleteItem(account: testAccount, service: testService, accessGroup: nil)
        keychainService = nil
    }
    
    func testAddItem() async throws {
        // Test adding a new item
        try await keychainService.addItem(
            testData,
            account: testAccount,
            service: testService,
            accessGroup: nil,
            accessibility: kSecAttrAccessibleWhenUnlocked,
            flags: []
        )
        
        // Verify item exists
        let exists = await keychainService.containsItem(
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        XCTAssertTrue(exists)
        
        // Verify data matches
        let retrievedData = try await keychainService.readItem(
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        XCTAssertEqual(retrievedData, testData)
    }
    
    func testUpdateItem() async throws {
        // First add an item
        try await keychainService.addItem(
            testData,
            account: testAccount,
            service: testService,
            accessGroup: nil,
            accessibility: kSecAttrAccessibleWhenUnlocked,
            flags: []
        )
        
        // Update with new data
        let updatedData = "Updated test data".data(using: .utf8)!
        try await keychainService.updateItem(
            updatedData,
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        
        // Verify updated data
        let retrievedData = try await keychainService.readItem(
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        XCTAssertEqual(retrievedData, updatedData)
    }
    
    func testDeleteItem() async throws {
        // First add an item
        try await keychainService.addItem(
            testData,
            account: testAccount,
            service: testService,
            accessGroup: nil,
            accessibility: kSecAttrAccessibleWhenUnlocked,
            flags: []
        )
        
        // Delete the item
        try await keychainService.deleteItem(
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        
        // Verify item no longer exists
        let exists = await keychainService.containsItem(
            account: testAccount,
            service: testService,
            accessGroup: nil
        )
        XCTAssertFalse(exists)
    }
    
    func testReadNonexistentItem() async throws {
        do {
            _ = try await keychainService.readItem(
                account: "nonexistent",
                service: testService,
                accessGroup: nil
            )
            XCTFail("Expected error not thrown")
        } catch let error as KeychainError {
            if case .itemNotFound = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testDuplicateItem() async throws {
        // Add initial item
        try await keychainService.addItem(
            testData,
            account: testAccount,
            service: testService,
            accessGroup: nil,
            accessibility: kSecAttrAccessibleWhenUnlocked,
            flags: []
        )
        
        // Attempt to add duplicate
        do {
            try await keychainService.addItem(
                testData,
                account: testAccount,
                service: testService,
                accessGroup: nil,
                accessibility: kSecAttrAccessibleWhenUnlocked,
                flags: []
            )
            XCTFail("Expected error not thrown")
        } catch let error as KeychainError {
            if case .duplicateItem = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testUpdateNonexistentItem() async throws {
        do {
            try await keychainService.updateItem(
                testData,
                account: "nonexistent",
                service: testService,
                accessGroup: nil
            )
            XCTFail("Expected error not thrown")
        } catch let error as KeychainError {
            if case .itemNotFound = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testAccessControlFlags() async throws {
        // Test various access control configurations
        let configurations: [(CFString, SecAccessControlCreateFlags)] = [
            (kSecAttrAccessibleWhenUnlocked, []),
            (kSecAttrAccessibleWhenUnlockedThisDeviceOnly, SecAccessControlCreateFlags(rawValue: 1)),
            (kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, SecAccessControlCreateFlags(rawValue: 3))
        ]
        
        for (index, config) in configurations.enumerated() {
            let account = "\(testAccount)_\(index)"
            
            try await keychainService.addItem(
                testData,
                account: account,
                service: testService,
                accessGroup: nil,
                accessibility: config.0,
                flags: config.1
            )
            
            let exists = await keychainService.containsItem(
                account: account,
                service: testService,
                accessGroup: nil
            )
            XCTAssertTrue(exists)
            
            try await keychainService.deleteItem(
                account: account,
                service: testService,
                accessGroup: nil
            )
        }
    }
}
