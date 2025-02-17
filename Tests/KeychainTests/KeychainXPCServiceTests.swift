import XCTest
@testable import UmbraKeychainService

final class KeychainXPCServiceTests: XCTestCase {
    private let testAccount = "testAccount"
    private let testService = "com.umbracore.tests"
    private let testData = "Test data".data(using: .utf8)!

    override class func setUp() {
        super.setUp()
        let expectation = XCTestExpectation(description: "XPC Service Started")
        Task {
            do {
                try await XPCServiceHelper.startService()
                expectation.fulfill()
            } catch {
                XCTFail("Failed to start XPC service: \(error)")
            }
        }
        XCTWaiter().wait(for: [expectation], timeout: 15.0) // Extended timeout for safety
    }

    override class func tearDown() {
        let expectation = XCTestExpectation(description: "XPC Service Stopped")
        Task {
            await XPCServiceHelper.stopService()
            expectation.fulfill()
        }
        XCTWaiter().wait(for: [expectation], timeout: 10.0)
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        // Wait for service to be ready with timeout
        try await Self.withTimeout(seconds: 5) {
            while !(await XPCServiceHelper.isServiceRunning()) {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                if Task.isCancelled { throw XPCError.serviceNotResponsive }
            }
        }

        // Clean up test items with retry
        try await Self.withRetry(maxAttempts: 3) {
            try await XPCServiceHelper.cleanupTestItems()
        }
    }

    func testXPCConnection() async throws {
        guard let service = await XPCServiceHelper.service else {
            XCTFail("XPC service not available")
            return
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()
        XCTAssertNotNil(proxy, "Should get a valid proxy object")
    }

    func testAddAndReadItem() async throws {
        guard let service = await XPCServiceHelper.service else {
            XCTFail("XPC service not available")
            return
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()

        // Test adding item
        try await proxy.addItem(testData,
                              account: testAccount,
                              service: testService,
                              accessGroup: nil,
                              accessibility: kSecAttrAccessibleWhenUnlocked as String,
                              flags: 0)

        // Test reading item
        let retrievedData = try await proxy.readItem(account: testAccount,
                                                    service: testService,
                                                    accessGroup: nil)

        XCTAssertEqual(retrievedData, testData, "Retrieved data should match original")
    }

    func testUpdateItem() async throws {
        guard let service = await XPCServiceHelper.service else {
            XCTFail("XPC service not available")
            return
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()

        // Add initial item
        try await proxy.addItem(testData,
                              account: testAccount,
                              service: testService,
                              accessGroup: nil,
                              accessibility: kSecAttrAccessibleWhenUnlocked as String,
                              flags: 0)

        // Update with new data
        let updatedData = "Updated data".data(using: .utf8)!
        try await proxy.updateItem(updatedData,
                                 account: testAccount,
                                 service: testService,
                                 accessGroup: nil)

        // Verify update
        let retrievedData = try await proxy.readItem(account: testAccount,
                                                    service: testService,
                                                    accessGroup: nil)

        XCTAssertEqual(retrievedData, updatedData, "Retrieved data should match updated data")
    }

    func testDeleteItem() async throws {
        guard let service = await XPCServiceHelper.service else {
            XCTFail("XPC service not available")
            return
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()

        // Add item
        try await proxy.addItem(testData,
                              account: testAccount,
                              service: testService,
                              accessGroup: nil,
                              accessibility: kSecAttrAccessibleWhenUnlocked as String,
                              flags: 0)

        // Delete item
        try await proxy.deleteItem(account: testAccount,
                                 service: testService,
                                 accessGroup: nil)

        // Verify deletion
        do {
            _ = try await proxy.readItem(account: testAccount,
                                       service: testService,
                                       accessGroup: nil)
            XCTFail("Item should have been deleted")
        } catch let error as KeychainError {
            if case .itemNotFound = error {
                // Expected error
            } else {
                throw error
            }
        }
    }

    func testConnectionReuse() async throws {
        guard let service = await XPCServiceHelper.service else {
            XCTFail("XPC service not available")
            return
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()

        // Multiple operations on same connection
        for i in 1...5 {
            let testData = "Test data \(i)".data(using: .utf8)!
            try await proxy.addItem(testData,
                                  account: "\(testAccount)_\(i)",
                                  service: testService,
                                  accessGroup: nil,
                                  accessibility: kSecAttrAccessibleWhenUnlocked as String,
                                  flags: 0)

            let retrievedData = try await proxy.readItem(account: "\(testAccount)_\(i)",
                                                        service: testService,
                                                        accessGroup: nil)

            XCTAssertEqual(retrievedData, testData, "Retrieved data should match for iteration \(i)")
        }
    }

    // Helper function for timeout
    private static func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
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
    private static func withRetry<T>(maxAttempts: Int, delay: TimeInterval = 0.5, operation: @escaping () async throws -> T) async throws -> T {
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
}
