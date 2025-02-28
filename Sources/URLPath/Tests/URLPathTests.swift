// URLPathTests.swift - Tests for Foundation-free implementation
// Part of UmbraCore project
// Created on 2025-02-28

import XCTest
@testable import URLPath

final class URLPathTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: URLPath!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        sut = URLPath()
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
