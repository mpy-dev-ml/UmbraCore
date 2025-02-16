/// A mock implementation of SecurityProvider for testing
public actor MockSecurityProvider: SecurityProvider {
    // MARK: - Types
    
    /// Represents a recorded operation for testing verification
    public struct Operation: Equatable {
        public let type: String
        public let parameters: [String: String]
        public let timestamp: Int
        
        public init(type: String, parameters: [String: String], timestamp: Int) {
            self.type = type
            self.parameters = parameters
            self.timestamp = timestamp
        }
    }
    
    // MARK: - Properties
    
    private var bookmarks: [String: [UInt8]] = [:]
    private var accessedPaths: Set<String> = []
    private var recordedOperations: [Operation] = []
    private var shouldSimulateError = false
    private var simulatedError: SecurityError?
    private var operationDelay: Int = 0
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Configuration
    
    /// Configures the mock to simulate an error
    public func simulateError(_ error: SecurityError) {
        shouldSimulateError = true
        simulatedError = error
    }
    
    /// Stops simulating errors
    public func stopSimulatingError() {
        shouldSimulateError = false
        simulatedError = nil
    }
    
    /// Sets a delay for all operations
    public func setOperationDelay(_ milliseconds: Int) {
        operationDelay = milliseconds
    }
    
    // MARK: - Operation Recording
    
    private func recordOperation(type: String, parameters: [String: String] = [:]) {
        let operation = Operation(
            type: type,
            parameters: parameters,
            timestamp: Int(epochTimestamp())
        )
        recordedOperations.append(operation)
    }
    
    /// Returns all recorded operations
    public func getRecordedOperations() -> [Operation] {
        recordedOperations
    }
    
    /// Clears all recorded operations
    public func clearRecordedOperations() {
        recordedOperations = []
    }
    
    // MARK: - SecurityProvider Implementation
    
    public func createBookmark(forPath path: String) async throws -> [UInt8] {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "createBookmark", parameters: ["path": path])
        
        // Create mock bookmark data by prefixing path with "MockBookmark:"
        let mockBookmark = "MockBookmark:\(path)"
        return Array(mockBookmark.utf8)
    }
    
    public func resolveBookmark(_ bookmarkData: [UInt8]) async throws -> (path: String, isStale: Bool) {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "resolveBookmark")
        
        // Extract path from mock bookmark data
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        guard mockBookmark.hasPrefix("MockBookmark:") else {
            throw SecurityError.invalidBookmarkData(identifier: nil)
        }
        
        let path = String(mockBookmark.dropFirst("MockBookmark:".count))
        let isStale = mockBookmark.hasPrefix("MockBookmark:Stale:")
        return (path: path, isStale: isStale)
    }
    
    public func saveBookmark(_ bookmarkData: [UInt8], withIdentifier identifier: String) async throws {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "saveBookmark", parameters: ["identifier": identifier])
        bookmarks[identifier] = bookmarkData
    }
    
    public func loadBookmark(withIdentifier identifier: String) async throws -> [UInt8] {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "loadBookmark", parameters: ["identifier": identifier])
        
        guard let bookmarkData = bookmarks[identifier] else {
            throw SecurityError.bookmarkNotFound(identifier: identifier)
        }
        return bookmarkData
    }
    
    public func deleteBookmark(withIdentifier identifier: String) async throws {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "deleteBookmark", parameters: ["identifier": identifier])
        bookmarks.removeValue(forKey: identifier)
    }
    
    public func withSecurityScopedAccess<T>(to path: String, perform operation: () async throws -> T) async throws -> T {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "withSecurityScopedAccess", parameters: ["path": path])
        
        _ = try await startAccessing(path: path)
        defer { Task { await stopAccessing(path: path) } }
        return try await operation()
    }
    
    public func startAccessing(path: String) async throws -> Bool {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "startAccessing", parameters: ["path": path])
        
        if accessedPaths.contains(path) {
            throw SecurityError.resourceAlreadyAccessed(path: path)
        }
        
        accessedPaths.insert(path)
        return true
    }
    
    public func stopAccessing(path: String) async {
        recordOperation(type: "stopAccessing", parameters: ["path": path])
        accessedPaths.remove(path)
    }
    
    public func stopAccessingAllResources() async {
        recordOperation(type: "stopAccessingAllResources")
        accessedPaths.removeAll()
    }
    
    public func isAccessing(path: String) async -> Bool {
        recordOperation(type: "isAccessing", parameters: ["path": path])
        return accessedPaths.contains(path)
    }
    
    public func validateBookmark(_ bookmarkData: [UInt8]) async throws -> Bool {
        try await simulateDelay()
        try checkForSimulatedError()
        
        recordOperation(type: "validateBookmark")
        
        let mockBookmark = String(decoding: bookmarkData, as: UTF8.self)
        return mockBookmark.hasPrefix("MockBookmark:")
    }
    
    public func getAccessedPaths() async -> Set<String> {
        recordOperation(type: "getAccessedPaths")
        return accessedPaths
    }
    
    // MARK: - Helper Methods
    
    private func simulateDelay() async throws {
        if operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(operationDelay) * 1_000_000)
        }
    }
    
    private func checkForSimulatedError() throws {
        if shouldSimulateError, let error = simulatedError {
            throw error
        }
    }
    
    private func epochTimestamp() -> Int {
        // Return a fixed timestamp for testing
        1708120457
    }
}
