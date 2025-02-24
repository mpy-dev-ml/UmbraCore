import CryptoKit
import CryptoSwift
import Foundation

/// Represents the type of cryptographic implementation to use
public enum CryptoImplementation: Sendable {
    /// Apple's CryptoKit for native macOS security features
    case cryptoKit
    /// CryptoSwift for cross-process operations
    case cryptoSwift
}

/// Represents a security context for cryptographic operations
public struct SecurityContext: Sendable {
    /// The type of application requesting the operation
    public enum ApplicationType: Sendable {
        /// ResticBar (native macOS app)
        case resticBar
        /// Rbum (cross-process GUI app)
        case rbum
        /// Rbx (VS Code extension)
        case rbx
    }

    /// The application type
    public let applicationType: ApplicationType
    /// Whether the operation is within a sandbox
    public let isSandboxed: Bool
    /// Whether the operation requires cross-process communication
    public let requiresXPC: Bool

    public init(
        applicationType: ApplicationType,
        isSandboxed: Bool = false,
        requiresXPC: Bool = false
    ) {
        self.applicationType = applicationType
        self.isSandboxed = isSandboxed
        self.requiresXPC = requiresXPC
    }
}

/// Represents a cryptographic key identifier
public struct KeyIdentifier: Hashable, Sendable {
    /// The unique identifier for this key
    public let id: String

    /// Create a new key identifier
    /// - Parameter id: The unique identifier for this key
    public init(id: String) {
        self.id = id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: KeyIdentifier, rhs: KeyIdentifier) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents the result of a key validation operation
public struct ValidationResult: Sendable {
    /// Whether the key is valid
    public let isValid: Bool
    /// Whether the key needs rotation
    public let needsRotation: Bool
    /// Optional reason if validation failed
    public let failureReason: String?

    public init(
        isValid: Bool,
        needsRotation: Bool = false,
        failureReason: String? = nil
    ) {
        self.isValid = isValid
        self.needsRotation = needsRotation
        self.failureReason = failureReason
    }
}

/// Orchestrates cryptographic operations across different implementations
public actor KeyManager {
    /// Current state of the key manager
    private var _state: ServiceState = .uninitialized
    public nonisolated(unsafe) private(set) var state: ServiceState = .uninitialized

    /// Maps key identifiers to their implementation type
    private var implementationMap: [KeyIdentifier: CryptoImplementation] = [:]

    /// Stores key material
    private var keyStore: [KeyIdentifier: Any] = [:]

    /// Stores key metadata
    private var keyMetadata: [KeyIdentifier: KeyMetadata] = [:]

    /// Last sync timestamp
    private var lastSyncTimestamp: Date?

    /// Initialise the key manager
    public init() {}

    /// Select the appropriate implementation based on the security context
    /// - Parameter context: The security context for the operation
    /// - Returns: The selected cryptographic implementation
    public func selectImplementation(for context: SecurityContext) -> CryptoImplementation {
        switch context.applicationType {
        case .resticBar:
            // ResticBar uses CryptoKit for native security features
            return .cryptoKit
        case .rbum, .rbx:
            // Rbum and Rbx use CryptoSwift for cross-process operations
            return .cryptoSwift
        }
    }

    /// Generate a new key for the given context
    /// - Parameter context: The security context for key generation
    /// - Returns: The identifier for the generated key
    /// - Throws: KeyManagerError if key generation fails
    public func generateKey(for context: SecurityContext) async throws -> KeyIdentifier {
        let implementation = selectImplementation(for: context)
        let keyId = UUID().uuidString
        let identifier = KeyIdentifier(id: keyId)

        // Store the implementation choice for this key
        implementationMap[identifier] = implementation

        switch implementation {
        case .cryptoKit:
            // Generate a new symmetric key using CryptoKit
            let key = SymmetricKey(size: .bits256)
            keyStore[identifier] = key
        case .cryptoSwift:
            // Generate a new key using CryptoSwift
            let key = try AES.randomIV(AES.blockSize)
            keyStore[identifier] = key
        }

        return identifier
    }

    /// Rotate a key
    /// - Parameter id: The key identifier to rotate
    /// - Throws: KeyManagerError if rotation fails
    public func rotateKey(id: KeyIdentifier) async throws {
        guard let implementation = implementationMap[id] else {
            throw KeyManagerError.keyNotFound
        }

        // Generate a new key with the same implementation
        let newKeyId = UUID().uuidString
        let newIdentifier = try await generateKey(keyId: newKeyId, implementation: implementation)

        // Copy any relevant metadata from the old key
        if let metadata = keyMetadata[id] {
            keyMetadata[newIdentifier] = metadata
        }

        // Mark the old key as rotated
        keyMetadata[id]?.status = .rotated(replacedBy: newIdentifier)

        // Schedule the old key for deletion after a grace period
        try await scheduleKeyDeletion(id: id, afterDelay: .hours(24))
    }

    /// Validate a key
    /// - Parameter id: The key identifier to validate
    /// - Returns: A validation result indicating the key's status
    /// - Throws: KeyManagerError if validation fails
    public func validateKey(id: KeyIdentifier) async throws -> ValidationResult {
        guard let implementation = implementationMap[id],
              let key = keyStore[id] else {
            throw KeyManagerError.keyNotFound
        }

        // Check key metadata
        if let metadata = keyMetadata[id] {
            // Check if key has been marked as compromised
            if metadata.status == .compromised {
                return ValidationResult(isValid: false, reason: "Key has been marked as compromised")
            }

            // Check if key has expired
            if let expiryDate = metadata.expiryDate,
               expiryDate < Date() {
                return ValidationResult(isValid: false, reason: "Key has expired")
            }
        }

        // Verify key material integrity
        switch implementation {
        case .cryptoKit:
            guard key is SymmetricKey else {
                return ValidationResult(isValid: false, reason: "Invalid key type for CryptoKit implementation")
            }
        case .cryptoSwift:
            guard let key = key as? [UInt8],
                  key.count == AES.blockSize else {
                return ValidationResult(
                    isValid: false,
                    reason: "Invalid key type or size for CryptoSwift implementation"
                )
            }
        }

        return ValidationResult(isValid: true)
    }

    /// Synchronise keys across processes if necessary
    /// - Throws: KeyManagerError if synchronisation fails
    public func synchroniseKeys() async throws {
        // Use XPC to broadcast key updates to other processes
        guard let xpcConnection = ServiceContainer.shared.xpcConnection else {
            throw KeyManagerError.synchronisationError("XPC connection not available")
        }

        // Prepare synchronisation data
        let syncData = KeySyncData(
            keys: keyStore,
            metadata: keyMetadata,
            implementations: implementationMap
        )

        // Send synchronisation request through XPC
        try await xpcConnection.synchroniseKeys(syncData)

        // Update last sync timestamp
        lastSyncTimestamp = Date()
    }

    /// Validate security boundaries for all keys
    /// - Throws: KeyManagerError if validation fails
    public func validateSecurityBoundaries() async throws {
        for (id, _) in keyStore {
            // Check key storage location
            guard isKeyStoredSecurely(id) else {
                throw KeyManagerError.securityBoundaryViolation("Key \(id) is not stored in secure enclave")
            }

            // Verify access controls
            guard await validateAccessControls(for: id) else {
                throw KeyManagerError.securityBoundaryViolation("Invalid access controls for key \(id)")
            }

            // Check for any cross-boundary violations
            if let violations = await detectCrossBoundaryViolations(for: id),
               !violations.isEmpty {
                let message = "Cross-boundary violations detected for key \(id): \(violations)"
                throw KeyManagerError.securityBoundaryViolation(message)
            }
        }
    }

    // MARK: - Private Helper Methods

    private func isKeyStoredSecurely(_ id: KeyIdentifier) -> Bool {
        // Check if the key is stored in the secure enclave
        guard let metadata = keyMetadata[id] else { return false }
        return metadata.storageLocation == .secureEnclave
    }

    private func validateAccessControls(for id: KeyIdentifier) async -> Bool {
        // Verify that access controls match security policy
        guard let metadata = keyMetadata[id] else { return false }
        return metadata.accessControls.isCompliant(with: SecurityPolicy.current)
    }

    private func detectCrossBoundaryViolations(for id: KeyIdentifier) async -> [SecurityViolation]? {
        // Check for any security boundary violations
        var violations: [SecurityViolation] = []

        guard let metadata = keyMetadata[id] else { return nil }

        // Check process isolation
        if !metadata.isProcessIsolated {
            violations.append(.processIsolationViolation)
        }

        // Check memory boundaries
        if !metadata.hasSecureMemoryBoundaries {
            violations.append(.memoryBoundaryViolation)
        }

        return violations.isEmpty ? nil : violations
    }

    private func scheduleKeyDeletion(id: KeyIdentifier, afterDelay: TimeInterval) async throws {
        // Schedule key for secure deletion
        guard let metadata = keyMetadata[id] else {
            throw KeyManagerError.keyNotFound
        }

        metadata.scheduledForDeletion = Date().addingTimeInterval(afterDelay)
        keyMetadata[id] = metadata

        // Set up deletion task
        Task {
            try await Task.sleep(nanoseconds: UInt64(afterDelay * 1_000_000_000))
            try await securelyDeleteKey(id: id)
        }
    }

    private func securelyDeleteKey(id: KeyIdentifier) async throws {
        // Securely delete key material
        guard let implementation = implementationMap[id] else {
            throw KeyManagerError.keyNotFound
        }

        // Overwrite key material with zeros
        switch implementation {
        case .cryptoKit:
            if var key = keyStore[id] as? SymmetricKey {
                withUnsafeMutableBytes(of: &key) { ptr in
                    ptr.fill(with: 0)
                }
            }
        case .cryptoSwift:
            if var key = keyStore[id] as? [UInt8] {
                key = Array(repeating: 0, count: key.count)
            }
        }

        // Remove key from stores
        keyStore.removeValue(forKey: id)
        implementationMap.removeValue(forKey: id)
        keyMetadata.removeValue(forKey: id)
    }
}

/// Errors that can occur during key management operations
public enum KeyManagerError: LocalizedError {
    /// The requested key was not found
    case keyNotFound
    /// Key generation failed
    case keyGenerationFailed(String)
    /// Key rotation failed
    case keyRotationFailed(String)
    /// Key validation failed
    case keyValidationFailed(String)
    /// Synchronisation failed
    case synchronisationFailed(String)
    /// Security boundary violation
    case securityBoundaryViolation(String)

    public var errorDescription: String? {
        switch self {
        case .keyNotFound:
            return "The requested key was not found"
        case .keyGenerationFailed(let reason):
            return "Key generation failed: \(reason)"
        case .keyRotationFailed(let reason):
            return "Key rotation failed: \(reason)"
        case .keyValidationFailed(let reason):
            return "Key validation failed: \(reason)"
        case .synchronisationFailed(let reason):
            return "Key synchronisation failed: \(reason)"
        case .securityBoundaryViolation(let reason):
            return "Security boundary violation: \(reason)"
        }
    }
}

// MARK: - Supporting Types

public struct KeyMetadata: Sendable {
    public var status: KeyStatus
    public var storageLocation: StorageLocation
    public var accessControls: AccessControls
    public var isProcessIsolated: Bool
    public var hasSecureMemoryBoundaries: Bool
    public var expiryDate: Date?
    public var scheduledForDeletion: Date?

    public init(
        status: KeyStatus,
        storageLocation: StorageLocation,
        accessControls: AccessControls,
        isProcessIsolated: Bool,
        hasSecureMemoryBoundaries: Bool,
        expiryDate: Date? = nil,
        scheduledForDeletion: Date? = nil
    ) {
        self.status = status
        self.storageLocation = storageLocation
        self.accessControls = accessControls
        self.isProcessIsolated = isProcessIsolated
        self.hasSecureMemoryBoundaries = hasSecureMemoryBoundaries
        self.expiryDate = expiryDate
        self.scheduledForDeletion = scheduledForDeletion
    }
}

public enum KeyStatus: Sendable {
    case active
    case compromised
    case rotated(replacedBy: KeyIdentifier)
}

public enum StorageLocation: Sendable {
    case secureEnclave
    case insecureStorage
}

public struct AccessControls: Sendable {
    public var isCompliant(with policy: SecurityPolicy) -> Bool {
        // Implement access control compliance check
        return true
    }
}

public enum SecurityViolation: Sendable {
    case processIsolationViolation
    case memoryBoundaryViolation
}

public struct SecurityPolicy: Sendable {
    public static var current: SecurityPolicy {
        // Implement current security policy
        return SecurityPolicy()
    }
}

public struct KeySyncData: Sendable {
    public let keys: [KeyIdentifier: Any]
    public let metadata: [KeyIdentifier: KeyMetadata]
    public let implementations: [KeyIdentifier: CryptoImplementation]

    public init(
        keys: [KeyIdentifier: Any],
        metadata: [KeyIdentifier: KeyMetadata],
        implementations: [KeyIdentifier: CryptoImplementation]
    ) {
        self.keys = keys
        self.metadata = metadata
        self.implementations = implementations
    }
}
