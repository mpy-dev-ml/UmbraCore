// SecurityProviderAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecureBytes
import SecurityProtocolsCore

/// SecurityProviderAdapter provides a bridge between Foundation-based security provider implementations
/// and the Foundation-free SecurityProviderProtocol.
///
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent
/// SecurityProviderProtocol interface.
public final class SecurityProviderAdapter: SecurityProviderProtocol, Sendable {
    // MARK: - Properties

    /// The Foundation-dependent security provider implementation
    private let implementation: any FoundationSecurityProvider

    /// The crypto service adapter
    private let cryptoServiceAdapter: CryptoServiceAdapter

    /// The key management adapter
    private let keyManagementAdapter: KeyManagementAdapter

    // MARK: - SecurityProviderProtocol Properties

    public var cryptoService: CryptoServiceProtocol {
        return cryptoServiceAdapter
    }

    public var keyManager: KeyManagementProtocol {
        return keyManagementAdapter
    }

    // MARK: - Initialization

    /// Create a new SecurityProviderAdapter
    /// - Parameter implementation: The Foundation-dependent security provider implementation
    public init(implementation: any FoundationSecurityProvider) {
        self.implementation = implementation
        self.cryptoServiceAdapter = CryptoServiceAdapter(implementation: implementation.cryptoService)
        self.keyManagementAdapter = KeyManagementAdapter(implementation: implementation.keyManager)
    }

    // MARK: - SecurityProviderProtocol Implementation

    public func performSecureOperation(
        operation: SecurityOperation,
        config: SecurityConfigDTO
    ) async -> SecurityResultDTO {
        // Convert foundation-free config to foundation-dependent options
        let options = configToOptions(config)

        // Call the implementation
        let result = await implementation.performOperation(
            operation: operation.rawValue,
            options: options
        )

        // Convert the result back to the protocol's types
        return processResult(result)
    }

    public func createSecureConfig(options: [String: Any]?) -> SecurityConfigDTO {
        // Default implementation for foundation-free config
        return SecurityConfigDTO(
            algorithm: options?["algorithm"] as? String ?? "AES-GCM",
            keySizeInBits: options?["keySizeInBits"] as? Int ?? 256,
            initializationVector: (options?["initializationVector"] as? Data)
                .flatMap { DataAdapter.secureBytes(from: $0) },
            additionalAuthenticatedData: (options?["additionalAuthenticatedData"] as? Data)
                .flatMap { DataAdapter.secureBytes(from: $0) },
            iterations: options?["iterations"] as? Int,
            options: convertStringDictionary(options?["algorithmOptions"] as? [String: Any])
        )
    }

    // MARK: - Private Helper Methods

    /// Convert security config to Foundation options dictionary
    private func configToOptions(_ config: SecurityConfigDTO) -> [String: Any] {
        var options: [String: Any] = [
            "algorithm": config.algorithm,
            "keySizeInBits": config.keySizeInBits
        ]

        // Add optional parameters if they exist
        if let iv = config.initializationVector {
            options["initializationVector"] = DataAdapter.data(from: iv as SecureBytes)
        }

        if let aad = config.additionalAuthenticatedData {
            options["additionalAuthenticatedData"] = DataAdapter.data(from: aad as SecureBytes)
        }

        if let iterations = config.iterations {
            options["iterations"] = iterations
        }

        if !config.options.isEmpty {
            options["algorithmOptions"] = config.options
        }

        return options
    }

    /// Convert Foundation result to SecurityResultDTO
    private func processResult(_ result: FoundationSecurityProviderResult) -> SecurityResultDTO {
        switch result {
        case .success(let data):
            if let data = data {
                return SecurityResultDTO(data: DataAdapter.secureBytes(from: data))
            } else {
                return SecurityResultDTO()
            }
        case .failure(let error):
            // Convert the error to NSError directly since the cast always succeeds
            let nsError = error as NSError
            return SecurityResultDTO(
                errorCode: nsError.code,
                errorMessage: nsError.localizedDescription
            )
        }
    }

    /// Convert dictionary to string-only values
    private func convertStringDictionary(_ dict: [String: Any]?) -> [String: String] {
        guard let dict = dict else { return [:] }

        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = String(describing: value)
        }

        return result
    }
}

/// Protocol for Foundation-based security providers
/// This adapter allows Foundation-dependent code to conform to the Foundation-independent SecurityProviderProtocol
public protocol FoundationSecurityProvider: Sendable {
    /// Access to the Foundation-dependent crypto service
    var cryptoService: any FoundationCryptoServiceImpl { get }

    /// Access to the Foundation-dependent key manager
    var keyManager: any FoundationKeyManagementImpl { get }

    /// Perform a security operation with Foundation types
    /// - Parameters:
    ///   - operation: Operation identifier as a string
    ///   - options: Configuration options dictionary
    /// - Returns: Result with Foundation types
    func performOperation(
        operation: String,
        options: [String: Any]
    ) async -> FoundationSecurityProviderResult
}

/// Typealias for Foundation-based security operation result
public typealias FoundationSecurityProviderResult = Result<Data?, Error>
