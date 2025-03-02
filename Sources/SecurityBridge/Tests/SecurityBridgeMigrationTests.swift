// SecurityBridgeMigrationTests.swift
// SecurityBridgeTests
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecureBytes
@testable import SecurityBridge
import SecurityProtocolsCore
import XCTest

final class SecurityBridgeMigrationTests: XCTestCase {
    // MARK: - XPCServiceBridge Tests

    func testXPCServiceBridgeProtocolIdentifier() {
        XCTAssertEqual(CoreTypesToFoundationBridgeAdapter.protocolIdentifier, "com.umbra.xpc.service.adapter.coretypes.bridge")
    }

    func testCoreToBridgeAdapter() throws {
        let mockXPCService = MockXPCServiceProtocolBase()
        let adapter = CoreTypesToFoundationBridgeAdapter(wrapping: mockXPCService)

        let expectation = XCTestExpectation(description: "Ping response received")
        adapter.pingFoundation { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFoundationToCoreAdapter() async throws {
        let mockFoundation = MockXPCServiceProtocolFoundationBridge()
        let adapter = FoundationToCoreTypesBridgeAdapter(wrapping: mockFoundation)

        let result = try await adapter.ping()
        XCTAssertTrue(result)

        let randomData = try await adapter.generateRandomData(length: 32)
        XCTAssertEqual(randomData.bytes().count, 32)
    }

    // MARK: - SecurityBridgeError Tests

    func testSecurityErrorMapping() {
        let securityError = SecurityError.encryptionFailed(reason: "Test error")
        let bridgeError = SecurityBridgeErrorMapper.mapToError(securityError)

        XCTAssertTrue(bridgeError is SecurityBridgeError)
        if let bridgeError = bridgeError as? SecurityBridgeError {
            switch bridgeError {
            case .operationFailed:
                // Test passed
                break
            default:
                XCTFail("Error mapping failed: \(bridgeError)")
            }
        }

        // Round-trip mapping
        let mappedBackError = SecurityBridgeErrorMapper.mapToSecurityError(bridgeError)
        XCTAssertEqual((mappedBackError as? SecurityError)?.description.prefix(10), "Internal e")
    }

    // MARK: - SecurityProviderBridge Tests

    func testSecurityProviderAdapter() async throws {
        let mockBridge = MockSecurityProviderBridge()
        let adapter = SecurityProviderProtocolAdapter(bridge: mockBridge)

        // Test the newly added generateRandomData
        let randomData = try await adapter.generateRandomData(length: 16)
        XCTAssertEqual(randomData.bytes().count, 16)

        // Test encryption/decryption
        let testData = CoreTypes.BinaryData([1, 2, 3, 4, 5])
        let testKey = CoreTypes.BinaryData([10, 20, 30, 40, 50])

        let encrypted = try await adapter.encrypt(testData, key: testKey)
        XCTAssertNotEqual(encrypted, testData)

        let decrypted = try await adapter.decrypt(encrypted, key: testKey)
        XCTAssertEqual(decrypted, testData)
    }
}

// MARK: - Test Mocks

private class MockXPCServiceProtocolBase: SecurityXPCServiceBridge, @unchecked Sendable {
    var protocolIdentifier: String = "mock.protocol"

    func ping() async throws -> Bool {
        return true
    }

    func generateRandomData(length: Int) async throws -> CoreTypes.BinaryData {
        var bytes = [UInt8]()
        for i in 0..<length {
            bytes.append(UInt8(i % 256))
        }
        return CoreTypes.BinaryData(bytes)
    }

    func synchroniseKeys(_ data: CoreTypes.BinaryData) async throws {
        // No-op for test
    }

    func encrypt(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Simple "encryption" for test
        var bytes = data.bytes()
        for i in 0..<bytes.count {
            bytes[i] = bytes[i] ^ 0xFF
        }
        return CoreTypes.BinaryData(bytes)
    }

    func decrypt(_ data: CoreTypes.BinaryData) async throws -> CoreTypes.BinaryData {
        // Simple "decryption" for test (which is the same as our encryption)
        var bytes = data.bytes()
        for i in 0..<bytes.count {
            bytes[i] = bytes[i] ^ 0xFF
        }
        return CoreTypes.BinaryData(bytes)
    }
}

@objc private class MockXPCServiceProtocolFoundationBridge: NSObject, XPCServiceProtocolFoundationBridge {
    static var protocolIdentifier: String = "mock.foundation.protocol"

    func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        reply(true, nil)
    }

    func synchroniseKeysFoundation(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void) {
        reply(nil)
    }

    func encryptFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // Simple "encryption" for test
        let length = data.length
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        data.getBytes(bytes, length: length)

        for i in 0..<length {
            bytes[i] = bytes[i] ^ 0xFF
        }

        let result = NSData(bytes: bytes, length: length)
        bytes.deallocate()

        reply(result, nil)
    }

    func decryptFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // Simple "decryption" for test (same as encryption)
        let length = data.length
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        data.getBytes(bytes, length: length)

        for i in 0..<length {
            bytes[i] = bytes[i] ^ 0xFF
        }

        let result = NSData(bytes: bytes, length: length)
        bytes.deallocate()

        reply(result, nil)
    }

    func generateRandomDataFoundation(_ length: Int, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)

        for i in 0..<length {
            bytes[i] = UInt8(i % 256)
        }

        let result = NSData(bytes: bytes, length: length)
        bytes.deallocate()

        reply(result, nil)
    }
}

private class MockSecurityProviderBridge: SecurityProviderBridge, @unchecked Sendable {
    static var protocolIdentifier: String = "mock.provider.bridge"

    func encrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        // Simple "encryption" for test
        var bytes = data.bytes
        for i in 0..<bytes.count {
            bytes[i] = bytes[i] ^ 0xFF
        }
        return DataBridge(CoreTypes.BinaryData(bytes))
    }

    func decrypt(_ data: DataBridge, key: DataBridge) async throws -> DataBridge {
        // Simple "decryption" for test (same as our encryption)
        var bytes = data.bytes
        for i in 0..<bytes.count {
            bytes[i] = bytes[i] ^ 0xFF
        }
        return DataBridge(CoreTypes.BinaryData(bytes))
    }

    func generateKey(length: Int) async throws -> DataBridge {
        var bytes = [UInt8]()
        for i in 0..<length {
            bytes.append(UInt8((i * 7) % 256))
        }
        return DataBridge(CoreTypes.BinaryData(bytes))
    }

    func generateRandomData(length: Int) async throws -> DataBridge {
        var bytes = [UInt8]()
        for i in 0..<length {
            bytes.append(UInt8(i % 256))
        }
        return DataBridge(CoreTypes.BinaryData(bytes))
    }

    func hash(_ data: DataBridge) async throws -> DataBridge {
        // Simple mock hash
        var hash = [UInt8](repeating: 0, count: 32)
        let sourceBytes = data.bytes
        for i in 0..<sourceBytes.count {
            hash[i % 32] = hash[i % 32] ^ sourceBytes[i]
        }
        return DataBridge(CoreTypes.BinaryData(hash))
    }

    func createBookmark(for urlString: String) async throws -> DataBridge {
        // Mock bookmark data
        let bookmarkData = urlString.data(using: .utf8)!
        return DataBridge(CoreTypes.BinaryData(Array(bookmarkData)))
    }

    func resolveBookmark(_ bookmarkData: DataBridge) async throws -> (urlString: String, isStale: Bool) {
        // Resolve mock bookmark
        if let urlString = String(data: Data(bookmarkData.bytes), encoding: .utf8) {
            return (urlString, false)
        }
        throw SecurityBridgeError.bookmarkResolutionFailed
    }
}
