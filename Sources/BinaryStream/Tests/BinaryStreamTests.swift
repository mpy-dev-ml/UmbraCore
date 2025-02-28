// BinaryStreamTests.swift - Tests for Foundation-free implementation
// Part of UmbraCore project
// Created on 2025-02-28

import XCTest
@testable import BinaryStream

final class BinaryStreamTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: BinaryStream!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        sut = BinaryStream()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialisation() {
        XCTAssertNotNil(sut)
    }
    
    func testExampleMethod() {
        XCTAssertTrue(sut.exampleMethod())
    }
}
