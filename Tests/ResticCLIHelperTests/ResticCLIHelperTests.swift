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
  let snapshotID: String

  var commandName: String { "ls" }

  var arguments: [String] {
    var args=[commandName]
    args.append(contentsOf: options.arguments)
    args.append(snapshotID)
    return args
  }

  var environment: [String: String] {
    var env=options.environmentVariables
    env["RESTIC_PASSWORD"]=options.password
    env["RESTIC_REPOSITORY"]=options.repository
    return env
  }

  func validate() throws {
    guard !snapshotID.isEmpty else {
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
    let mockRepository=try await TestRepository.create()
    let helper=try ResticCLIHelper(executablePath: "/opt/homebrew/bin/restic")

    // Create test files
    let testFilePath=(mockRepository.testFilesPath as NSString).appendingPathComponent("test.txt")
    try "Test file content".write(toFile: testFilePath, atomically: true, encoding: .utf8)

    // Create a backup
    let options=CommonOptions(
      repository: mockRepository.path,
      password: mockRepository.password,
      validateCredentials: true,
      jsonOutput: true
    )

    let backupCommand=BackupCommand(
      paths: [mockRepository.testFilesPath],
      tags: ["test-snapshot"],
      options: options
    )

    let output=try await helper.execute(backupCommand)
    XCTAssertFalse(output.isEmpty, "Expected output from backup command")

    // List snapshots
    let snapshotCommand=SnapshotCommand(
      options: CommonOptions(
        repository: mockRepository.path,
        password: mockRepository.password,
        validateCredentials: true,
        jsonOutput: true
      ),
      operation: .list,
      tags: ["test-snapshot"]
    )

    let snapshotOutput=try await helper.execute(snapshotCommand)

    // Parse JSON output manually
    guard
      let jsonData=snapshotOutput.data(using: .utf8),
      let snapshots=try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
      !snapshots.isEmpty
    else {
      XCTFail("Failed to parse snapshots output")
      return
    }

    XCTAssertFalse(snapshots.isEmpty, "Expected at least one snapshot")
    if let hostname=snapshots[0]["hostname"] as? String {
      XCTAssertEqual(hostname, Host.current().localizedName ?? "unknown")
    }
  }

  func testRestoreCommand() async throws {
    // Create a file to backup
    let testPath=(mockRepository.testFilesPath as NSString)
      .appendingPathComponent("restore-test.txt")
    let testData="Test data for restore"
    try testData.write(toFile: testPath, atomically: true, encoding: .utf8)

    // Create a backup first
    let backupOptions=CommonOptions(
      repository: mockRepository.path,
      password: mockRepository.password,
      validateCredentials: true,
      jsonOutput: true
    )

    let backupCommand=BackupCommand(
      paths: [testPath],
      tags: ["test-restore"],
      options: backupOptions
    )

    _=try await helper.execute(backupCommand)

    // Get the snapshot ID
    let snapshotCommand=SnapshotCommand(
      options: CommonOptions(
        repository: mockRepository.path,
        password: mockRepository.password,
        jsonOutput: true
      ),
      operation: .list,
      tags: ["test-restore"]
    )

    let snapshotOutput=try await helper.execute(snapshotCommand)

    // Parse JSON output manually
    guard
      let jsonData=snapshotOutput.data(using: .utf8),
      let snapshots=try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
      !snapshots.isEmpty,
      let snapshotID=snapshots[0]["id"] as? String
    else {
      XCTFail("Failed to parse snapshots output")
      return
    }

    // First restore test - with verification
    let restoreOptions=CommonOptions(
      repository: mockRepository.path,
      password: mockRepository.password,
      validateCredentials: true,
      jsonOutput: true
    )

    let restoreCommand=RestoreCommand(
      options: restoreOptions,
      snapshotID: snapshotID,
      targetPath: mockRepository.restorePath,
      verify: true
    )

    _=try await helper.execute(restoreCommand)

    // Verify file was restored
    let restoredPath=(mockRepository.restorePath as NSString)
      .appendingPathComponent((testPath as NSString).lastPathComponent)
    let restoredData=try String(contentsOfFile: restoredPath, encoding: .utf8)
    XCTAssertEqual(restoredData, testData, "Restored file data should match original")

    // Clean up restored files
    try FileManager.default.removeItem(atPath: mockRepository.restorePath)
    try FileManager.default.createDirectory(
      atPath: mockRepository.restorePath,
      withIntermediateDirectories: true
    )

    // Second restore test - without verification
    let restoreCommand2=RestoreCommand(
      options: restoreOptions,
      snapshotID: snapshotID,
      targetPath: mockRepository.restorePath,
      verify: false
    )

    _=try await helper.execute(restoreCommand2)

    // Verify file was restored
    let restoredPath2=(mockRepository.restorePath as NSString)
      .appendingPathComponent((testPath as NSString).lastPathComponent)
    let restoredData2=try String(contentsOfFile: restoredPath2, encoding: .utf8)
    XCTAssertEqual(restoredData2, testData, "Restored file data should match original")
  }

  func testSnapshotCommand() async throws {
    // Create test files
    let testPath=(mockRepository.testFilesPath as NSString)
      .appendingPathComponent("snapshot-test.txt")
    let testData="Test data for snapshot"
    try testData.write(toFile: testPath, atomically: true, encoding: .utf8)

    // Create a backup
    let options=CommonOptions(
      repository: mockRepository.path,
      password: mockRepository.password,
      validateCredentials: true,
      jsonOutput: true
    )

    let backupCommand=BackupCommand(
      paths: [mockRepository.testFilesPath],
      tags: ["test-snapshot"],
      options: options
    )

    _=try await helper.execute(backupCommand)

    // List snapshots
    let snapshotCommand=SnapshotCommand(
      options: CommonOptions(
        repository: mockRepository.path,
        password: mockRepository.password,
        jsonOutput: true
      ),
      operation: .list,
      tags: ["test-snapshot"]
    )

    let snapshotOutput=try await helper.execute(snapshotCommand)

    // Parse JSON output manually
    guard
      let jsonData=snapshotOutput.data(using: .utf8),
      let snapshots=try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
      !snapshots.isEmpty,
      let tags=snapshots[0]["tags"] as? [String]
    else {
      XCTFail("Failed to parse snapshots output")
      return
    }

    XCTAssertFalse(snapshots.isEmpty, "Should have at least one snapshot")
    XCTAssertEqual(tags, ["test-snapshot"])
  }
}
