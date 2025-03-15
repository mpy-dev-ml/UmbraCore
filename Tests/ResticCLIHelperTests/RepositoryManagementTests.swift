import Foundation
@testable import ResticCLIHelper
@testable import ResticCLIHelperCommands
@testable import ResticCLIHelperModels
@testable import ResticCLIHelperTypes
import ResticTypes
import UmbraTestKit
import XCTest

/// Tests for repository initialization and management commands
final class RepositoryManagementTests: ResticTestCase {
    func testInitAndCheck() async throws {
        // Set up a clean repository
        let tempPath = NSTemporaryDirectory()
        let repoPath = (tempPath as NSString).appendingPathComponent("clean-repo")
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)

        let helper = try ResticCLIHelper(executablePath: "/opt/homebrew/bin/restic")

        // Initialize a new repository
        let options = CommonOptions(
            repository: repoPath,
            password: "test-password",
            validateCredentials: true,
            jsonOutput: false
        )

        let initCommand = InitCommand(options: options)
        let output = try await helper.execute(initCommand)
        XCTAssertTrue(output.contains("created restic repository"), "Repository should be created")

        // Check repository structure
        let repoFiles = try FileManager.default.contentsOfDirectory(atPath: repoPath)
        XCTAssertTrue(repoFiles.contains("config"), "Repository should contain config file")
        XCTAssertTrue(repoFiles.contains("data"), "Repository should contain data directory")
        XCTAssertTrue(repoFiles.contains("index"), "Repository should contain index directory")
        XCTAssertTrue(repoFiles.contains("keys"), "Repository should contain keys directory")
        XCTAssertTrue(repoFiles.contains("snapshots"), "Repository should contain snapshots directory")

        // Verify repository exists and is valid
        let checkCommand = CheckCommand(options: options)
        let checkOutput = try await helper.execute(checkCommand)
        XCTAssertTrue(checkOutput.contains("no errors were found"), "Repository check should pass")
    }

    func testRepositoryCopy() async throws {
        let sourceRepo = try await TestRepository.create()
        let tempPath = NSTemporaryDirectory()
        let destRepoPath = (tempPath as NSString).appendingPathComponent("dest-repo")
        try FileManager.default.createDirectory(atPath: destRepoPath, withIntermediateDirectories: true)

        let helper = try ResticCLIHelper(executablePath: "/opt/homebrew/bin/restic")

        // Create a backup in source repository
        let backupCommand = BackupCommand(
            paths: [sourceRepo.testFilesPath],
            tags: ["test-copy"],
            options: CommonOptions(
                repository: sourceRepo.path,
                password: sourceRepo.password,
                validateCredentials: true,
                jsonOutput: true
            )
        )
        _ = try await helper.execute(backupCommand)

        // Initialize destination repository
        let initCommand = InitCommand(
            options: CommonOptions(
                repository: destRepoPath,
                password: "dest-password",
                validateCredentials: true,
                jsonOutput: true
            )
        )
        _ = try await helper.execute(initCommand)

        // Get snapshot IDs from source repository
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: sourceRepo.path,
                password: sourceRepo.password,
                validateCredentials: true,
                jsonOutput: true
            ),
            operation: .list,
            tags: ["test-copy"]
        )
        let snapshotOutput = try await helper.execute(snapshotCommand)

        // Parse JSON output manually
        guard let jsonData = snapshotOutput.data(using: .utf8),
              let snapshots = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
              !snapshots.isEmpty,
              let snapshotId = snapshots[0]["id"] as? String
        else {
            XCTFail("Failed to parse snapshots output")
            return
        }

        // Copy from source to destination repository
        let copyCommand = CopyCommand(
            options: CommonOptions(
                repository: sourceRepo.path,
                password: sourceRepo.password,
                validateCredentials: true,
                jsonOutput: true
            ),
            snapshotIds: [snapshotId],
            targetRepository: destRepoPath,
            targetPassword: "dest-password"
        )
        let copyOutput = try await helper.execute(copyCommand)
        XCTAssertTrue(copyOutput.contains("snapshot"), "Copy command should copy at least one snapshot")

        // Check destination repository
        let checkCommand = CheckCommand(
            options: CommonOptions(
                repository: destRepoPath,
                password: "dest-password",
                validateCredentials: true,
                jsonOutput: true
            )
        )
        let checkOutput = try await helper.execute(checkCommand)
        XCTAssertTrue(checkOutput.contains("no errors were found"), "Destination repository check should pass")
    }

    func testBackupAndRestore() async throws {
        let sourceRepo = try await TestRepository.create()
        let helper = try ResticCLIHelper(executablePath: "/opt/homebrew/bin/restic")

        // Get snapshot ID
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: sourceRepo.path,
                password: sourceRepo.password,
                validateCredentials: true,
                jsonOutput: true
            ),
            operation: .list,
            tags: []
        )
        let snapshotOutput = try await helper.execute(snapshotCommand)

        // Parse JSON output manually
        guard let jsonData = snapshotOutput.data(using: .utf8),
              let snapshots = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
              !snapshots.isEmpty,
              let snapshotId = snapshots[0]["id"] as? String
        else {
            XCTFail("Failed to parse snapshots output")
            return
        }

        // Restore files from snapshot
        let restoreOptions = CommonOptions(
            repository: sourceRepo.path,
            password: sourceRepo.password,
            validateCredentials: true,
            jsonOutput: true
        )

        let restoreCommand = RestoreCommand(
            options: restoreOptions,
            snapshotId: snapshotId,
            targetPath: sourceRepo.restorePath,
            verify: true
        )
        _ = try await helper.execute(restoreCommand)

        // Verify restored files
        let fileManager = FileManager.default
        let restoredFiles = try fileManager.contentsOfDirectory(atPath: sourceRepo.restorePath)
        XCTAssertTrue(
            restoredFiles.contains(where: { $0.contains("test1.txt") }),
            "test1.txt should be restored"
        )
        XCTAssertTrue(
            restoredFiles.contains(where: { $0.contains("test2.txt") }),
            "test2.txt should be restored"
        )
    }
}
