// SecurityProtocolsCoreTests.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import UmbraCoreTypes
@testable import SecurityProtocolsCore
import XCTest

class SecurityProtocolsCoreTests: XCTestCase {

    func testVersion() {
        XCTAssertFalse(SecurityProtocolsCore.version.isEmpty)
    }

    // MARK: - SecurityError Tests

    func testSecurityErrorEquatable() {
        // Test that the errors are equatable
        let error1 = SecurityError.encryptionFailed(reason: "test")
        let error2 = SecurityError.encryptionFailed(reason: "test")
        let error3 = SecurityError.decryptionFailed(reason: "test")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testSecurityErrorDescription() {
        // Test that the errors have descriptions
        let error1 = SecurityError.encryptionFailed(reason: "test")
        let error2 = SecurityError.invalidKey

        XCTAssertEqual(error1.description, "Encryption failed: test")
        XCTAssertEqual(error2.description, "Invalid key")
    }

    // MARK: - SecurityOperation Tests

    func testSecurityOperationDescription() {
        // Test operation descriptions
        XCTAssertEqual(SecurityOperation.encryption.description, "Encryption")
        XCTAssertEqual(SecurityOperation.keyGeneration.description, "Key Generation")
        XCTAssertEqual(SecurityOperation.custom("Test").description, "Custom: Test")
    }

    func testSecurityOperationEquatable() {
        // Test operations are equatable
        let op1 = SecurityOperation.encryption
        let op2 = SecurityOperation.encryption
        let op3 = SecurityOperation.decryption

        XCTAssertEqual(op1, op2)
        XCTAssertNotEqual(op1, op3)
    }

    // MARK: - SecurityConfigDTO Tests

    func testSecurityConfigDTODefaults() {
        // Test default configuration
        let config = SecurityConfigDTO.default

        XCTAssertEqual(config.algorithm, .aes256)
        XCTAssertEqual(config.hashAlgorithm, .sha256)
        XCTAssertNil(config.keyDerivation)
        XCTAssertEqual(config.timeoutSeconds, 30)
    }

    func testSecurityConfigDTOEquatable() {
        // Test configurations are equatable
        let config1 = SecurityConfigDTO(algorithm: .aes256, hashAlgorithm: .sha256)
        let config2 = SecurityConfigDTO(algorithm: .aes256, hashAlgorithm: .sha256)
        let config3 = SecurityConfigDTO(algorithm: .chacha20Poly1305, hashAlgorithm: .sha256)

        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }

    // MARK: - SecurityResultDTO Tests

    func testSecurityResultDTOSuccess() {
        // Test successful result creation
        let data = SecureBytes([0x01, 0x02, 0x03])
        let result = SecurityResultDTO.success(
            operation: .encryption,
            resultData: data,
            metadata: ["key": "value"],
            durationMilliseconds: 100
        )

        XCTAssertEqual(result.operation, .encryption)
        XCTAssertEqual(result.resultData, data)
        XCTAssertEqual(result.metadata["key"], "value")
        XCTAssertEqual(result.durationMilliseconds, 100)
        XCTAssertTrue(result.isSuccess)
        XCTAssertNil(result.error)
    }

    func testSecurityResultDTOFailure() {
        // Test failure result creation
        let error = SecurityError.encryptionFailed(reason: "test")
        let result = SecurityResultDTO.failure(
            operation: .encryption,
            error: error,
            metadata: ["key": "value"],
            durationMilliseconds: 100
        )

        XCTAssertEqual(result.operation, .encryption)
        XCTAssertNil(result.resultData)
        XCTAssertEqual(result.metadata["key"], "value")
        XCTAssertEqual(result.durationMilliseconds, 100)
        XCTAssertFalse(result.isSuccess)
        XCTAssertEqual(result.error, error)
    }
}
