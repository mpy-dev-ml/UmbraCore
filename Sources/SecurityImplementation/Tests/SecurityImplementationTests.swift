// SecurityImplementationTests.swift
// SecurityImplementation
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import SecurityImplementation

class SecurityImplementationTests: XCTestCase {
    
    func testVersion() {
        XCTAssertFalse(SecurityImplementation.version.isEmpty)
    }
}
