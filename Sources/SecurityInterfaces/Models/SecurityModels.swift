// SecurityModels.swift
// SecurityInterfaces
//
// Domain models for the SecurityInterfaces module

import CoreTypes
import Foundation

/// Represents various security operations that can be performed
public enum SecurityOperation {
    case encrypt
    case decrypt
    case sign
    case verify
    case hash
    case keyGeneration
    case keyRotation
    case keyDeletion
    case custom(String)

    public var rawValue: String {
        switch self {
        case .encrypt:
            return "encrypt"
        case .decrypt:
            return "decrypt"
        case .sign:
            return "sign"
        case .verify:
            return "verify"
        case .hash:
            return "hash"
        case .keyGeneration:
            return "keyGeneration"
        case .keyRotation:
            return "keyRotation"
        case .keyDeletion:
            return "keyDeletion"
        case .custom(let value):
            return value
        }
    }
}

/// Result of a security operation
public struct SecurityResult {
    /// Whether the operation was successful
    public let success: Bool

    /// Output data from the operation, if any
    public let data: Data?

    /// Additional metadata about the operation
    public let metadata: [String: String]

    public init(success: Bool, data: Data? = nil, metadata: [String: String] = [:]) {
        self.success = success
        self.data = data
        self.metadata = metadata
    }
}

/// Current status of the security system
public struct SecurityStatus {
    /// Whether the security system is active
    public let isActive: Bool

    /// Numeric status code
    public let statusCode: Int

    /// Human-readable status message
    public let statusMessage: String

    public init(isActive: Bool, statusCode: Int, statusMessage: String) {
        self.isActive = isActive
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}
