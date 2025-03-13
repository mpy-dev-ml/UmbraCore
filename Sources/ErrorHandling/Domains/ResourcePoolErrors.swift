import ErrorHandlingInterfaces
import Foundation

public extension UmbraErrors.Resource {
    /// Resource pool management errors
    enum Pool: Error, UmbraError, StandardErrorCapabilities {
        // Pool creation and management errors
        /// Failed to create resource pool
        case poolCreationFailed(poolName: String, reason: String)

        /// Failed to initialise resource pool
        case poolInitialisationFailed(poolName: String, reason: String)

        /// Resource pool is exhausted
        case poolExhausted(poolName: String, currentSize: Int, maxSize: Int)

        /// Resource pool is in an invalid state
        case invalidPoolState(poolName: String, state: String, expectedState: String?)

        /// Pool already exists
        case poolAlreadyExists(poolName: String)

        // Resource acquisition errors
        /// Failed to acquire resource from pool
        case resourceAcquisitionFailed(poolName: String, resourceId: String?, reason: String)

        /// Failed to release resource back to pool
        case resourceReleaseFailed(poolName: String, resourceId: String, reason: String)

        /// Resource not found in pool
        case resourceNotFound(poolName: String, resourceId: String)

        /// Resource is already in use
        case resourceAlreadyInUse(poolName: String, resourceId: String, owner: String?)

        /// Resource is invalid for the pool
        case invalidResource(poolName: String, resourceId: String, reason: String)

        /// Wait timeout for resource acquisition
        case acquisitionTimeout(poolName: String, timeoutMs: Int)

        /// Pool operation failed
        case operationFailed(poolName: String, operation: String, reason: String)

        // MARK: - UmbraError Protocol

        /// Domain identifier for pool errors
        public var domain: String {
            "Resource.Pool"
        }

        /// Error code uniquely identifying the error type
        public var code: String {
            switch self {
            case .poolCreationFailed:
                "pool_creation_failed"
            case .poolInitialisationFailed:
                "pool_initialisation_failed"
            case .poolExhausted:
                "pool_exhausted"
            case .invalidPoolState:
                "invalid_pool_state"
            case .poolAlreadyExists:
                "pool_already_exists"
            case .resourceAcquisitionFailed:
                "resource_acquisition_failed"
            case .resourceReleaseFailed:
                "resource_release_failed"
            case .resourceNotFound:
                "resource_not_found"
            case .resourceAlreadyInUse:
                "resource_already_in_use"
            case .invalidResource:
                "invalid_resource"
            case .acquisitionTimeout:
                "acquisition_timeout"
            case .operationFailed:
                "operation_failed"
            }
        }

        /// Human-readable description of the error
        public var errorDescription: String {
            switch self {
            case let .poolCreationFailed(poolName, reason):
                "Failed to create resource pool '\(poolName)': \(reason)"
            case let .poolInitialisationFailed(poolName, reason):
                "Failed to initialise resource pool '\(poolName)': \(reason)"
            case let .poolExhausted(poolName, currentSize, maxSize):
                "Resource pool '\(poolName)' exhausted (current: \(currentSize), maximum: \(maxSize))"
            case let .invalidPoolState(poolName, state, expectedState):
                if let expected = expectedState {
                    "Resource pool '\(poolName)' is in invalid state: current '\(state)', expected '\(expected)'"
                } else {
                    "Resource pool '\(poolName)' is in invalid state: '\(state)'"
                }
            case let .poolAlreadyExists(poolName):
                "Resource pool '\(poolName)' already exists"
            case let .resourceAcquisitionFailed(poolName, resourceId, reason):
                if let id = resourceId {
                    "Failed to acquire resource '\(id)' from pool '\(poolName)': \(reason)"
                } else {
                    "Failed to acquire resource from pool '\(poolName)': \(reason)"
                }
            case let .resourceReleaseFailed(poolName, resourceId, reason):
                "Failed to release resource '\(resourceId)' back to pool '\(poolName)': \(reason)"
            case let .resourceNotFound(poolName, resourceId):
                "Resource '\(resourceId)' not found in pool '\(poolName)'"
            case let .resourceAlreadyInUse(poolName, resourceId, owner):
                if let owner {
                    "Resource '\(resourceId)' in pool '\(poolName)' is already in use by: \(owner)"
                } else {
                    "Resource '\(resourceId)' in pool '\(poolName)' is already in use"
                }
            case let .invalidResource(poolName, resourceId, reason):
                "Resource '\(resourceId)' is invalid for pool '\(poolName)': \(reason)"
            case let .acquisitionTimeout(poolName, timeoutMs):
                "Timeout waiting for resource from pool '\(poolName)' after \(timeoutMs)ms"
            case let .operationFailed(poolName, operation, reason):
                "Operation '\(operation)' failed for pool '\(poolName)': \(reason)"
            }
        }

        /// Source information about where the error occurred
        public var source: ErrorHandlingInterfaces.ErrorSource? {
            nil // Source is typically set when the error is created with context
        }

        /// The underlying error, if any
        public var underlyingError: Error? {
            nil // Underlying error is typically set when the error is created with context
        }

        /// Additional context for the error
        public var context: ErrorHandlingInterfaces.ErrorContext {
            ErrorHandlingInterfaces.ErrorContext(
                source: domain,
                operation: "pool_operation",
                details: errorDescription
            )
        }

        /// Creates a new instance of the error with additional context
        public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
            // Since these are enum cases, we need to return a new instance with the same value
            switch self {
            case let .poolCreationFailed(poolName, reason):
                .poolCreationFailed(poolName: poolName, reason: reason)
            case let .poolInitialisationFailed(poolName, reason):
                .poolInitialisationFailed(poolName: poolName, reason: reason)
            case let .poolExhausted(poolName, currentSize, maxSize):
                .poolExhausted(poolName: poolName, currentSize: currentSize, maxSize: maxSize)
            case let .invalidPoolState(poolName, state, expectedState):
                .invalidPoolState(poolName: poolName, state: state, expectedState: expectedState)
            case let .poolAlreadyExists(poolName):
                .poolAlreadyExists(poolName: poolName)
            case let .resourceAcquisitionFailed(poolName, resourceId, reason):
                .resourceAcquisitionFailed(poolName: poolName, resourceId: resourceId, reason: reason)
            case let .resourceReleaseFailed(poolName, resourceId, reason):
                .resourceReleaseFailed(poolName: poolName, resourceId: resourceId, reason: reason)
            case let .resourceNotFound(poolName, resourceId):
                .resourceNotFound(poolName: poolName, resourceId: resourceId)
            case let .resourceAlreadyInUse(poolName, resourceId, owner):
                .resourceAlreadyInUse(poolName: poolName, resourceId: resourceId, owner: owner)
            case let .invalidResource(poolName, resourceId, reason):
                .invalidResource(poolName: poolName, resourceId: resourceId, reason: reason)
            case let .acquisitionTimeout(poolName, timeoutMs):
                .acquisitionTimeout(poolName: poolName, timeoutMs: timeoutMs)
            case let .operationFailed(poolName, operation, reason):
                .operationFailed(poolName: poolName, operation: operation, reason: reason)
            }
            // In a real implementation, we would attach the context
        }

        /// Creates a new instance of the error with a specified underlying error
        public func with(underlyingError _: Error) -> Self {
            // Similar to above, return a new instance with the same value
            self // In a real implementation, we would attach the underlying error
        }

        /// Creates a new instance of the error with source information
        public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
            // Similar to above, return a new instance with the same value
            self // In a real implementation, we would attach the source information
        }
    }
}

// MARK: - Factory Methods

public extension UmbraErrors.Resource.Pool {
    /// Create an error for a failed pool creation
    static func makeCreationFailed(
        poolName: String,
        reason: String,
        file _: String = #file,
        line _: Int = #line,
        function _: String = #function
    ) -> Self {
        .poolCreationFailed(poolName: poolName, reason: reason)
    }

    /// Create an error for a failed resource acquisition
    static func makeAcquisitionFailed(
        poolName: String,
        resourceId: String? = nil,
        reason: String,
        file _: String = #file,
        line _: Int = #line,
        function _: String = #function
    ) -> Self {
        .resourceAcquisitionFailed(poolName: poolName, resourceId: resourceId, reason: reason)
    }

    /// Create an error for a resource not found in pool
    static func makeResourceNotFound(
        poolName: String,
        resourceId: String,
        file _: String = #file,
        line _: Int = #line,
        function _: String = #function
    ) -> Self {
        .resourceNotFound(poolName: poolName, resourceId: resourceId)
    }

    /// Create an error for an exhausted resource pool
    static func makeExhausted(
        poolName: String,
        currentSize: Int,
        maxSize: Int,
        file _: String = #file,
        line _: Int = #line,
        function _: String = #function
    ) -> Self {
        .poolExhausted(poolName: poolName, currentSize: currentSize, maxSize: maxSize)
    }
}
