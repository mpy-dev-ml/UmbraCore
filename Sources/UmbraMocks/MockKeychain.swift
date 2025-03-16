import CoreErrors
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// Mock implementation of a secure storage service for testing
public final class MockKeychain: @unchecked Sendable, SecureStorageServiceProtocol {
    /// Storage for the mock keychain
    private let storageQueue = DispatchQueue(label: "com.umbra.mock-keychain", attributes: .concurrent)
    private var storageDict: [String: (SecureBytes, [String: String]?)] = [:]

    public init() {}

    /// Store data securely in the mock keychain
    /// - Parameters:
    ///   - data: Data to store
    ///   - identifier: Unique identifier for the data
    ///   - metadata: Optional metadata to associate with the data
    /// - Returns: Success or failure
    public func storeData(
        _ data: SecureBytes,
        identifier: String,
        metadata: [String: String]?
    ) async -> Result<Void, XPCSecurityError> {
        storageQueue.async(flags: .barrier) { [self] in
            storageDict[identifier] = (data, metadata)
        }
        return .success(())
    }

    /// Retrieve securely stored data
    /// - Parameter identifier: Identifier for the data to retrieve
    /// - Returns: The stored data
    public func retrieveData(
        identifier: String
    ) async -> Result<SecureBytes, XPCSecurityError> {
        var result: Result<SecureBytes, XPCSecurityError> = .failure(.keyNotFound(identifier: identifier))

        storageQueue.sync { [self] in
            if let (data, _) = storageDict[identifier] {
                result = .success(data)
            }
        }

        return result
    }

    /// Delete securely stored data
    /// - Parameter identifier: Identifier for the data to delete
    /// - Returns: Success or failure
    public func deleteData(
        identifier: String
    ) async -> Result<Void, XPCSecurityError> {
        storageQueue.async(flags: .barrier) { [self] in
            storageDict.removeValue(forKey: identifier)
        }
        return .success(())
    }

    /// List all data identifiers
    /// - Returns: Array of data identifiers
    public func listDataIdentifiers() async -> Result<[String], XPCSecurityError> {
        var keys: [String] = []

        storageQueue.sync { [self] in
            keys = Array(storageDict.keys)
        }

        return .success(keys)
    }

    /// Get metadata for stored data
    /// - Parameter identifier: Identifier for the data
    /// - Returns: Associated metadata
    public func getDataMetadata(
        for identifier: String
    ) async -> Result<[String: String]?, XPCSecurityError> {
        var result: Result<[String: String]?, XPCSecurityError> = .failure(.keyNotFound(identifier: identifier))

        storageQueue.sync { [self] in
            if let (_, metadata) = storageDict[identifier] {
                result = .success(metadata)
            }
        }

        return result
    }

    /// Reset the mock keychain, clearing all stored data
    public func reset() async {
        storageQueue.async(flags: .barrier) { [self] in
            storageDict.removeAll()
        }
    }
}
