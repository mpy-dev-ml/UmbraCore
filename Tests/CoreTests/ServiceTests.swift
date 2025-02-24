@testable import Core
import XCTest

/// Mock service for testing
actor MockService: UmbraService {
    static let serviceIdentifier = "com.umbracore.mock-service"
    nonisolated var state: ServiceState {
        get async {
            await _state
        }
    }
    private var _state: ServiceState = .uninitialized
    nonisolated var initializeCalled: Bool {
        get async {
            await _initializeCalled
        }
    }
    private var _initializeCalled = false
    nonisolated var shutdownCalled: Bool {
        get async {
            await _shutdownCalled
        }
    }
    private var _shutdownCalled = false

    func initialize() async throws {
        _state = .initializing
        _initializeCalled = true
        _state = .ready
    }

    func shutdown() async {
        _state = .shuttingDown
        _shutdownCalled = true
        _state = .shutdown
    }
}

/// Mock service with dependencies
actor DependentMockService: UmbraService {
    static let serviceIdentifier = "com.umbracore.dependent-mock-service"
    nonisolated var state: ServiceState {
        get async {
            await _state
        }
    }
    private var _state: ServiceState = .uninitialized
    private let dependency: MockService

    init(dependency: MockService) {
        self.dependency = dependency
    }

    func initialize() async throws {
        _state = .initializing
        _ = await dependency.state
        _state = .ready
    }

    func shutdown() async {
        _state = .shuttingDown
        await dependency.shutdown()
        _state = .shutdown
    }
}

final class ServiceTests: XCTestCase {
    var container: ServiceContainer!
    
    override func setUp() async throws {
        container = ServiceContainer()
    }
    
    override func tearDown() async throws {
        await container.shutdownAll()
        container = nil
    }
    
    func testServiceRegistration() async throws {
        let service = MockService()
        try await container.register(service)
        
        let initialState = await service.state
        XCTAssertEqual(initialState, .uninitialized)
        
        try await container.initialiseAll()
        let isInitialized = await service.initializeCalled
        XCTAssertTrue(isInitialized)
        let readyState = await service.state
        XCTAssertEqual(readyState, .ready)
        
        await container.shutdownAll()
        let isShutdown = await service.shutdownCalled
        XCTAssertTrue(isShutdown)
        let finalState = await service.state
        XCTAssertEqual(finalState, .shutdown)
    }
    
    func testDependencyResolution() async throws {
        let service = MockService()
        try await container.register(service)
        try await container.initialiseAll()
        
        let resolved: MockService = try await container.resolve(MockService.self)
        let resolvedState = await resolved.state
        XCTAssertEqual(resolvedState, .ready)
        
        do {
            let _: DependentMockService = try await container.resolve(DependentMockService.self)
            XCTFail("Expected resolution error")
        } catch let error as ServiceError {
            guard case .dependencyError = error else {
                XCTFail("Expected dependency error")
                return
            }
        }
    }
}
