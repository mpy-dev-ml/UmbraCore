/// Core Module
///
/// Provides fundamental types and utilities that form the foundation
/// of the UmbraCore framework. This module contains essential
/// functionality used across all other modules.
///
/// # Key Features
/// - Base types and protocols
/// - Common utilities
/// - Framework configuration
/// - System integration
///
/// # Module Organisation
///
/// ## Foundation Types
/// ```swift
/// Result
/// Optional
/// Sequence
/// ```
///
/// ## Configuration
/// ```swift
/// CoreConfig
/// Environment
/// BuildFlags
/// ```
///
/// ## System Integration
/// ```swift
/// SystemInfo
/// PlatformUtils
/// VersionInfo
/// ```
///
/// # Framework Configuration
///
/// ## Build Configuration
/// Supports multiple build configurations:
/// - Debug: Development builds
/// - Release: Production builds
/// - Profile: Performance analysis
///
/// ## Environment Settings
/// Environment-specific configuration:
/// - Development
/// - Staging
/// - Production
///
/// # System Integration
///
/// ## Platform Support
/// - macOS 14.0+
/// - Apple Silicon optimisation
/// - Intel compatibility
///
/// ## Version Management
/// - Semantic versioning
/// - Compatibility checking
/// - Update management
///
/// # Performance Considerations
///
/// ## Memory Management
/// - Resource pooling
/// - Cache management
/// - Memory limits
///
/// ## Optimisation
/// - Lazy loading
/// - Value semantics
/// - Copy-on-write
///
/// # Usage Example
/// ```swift
/// let config = CoreConfig.current
/// 
/// if config.isDebugBuild {
///     // Enable additional debugging
/// }
/// ```
///
/// # Thread Safety
/// Core types are designed for concurrent use:
/// - Thread-safe configuration
/// - Atomic operations
/// - Value types

import Foundation

/// Core framework initialisation and management
public enum Core {
    /// Current version of the Core module
    public static let version = "1.0.0"

    /// Initialise the Core framework
    /// - Throws: CoreError if initialisation fails
    public static func initialise() async throws {
        // TODO: Implement core initialisation
    }
}

/// Errors that can occur during Core operations
public enum CoreError: Foundation.LocalizedError {
    /// Error during initialisation
    case initialisationError(String)

    public var errorDescription: String? {
        switch self {
        case .initialisationError(let message):
            return "Initialisation error: \(message)"
        }
    }
}
