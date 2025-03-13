import Foundation

/// Root namespace for all UmbraCore errors.
/// This serves as the entry point for the error type hierarchy.
enum UmbraErrors {
    /// Security-related errors encountered within UmbraCore.
    /// These errors pertain to security operations, authentication, and access control.
    enum Security: Error {
        /// Domain identifier for Security errors
        static let errorDomain = "security.umbracore.dev"

        /// Thrown when authentication fails due to the provided reason.
        /// - Parameter reason: Detailed description of the authentication failure
        /// - Returns: An error representing an authentication failure
        case authenticationFailed(reason: String)

        /// Thrown when permission to access the specified resource is denied.
        /// - Parameter resource: The resource for which permission was denied
        /// - Returns: An error representing a permission denial
        case permissionDenied(resource: String)

        /// Thrown when encryption or decryption operations fail.
        /// - Parameters:
        ///   - operation: The specific operation that failed (e.g., "encryption", "decryption")
        ///   - reason: The reason for the failure
        /// - Returns: An error representing a cryptographic operation failure
        case cryptographicOperationFailed(operation: String, reason: String)

        /// Thrown when a security-related configuration is invalid.
        /// - Parameters:
        ///   - component: The component with invalid configuration
        ///   - issue: Description of the configuration issue
        /// - Returns: An error representing an invalid security configuration
        case invalidConfiguration(component: String, issue: String)

        /// Protocol-specific security errors.
        /// These errors relate to security protocol implementations and communication.
        enum Protocols: Error {
            /// Domain identifier for Security Protocol errors
            static let errorDomain = "security.protocols.umbracore.dev"

            /// Thrown when a required protocol implementation cannot be found.
            /// - Parameter protocolName: The name of the missing protocol
            /// - Returns: An error representing a missing protocol implementation
            case missingProtocolImplementation(protocolName: String)

            /// Thrown when data is in an invalid format for the requested operation.
            /// - Parameter reason: Detailed description of the format issue
            /// - Returns: An error representing an invalid format error
            case invalidFormat(reason: String)

            /// Thrown when the requested operation is not supported by the protocol.
            /// - Parameter name: The name of the unsupported operation
            /// - Returns: An error representing an unsupported operation
            case unsupportedOperation(name: String)

            /// Thrown when the protocol version is incompatible.
            /// - Parameter version: The incompatible version string
            /// - Returns: An error representing an incompatible version
            case incompatibleVersion(version: String)

            /// Thrown when the protocol is in an invalid state for the requested operation.
            /// - Parameters:
            ///   - state: The current state of the protocol
            ///   - expectedState: The state required for the operation
            /// - Returns: An error representing an invalid state error
            case invalidState(state: String, expectedState: String)

            /// Thrown when an internal error occurs within the protocol implementation.
            /// - Parameter details: Details about the internal error
            /// - Returns: An error representing an internal protocol error
            case internalError(String)
        }
    }

    /// Application-level errors encountered within UmbraCore.
    /// These errors relate to general application functionality and operations.
    enum Application: Error {
        /// Domain identifier for Application errors
        static let errorDomain = "application.umbracore.dev"

        /// Thrown when the application is in an invalid state for the requested operation.
        /// - Parameters:
        ///   - current: The current state of the application
        ///   - expected: The state required for the operation
        /// - Returns: An error representing an invalid application state
        case invalidState(current: String, expected: String)

        /// Thrown when a required resource is not found.
        /// - Parameter item: The resource that could not be found
        /// - Returns: An error representing a missing resource
        case notFound(item: String)

        /// Thrown when an operation fails due to the provided reason.
        /// - Parameters:
        ///   - name: The name of the operation that failed
        ///   - reason: The reason for the failure
        /// - Returns: An error representing an operation failure
        case operationFailed(name: String, reason: String)

        /// Thrown when an operation times out.
        /// - Parameters:
        ///   - operation: The operation that timed out
        ///   - limit: The time limit that was exceeded (in seconds)
        /// - Returns: An error representing a timeout
        case timeout(operation: String, limit: TimeInterval)

        /// Thrown when an unexpected error occurs that doesn't fit other categories.
        /// - Parameter details: Details about the unexpected error
        /// - Returns: An error representing an unknown error condition
        case unknown(details: String)
    }

    /// Storage-related errors encountered within UmbraCore.
    /// These errors relate to data persistence, retrieval, and management.
    enum Storage: Error {
        /// Domain identifier for Storage errors
        static let errorDomain = "storage.umbracore.dev"

        /// Thrown when a read operation fails.
        /// - Parameters:
        ///   - resource: The resource that was being read
        ///   - reason: The reason for the failure
        /// - Returns: An error representing a read operation failure
        case readFailed(resource: String, reason: String)

        /// Thrown when a write operation fails.
        /// - Parameters:
        ///   - resource: The resource that was being written
        ///   - reason: The reason for the failure
        /// - Returns: An error representing a write operation failure
        case writeFailed(resource: String, reason: String)

        /// Thrown when the requested item cannot be found in storage.
        /// - Parameter item: The item that could not be found
        /// - Returns: An error representing a missing item
        case notFound(item: String)

        /// Thrown when there is insufficient storage space for the operation.
        /// - Parameters:
        ///   - available: The available space in bytes
        ///   - required: The required space in bytes
        /// - Returns: An error representing insufficient storage space
        case insufficientSpace(available: UInt64, required: UInt64)

        /// Thrown when storage access is denied due to permissions.
        /// - Parameter resource: The resource for which access was denied
        /// - Returns: An error representing a permission denial
        case permissionDenied(resource: String)
    }

    /// Network-related errors encountered within UmbraCore.
    /// These errors relate to network connectivity, requests, and responses.
    enum Network: Error {
        /// Domain identifier for Network errors
        static let errorDomain = "network.umbracore.dev"

        /// Thrown when a network request fails.
        /// - Parameters:
        ///   - url: The URL of the failed request
        ///   - statusCode: The HTTP status code if available
        ///   - reason: The reason for the failure
        /// - Returns: An error representing a network request failure
        case requestFailed(url: URL, statusCode: Int?, reason: String)

        /// Thrown when network connectivity is unavailable.
        /// - Returns: An error representing no network connectivity
        case connectivityUnavailable

        /// Thrown when a network timeout occurs.
        /// - Parameters:
        ///   - url: The URL that timed out
        ///   - timeoutInterval: The timeout interval in seconds
        /// - Returns: An error representing a network timeout
        case timeout(url: URL, timeoutInterval: TimeInterval)

        /// Thrown when the server response cannot be parsed.
        /// - Parameters:
        ///   - url: The URL of the request
        ///   - reason: The reason the response couldn't be parsed
        /// - Returns: An error representing an invalid server response
        case invalidResponse(url: URL, reason: String)

        /// Thrown when the client is not authorised to make the request.
        /// - Parameter url: The URL for which authorisation failed
        /// - Returns: An error representing an authorisation failure
        case notAuthorised(url: URL)
    }
}

// MARK: - Usage Examples

class SecurityService {
    func authenticate(username: String, password: String) throws {
        guard !username.isEmpty && !password.isEmpty else {
            throw UmbraErrors.Security.authenticationFailed(reason: "Missing credentials")
        }

        // Simulate authentication failure
        if username != "validUser" || password != "correctPassword" {
            throw UmbraErrors.Security.authenticationFailed(reason: "Invalid username or password")
        }

        // Successful authentication continues...
    }

    func accessSecureResource(resourceName: String) throws -> Data {
        // Check permissions
        guard isAuthorised(for: resourceName) else {
            throw UmbraErrors.Security.permissionDenied(resource: resourceName)
        }

        // Attempt to fetch the resource
        do {
            return try fetchResource(resourceName)
        } catch {
            throw UmbraErrors.Application.notFound(item: resourceName)
        }
    }

    func encryptData(_: Data, with key: Data) throws -> Data {
        guard validateKey(key) else {
            throw UmbraErrors.Security.cryptographicOperationFailed(
                operation: "encryption",
                reason: "Invalid encryption key"
            )
        }

        // Encryption implementation...
        return Data() // Placeholder
    }

    // Helper methods
    private func isAuthorised(for _: String) -> Bool {
        // Check authorisation logic
        true // Placeholder
    }

    private func fetchResource(_: String) throws -> Data {
        // Resource fetching logic
        Data() // Placeholder
    }

    private func validateKey(_ key: Data) -> Bool {
        // Key validation logic
        key.count >= 16 // Placeholder
    }
}

// MARK: - Error Handling Examples

class ErrorHandlingDemonstration {
    let securityService = SecurityService()

    func demonstrateErrorHandling() {
        // Example 1: Basic try-catch
        do {
            try securityService.authenticate(username: "invalidUser", password: "wrongPassword")
        } catch let error as UmbraErrors.Security {
            switch error {
            case let .authenticationFailed(reason):
                print("Authentication failed: \(reason)")
            default:
                print("Security error: \(error)")
            }
        } catch {
            print("Unexpected error: \(error)")
        }

        // Example 2: Pattern matching in catch clauses
        do {
            _ = try securityService.accessSecureResource(resourceName: "confidentialDocument")
        } catch let UmbraErrors.Security.permissionDenied(resource) {
            print("Permission denied for resource: \(resource)")
        } catch let UmbraErrors.Application.notFound(item) {
            print("Resource not found: \(item)")
        } catch {
            print("Other error: \(error)")
        }

        // Example 3: Nested error handling with protocol errors
        do {
            // Hypothetical protocol operation
            throw UmbraErrors.Security.Protocols.invalidFormat(reason: "Malformed header")
        } catch let error as UmbraErrors.Security.Protocols {
            switch error {
            case let .invalidFormat(reason):
                print("Protocol format error: \(reason)")
            case let .incompatibleVersion(version):
                print("Incompatible protocol version: \(version)")
            default:
                print("Other protocol error: \(error)")
            }
        } catch {
            print("Non-protocol error: \(error)")
        }
    }
}

// Call the demonstration
// let demo = ErrorHandlingDemonstration()
// demo.demonstrateErrorHandling()
