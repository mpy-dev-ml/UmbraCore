import XCTest
import SecurityTypes

/// Base class for tests that need to simulate sandbox behavior
open class SandboxTestCase: XCTestCase {
    /// Mock file manager for simulating sandbox operations
    internal var mockFileManager: MockFileManager!
    
    /// Temporary directory for test files
    private var tempDirectory: URL!
    
    /// Set up sandbox test environment
    open override func setUp() async throws {
        try await super.setUp()
        
        // Create temporary directory
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        // Initialize mock file manager
        mockFileManager = MockFileManager()
        try mockFileManager.simulateCreateDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    /// Clean up sandbox test environment
    open override func tearDown() async throws {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        mockFileManager = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// Create a test file in the sandbox with specified content
    /// - Parameters:
    ///   - name: Name of the file
    ///   - content: Content to write to the file
    ///   - access: Access permissions to set
    /// - Returns: URL to the created file
    public func createTestFile(
        named name: String,
        content: String,
        access: FilePermission = .readWrite
    ) -> URL {
        let fileURL = tempDirectory.appendingPathComponent(name)
        mockFileManager.simulateSetFileContent(content, at: fileURL)
        _ = mockFileManager.simulateSetAccess(access, for: fileURL)
        return fileURL
    }
    
    /// Create a test directory in the sandbox
    /// - Parameters:
    ///   - name: Name of the directory
    ///   - access: Access permissions to set
    /// - Returns: URL to the created directory
    public func createTestDirectory(
        named name: String,
        access: FilePermission = .readWrite
    ) throws -> URL {
        let dirURL = tempDirectory.appendingPathComponent(name)
        try mockFileManager.simulateCreateDirectory(at: dirURL, withIntermediateDirectories: true)
        _ = mockFileManager.simulateSetAccess(access, for: dirURL)
        return dirURL
    }
}
