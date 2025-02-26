import Foundation
import CryptoTypes
import CryptoTypesProtocols
import CryptoTypesTypes

/// A mock implementation of CryptoServiceProtocol for testing
public final class MockCryptoService: CryptoServiceProtocol, Resettable {
    /// Initializer
    public init() {
        MockManager.shared.register(self)
    }
    
    /// Reset the mock to its initial state
    public func reset() {
        encryptCallCount = 0
        decryptCallCount = 0
        generateKeyCallCount = 0
        hashDataCallCount = 0
        encryptHandler = nil
        decryptHandler = nil
        generateKeyHandler = nil
        hashDataHandler = nil
        encryptError = nil
        decryptError = nil
        generateKeyError = nil
        hashDataError = nil
    }
    
    // MARK: - Call Counters
    
    /// Number of times encrypt was called
    public private(set) var encryptCallCount = 0
    
    /// Number of times decrypt was called
    public private(set) var decryptCallCount = 0
    
    /// Number of times generateKey was called
    public private(set) var generateKeyCallCount = 0
    
    /// Number of times hashData was called
    public private(set) var hashDataCallCount = 0
    
    // MARK: - Handlers
    
    /// Handler for encrypt calls
    public var encryptHandler: ((Data, Data) throws -> Data)?
    
    /// Handler for decrypt calls
    public var decryptHandler: ((Data, Data) throws -> Data)?
    
    /// Handler for generateKey calls
    public var generateKeyHandler: ((Int) throws -> Data)?
    
    /// Handler for hashData calls
    public var hashDataHandler: ((Data) throws -> Data)?
    
    // MARK: - Errors
    
    /// Error to throw on encrypt calls
    public var encryptError: Error?
    
    /// Error to throw on decrypt calls
    public var decryptError: Error?
    
    /// Error to throw on generateKey calls
    public var generateKeyError: Error?
    
    /// Error to throw on hashData calls
    public var hashDataError: Error?
    
    // MARK: - CryptoServiceProtocol Implementation
    
    public func encrypt(_ data: Data, with key: Data) throws -> Data {
        encryptCallCount += 1
        
        if let error = encryptError {
            throw error
        }
        
        if let handler = encryptHandler {
            return try handler(data, key)
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
    
    public func decrypt(_ data: Data, with key: Data) throws -> Data {
        decryptCallCount += 1
        
        if let error = decryptError {
            throw error
        }
        
        if let handler = decryptHandler {
            return try handler(data, key)
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
    
    public func generateKey(size: Int) throws -> Data {
        generateKeyCallCount += 1
        
        if let error = generateKeyError {
            throw error
        }
        
        if let handler = generateKeyHandler {
            return try handler(size)
        }
        
        // Default implementation
        return Data(repeating: 0xAB, count: size)
    }
    
    public func hashData(_ data: Data) throws -> Data {
        hashDataCallCount += 1
        
        if let error = hashDataError {
            throw error
        }
        
        if let handler = hashDataHandler {
            return try handler(data)
        }
        
        // Default implementation (simple hash for testing)
        var hash: UInt64 = 0
        for byte in data {
            hash = hash &* 31 &+ UInt64(byte)
        }
        
        var result = Data(count: 8)
        for i in 0..<8 {
            result[i] = UInt8((hash >> (i * 8)) & 0xFF)
        }
        return result
    }
}
