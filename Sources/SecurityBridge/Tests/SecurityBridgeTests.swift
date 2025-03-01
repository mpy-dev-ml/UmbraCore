// SecurityBridgeTests.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import SecurityBridge
import SecureBytes
import UmbraCoreTypes
import Foundation

class SecurityBridgeTests: XCTestCase {
    
    func testVersion() {
        XCTAssertFalse(SecurityBridge.version.isEmpty)
    }
    
    // MARK: - DataAdapter Tests
    
    func testDataAdapter_SecureBytesToData() {
        // Arrange
        let testBytes: [UInt8] = [1, 2, 3, 4, 5]
        let secureBytes = SecureBytes(testBytes)
        
        // Act
        let data = DataAdapter.data(from: secureBytes)
        
        // Assert
        XCTAssertEqual(data.count, testBytes.count)
        XCTAssertEqual([UInt8](data), testBytes)
    }
    
    func testDataAdapter_DataToSecureBytes() {
        // Arrange
        let testBytes: [UInt8] = [5, 4, 3, 2, 1]
        let data = Data(testBytes)
        
        // Act
        let secureBytes = DataAdapter.secureBytes(from: data)
        
        // Assert
        XCTAssertEqual(secureBytes.count, testBytes.count)
        XCTAssertEqual(secureBytes.bytes(), testBytes)
    }
    
    func testDataAdapter_RoundTrip() {
        // Arrange
        let testBytes: [UInt8] = [0, 10, 20, 30, 40, 50]
        let original = SecureBytes(testBytes)
        
        // Act
        let data = DataAdapter.data(from: original)
        let roundTrip = DataAdapter.secureBytes(from: data)
        
        // Assert
        XCTAssertEqual(original, roundTrip)
    }
    
    // MARK: - URLAdapter Tests
    
    func testURLAdapter_URLToResourceLocator() throws {
        // Arrange
        let url = URL(string: "https://example.com/path?query=value#fragment")!
        
        // Act
        let locator = try URLAdapter.resourceLocator(from: url)
        
        // Assert
        XCTAssertEqual(locator.scheme, "https")
        XCTAssertEqual(locator.path, "/path")
        XCTAssertEqual(locator.query, "query=value")
        XCTAssertEqual(locator.fragment, "fragment")
    }
    
    func testURLAdapter_ResourceLocatorToURL() throws {
        // Arrange
        let locator = ResourceLocator(
            scheme: "https",
            path: "/path",
            query: "query=value",
            fragment: "fragment"
        )
        
        // Act
        let url = try URLAdapter.url(from: locator)
        
        // Assert
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.path, "/path")
        XCTAssertEqual(url.query, "query=value")
        XCTAssertEqual(url.fragment, "fragment")
    }
    
    func testURLAdapter_FileURLConversion() throws {
        // Arrange
        let filePath = "/Users/example/Documents/test.txt"
        let fileLocator = ResourceLocator.fileLocator(path: filePath)
        
        // Act
        let fileURL = try URLAdapter.fileURL(from: fileLocator)
        
        // Assert
        XCTAssertEqual(fileURL.path, filePath)
        XCTAssertTrue(fileURL.isFileURL)
    }
    
    // MARK: - DateAdapter Tests
    
    func testDateAdapter_DateToTimePoint() {
        // Arrange
        let timestamp: TimeInterval = 1614502800 // February 28, 2021
        let date = Date(timeIntervalSince1970: timestamp)
        
        // Act
        let timePoint = DateAdapter.timePoint(from: date)
        
        // Assert
        XCTAssertEqual(timePoint.timeIntervalSince1970, timestamp)
    }
    
    func testDateAdapter_TimePointToDate() {
        // Arrange
        let timestamp: TimeInterval = 1709337600 // March 1, 2024
        let timePoint = TimePoint(timeIntervalSince1970: timestamp)
        
        // Act
        let date = DateAdapter.date(from: timePoint)
        
        // Assert
        XCTAssertEqual(date.timeIntervalSince1970, timestamp)
    }
    
    func testDateAdapter_TimePointRoundTrip() {
        // Arrange
        let now = Date()
        
        // Act
        let timePoint = DateAdapter.timePoint(from: now)
        let roundTrip = DateAdapter.date(from: timePoint)
        
        // Assert
        XCTAssertEqual(now.timeIntervalSince1970, roundTrip.timeIntervalSince1970)
    }
    
    func testDateAdapter_Now() {
        // Act
        let now = DateAdapter.now()
        
        // Assert
        XCTAssertFalse(now.timeIntervalSince1970.isZero)
        
        // TimePoint.now() should be somewhat close to the current time
        let currentTime = Date().timeIntervalSince1970
        XCTAssertTrue(abs(now.timeIntervalSince1970 - currentTime) < 10) // Within 10 seconds
    }
}
