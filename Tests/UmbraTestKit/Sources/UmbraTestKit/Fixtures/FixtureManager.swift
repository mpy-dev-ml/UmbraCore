import Foundation

/// Protocol for test fixtures
public protocol TestFixture {
    /// The name of the fixture
    var name: String { get }
    
    /// Set up the fixture
    func setUp() throws
    
    /// Tear down the fixture
    func tearDown() throws
}

/// Manager for test fixtures
@MainActor
public final class FixtureManager {
    /// Shared instance of the fixture manager
    public static let shared = FixtureManager()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Dictionary of registered fixtures
    private var fixtures: [String: TestFixture] = [:]
    
    /// Register a fixture with the manager
    /// - Parameter fixture: The fixture to register
    public func register(_ fixture: TestFixture) {
        fixtures[fixture.name] = fixture
    }
    
    /// Get a fixture by name
    /// - Parameter name: The name of the fixture to retrieve
    /// - Returns: The fixture with the specified name, or nil if not found
    public func fixture(named name: String) -> TestFixture? {
        return fixtures[name]
    }
    
    /// Set up a fixture by name
    /// - Parameter name: The name of the fixture to set up
    /// - Throws: An error if the fixture cannot be set up
    public func setUp(fixture named: String) throws {
        guard let fixture = fixture(named: named) else {
            throw NSError(domain: "FixtureManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(named)"])
        }
        
        try fixture.setUp()
    }
    
    /// Tear down a fixture by name
    /// - Parameter name: The name of the fixture to tear down
    /// - Throws: An error if the fixture cannot be torn down
    public func tearDown(fixture named: String) throws {
        guard let fixture = fixture(named: named) else {
            throw NSError(domain: "FixtureManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(named)"])
        }
        
        try fixture.tearDown()
    }
    
    /// Set up all registered fixtures
    /// - Throws: An error if any fixture cannot be set up
    public func setUpAll() throws {
        for fixture in fixtures.values {
            try fixture.setUp()
        }
    }
    
    /// Tear down all registered fixtures
    /// - Throws: An error if any fixture cannot be torn down
    public func tearDownAll() throws {
        for fixture in fixtures.values {
            try fixture.tearDown()
        }
    }
}
