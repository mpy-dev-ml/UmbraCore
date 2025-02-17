@testable import UmbraKeychainService
import XCTest

final class KeychainXPCServiceTests: XCTestCase {
    private var proxy: (any KeychainXPCProtocol)!
    let testAccount = "test_account"
    let testService = "test_service"
    let testData = "test_data".data(using: .utf8)!

    override func setUp() async throws {
        try await super.setUp()
        proxy = try await MockXPCServiceHelper.getServiceProxy()
    }

    override func tearDown() async throws {
        await MockXPCServiceHelper.reset()
        proxy = nil
        try await super.tearDown()
    }

    func testBasicOperations() async throws {
        // Test adding item
        try await proxy.addItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?,
            data: testData
        )

        // Test reading item
        let retrievedData = try await proxy.retrieveItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?
        )
        XCTAssertEqual(retrievedData, testData)

        // Test updating item
        let updatedData = "updated_data".data(using: .utf8)!
        try await proxy.updateItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?,
            data: updatedData
        )

        // Verify update
        let updatedRetrievedData = try await proxy.retrieveItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?
        )
        XCTAssertEqual(updatedRetrievedData, updatedData)

        // Test removing item
        try await proxy.removeItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?
        )

        // Verify removal
        do {
            _ = try await proxy.retrieveItem(
                account: testAccount,
                service: testService,
                accessGroup: nil as String?
            )
            XCTFail("Item should have been removed")
        } catch KeychainError.itemNotFound {
            // Expected error
        }
    }

    func testConcurrentOperations() async throws {
        let iterations = 5
        let testService = self.testService // Capture testService value

        // Concurrent additions
        try await withThrowingTaskGroup(of: Void.self) { [testService] group in
            for i in 0..<iterations {
                group.addTask {
                    let account = "concurrent_\(i)"
                    let data = "data_\(i)".data(using: .utf8)!
                    try await self.proxy.addItem(
                        account: account,
                        service: testService,
                        accessGroup: nil as String?,
                        data: data
                    )
                }
            }
            try await group.waitForAll()
        }

        // Verify all items
        for i in 0..<iterations {
            let account = "concurrent_\(i)"
            let expectedData = "data_\(i)".data(using: .utf8)!
            let retrievedData = try await proxy.retrieveItem(
                account: account,
                service: testService,
                accessGroup: nil as String?
            )
            XCTAssertEqual(retrievedData, expectedData)
        }

        // Concurrent updates
        try await withThrowingTaskGroup(of: Void.self) { [testService] group in
            for i in 0..<iterations {
                group.addTask {
                    let account = "concurrent_\(i)"
                    let updatedData = "updated_\(i)".data(using: .utf8)!
                    try await self.proxy.updateItem(
                        account: account,
                        service: testService,
                        accessGroup: nil as String?,
                        data: updatedData
                    )
                }
            }
            try await group.waitForAll()
        }

        // Verify updates
        for i in 0..<iterations {
            let account = "concurrent_\(i)"
            let expectedData = "updated_\(i)".data(using: .utf8)!
            let retrievedData = try await proxy.retrieveItem(
                account: account,
                service: testService,
                accessGroup: nil as String?
            )
            XCTAssertEqual(retrievedData, expectedData)
        }

        // Clean up
        for i in 0..<iterations {
            let account = "concurrent_\(i)"
            try await proxy.removeItem(
                account: account,
                service: testService,
                accessGroup: nil as String?
            )
        }
    }

    func testErrorHandling() async throws {
        // Test duplicate item
        try await proxy.addItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?,
            data: testData
        )

        do {
            try await proxy.addItem(
                account: testAccount,
                service: testService,
                accessGroup: nil as String?,
                data: testData
            )
            XCTFail("Should throw duplicate item error")
        } catch KeychainError.duplicateItem {
            // Expected error
        }

        // Test item not found
        do {
            _ = try await proxy.retrieveItem(
                account: "nonexistent",
                service: testService,
                accessGroup: nil as String?
            )
            XCTFail("Should throw item not found error")
        } catch KeychainError.itemNotFound {
            // Expected error
        }

        // Clean up
        try await proxy.removeItem(
            account: testAccount,
            service: testService,
            accessGroup: nil as String?
        )
    }
}
