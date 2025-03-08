@testable import Core
import CoreTypesInterfaces
import CryptoTypes
import Services
import XCTest

/// Mock service for testing
actor MockService: UmbraService {
  static let serviceIdentifier = "com.umbracore.mock-service"

  private var _state: ServiceState = .uninitialized
  public private(set) nonisolated(unsafe) var state: ServiceState = .uninitialized

  private var _initializeCalled = false
  nonisolated var initializeCalled: Bool {
    get async {
      await _initializeCalled
    }
  }

  private var _shutdownCalled = false
  nonisolated var shutdownCalled: Bool {
    get async {
      await _shutdownCalled
    }
  }

  func initialize() async throws {
    state = ServiceState.initializing
    _state = ServiceState.initializing
    _initializeCalled = true
    state = ServiceState.ready
    _state = ServiceState.ready
  }

  func shutdown() async {
    state = ServiceState.shuttingDown
    _state = ServiceState.shuttingDown
    _shutdownCalled = true
    state = ServiceState.shutdown
    _state = ServiceState.shutdown
  }
}

/// Mock service with dependencies
actor DependentMockService: UmbraService {
  static let serviceIdentifier = "com.umbracore.dependent-mock-service"

  private var _state: ServiceState = .uninitialized
  public private(set) nonisolated(unsafe) var state: ServiceState = .uninitialized

  private let dependency: MockService

  init(dependency: MockService) {
    self.dependency = dependency
  }

  func initialize() async throws {
    state = ServiceState.initializing
    _state = ServiceState.initializing
    _ = await dependency.state
    state = ServiceState.ready
    _state = ServiceState.ready
  }

  func shutdown() async {
    state = ServiceState.shuttingDown
    _state = ServiceState.shuttingDown
    await dependency.shutdown()
    state = ServiceState.shutdown
    _state = ServiceState.shutdown
  }
}

/// Test cases for the ServiceContainer and UmbraService implementations
final class ServiceTests: XCTestCase {
  // MARK: - Lifecycle Tests

  /// Tests the basic lifecycle of a service: registration, initialization, and shutdown
  func testServiceInitialization() async throws {
    let container = ServiceContainer()
    let service = MockService()

    try await container.register(service)
    let initialState = service.state
    XCTAssertEqual(initialState, ServiceState.uninitialized)

    try await container.initialiseAll()
    let isInitialized = await service.initializeCalled
    let readyState = service.state
    XCTAssertTrue(isInitialized)
    XCTAssertEqual(readyState, ServiceState.ready)

    await container.shutdownAll()
    let isShutdown = await service.shutdownCalled
    let finalState = service.state
    XCTAssertTrue(isShutdown)
    XCTAssertEqual(finalState, ServiceState.shutdown)
  }

  // MARK: - Dependency Tests

  /// Tests proper resolution and handling of service dependencies
  func testDependencyResolution() async throws {
    let container = ServiceContainer()
    let dependency = MockService()
    let service = DependentMockService(dependency: dependency)

    try await container.register(dependency)
    try await container.register(service)

    try await container.initialiseAll()
    let depState = dependency.state
    let svcState = service.state
    XCTAssertEqual(depState, ServiceState.ready)
    XCTAssertEqual(svcState, ServiceState.ready)

    await container.shutdownAll()
    let depFinalState = dependency.state
    let svcFinalState = service.state
    XCTAssertEqual(depFinalState, ServiceState.shutdown)
    XCTAssertEqual(svcFinalState, ServiceState.shutdown)
  }

  // MARK: - Scale Tests

  /// Tests handling of multiple services within a single container
  func testMultipleServices() async throws {
    let container = ServiceContainer()
    let services = (0..<5).map { _ in MockService() }

    for service in services {
      try await container.register(service)
    }

    try await container.initialiseAll()
    for service in services {
      let state = service.state
      XCTAssertEqual(state, ServiceState.ready)
    }

    await container.shutdownAll()
    for service in services {
      let state = service.state
      XCTAssertEqual(state, ServiceState.shutdown)
    }
  }

  // MARK: - Error Handling Tests

  /// Tests various error conditions and their proper handling
  func testErrorHandling() async throws {
    let container = ServiceContainer()
    let service = MockService()

    // Test duplicate registration
    try await container.register(service)
    do {
      try await container.register(service)
      XCTFail("Expected duplicate registration error")
    } catch let error as CoreError {
      XCTAssertTrue(error.errorDescription?.contains("already registered") == true)
    }

    // Test resolving non-existent service
    do {
      _ = try await container.resolve(CryptoService.self)
      XCTFail("Expected service not found error")
    } catch let error as CoreError {
      XCTAssertTrue(error.errorDescription?.contains("not found") == true)
    }
  }
}
