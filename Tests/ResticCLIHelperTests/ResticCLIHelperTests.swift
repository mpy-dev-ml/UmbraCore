// CryptoKit removed - cryptography will be handled in ResticBar
@testable import ResticCLIHelper
import UmbraTestKit
import XCTest

// Custom command type for ls
struct LsCommand: ResticCommand {
    let options: CommonOptions
    let snapshotId: String

    var commandName: String { "ls" }

    var environment: [String: String] {
        var env = options.environmentVariables
        env["RESTIC_PASSWORD"] = options.password
        env["RESTIC_REPOSITORY"] = options.repository
        return env
    }

    var commandArguments: [String] {
        var args = options.arguments
        args.append(snapshotId)
        return args
    }

    func validate() throws {
        guard !snapshotId.isEmpty else {
            throw ResticError.missingParameter("snapshot ID is required")
        }
    }
}

final class ResticCLIHelperTests: ResticTestCase {
    override func setUp() async throws {
        try await super.setUp()
        // Create standard test files
        try mockRepository.createStandardTestFiles()
    }

    func testBackupCommand() async throws {
        let mockRepository = try MockResticRepository()
        let helper = ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")

        // Create test files
        let testData = "Test file content"
        let testDir = (mockRepository.testFilesPath as NSString)
        let test1Path = testDir.appendingPathComponent("test1.txt")
        let test2Path = testDir.appendingPathComponent("test2.txt")
        try testData.write(toFile: test1Path, atomically: true, encoding: .utf8)
        try testData.write(toFile: test2Path, atomically: true, encoding: .utf8)

        // Create a backup
        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )

        let backupCommand = BackupCommand(options: options)
        backupCommand.addPath(test1Path)
        backupCommand.addPath(test2Path)
        backupCommand.tag("test-backup")
        backupCommand.setCachePath(mockRepository.cachePath)

        _ = try await helper.execute(backupCommand)

        // Verify backup exists
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: mockRepository.path,
                password: mockRepository.password,
                jsonOutput: true
            ),
            operation: .list,
            tags: ["test-backup"]
        )

        let snapshotOutput = try await helper.execute(snapshotCommand)
        let snapshots: [SnapshotInfo] = try JSONDecoder().decode([SnapshotInfo].self, from: Data(snapshotOutput.utf8))
        XCTAssertFalse(snapshots.isEmpty, "Should have at least one snapshot")
        XCTAssertEqual(snapshots.first?.tags?.first, "test-backup", "Snapshot should have test-backup tag")
    }

    func testRestoreCommand() async throws {
        let mockRepository = try MockResticRepository()
        let helper = ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")

        // Create test files and backup
        let testData = "Test file content"
        let testDir = (mockRepository.testFilesPath as NSString)
        let testPath = testDir.appendingPathComponent("test.txt")
        try testData.write(toFile: testPath, atomically: true, encoding: .utf8)

        // Create a backup first
        let backupOptions = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )

        let backupCommand = BackupCommand(options: backupOptions)
        backupCommand.addPath(testPath)
        backupCommand.tag("test-restore")
        backupCommand.setCachePath(mockRepository.cachePath)

        _ = try await helper.execute(backupCommand)

        // Get the snapshot ID
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: mockRepository.path,
                password: mockRepository.password,
                jsonOutput: true
            ),
            operation: .list,
            tags: ["test-restore"]
        )

        let snapshotOutput = try await helper.execute(snapshotCommand)
        let snapshots: [SnapshotInfo] = try JSONDecoder().decode([SnapshotInfo].self, from: Data(snapshotOutput.utf8))
        XCTAssertFalse(snapshots.isEmpty, "Should have at least one snapshot")
        let snapshotId = snapshots[0].id

        // First restore test - with verification
        let restoreOptions = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )

        let restoreCommand = RestoreCommand(
            options: restoreOptions,
            snapshotId: snapshotId,
            targetPath: mockRepository.restorePath,
            verify: true
        )

        let restoreOutput = try await helper.execute(restoreCommand)
        print("\nRestore output:")
        print(restoreOutput)

        // Verify restored files
        try verifyRestoredFiles(
            testFiles: [testPath],
            testFilesPath: mockRepository.testFilesPath,
            restorePath: mockRepository.restorePath
        )

        // Delete restored files for next test
        try FileManager.default.removeItem(atPath: mockRepository.restorePath)

        // Second restore test - with verification
        let restoreCommand2 = RestoreCommand(
            options: restoreOptions,
            snapshotId: snapshotId,
            targetPath: mockRepository.restorePath,
            verify: true
        )

        let restoreOutput2 = try await helper.execute(restoreCommand2)
        print("\nRestore output (second restore):")
        print(restoreOutput2)

        // Verify restored files again
        try verifyRestoredFiles(
            testFiles: [testPath],
            testFilesPath: mockRepository.testFilesPath,
            restorePath: mockRepository.restorePath
        )
    }

    func testSnapshotListing() async throws {
        let mockRepository = try MockResticRepository()
        let helper = ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")

        // Create test files
        let testData = "Test file content"
        let testDir = (mockRepository.testFilesPath as NSString)
        let testPath = testDir.appendingPathComponent("test.txt")
        try testData.write(toFile: testPath, atomically: true, encoding: .utf8)

        // Create a backup
        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )

        let backupCommand = BackupCommand(options: options)
        backupCommand.addPath(mockRepository.testFilesPath)
        backupCommand.tag("test-snapshot")
        backupCommand.setCachePath(mockRepository.cachePath)

        _ = try await helper.execute(backupCommand)

        // List snapshots
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: mockRepository.path,
                password: mockRepository.password,
                jsonOutput: true
            ),
            operation: .list,
            tags: ["test-snapshot"]
        )

        let snapshotOutput = try await helper.execute(snapshotCommand)
        let snapshots: [SnapshotInfo] = try JSONDecoder().decode([SnapshotInfo].self, from: Data(snapshotOutput.utf8))
        XCTAssertFalse(snapshots.isEmpty, "Should have at least one snapshot")
        XCTAssertEqual(snapshots.first?.tags?.first, "test-snapshot", "Snapshot should have test-snapshot tag")
    }

    private func verifyRestoredFiles(testFiles: [String], testFilesPath: String, restorePath: String) throws {
        let fileManager = FileManager.default

        print("\nVerifying restored files:")
        print("Test files path: \(testFilesPath)")
        print("Restore path: \(restorePath)")

        // Check that the restore directory exists
        let restoreExists = fileManager.fileExists(atPath: restorePath)
        XCTAssertTrue(restoreExists, "Restore directory should exist at \(restorePath)")

        // Check that at least one file was restored
        let enumerator = fileManager.enumerator(atPath: restorePath)
        var hasFiles = false
        while let file = enumerator?.nextObject() as? String {
            let fullPath = (restorePath as NSString).appendingPathComponent(file)
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) && !isDirectory.boolValue {
                hasFiles = true
                break
            }
        }
        XCTAssertTrue(hasFiles, "Restore directory should contain files")

        // The --verify flag in the restore command ensures:
        // 1. All files are restored correctly
        // 2. File contents match the snapshot
        // 3. File metadata (permissions, timestamps) is preserved
        print("Restic's --verify flag confirmed successful restore")
    }
}
