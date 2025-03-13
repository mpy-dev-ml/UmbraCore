import Foundation
import KeyManagementTypes
import XCTest

final class KeyStatusTests: XCTestCase {
    // MARK: - Canonical Type Tests

    func testCanonicalKeyStatusEquality() {
        let active1 = KeyManagementTypes.KeyStatus.active
        let active2 = KeyManagementTypes.KeyStatus.active
        let compromised = KeyManagementTypes.KeyStatus.compromised
        let retired = KeyManagementTypes.KeyStatus.retired
        let date = Date()
        let pendingDeletion = KeyManagementTypes.KeyStatus.pendingDeletion(date)

        XCTAssertEqual(active1, active2)
        XCTAssertNotEqual(active1, compromised)
        XCTAssertNotEqual(active1, retired)
        XCTAssertNotEqual(active1, pendingDeletion)
        XCTAssertNotEqual(compromised, retired)
        XCTAssertNotEqual(compromised, pendingDeletion)
        XCTAssertNotEqual(retired, pendingDeletion)

        // Test that pendingDeletion with the same date is equal
        let pendingDeletion2 = KeyManagementTypes.KeyStatus.pendingDeletion(date)
        XCTAssertEqual(pendingDeletion, pendingDeletion2)

        // Test that pendingDeletion with different dates is not equal
        let differentDate = Date(timeIntervalSince1970: date.timeIntervalSince1970 + 100)
        let pendingDeletion3 = KeyManagementTypes.KeyStatus.pendingDeletion(differentDate)
        XCTAssertNotEqual(pendingDeletion, pendingDeletion3)
    }

    func testCanonicalKeyStatusTimestampConversion() {
        // Test timestamp-based creation and conversion
        let timestamp: Int64 = 1_627_084_800 // July 24, 2021 00:00:00 UTC
        let status = KeyManagementTypes.KeyStatus.pendingDeletionWithTimestamp(timestamp)

        // Extract the timestamp and check that it matches the original
        if let extractedTimestamp = status.getDeletionTimestamp() {
            XCTAssertEqual(extractedTimestamp, timestamp)
        } else {
            XCTFail("Failed to extract timestamp from pendingDeletion status")
        }

        // Verify other status types return nil for getDeletionTimestamp
        XCTAssertNil(KeyManagementTypes.KeyStatus.active.getDeletionTimestamp())
        XCTAssertNil(KeyManagementTypes.KeyStatus.compromised.getDeletionTimestamp())
        XCTAssertNil(KeyManagementTypes.KeyStatus.retired.getDeletionTimestamp())
    }

    func testCanonicalKeyStatusCodable() throws {
        // Test encoding and decoding simple status
        let active = KeyManagementTypes.KeyStatus.active
        let encoder = JSONEncoder()
        let activeData = try encoder.encode(active)
        let decoder = JSONDecoder()
        let decodedActive = try decoder.decode(KeyManagementTypes.KeyStatus.self, from: activeData)
        XCTAssertEqual(active, decodedActive)

        // Test encoding and decoding pendingDeletion with date
        let date = Date()
        let pendingDeletion = KeyManagementTypes.KeyStatus.pendingDeletion(date)
        let pendingData = try encoder.encode(pendingDeletion)
        let decodedPending = try decoder.decode(KeyManagementTypes.KeyStatus.self, from: pendingData)
        XCTAssertEqual(pendingDeletion, decodedPending)
    }

    // MARK: - Raw Status Conversion Tests

    func testRawStatusConversion() {
        let date = Date()
        let timestamp: Int64 = 1_627_084_800

        // Test conversion to raw status
        XCTAssertEqual(KeyStatus.active.toRawStatus(), .active)
        XCTAssertEqual(KeyStatus.compromised.toRawStatus(), .compromised)
        XCTAssertEqual(KeyStatus.retired.toRawStatus(), .retired)
        XCTAssertEqual(KeyStatus.pendingDeletion(date).toRawStatus(), .pendingDeletion(date))

        // Test creation from raw status
        XCTAssertEqual(KeyStatus.from(rawStatus: .active), .active)
        XCTAssertEqual(KeyStatus.from(rawStatus: .compromised), .compromised)
        XCTAssertEqual(KeyStatus.from(rawStatus: .retired), .retired)
        XCTAssertEqual(KeyStatus.from(rawStatus: .pendingDeletion(date)), .pendingDeletion(date))
        XCTAssertEqual(
            KeyStatus.from(rawStatus: .pendingDeletionWithTimestamp(timestamp)),
            .pendingDeletionWithTimestamp(timestamp)
        )
    }

    // MARK: - RawStatus Enum Tests

    func testRawStatusEquality() {
        let date1 = Date()
        let date2 = Date(timeIntervalSince1970: date1.timeIntervalSince1970)
        let date3 = Date(timeIntervalSince1970: date1.timeIntervalSince1970 + 100)
        let timestamp1 = Int64(date1.timeIntervalSince1970)
        let timestamp2 = Int64(date2.timeIntervalSince1970)
        let timestamp3 = Int64(date3.timeIntervalSince1970)

        // Test equality for simple cases
        XCTAssertEqual(KeyStatus.RawStatus.active, KeyStatus.RawStatus.active)
        XCTAssertNotEqual(KeyStatus.RawStatus.active, KeyStatus.RawStatus.compromised)

        // Test equality for date-based cases
        XCTAssertEqual(
            KeyStatus.RawStatus.pendingDeletion(date1),
            KeyStatus.RawStatus.pendingDeletion(date2)
        )
        XCTAssertNotEqual(
            KeyStatus.RawStatus.pendingDeletion(date1),
            KeyStatus.RawStatus.pendingDeletion(date3)
        )

        // Test equality for timestamp-based cases
        XCTAssertEqual(
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp1),
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp2)
        )
        XCTAssertNotEqual(
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp1),
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp3)
        )

        // Test equality between date and timestamp cases
        XCTAssertEqual(
            KeyStatus.RawStatus.pendingDeletion(date1),
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp1)
        )
        XCTAssertEqual(
            KeyStatus.RawStatus.pendingDeletionWithTimestamp(timestamp1),
            KeyStatus.RawStatus.pendingDeletion(date1)
        )
    }
}
