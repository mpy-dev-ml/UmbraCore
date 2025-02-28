// BinaryDataTests.swift - Tests for Foundation-free implementation
// Part of UmbraCore project
// Created on 2025-02-28

import XCTest
@testable import BinaryData

final class BinaryDataTests: XCTestCase {
    // MARK: - Initialisation Tests
    
    func testEmptyInit() {
        let data = BinaryData()
        XCTAssertEqual(data.count, 0)
        XCTAssertTrue(data.isEmpty)
    }
    
    func testBytesInit() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        let data = BinaryData(bytes: bytes)
        
        XCTAssertEqual(data.count, 4)
        XCTAssertEqual(data.bytes(), bytes)
        XCTAssertFalse(data.isEmpty)
    }
    
    func testStaticBytesInit() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        let data = BinaryData(staticBytes: bytes)
        
        XCTAssertEqual(data.count, 4)
        XCTAssertEqual(data.bytes(), bytes)
    }
    
    func testCountInit() {
        let count = 10
        let data = BinaryData(count: count)
        
        XCTAssertEqual(data.count, count)
        XCTAssertEqual(data.bytes(), Array(repeating: 0, count: count))
    }
    
    func testArrayLiteralInit() {
        let data: BinaryData = [0x01, 0x02, 0x03, 0x04]
        
        XCTAssertEqual(data.count, 4)
        XCTAssertEqual(data.bytes(), [0x01, 0x02, 0x03, 0x04])
    }
    
    // MARK: - Subscription Tests
    
    func testIndexSubscript() {
        let data: BinaryData = [0x01, 0x02, 0x03, 0x04]
        
        XCTAssertEqual(data[0], 0x01)
        XCTAssertEqual(data[1], 0x02)
        XCTAssertEqual(data[2], 0x03)
        XCTAssertEqual(data[3], 0x04)
    }
    
    func testRangeSubscript() {
        let data: BinaryData = [0x01, 0x02, 0x03, 0x04, 0x05]
        let subData = data[1..<4]
        
        XCTAssertEqual(subData.count, 3)
        XCTAssertEqual(subData.bytes(), [0x02, 0x03, 0x04])
    }
    
    // MARK: - Method Tests
    
    func testAppendingBinaryData() {
        let data1: BinaryData = [0x01, 0x02]
        let data2: BinaryData = [0x03, 0x04]
        
        let combined = data1.appending(data2)
        
        XCTAssertEqual(combined.count, 4)
        XCTAssertEqual(combined.bytes(), [0x01, 0x02, 0x03, 0x04])
    }
    
    func testAppendingByte() {
        let data: BinaryData = [0x01, 0x02]
        let result = data.appending(byte: 0x03)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.bytes(), [0x01, 0x02, 0x03])
    }
    
    func testHexEncodedString() {
        let data: BinaryData = [0x01, 0xAB, 0xCD, 0xEF]
        let hexString = data.hexEncodedString()
        
        XCTAssertEqual(hexString, "01abcdef")
    }
    
    // MARK: - Conversion Tests
    
    func testFromHexEncodedString() {
        let hexString = "01abcdef"
        let data = BinaryData.fromHexEncodedString(hexString)
        
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.bytes(), [0x01, 0xAB, 0xCD, 0xEF])
    }
    
    func testFromInvalidHexString() {
        let invalidHexString = "01abcdefg"
        let data = BinaryData.fromHexEncodedString(invalidHexString)
        
        XCTAssertNil(data)
    }
    
    func testFromOddLengthHexString() {
        let oddLengthHexString = "01abc"
        let data = BinaryData.fromHexEncodedString(oddLengthHexString)
        
        XCTAssertNil(data)
    }
    
    // MARK: - Equatable and Hashable Tests
    
    func testEquatable() {
        let data1: BinaryData = [0x01, 0x02, 0x03]
        let data2: BinaryData = [0x01, 0x02, 0x03]
        let data3: BinaryData = [0x01, 0x02, 0x04]
        
        XCTAssertEqual(data1, data2)
        XCTAssertNotEqual(data1, data3)
    }
    
    func testHashable() {
        let data1: BinaryData = [0x01, 0x02, 0x03]
        let data2: BinaryData = [0x01, 0x02, 0x03]
        
        var set = Set<BinaryData>()
        set.insert(data1)
        
        XCTAssertTrue(set.contains(data2))
    }
}
