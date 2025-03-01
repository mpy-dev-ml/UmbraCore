// MockFoundationXPCSecurityService.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecurityProtocolsCore
@testable import SecurityBridge

final class MockFoundationXPCSecurityService: NSObject, FoundationXPCSecurityService, @unchecked Sendable {
    // MARK: - Test Control Properties
    
    var shouldFail = false
    var errorToThrow: Error?
    var methodCalls: [String] = []
    
    // Data for key management methods
    var keyListResponse: [String]?
    var keyDataToReturn: Data?
    
    // Data for crypto service methods
    var encryptedDataToReturn: Data?
    var decryptedDataToReturn: Data?
    var signatureToReturn: Data?
    var verificationResult = true
    var hashDataToReturn: Data?
    
    // MARK: - Basic crypto methods
    
    func encrypt(data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void) {
        methodCalls.append("encrypt")
        
        if shouldFail {
            completion(nil, errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Encryption failed"]))
            return
        }
        
        if let dataToReturn = encryptedDataToReturn {
            completion(dataToReturn, nil)
        } else {
            // Simple mock encryption (append "ENCRYPTED")
            var result = data
            result.append(Data("ENCRYPTED".utf8))
            completion(result, nil)
        }
    }
    
    func decrypt(data: Data, key: Data, completion: @escaping (Data?, Error?) -> Void) {
        methodCalls.append("decrypt")
        
        if shouldFail {
            completion(nil, errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Decryption failed"]))
            return
        }
        
        if let dataToReturn = decryptedDataToReturn {
            completion(dataToReturn, nil)
        } else {
            // Simple mock decryption (remove "ENCRYPTED" suffix)
            let suffixLength = "ENCRYPTED".utf8.count
            if data.count >= suffixLength {
                let result = data.subdata(in: 0..<(data.count - suffixLength))
                completion(result, nil)
            } else {
                completion(data, nil)
            }
        }
    }
    
    func generateKey(completion: @escaping (Data?, Error?) -> Void) {
        methodCalls.append("generateKey")
        
        if shouldFail {
            completion(nil, errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Key generation failed"]))
            return
        }
        
        // If there's specific test data to return, prioritize it
        if let keyData = keyDataToReturn {
            completion(keyData, nil)
            return
        }
        
        // Generate a mock key
        var keyData = Data(count: 32) // 256-bit key
        for i in 0..<keyData.count {
            keyData[i] = UInt8(i % 256)
        }
        
        completion(keyData, nil)
    }
    
    // MARK: - Key management methods
    
    func retrieveKey(identifier: String, completion: @escaping (Data?, Error?) -> Void) {
        methodCalls.append("retrieveKey(\(identifier))")
        
        if shouldFail {
            completion(nil, errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Key not found"]))
            return
        }
        
        completion(keyDataToReturn ?? Data([UInt8](identifier.utf8) + [0, 1, 2, 3, 4]), nil)
    }
    
    func storeKey(key: Data, identifier: String, completion: @escaping (Error?) -> Void) {
        methodCalls.append("storeKey(\(identifier))")
        
        if shouldFail {
            completion(errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to store key"]))
            return
        }
        
        completion(nil)
    }
    
    func deleteKey(identifier: String, completion: @escaping (Error?) -> Void) {
        methodCalls.append("deleteKey(\(identifier))")
        
        if shouldFail {
            completion(errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 403, userInfo: [NSLocalizedDescriptionKey: "Cannot delete key"]))
            return
        }
        
        completion(nil)
    }
    
    func listKeyIdentifiers(completion: @escaping ([String]?, Error?) -> Void) {
        methodCalls.append("listKeyIdentifiers")
        
        if shouldFail {
            completion(nil, errorToThrow ?? NSError(domain: "com.umbracore.mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to list keys"]))
            return
        }
        
        completion(keyListResponse ?? ["test-key-1", "test-key-2", "test-key-3"], nil)
    }
    
    // MARK: - Extended methods
    
    func encryptSymmetricXPC(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("encryptSymmetricXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Encryption failed")
            return
        }
        
        // Return the expected data from the test if available
        if let encryptedData = encryptedDataToReturn {
            completion(encryptedData, nil, nil)
            return
        }
        
        // Create mock encrypted data (prepend IV and key byte)
        var result = Data()
        if let iv = iv {
            result.append(iv)
        }
        if let firstByte = key.first {
            result.append(Data([firstByte]))
        }
        result.append(data)
        
        completion(result, nil, nil)
    }
    
    func decryptSymmetricXPC(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        iv: Data?,
        aad: Data?,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("decryptSymmetricXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Decryption failed")
            return
        }
        
        // Return the expected data from the test if available
        if let decryptedData = decryptedDataToReturn {
            completion(decryptedData, nil, nil)
            return
        }
        
        // Mock decryption - just return a subset of the input data
        var startIndex = 0
        if let iv = iv {
            startIndex += iv.count
        }
        startIndex += 1 // Skip the key byte
        
        if data.count <= startIndex {
            completion(Data(), nil, nil)
        } else {
            let result = data.subdata(in: startIndex..<data.count)
            completion(result, nil, nil)
        }
    }
    
    func encryptAsymmetricXPC(
        data: Data,
        publicKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("encryptAsymmetricXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Asymmetric encryption failed")
            return
        }
        
        // Return the expected data from the test if available
        if let encryptedData = encryptedDataToReturn {
            completion(encryptedData, nil, nil)
            return
        }
        
        // Simple mock encryption
        var result = Data()
        if let firstByte = publicKey.first {
            result.append(Data([firstByte]))
        }
        result.append(data)
        
        completion(result, nil, nil)
    }
    
    func decryptAsymmetricXPC(
        data: Data,
        privateKey: Data,
        algorithm: String,
        keySizeInBits: Int,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("decryptAsymmetricXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Asymmetric decryption failed")
            return
        }
        
        // Return the expected data from the test if available
        if let decryptedData = decryptedDataToReturn {
            completion(decryptedData, nil, nil)
            return
        }
        
        // Mock decryption - just return the data without the first byte
        if data.isEmpty {
            completion(Data(), nil, nil)
        } else {
            let result = data.subdata(in: 1..<data.count)
            completion(result, nil, nil)
        }
    }
    
    func hashDataXPC(
        data: Data,
        algorithm: String,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("hashDataXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Hashing failed")
            return
        }
        
        if let hashData = hashDataToReturn {
            completion(hashData, nil, nil)
            return
        }
        
        // Create a mock hash based on algorithm
        let algorithmBytes = Data(algorithm.utf8)
        var result = Data()
        result.append(algorithmBytes.prefix(4))
        result.append(data.prefix(4))
        
        // Pad to 32 bytes for a common hash size
        while result.count < 32 {
            result.append(0)
        }
        
        completion(result, nil, nil)
    }
    
    func signDataXPC(
        data: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        optionsJson: String,
        completion: @escaping (Data?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("signDataXPC(\(algorithm))")
        
        if shouldFail {
            completion(nil, NSNumber(value: 500), "Signing failed")
            return
        }
        
        // Return the expected data from the test if available
        if let signature = signatureToReturn {
            completion(signature, nil, nil)
            return
        }
        
        // Simple mock signature
        var result = Data()
        if let firstByte = key.first {
            result.append(Data([firstByte]))
        }
        result.append(data)
        
        completion(result, nil, nil)
    }
    
    func verifySignatureXPC(
        data: Data,
        signature: Data,
        key: Data,
        algorithm: String,
        keySizeInBits: Int,
        optionsJson: String,
        completion: @escaping (Bool?, NSNumber?, String?) -> Void
    ) {
        methodCalls.append("verifySignatureXPC(\(algorithm))")
        
        if shouldFail {
            // Ensure a consistent false result when shouldFail is true
            completion(false, nil, nil)
            return
        }
        
        // Return the verification result directly
        completion(verificationResult, nil, nil)
    }
}
