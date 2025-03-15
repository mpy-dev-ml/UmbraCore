import Foundation
@testable import ResticCLIHelper
@testable import ResticCLIHelperCommands
@testable import ResticCLIHelperTypes
import ResticTypes
import UmbraTestKit
import XCTest

/**
 * A test repository for restic tests.
 * Each instance creates a temporary repository with a unique name and password.
 */
final class TestRepository {
    /// Path to the repository
    let path: String

    /// Path to a directory for test files
    let testFilesPath: String

    /// Path to a directory for restored files
    let restorePath: String

    /// Path to a directory for cache files
    let cachePath: String

    /// Password for the repository
    let password: String = "test-password"

    /// Main helper instance
    private let helper: ResticCLIHelper

    /// URL to repository folder
    private let repositoryURL: URL

    /**
     * Create a new test repository with a unique name.
     * The repository will be deleted when the test case is torn down.
     */
    static func create() async throws -> TestRepository {
        let instance = try TestRepository()

        // Initialize the repository
        let options = CommonOptions(
            repository: instance.path,
            password: instance.password,
            validateCredentials: false,
            jsonOutput: true
        )

        let initCommand = InitCommand(options: options)
        _ = try await instance.helper.testExecute(initCommand)

        return instance
    }

    /// Private initializer, call `create()` instead
    private init() throws {
        // Create unique temporary directory
        let tempDirURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("restic-tests-\(UUID().uuidString)")

        // Create repository subdirectory
        repositoryURL = tempDirURL.appendingPathComponent("repo")
        path = repositoryURL.path

        // Create test files directory
        let testFilesURL = tempDirURL.appendingPathComponent("test-files")
        testFilesPath = testFilesURL.path

        // Create restore directory
        let restoreURL = tempDirURL.appendingPathComponent("restore")
        restorePath = restoreURL.path

        // Create cache directory
        let cacheURL = tempDirURL.appendingPathComponent("cache")
        cachePath = cacheURL.path

        // Create all directories
        try FileManager.default.createDirectory(at: repositoryURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: testFilesURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: restoreURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)

        // Initialize helper using the test factory method instead of direct initialization
        helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")
    }

    /**
     * Create standard test files for use in tests.
     * This creates several files with different sizes and content types.
     */
    func createStandardTestFiles() throws {
        // Create a simple text file
        let textFile = (testFilesPath as NSString).appendingPathComponent("text.txt")
        try "This is a test file.\nIt has multiple lines.\nThis is line 3."
            .write(toFile: textFile, atomically: true, encoding: .utf8)

        // Create a binary file with random data
        let binaryFile = (testFilesPath as NSString).appendingPathComponent("binary.dat")
        var randomData = Data(count: 1024) // 1KB file
        _ = randomData.withUnsafeMutableBytes { bytes in
            if let baseAddress = bytes.baseAddress {
                arc4random_buf(baseAddress, 1024)
            }
        }
        try randomData.write(to: URL(fileURLWithPath: binaryFile))

        // Create an empty file
        let emptyFile = (testFilesPath as NSString).appendingPathComponent("empty.txt")
        try Data().write(to: URL(fileURLWithPath: emptyFile))
    }

    /**
     * Clean up the repository and all associated directories.
     */
    func cleanup() throws {
        try FileManager.default.removeItem(at: repositoryURL.deletingLastPathComponent())
    }
}
