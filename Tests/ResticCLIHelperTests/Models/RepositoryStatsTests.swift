@testable import ResticCLIHelper
import XCTest

final class RepositoryStatsTests: XCTestCase {
  func testRepositoryStatsDecoding() throws {
    let json = """
      {
          "total_size": 1073741824,
          "total_file_count": 1000,
          "total_blob_count": 2000,
          "snapshots_count": 5,
          "total_uncompressed_size": 2147483648,
          "compression_ratio": 0.5,
          "compression_progress": 100.0,
          "compression_space_saving": 0.5
      }
      """

    let data = json.data(using: .utf8)!
    let stats = try JSONDecoder().decode(RepositoryStats.self, from: data)

    XCTAssertEqual(stats.totalSize, 1_073_741_824)
    XCTAssertEqual(stats.totalFileCount, 1_000)
    XCTAssertEqual(stats.totalBlobCount, 2_000)
    XCTAssertEqual(stats.snapshotsCount, 5)
    XCTAssertEqual(stats.totalUncompressedSize, 2_147_483_648)
    XCTAssertEqual(stats.compressionRatio, 0.5)
    XCTAssertEqual(stats.compressionProgress, 100.0)
    XCTAssertEqual(stats.compressionSpaceSaving, 0.5)
  }
}
