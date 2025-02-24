import Core
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
    func testServiceInitialization() async throws {
        let container = ServiceContainer()
        let service = MockService()
        
        try await container.register(service)
        let initialState = await service.state
        XCTAssertEqual(initialState, .uninitialized)
        
        try await container.initialiseAll()
        let isInitialized = await service.initializeCalled
        let readyState = await service.state
        XCTAssertTrue(isInitialized)
        XCTAssertEqual(readyState, .ready)
        
        await container.shutdownAll()
        let isShutdown = await service.shutdownCalled
        let finalState = await service.state
        XCTAssertTrue(isShutdown)
        XCTAssertEqual(finalState, .shutdown)
    }
    
    func testDependencyResolution() async throws {
        let container = ServiceContainer()
        let dependency = MockService()
        let service = DependentMockService(dependency: dependency)
        
        try await container.register(dependency)
        try await container.register(service)
        
        try await container.initialiseAll()
        let depState = await dependency.state
        let svcState = await service.state
        XCTAssertEqual(depState, .ready)
        XCTAssertEqual(svcState, .ready)
        
        await container.shutdownAll()
        let depFinalState = await dependency.state
        let svcFinalState = await service.state
        XCTAssertEqual(depFinalState, .shutdown)
        XCTAssertEqual(svcFinalState, .shutdown)
    }
    
    func testMultipleServices() async throws {
        let container = ServiceContainer()
        let services = (0..<5).map { _ in MockService() }
        
        for service in services {
            try await container.register(service)
        }
        
        try await container.initialiseAll()
        for service in services {
            let state = await service.state
            XCTAssertEqual(state, .ready)
        }
        
        await container.shutdownAll()
        for service in services {
            let state = await service.state
            XCTAssertEqual(state, .shutdown)
        }
    }
    
    func testErrorHandling() async throws {
        let container = ServiceContainer()
        let service = MockService()
        
        // Test duplicate registration
        try await container.register(service)
        do {
            try await container.register(service)
            XCTFail("Expected duplicate registration error")
        } catch let error as ServiceError {
            XCTAssertTrue(error.errorDescription?.contains("already registered") == true)
        }
        
        // Test resolving non-existent service
        do {
            _ = try await container.resolve(CryptoService.self)
            XCTFail("Expected service not found error")
        } catch let error as ServiceError {
            XCTAssertTrue(error.errorDescription?.contains("not found") == true)
        }
    }
}
