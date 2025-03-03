// Test support for SecurityInterfaces
import Foundation
import SecurityInterfaces
import SecurityInterfacesProtocols
import SecurityBridge

/// Mock implementation of SecurityProviderProtocol for testing
public final class MockSecurityProvider: SecurityInterfacesProtocols.SecurityProviderProtocol {
    public init() {}
    
    public func encrypt(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        return data // Mock implementation returns the original data
    }
    
    public func decrypt(_ data: SecurityInterfacesProtocols.BinaryData, key: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        return data // Mock implementation returns the original data
    }
    
    public func hash(_ data: SecurityInterfacesProtocols.BinaryData) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Return a fixed hash value for testing
        return SecurityInterfacesProtocols.BinaryData([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    public func generateKey(length: Int) async throws -> SecurityInterfacesProtocols.BinaryData {
        // Return a fixed key for testing
        return SecurityInterfacesProtocols.BinaryData(Array(repeating: 0, count: length))
    }
}

/// Test utilities for SecurityInterfaces module
public struct SecurityInterfacesTestSupport {
    /// Creates a test security provider for testing
    public static func createTestSecurityProvider() -> any SecurityInterfacesProtocols.SecurityProviderProtocol {
        return MockSecurityProvider()
    }
    
    /// Creates test binary data for testing
    public static func createTestBinaryData(length: Int = 32) -> SecurityInterfacesProtocols.BinaryData {
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return SecurityInterfacesProtocols.BinaryData(bytes)
    }
}
