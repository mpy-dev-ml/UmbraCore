// SecurityBridgeMigrationTests.swift
// SecurityBridgeTests
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import CoreTypes
import Foundation
import FoundationBridgeTypes
import SecurityBridge
import SecurityInterfacesProtocols
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest
import SecurityBridgeProtocolAdapters

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
        XCTAssertEqual(randomData.bytes.count, 32)
    }

    // MARK: - SecurityBridgeError Tests

    func testSecurityErrorMapping() {
        let securityError = SecurityError.encryptionFailed(reason: "Test error")
        let bridgeError = SecurityBridgeErrorMapper.mapToBridgeError(securityError)

        XCTAssertTrue(bridgeError is SecurityBridgeError)
        if let bridgeError = bridgeError as? SecurityBridgeError {
            switch bridgeError {
            case .implementationMissing:
                // Test passed
                break
            case .bookmarkResolutionFailed:
                XCTFail("Expected implementationMissing error but got bookmarkResolutionFailed")
            }
        }

        // Round-trip mapping
        let mappedBackError = SecurityBridgeErrorMapper.mapToSecurityError(bridgeError)
        XCTAssertTrue((mappedBackError as? SecurityError)?.description.starts(with: "Internal") ?? false)
    }

    func testFoundationDataBridge() throws {
        // Create CoreTypes BinaryData
        let originalData = CoreTypes.BinaryData([1, 2, 3, 4, 5])
        
        // Create DataBridge from it
        let dataBridge = DataBridge(originalData.unsafeBytes)
        
        // Check data integrity
        XCTAssertEqual(dataBridge.bytes.count, originalData.unsafeBytes.count)
        for i in 0..<originalData.unsafeBytes.count {
            XCTAssertEqual(dataBridge.bytes[i], originalData.unsafeBytes[i])
        }
    }

    func testSecurityErrorBridging() {
        // Create a SecurityError
        let originalError = SecurityError.internalError("Test error")
        
        // Create bridge error from it
        let bridgeError = SecurityBridgeErrorMapper.mapToBridgeError(originalError)
        
        // Check error mapping
        if case .implementationMissing(let message) = bridgeError {
            XCTAssertTrue(message.contains("Test error"))
        } else {
            XCTFail("Error mapping failed: \(bridgeError)")
        }

        // Round-trip mapping
        let mappedBackError = SecurityBridgeErrorMapper.mapToSecurityError(bridgeError)
        XCTAssertTrue((mappedBackError as? SecurityError)?.description.starts(with: "Internal") ?? false)
    }

    // MARK: - SecurityProviderBridge Tests

    func testSecurityProviderAdapter() async throws {
        let mockBridge = MockSecurityProviderBridge()
        let adapter = SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

        // Test encryption/decryption
        let protocolsTestData = SecurityInterfacesProtocols.BinaryData([1, 2, 3, 4, 5])
        let protocolsTestKey = SecurityInterfacesProtocols.BinaryData([10, 20, 30, 40, 50])
        
        let encrypted = try await adapter.encrypt(protocolsTestData, key: protocolsTestKey)
        XCTAssertNotEqual(encrypted.bytes, protocolsTestData.bytes)
        
        let decrypted = try await adapter.decrypt(encrypted, key: protocolsTestKey)
        XCTAssertEqual(decrypted.bytes, protocolsTestData.bytes)
        
        // Test key generation
        let generatedKey = try await adapter.generateKey(length: 16)
        XCTAssertEqual(generatedKey.bytes.count, 16)
        
        // Test hashing
        let hashedData = try await adapter.hash(protocolsTestData)
        XCTAssertEqual(hashedData.bytes.count, 32) // Mock hash is 32 bytes
    }

    func testSecurityProviderAdapterGenerateRandomData() async throws {
        let mockBridge = MockSecurityProviderBridge()
        let adapter = SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

        // Test the newly added generateRandomData
        let randomData = try await adapter.generateRandomData(length: 16)
        XCTAssertEqual(randomData.bytes.count, 16)

        // Test encryption/decryption with CoreTypes BinaryData
        let testData = SecurityInterfacesProtocols.BinaryData([1, 2, 3, 4, 5])
        let testKey = SecurityInterfacesProtocols.BinaryData([10, 20, 30, 40, 50])

        let encrypted = try await adapter.encrypt(testData, key: testKey)
        XCTAssertNotEqual(encrypted.bytes, testData.bytes)

        let decrypted = try await adapter.decrypt(encrypted, key: testKey)
        XCTAssertEqual(decrypted.bytes, testData.bytes)
    }
}

// MARK: - Test Mocks

private class MockXPCServiceProtocolBase: SecurityInterfacesProtocols.XPCServiceProtocolBase, @unchecked Sendable {
    static var protocolIdentifier: String = "mock.protocol"

    func ping() async throws -> Bool {
        return true
    }
    
    func synchroniseKeys(_ syncData: SecurityInterfacesProtocols.BinaryData) async throws {
        // No-op for mock
    }

    func generateRandomData(length: Int) async throws -> CoreTypes.BinaryData {
        var bytes = [UInt8]()
        for i in 0..<length {
            bytes.append(UInt8(i % 256))
        }
        return CoreTypes.BinaryData(bytes)
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

    func encryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
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

    func decryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
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

private class MockSecurityProviderBridge: SecurityBridgeProtocolAdapters.SecurityProviderBridge, @unchecked Sendable {
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

    func validateBookmark(_ bookmarkData: DataBridge) async throws -> Bool {
        // Very simple validation - always return true
        return true
    }
}
