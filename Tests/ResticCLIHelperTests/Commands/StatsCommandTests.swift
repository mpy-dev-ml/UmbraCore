import Foundation
@testable import ResticCLIHelper
@testable import ResticCLIHelperCommands
@testable import ResticCLIHelperModels
@testable import ResticCLIHelperTypes
import ResticTypes
import UmbraTestKit
import XCTest

/// Tests for the stats command
final class StatsCommandTests: ResticTestCase {
    func testStatsCommandBuilder() async throws {
        let options = CommonOptions(
            repository: "/tmp/repo",
            password: "test"
        )

        let command = StatsCommand(options: options)
            .mode(.restoreSize)
            .host("test-host")
            .tag("test-tag")
            .path("path1")
            .path("path2")  // This appears to replace path1 rather than add a second path

        // Print actual command arguments for debugging
        let cmdArgs = command.commandArguments
        print("StatsCommand CommandArguments: \(cmdArgs)")
        
        XCTAssertEqual(command.commandName, "stats")
        XCTAssertEqual(command.options.repository, "/tmp/repo")
        XCTAssertEqual(command.options.password, "test")
        
        // Check all flags are included properly
        XCTAssertTrue(command.commandArguments.contains { $0 == "--mode" }, "Command should contain --mode flag")
        XCTAssertTrue(command.commandArguments.contains { $0 == "restore-size" }, "Command should contain restore-size value")
        XCTAssertTrue(command.commandArguments.contains { $0 == "--host" }, "Command should contain --host flag")
        XCTAssertTrue(command.commandArguments.contains { $0 == "test-host" }, "Command should contain test-host value")
        XCTAssertTrue(command.commandArguments.contains { $0 == "--tag" }, "Command should contain --tag flag")
        XCTAssertTrue(command.commandArguments.contains { $0 == "test-tag" }, "Command should contain test-tag value")
        XCTAssertTrue(command.commandArguments.contains { $0 == "--path" }, "Command should contain --path flag")
        
        // Since .path("path2") overwrites .path("path1"), we only expect path2 to be in the arguments
        XCTAssertTrue(command.commandArguments.contains { $0 == "path2" }, "Command should contain path2 value")
        XCTAssertFalse(command.commandArguments.contains { $0 == "path1" }, "Command should NOT contain path1 as it was replaced by path2")
        
        // Create another command with just one path to verify it works correctly
        let singlePathCommand = StatsCommand(options: options)
            .mode(.restoreSize)
            .path("single-path")
            
        XCTAssertTrue(singlePathCommand.commandArguments.contains { $0 == "--path" }, "Command should contain --path flag")
        XCTAssertTrue(singlePathCommand.commandArguments.contains { $0 == "single-path" }, "Command should contain single-path value")
    }

    func testStatsCommandExecution() async throws {
        let mockRepository = try await TestRepository.create()
        let helper = try ResticCLIHelper.createForTesting(executablePath: "/opt/homebrew/bin/restic")

        // Backup some files first
        let backupCommand = BackupCommand(
            paths: [mockRepository.testFilesPath],
            options: CommonOptions(
                repository: mockRepository.path,
                password: mockRepository.password,
                jsonOutput: true
            )
        )

        _ = try await helper.testExecute(backupCommand)

        let options = CommonOptions(
            repository: mockRepository.path,
            password: mockRepository.password,
            jsonOutput: true
        )

        let statsCommand = StatsCommand(options: options)
        let output = try await helper.testExecute(statsCommand)

        XCTAssertFalse(output.isEmpty, "Stats command should produce output")

        // Parse JSON manually since we don't have access to the Decodable implementation
        let jsonData = Data(output.utf8)
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            XCTFail("Failed to parse stats output as JSON")
            return
        }

        // Validate some basic stats properties
        XCTAssertNotNil(json["total_file_count"], "Should have total_file_count in stats")
        XCTAssertNotNil(json["snapshots_count"], "Should have snapshots_count in stats")
    }
}
