import Foundation
@testable import ResticCLIHelper
import UmbraTestKit
import XCTest

final class RepositoryManagementTests: ResticTestCase {
  func testInitCommand() async throws {
    // Create a new directory for the repository
    let repoPath=URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("restic_tests_\(UUID().uuidString)")
      .appendingPathComponent("repo")
      .path

    let helper=ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")

    // Initialize a new repository
    let options=CommonOptions(
      repository: repoPath,
      password: "test-password",
      validateCredentials: true,
      jsonOutput: true
    )

    let initCommand=InitCommand(options: options)
    let output=try await helper.execute(initCommand)

    // Parse JSON output
    struct InitOutput: Codable {
      let messageType: String
      let id: String
      let repository: String

      enum CodingKeys: String, CodingKey {
        case messageType="message_type"
        case id
        case repository
      }
    }

    let initInfo=try JSONDecoder().decode(InitOutput.self, from: Data(output.utf8))
    XCTAssertEqual(initInfo.messageType, "initialized", "Message type should be 'initialized'")
    XCTAssertEqual(initInfo.repository, repoPath, "Repository path should match")
    XCTAssertEqual(initInfo.id.count, 64, "Repository ID should be 64 characters (32 bytes hex)")

    // Verify repository exists and is valid
    let checkCommand=CheckCommand(options: options)
    let checkOutput=try await helper.execute(checkCommand)
    XCTAssertTrue(checkOutput.contains("no errors were found"), "Repository check should pass")
  }

  func testCopyCommand() async throws {
    let sourceRepo=try await TestRepository.create()
    let targetRepo=try await TestRepository.create()
    let helper=ResticCLIHelper()

    // Create a backup in source repository
    let backupCommand=BackupCommand(
      options: CommonOptions(
        repository: sourceRepo.path,
        password: sourceRepo.password,
        validateCredentials: true,
        jsonOutput: true
      )
    )
    backupCommand.addPath(sourceRepo.testFilesPath)
    backupCommand.tag("test-copy")
    print("Backup command arguments: \(backupCommand.arguments)")
    print("Backup command environment: \(backupCommand.environment)")
    let backupOutput=try await helper.execute(backupCommand)
    print("Backup output: \(backupOutput)")

    // Verify backup was created
    struct BackupMessage: Codable {
      let messageType: String
      let filesNew: Int?
      let snapshotId: String?

      enum CodingKeys: String, CodingKey {
        case messageType="message_type"
        case filesNew="files_new"
        case snapshotId="snapshot_id"
      }
    }

    // Split output into lines and parse each line as JSON
    var foundSummary=false
    var newFiles=0
    var snapshotId: String?
    for line in backupOutput.split(separator: "\n") {
      if
        let data=line.data(using: .utf8),
        let message=try? JSONDecoder().decode(BackupMessage.self, from: data),
        message.messageType == "summary"
      {
        foundSummary=true
        newFiles=message.filesNew ?? 0
        snapshotId=message.snapshotId
        break
      }
    }

    XCTAssertTrue(foundSummary, "Expected backup summary")
    XCTAssertGreaterThan(newFiles, 0, "Expected new files to be backed up")
    XCTAssertNotNil(snapshotId, "Expected snapshot ID in backup summary")

    // Wait for backup to complete
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

    // Get snapshot ID
    let snapshotCommand=SnapshotCommand(
      options: CommonOptions(
        repository: sourceRepo.path,
        password: sourceRepo.password,
        validateCredentials: true,
        jsonOutput: true
      ),
      operation: .list,
      tags: ["test-copy"]
    )
    print("Snapshot command arguments: \(snapshotCommand.arguments)")
    print("Snapshot command environment: \(snapshotCommand.environment)")
    let snapshotOutput=try await helper.execute(snapshotCommand)
    print("Snapshot output: \(snapshotOutput)")

    // Add a small delay to ensure snapshot is fully written
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

    let snapshotInfo=try JSONDecoder().decode([SnapshotInfo].self, from: Data(snapshotOutput.utf8))

    XCTAssertFalse(snapshotInfo.isEmpty, "Expected at least one snapshot")
    guard !snapshotInfo.isEmpty else {
      throw ResticError.missingParameter("No snapshots found with tag 'test-copy'")
    }
    let snapshotIdFromList=snapshotInfo[0].id
    XCTAssertEqual(snapshotId, snapshotIdFromList, "Snapshot IDs should match")

    // Copy snapshots from source to target
    let copyCommand=CopyCommand(
      options: CommonOptions(
        repository: sourceRepo.path,
        password: sourceRepo.password,
        validateCredentials: true,
        jsonOutput: true
      ),
      snapshotIds: [snapshotIdFromList],
      targetRepository: targetRepo.path,
      targetPassword: targetRepo.password
    )
    _=try await helper.execute(copyCommand)

    // Verify snapshot was copied
    let targetSnapshotCommand=SnapshotCommand(
      options: CommonOptions(
        repository: targetRepo.path,
        password: targetRepo.password,
        validateCredentials: true,
        jsonOutput: true
      ),
      operation: .list
    )
    let targetOutput=try await helper.execute(targetSnapshotCommand)
    let targetSnapshots=try JSONDecoder().decode([SnapshotInfo].self, from: Data(targetOutput.utf8))
    XCTAssertEqual(targetSnapshots.count, 1, "Expected 1 snapshot to be copied")
    XCTAssertEqual(targetSnapshots[0].tree, snapshotInfo[0].tree, "Snapshot tree hash should match")
    XCTAssertEqual(targetSnapshots[0].paths, snapshotInfo[0].paths, "Snapshot paths should match")

    // Clean up
    try sourceRepo.cleanup()
    try targetRepo.cleanup()
  }

  func testCheckCommand() async throws {
    // Create a new directory for the repository
    let repoPath=URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("restic_tests_\(UUID().uuidString)")
      .appendingPathComponent("repo")
      .path

    let helper=ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")

    // Initialize repository
    let options=CommonOptions(
      repository: repoPath,
      password: "test-password",
      validateCredentials: true,
      jsonOutput: true
    )

    let initCommand=InitCommand(options: options)
    _=try await helper.execute(initCommand)

    // Run check command
    let checkCommand=CheckCommand(options: options)
    let output=try await helper.execute(checkCommand)
    XCTAssertTrue(output.contains("no errors were found"), "Repository check should pass")
  }
}
