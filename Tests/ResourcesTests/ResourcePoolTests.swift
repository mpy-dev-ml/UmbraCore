@testable import Resources
import ResourcesProtocols
import ResourcesTypes
import XCTest

/// State manager for test resources
private final class TestResourceStateManager: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.umbra.test.resource.state")
    private var _state: ResourceState

    init(initialState: ResourceState = .uninitialized) {
        self._state = initialState
    }

    var state: ResourceState {
        get { queue.sync { _state } }
        set { queue.sync { _state = newValue } }
    }
}

/// Test implementation of BasicManagedResource
private actor TestResource: BasicManagedResource {
    nonisolated private let stateManager: TestResourceStateManager
    nonisolated var state: ResourceState { stateManager.state }
    static var resourceType: String { "test" }

    nonisolated let id: String
    private var error: Error?

    init(id: String) {
        self.id = id
        self.stateManager = TestResourceStateManager()
    }

    private func updateState(_ newState: ResourceState) {
        stateManager.state = newState
    }

    func setError(_ error: Error) {
        self.error = error
    }

    func acquire() async throws {
        if let error = error {
            throw error
        }
        updateState(.inUse)
    }

    func release() async {
        updateState(.ready)
    }

    func cleanup() async {
        updateState(.released)
    }
}

final class ResourcePoolTests: XCTestCase {
    func testResourceAcquisitionAndRelease() async throws {
        let pool = ResourcePool<TestResource>(maxSize: 2)
        let resource1 = TestResource(id: "1")
        let resource2 = TestResource(id: "2")

        // Add resources to pool
        try await pool.add(resource1)
        try await pool.add(resource2)

        // Acquire resources
        let acquired1 = try await pool.acquire()
        XCTAssertEqual(acquired1.id, "1")
        let acquired1State = acquired1.state
        XCTAssertEqual(acquired1State, .inUse)

        let acquired2 = try await pool.acquire()
        XCTAssertEqual(acquired2.id, "2")
        let acquired2State = acquired2.state
        XCTAssertEqual(acquired2State, .inUse)

        // Release resources
        await pool.release(acquired1)
        let released1State = acquired1.state
        XCTAssertEqual(released1State, .ready)

        await pool.release(acquired2)
        let released2State = acquired2.state
        XCTAssertEqual(released2State, .ready)
    }

    func testResourcePoolMaxSize() async throws {
        let pool = ResourcePool<TestResource>(maxSize: 1)
        let resource1 = TestResource(id: "1")
        let resource2 = TestResource(id: "2")

        // First resource should be added successfully
        try await pool.add(resource1)

        // Second resource should fail
        do {
            try await pool.add(resource2)
            XCTFail("Expected ResourceError.poolExhausted")
        } catch let error as ResourcesProtocols.ResourceError {
            if case .poolExhausted = error {
                // Expected error
            } else {
                XCTFail("Expected poolExhausted error")
            }
        } catch {
            XCTFail("Expected ResourceError")
        }
    }

    func testResourceInitializationFailure() async {
        let pool = ResourcePool<TestResource>(maxSize: 1)
        let resource = TestResource(id: "1")
        await resource.setError(ResourcesProtocols.ResourceError.acquisitionFailed("Test error"))

        do {
            try await pool.add(resource)
            XCTFail("Expected ResourceError.acquisitionFailed")
        } catch let error as ResourcesProtocols.ResourceError {
            if case .acquisitionFailed(let message) = error {
                XCTAssertEqual(message, "Test error")
            } else {
                XCTFail("Expected acquisitionFailed error")
            }
        } catch {
            XCTFail("Expected ResourceError")
        }
    }

    func testResourceErrorDescription() {
        let errors: [ResourcesProtocols.ResourceError] = [
            .acquisitionFailed("test"),
            .invalidState("test"),
            .timeout("test"),
            .poolExhausted("test"),
            .cleanupFailed("test")
        ]

        let expectedDescriptions = [
            "Resource acquisition failed: test",
            "Resource is in an invalid state: test",
            "Resource operation timed out: test",
            "Resource pool is exhausted: test",
            "Resource cleanup failed: test"
        ]

        for (error, expectedDescription) in zip(errors, expectedDescriptions) {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
}
