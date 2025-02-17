import XCTest
import Security
@testable import UmbraKeychainService

final class KeychainServiceTests: XCTestCase {
    private static var sharedService: KeychainService?
    private var keychainService: KeychainService!
    let testService = "com.umbracore.tests"
    let testAccount = "testAccount"
    let testData = "Test data string".data(using: .utf8)!

    override class func setUp() {
        super.setUp()
        // Start XPC service at the class level
        let expectation = XCTestExpectation(description: "XPC Service Started")
        Task {
            do {
                try await XPCServiceHelper.startService()
                // Create a shared service instance
                sharedService = KeychainService(enableXPC: true, accessGroup: nil)
                expectation.fulfill()
            } catch {
                XCTFail("Failed to start XPC service: \(error)")
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 15.0)
        if result != .completed {
            XCTFail("Failed to start XPC service within timeout")
        }
    }

    override class func tearDown() {
        let expectation = XCTestExpectation(description: "XPC Service Stopped")
        Task {
            do {
                // Ensure all connections are cleaned up
                sharedService = nil
                try await Task.sleep(nanoseconds: 100_000_000) // Brief pause to allow connections to close
                await XPCServiceHelper.stopService()
                expectation.fulfill()
            } catch {
                XCTFail("Failed to stop XPC service: \(error)")
            }
        }
        let result = XCTWaiter().wait(for: [expectation], timeout: 15.0)
        if result != .completed {
            XCTFail("Failed to stop XPC service within timeout")
        }
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()

        // Use the shared service instance
        guard let service = Self.sharedService else {
            throw XCTSkip("Shared service not available")
        }
        keychainService = service

        // Wait for service to be ready with timeout
        try await withTimeout(seconds: 5) {
            while !(await XPCServiceHelper.isServiceRunning()) {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                if Task.isCancelled { throw XPCError.serviceNotResponsive }
            }
        }

        // Clean up any existing test items with retry
        try await withRetry(maxAttempts: 3) { [self] in
            try? await self.keychainService.deleteItem(account: self.testAccount, service: self.testService, accessGroup: nil)
            try await XPCServiceHelper.cleanupTestItems()
        }
    }

    override func tearDown() async throws {
        // Clean up test items with retry
        if keychainService != nil {
            try await withRetry(maxAttempts: 3) { [self] in
                try? await self.keychainService.deleteItem(account: self.testAccount, service: self.testService, accessGroup: nil)
                try await XPCServiceHelper.cleanupTestItems()
            }
        }

        keychainService = nil
        try await super.tearDown()
    }

    // Helper function for timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError(seconds: seconds)
            }

            let result = try await group.next()
            group.cancelAll()
            return try result ?? { throw TimeoutError(seconds: seconds) }()
        }
    }

    // Helper function for retry
    private func withRetry<T>(maxAttempts: Int, delay: TimeInterval = 0.5, operation: @escaping () async throws -> T) async throws -> T {
        var attempts = 0
        var lastError: Error?

        while attempts < maxAttempts {
            do {
                return try await operation()
            } catch {
                attempts += 1
                lastError = error
                if attempts < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? XPCError.serviceNotResponsive
    }

    // Custom error for timeout
    private struct TimeoutError: LocalizedError {
        let seconds: TimeInterval
        var errorDescription: String? {
            return "Operation timed out after \(seconds) seconds"
        }
    }

    func testAddItem() async throws {
        // Ensure service is ready
        guard await XPCServiceHelper.isServiceRunning() else {
            throw XCTSkip("XPC service not available")
        }

        do {
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
        } catch let error as KeychainError {
            if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
            }
            throw error
        } catch {
            XCTFail("Unexpected error: \(error)")
            throw error
        }
    }

    func testUpdateItem() async throws {
        do {
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
        } catch let error as KeychainError {
            if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
            }
            throw error
        }
    }

    func testDeleteItem() async throws {
        do {
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
        } catch let error as KeychainError {
            if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
            }
            throw error
        }
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
            } else if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func testDuplicateItem() async throws {
        do {
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
            } else if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
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
            } else if case .unexpectedStatus(errSecMissingEntitlement) = error {
                // Skip test if entitlements are missing
                print("Warning: Missing entitlements, skipping test")
                throw XCTSkip("Test requires keychain entitlements")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func testAccessControlFlags() async throws {
        // Test various access control configurations
        let configurations: [(CFString, SecAccessControlCreateFlags)] = [
            (kSecAttrAccessibleWhenUnlocked, []),
            (kSecAttrAccessibleWhenUnlockedThisDeviceOnly, []),
            (kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, [])
        ]

        for (index, config) in configurations.enumerated() {
            let account = "\(testAccount)_\(index)"

            do {
                // Add item with access control
                try await keychainService.addItem(
                    testData,
                    account: account,
                    service: testService,
                    accessGroup: nil,
                    accessibility: config.0,
                    flags: config.1
                )

                // Wait for XPC service to process
                try await Task.sleep(nanoseconds: 100_000_000)

                // Verify item exists
                let exists = await keychainService.containsItem(
                    account: account,
                    service: testService,
                    accessGroup: nil
                )
                XCTAssertTrue(exists, "Item should exist for configuration \(index)")

                // Read item to verify access
                let readData = try await keychainService.readItem(
                    account: account,
                    service: testService,
                    accessGroup: nil
                )
                XCTAssertEqual(readData, testData, "Data should match for configuration \(index)")

                // Clean up
                try await keychainService.deleteItem(
                    account: account,
                    service: testService,
                    accessGroup: nil
                )

                // Wait for cleanup
                try await Task.sleep(nanoseconds: 100_000_000)

                // Verify cleanup
                let existsAfterDelete = await keychainService.containsItem(
                    account: account,
                    service: testService,
                    accessGroup: nil
                )
                XCTAssertFalse(existsAfterDelete, "Item should be deleted for configuration \(index)")
            } catch let error as KeychainError {
                if case .unexpectedStatus(errSecMissingEntitlement) = error {
                    print("Warning: Missing entitlements for configuration \(index), skipping")
                    continue
                }
                throw error
            }
        }
    }
}
