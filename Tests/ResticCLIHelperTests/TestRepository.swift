import Foundation
import ResticCLIHelper

/// A test repository for testing Restic commands
final class TestRepository {
    /// Path to the repository
    let path: String

    /// Password for the repository
    let password: String

    /// Path to the cache directory
    let cachePath: String

    /// Path to test files
    let testFilesPath: String

    /// Path to restore files
    let restorePath: String

    private init(
        path: String,
        password: String,
        cachePath: String,
        testFilesPath: String,
        restorePath: String
    ) {
        self.path = path
        self.password = password
        self.cachePath = cachePath
        self.testFilesPath = testFilesPath
        self.restorePath = restorePath
    }

    /// Create a new test repository
    static func create() async throws -> TestRepository {
        let tempDir = FileManager.default.temporaryDirectory
        let uuid = UUID().uuidString

        let repoPath = tempDir.appendingPathComponent("restic-test-\(uuid)", isDirectory: true).path
        let cachePath = tempDir.appendingPathComponent("restic-cache-\(uuid)", isDirectory: true).path
        let testFilesPath = tempDir.appendingPathComponent("restic-test-files-\(uuid)", isDirectory: true)
            .path
        let restorePath = tempDir.appendingPathComponent("restic-restore-\(uuid)", isDirectory: true).path

        // Clean up any existing directories
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: repoPath) {
            try fileManager.removeItem(atPath: repoPath)
        }
        if fileManager.fileExists(atPath: cachePath) {
            try fileManager.removeItem(atPath: cachePath)
        }
        if fileManager.fileExists(atPath: testFilesPath) {
            try fileManager.removeItem(atPath: testFilesPath)
        }
        if fileManager.fileExists(atPath: restorePath) {
            try fileManager.removeItem(atPath: restorePath)
        }

        // Create directories
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            atPath: testFilesPath,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(atPath: restorePath, withIntermediateDirectories: true)

        // Create test files
        let testFile1Path = (testFilesPath as NSString).appendingPathComponent("test1.txt")
        let testFile2Path = (testFilesPath as NSString).appendingPathComponent("test2.txt")
        try "Test file 1".write(toFile: testFile1Path, atomically: true, encoding: .utf8)
        try "Test file 2".write(toFile: testFile2Path, atomically: true, encoding: .utf8)

        // Initialize repository
        let helper = ResticCLIHelper()
        let initCommand = InitCommand(
            options: CommonOptions(
                repository: repoPath,
                password: "test-password",
                validateCredentials: true,
                jsonOutput: true
            )
        )
        _ = try await helper.execute(initCommand)

        return TestRepository(
            path: repoPath,
            password: "test-password",
            cachePath: cachePath,
            testFilesPath: testFilesPath,
            restorePath: restorePath
        )
    }

    /// Clean up the test repository
    func cleanup() throws {
        // Clean up any existing directories
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        if fileManager.fileExists(atPath: cachePath) {
            try fileManager.removeItem(atPath: cachePath)
        }
        if fileManager.fileExists(atPath: testFilesPath) {
            try fileManager.removeItem(atPath: testFilesPath)
        }
        if fileManager.fileExists(atPath: restorePath) {
            try fileManager.removeItem(atPath: restorePath)
        }
    }
}
