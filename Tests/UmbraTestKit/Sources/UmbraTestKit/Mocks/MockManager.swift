import Foundation

/// Protocol for objects that can be reset to their initial state
public protocol Resettable {
    /// Reset the object to its initial state
    func reset()
}

/// Manager for mock objects used in tests
public final class MockManager {
    /// Shared instance of the mock manager
    public static let shared = MockManager()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Dictionary of registered mocks
    private var registeredMocks: [String: Resettable] = [:]
    
    /// Register a mock with the manager
    /// - Parameters:
    ///   - mock: The mock object to register
    ///   - name: Optional name for the mock, defaults to the type name
    public func register<T: Resettable>(_ mock: T, name: String? = nil) {
        let key = name ?? String(describing: type(of: mock))
        registeredMocks[key] = mock
    }
    
    /// Get a registered mock by type
    /// - Parameter type: The type of the mock to retrieve
    /// - Returns: The registered mock of the specified type, or nil if not found
    public func mock<T: Resettable>(ofType type: T.Type) -> T? {
        let key = String(describing: type)
        return registeredMocks[key] as? T
    }
    
    /// Get a registered mock by name
    /// - Parameter name: The name of the mock to retrieve
    /// - Returns: The registered mock with the specified name, or nil if not found
    public func mock(named name: String) -> Resettable? {
        return registeredMocks[name]
    }
    
    /// Reset all registered mocks
    public func resetAll() {
        for mock in registeredMocks.values {
            mock.reset()
        }
    }
    
    /// Reset a specific mock by type
    /// - Parameter type: The type of the mock to reset
    public func reset<T: Resettable>(mockOfType type: T.Type) {
        if let mock = mock(ofType: type) {
            mock.reset()
        }
    }
    
    /// Reset a specific mock by name
    /// - Parameter name: The name of the mock to reset
    public func reset(mockNamed name: String) {
        if let mock = mock(named: name) {
            mock.reset()
        }
    }
}
