@testable import ResticCLIHelper
import XCTest

final class SnapshotInfoTests: XCTestCase {
  func testSnapshotInfoDecoding() throws {
    let json="""
      {
          "time": "2025-02-20T12:00:00Z",
          "parent": "abc123",
          "tree": "def456",
          "paths": ["/test/path"],
          "hostname": "test-host",
          "username": "test-user",
          "uid": 501,
          "gid": 20,
          "excludes": ["*.tmp"],
          "tags": ["test"],
          "program_version": "restic 0.17.3",
          "id": "ghi789",
          "short_id": "ghi7"
      }
      """

    let data=json.data(using: .utf8)!
    let decoder=JSONDecoder()
    let snapshot=try decoder.decode(SnapshotInfo.self, from: data)

    XCTAssertEqual(snapshot.hostname, "test-host")
    XCTAssertEqual(snapshot.username, "test-user")
    XCTAssertEqual(snapshot.uid, 501)
    XCTAssertEqual(snapshot.gid, 20)
    XCTAssertEqual(snapshot.paths, ["/test/path"])
    XCTAssertEqual(snapshot.excludes, ["*.tmp"])
    XCTAssertEqual(snapshot.tags, ["test"])
    XCTAssertEqual(snapshot.programVersion, "restic 0.17.3")
    XCTAssertEqual(snapshot.id, "ghi789")
    XCTAssertEqual(snapshot.shortId, "ghi7")
  }
}
