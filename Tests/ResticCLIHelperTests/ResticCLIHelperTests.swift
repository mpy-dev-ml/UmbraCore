// CryptoKit removed - cryptography will be handled in ResticBar
import Foundation
@testable import ResticCLIHelper
@testable import ResticCLIHelperCommands
@testable import ResticCLIHelperModels
@testable import ResticCLIHelperTypes
import ResticTypes
import UmbraTestKit
import XCTest

// Custom command type for ls
struct LsCommand: ResticCommand {
    let options: CommonOptions
    let snapshotId: String

    var commandName: String { "ls" }

    var arguments: [String] {
        var args = [commandName]
        args.append(contentsOf: options.arguments)
        args.append(snapshotId)
        return args
    }

    var environment: [String: String] {
        var env = options.environmentVariables
        env["RESTIC_PASSWORD"] = options.password
        env["RESTIC_REPOSITORY"] = options.repository
        return env
    }

    func validate() throws {
        guard !snapshotId.isEmpty else {
            throw ResticCLIHelperTypes.ResticError.missingParameter("snapshot ID is required")
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
        let helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")

        // Create test files
        let testFilePath = (mockRepository.testFilesPath as NSString).appendingPathComponent("test.txt")
        let testData = "Test data for backup"
        try testData.write(toFile: testFilePath, atomically: true, encoding: .utf8)

        // Create and execute backup command
        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )
        
        let backupCommand = BackupCommand(
            paths: [mockRepository.testFilesPath],
            tags: ["test", "backup"],
            options: options
        )

        let output = try await helper.testExecute(backupCommand)
        XCTAssertTrue(output.contains("snapshot"), "Backup output should contain snapshot information")
    }

    func testInitCommand() async throws {
        let helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")

        // Create and execute init command
        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: false,
            jsonOutput: true
        )
        
        let initCommand = InitCommand(options: options)

        let output = try await helper.testExecute(initCommand)
        XCTAssertTrue(output.contains("created restic repository"), "Init should contain repository creation message")
    }

    func testRestoreCommand() async throws {
        // Create a file to backup
        let testPath = (mockRepository.testFilesPath as NSString).appendingPathComponent("restore-test.txt")
        let testData = "Test data for restore"
        try testData.write(toFile: testPath, atomically: true, encoding: .utf8)

        // Create helper and backup the file
        let helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")
        
        let backupOptions = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )
        
        let backupCommand = BackupCommand(
            paths: [mockRepository.testFilesPath],
            tags: ["restore-test"],
            options: backupOptions
        )
        
        let backupOutput = try await helper.testExecute(backupCommand)
        XCTAssertTrue(backupOutput.contains("snapshot"), "Backup output should contain snapshot information")

        // Get latest snapshot
        let snapshotOptions = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            jsonOutput: true
        )
        
        let snapshotCommand = SnapshotCommand(
            options: snapshotOptions,
            operation: .list,
            tags: ["restore-test"]
        )
        
        let snapshotsOutput = try await helper.testExecute(snapshotCommand)
        
        // Parse JSON output manually
        guard let jsonData = snapshotsOutput.data(using: String.Encoding.utf8),
              let snapshots = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
              !snapshots.isEmpty,
              let snapshotId = snapshots[0]["id"] as? String
        else {
            XCTFail("Failed to parse snapshots output")
            return
        }
        
        // Remove original file
        try FileManager.default.removeItem(atPath: testPath)
        
        // Restore the file
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
        
        let restoreOutput = try await helper.testExecute(restoreCommand)
        XCTAssertTrue(restoreOutput.contains("restoring") || restoreOutput.contains("\"files_restored\""), 
                      "Restore output should contain restoration information")
        
        // Verify restored file
        let restoredFilePath = (mockRepository.restorePath as NSString)
            .appendingPathComponent("restore-test.txt")
        
        let restoredData = try String(contentsOfFile: restoredFilePath, encoding: .utf8)
        XCTAssertEqual(restoredData, testData, "Restored data should match original data")
    }

    func testSnapshotCommand() async throws {
        // Create test files
        let testPath = (mockRepository.testFilesPath as NSString).appendingPathComponent("snapshot-test.txt")
        let testData = "Test data for snapshot"
        try testData.write(toFile: testPath, atomically: true, encoding: .utf8)
        
        let helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")
        
        // Create backup
        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            validateCredentials: true,
            jsonOutput: true
        )
        
        let backupCommand = BackupCommand(
            paths: [mockRepository.testFilesPath],
            tags: ["snapshot-test"],
            options: options
        )
        
        _ = try await helper.testExecute(backupCommand)
        
        // List snapshots
        let snapshotCommand = SnapshotCommand(
            options: CommonOptions(
                repository: mockRepository.path,
                password: mockRepository.password,
                jsonOutput: true
            ),
            operation: .list,
            tags: ["snapshot-test"]
        )
        
        let output = try await helper.testExecute(snapshotCommand)
        XCTAssertTrue(output.contains("snapshot") || output.contains("\"id\""), 
                      "Snapshots output should contain snapshot information")
        XCTAssertTrue(output.contains("snapshot-test"), "Snapshots output should contain our tag")
    }
}
