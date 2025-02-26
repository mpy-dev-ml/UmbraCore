import Foundation

/// Protocol for objects that can be reset to their initial state
@preconcurrency
public protocol Resettable: AnyObject, Sendable {
    /// Reset the object to its initial state
    func reset() async
}

/// Manager for mock objects used in tests
@MainActor
public final class MockManager {
    /// Shared instance of the MockManager
    public static let shared = MockManager()
    
    /// Dictionary of registered mocks
    private var registeredMocks: [String: any (Resettable & Sendable)] = [:]
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Register a mock object
    ///
    /// - Parameter mock: The mock object to register
    public func register(_ mock: any (Resettable & Sendable)) {
        let name = String(describing: type(of: mock))
        registeredMocks[name] = mock
    }
    
    /// Register a mock object with a specific name
    ///
    /// - Parameters:
    ///   - mock: The mock object to register
    ///   - name: The name to register the mock with
    public func register(_ mock: any (Resettable & Sendable), name: String) {
        registeredMocks[name] = mock
    }
    
    /// Get a mock object by type
    ///
    /// - Parameter type: The type of the mock to get
    /// - Returns: The mock object, or nil if not found
    public func mock<T: Resettable & Sendable>(ofType type: T.Type) -> T? {
        let name = String(describing: type)
        return registeredMocks[name] as? T
    }
    
    /// Get a mock object by name
    ///
    /// - Parameter name: The name of the mock to get
    /// - Returns: The mock object, or nil if not found
    public func mock(named name: String) -> (any (Resettable & Sendable))? {
        return registeredMocks[name]
    }
    
    /// Reset all registered mocks
    public func resetAll() async {
        // Make a copy of the mocks to avoid concurrent access issues
        let mocks = Array(registeredMocks.values)
        
        // Reset each mock outside of the actor context
        for mock in mocks {
            await mock.reset()
        }
    }
    
    /// Reset a mock object by type
    ///
    /// - Parameter type: The type of the mock to reset
    public func reset<T: Resettable & Sendable>(mockOfType type: T.Type) async {
        if let mock = mock(ofType: type) {
            await mock.reset()
        }
    }
    
    /// Reset a mock object by name
    ///
    /// - Parameter name: The name of the mock to reset
    public func reset(mockNamed name: String) async {
        if let mock = mock(named: name) {
            await mock.reset()
        }
    }
}
