@testable import ResticCLIHelper
import ResticTypes
import XCTest

/// Tests for the progress parsing functionality.
final class ProgressTests: XCTestCase {
  /// Mock progress handler for testing.
  private class MockProgressHandler: ResticProgressReporting {
    var backupProgress: [BackupProgress]=[]
    var restoreProgress: [RestoreProgress]=[]

    func progressUpdated(_ progress: Any) {
      if let progress=progress as? BackupProgress {
        backupProgress.append(progress)
      } else if let progress=progress as? RestoreProgress {
        restoreProgress.append(progress)
      }
    }
  }

  func testBackupProgressParsing() throws {
    let handler=MockProgressHandler()
    let parser=ProgressParser(delegate: handler)

    // Test scanning phase
    let scanningJSON="""
      {
        "message_type": "scanning",
        "total_files": 100,
        "total_bytes": 1048576,
        "files_done": 50,
        "bytes_done": 524288,
        "current_file": "/path/to/file.txt",
        "seconds_elapsed": 5.5
      }
      """
    XCTAssertTrue(parser.parseLine(scanningJSON))
    XCTAssertEqual(handler.backupProgress.count, 1)
    XCTAssertEqual(handler.backupProgress[0].status, .scanning)
    XCTAssertEqual(handler.backupProgress[0].totalFiles, 100)
    XCTAssertEqual(handler.backupProgress[0].totalBytes, 1_048_576)
    XCTAssertEqual(handler.backupProgress[0].processedFiles, 50)
    XCTAssertEqual(handler.backupProgress[0].processedBytes, 524_288)
    XCTAssertEqual(handler.backupProgress[0].currentFile, "/path/to/file.txt")
    XCTAssertEqual(handler.backupProgress[0].secondsElapsed, 5.5)

    // Test processing phase
    let processingJSON="""
      {
        "message_type": "processing",
        "total_files": 100,
        "total_bytes": 1048576,
        "files_done": 75,
        "bytes_done": 786432,
        "current_file": "/path/to/another.txt",
        "seconds_elapsed": 8.2
      }
      """
    XCTAssertTrue(parser.parseLine(processingJSON))
    XCTAssertEqual(handler.backupProgress.count, 2)
    XCTAssertEqual(handler.backupProgress[1].status, .processing)
    XCTAssertEqual(handler.backupProgress[1].totalFiles, 100)
    XCTAssertEqual(handler.backupProgress[1].totalBytes, 1_048_576)
    XCTAssertEqual(handler.backupProgress[1].processedFiles, 75)
    XCTAssertEqual(handler.backupProgress[1].processedBytes, 786_432)
    XCTAssertEqual(handler.backupProgress[1].currentFile, "/path/to/another.txt")
    XCTAssertEqual(handler.backupProgress[1].secondsElapsed, 8.2)
  }

  func testRestoreProgressParsing() throws {
    let handler=MockProgressHandler()
    let parser=ProgressParser(delegate: handler)

    let restoreJSON="""
      {
        "message_type": "restoring",
        "total_files": 50,
        "total_bytes": 524288,
        "files_done": 25,
        "bytes_done": 262144,
        "current_file": "/path/to/restore.txt",
        "seconds_elapsed": 3.2
      }
      """
    XCTAssertTrue(parser.parseLine(restoreJSON))
    XCTAssertEqual(handler.restoreProgress.count, 1)
    XCTAssertEqual(handler.restoreProgress[0].status, .restoring)
    XCTAssertEqual(handler.restoreProgress[0].totalFiles, 50)
    XCTAssertEqual(handler.restoreProgress[0].totalBytes, 524_288)
    XCTAssertEqual(handler.restoreProgress[0].restoredFiles, 25)
    XCTAssertEqual(handler.restoreProgress[0].restoredBytes, 262_144)
    XCTAssertEqual(handler.restoreProgress[0].currentFile, "/path/to/restore.txt")
    XCTAssertEqual(handler.restoreProgress[0].secondsElapsed, 3.2)
  }

  func testInvalidInput() throws {
    let handler=MockProgressHandler()
    let parser=ProgressParser(delegate: handler)

    // Test empty input
    XCTAssertFalse(parser.parseLine(""))

    // Test invalid JSON
    XCTAssertFalse(parser.parseLine("not json"))

    // Test valid JSON but wrong format
    XCTAssertFalse(parser.parseLine("""
      {
        "wrong": "format"
      }
      """))
  }
}
