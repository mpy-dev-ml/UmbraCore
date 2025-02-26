import Foundation
import CryptoTypes
import CryptoTypesProtocols

/// A mock implementation of CryptoServiceProtocol for testing
@MainActor
public final class MockCryptoService: CryptoServiceProtocol, Resettable, @unchecked Sendable {
    /// Initializer
    public init() {
        // Register with the MockManager
        MockManager.shared.register(self)
    }
    
    /// Reset the mock to its initial state
    public func reset() async {
        encryptCallCount = 0
        decryptCallCount = 0
        deriveKeyCallCount = 0
        generateSecureRandomKeyCallCount = 0
        generateHMACCallCount = 0
        
        encryptHandler = nil
        decryptHandler = nil
        deriveKeyHandler = nil
        generateSecureRandomKeyHandler = nil
        generateHMACHandler = nil
        
        encryptError = nil
        decryptError = nil
        deriveKeyError = nil
        generateSecureRandomKeyError = nil
        generateHMACError = nil
    }
    
    // MARK: - Call Counters
    
    /// Number of times encrypt was called
    public private(set) var encryptCallCount = 0
    
    /// Number of times decrypt was called
    public private(set) var decryptCallCount = 0
    
    /// Number of times deriveKey was called
    public private(set) var deriveKeyCallCount = 0
    
    /// Number of times generateSecureRandomKey was called
    public private(set) var generateSecureRandomKeyCallCount = 0
    
    /// Number of times generateHMAC was called
    public private(set) var generateHMACCallCount = 0
    
    // MARK: - Handlers
    
    /// Handler for encrypt calls
    public var encryptHandler: ((Data, Data, Data) async throws -> Data)?
    
    /// Handler for decrypt calls
    public var decryptHandler: ((Data, Data, Data) async throws -> Data)?
    
    /// Handler for deriveKey calls
    public var deriveKeyHandler: ((String, Data, Int) async throws -> Data)?
    
    /// Handler for generateSecureRandomKey calls
    public var generateSecureRandomKeyHandler: ((Int) async throws -> Data)?
    
    /// Handler for generateHMAC calls
    public var generateHMACHandler: ((Data, Data) async throws -> Data)?
    
    // MARK: - Errors
    
    /// Error to throw on encrypt calls
    public var encryptError: Error?
    
    /// Error to throw on decrypt calls
    public var decryptError: Error?
    
    /// Error to throw on deriveKey calls
    public var deriveKeyError: Error?
    
    /// Error to throw on generateSecureRandomKey calls
    public var generateSecureRandomKeyError: Error?
    
    /// Error to throw on generateHMAC calls
    public var generateHMACError: Error?
    
    // MARK: - CryptoServiceProtocol Implementation
    
    public func encrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        encryptCallCount += 1
        
        if let error = encryptError {
            throw error
        }
        
        if let handler = encryptHandler {
            return try await handler(data, key, iv)
        }
        
        // Default implementation (simple XOR for testing)
        var result = Data(count: data.count)
        for i in 0..<data.count {
            let keyByte = key[i % key.count]
            let dataByte = data[i]
            result[i] = dataByte ^ keyByte
        }
        return result
    }
    
    public func decrypt(_ data: Data, using key: Data, iv: Data) async throws -> Data {
        decryptCallCount += 1
        
        if let error = decryptError {
            throw error
        }
        
        if let handler = decryptHandler {
            return try await handler(data, key, iv)
        }
        
        // Default implementation (simple XOR for testing)
        var result = Data(count: data.count)
        for i in 0..<data.count {
            let keyByte = key[i % key.count]
            let dataByte = data[i]
            result[i] = dataByte ^ keyByte
        }
        return result
    }
    
    public func deriveKey(from password: String, salt: Data, iterations: Int) async throws -> Data {
        deriveKeyCallCount += 1
        
        if let error = deriveKeyError {
            throw error
        }
        
        if let handler = deriveKeyHandler {
            return try await handler(password, salt, iterations)
        }
        
        // Default implementation - simple mock that doesn't actually derive a key
        let passwordData = password.data(using: .utf8) ?? Data()
        var result = Data(passwordData)
        result.append(salt)
        return Data(result.prefix(32)) // Return a 32-byte key
    }
    
    public func generateSecureRandomKey(length: Int) async throws -> Data {
        generateSecureRandomKeyCallCount += 1
        
        if let error = generateSecureRandomKeyError {
            throw error
        }
        
        if let handler = generateSecureRandomKeyHandler {
            return try await handler(length)
        }
        
        // Default implementation - predictable "random" data for testing
        return Data(repeating: 0xAB, count: length)
    }
    
    public func generateHMAC(for data: Data, using key: Data) async throws -> Data {
        generateHMACCallCount += 1
        
        if let error = generateHMACError {
            throw error
        }
        
        if let handler = generateHMACHandler {
            return try await handler(data, key)
        }
        
        // Default implementation - simple hash for testing
        var hash: UInt64 = 0
        for byte in data {
            hash = hash &* 31 &+ UInt64(byte)
        }
        
        var result = Data(count: 32) // HMAC-SHA256 is 32 bytes
        for i in 0..<8 {
            let value = UInt8((hash >> (i * 8)) & 0xFF)
            for j in 0..<4 {
                result[i*4 + j] = value ^ UInt8(j)
            }
        }
        return result
    }
}
