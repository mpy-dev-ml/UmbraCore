import Foundation

/// Factory for creating services with appropriate implementations based on build configuration
///
/// The ServiceFactory provides a centralized way to create services with the appropriate
/// implementation based on the current build configuration and settings. It supports:
/// - Development vs Production implementations
/// - Debug vs Release builds
/// - Feature flags and configuration
/// - Dependency injection
///
/// Example usage:
/// ```swift
/// // Create services
/// let logger = LoggerFactory.createLogger(category: .security)
/// let security = ServiceFactory.createSecurityService(logger: logger)
/// let bookmark = ServiceFactory.createBookmarkService(logger: logger)
///
/// // Configure factory
/// ServiceFactory.configuration = .init(
///     developmentEnabled: true,
///     debugLoggingEnabled: true
/// )
/// ```
public enum ServiceFactory {
    // MARK: Public

    // MARK: - Types

    /// Configuration for the service factory
    public struct Configuration {
        // MARK: Lifecycle

        /// Initialize with default values
        public init(
            developmentEnabled: Bool = false,
            debugLoggingEnabled: Bool = false
        ) {
            self.developmentEnabled = developmentEnabled
            self.debugLoggingEnabled = debugLoggingEnabled
        }

        // MARK: Public

        /// Whether development services should be used
        public var developmentEnabled: Bool

        /// Whether debug logging is enabled
        public var debugLoggingEnabled: Bool
    }

    /// Global configuration for the service factory
    public static var configuration: Configuration = .init()

    // MARK: - Service Creation

    /// Create a security service
    /// - Parameter logger: Logger for the service
    /// - Returns: A security service implementation
    public static func createSecurityService(
        logger: LoggerProtocol
    ) -> SecurityServiceProtocol {
        queue.sync {
            if configuration.developmentEnabled {
                DevelopmentSecurityService(
                    logger: logger,
                    configuration: developmentConfiguration
                )
            } else {
                SecurityService(logger: logger)
            }
        }
    }

    /// Create a bookmark service
    /// - Parameter logger: Logger for the service
    /// - Returns: A bookmark service implementation
    public static func createBookmarkService(
        logger: LoggerProtocol
    ) -> BookmarkServiceProtocol {
        queue.sync {
            if configuration.developmentEnabled {
                DevelopmentBookmarkService(
                    logger: logger,
                    configuration: developmentConfiguration
                )
            } else {
                SecurityScopedBookmarkService(logger: logger)
            }
        }
    }

    // MARK: Internal

    /// Development configuration for debug builds
    struct DevelopmentConfiguration {
        /// Whether to simulate permission failures
        var shouldSimulatePermissionFailures = false

        /// Whether to simulate bookmark failures
        var shouldSimulateBookmarkFailures = false

        /// Artificial delay for operations in seconds
        var artificialDelay: TimeInterval = 0
    }

    /// Development configuration for debug builds
    static let developmentConfiguration: DevelopmentConfiguration = .init()

    // MARK: Private

    /// Queue for synchronizing service creation
    private static let queue: DispatchQueue = .init(
        label: "dev.mpy.umbracore.servicefactory",
        qos: .userInitiated
    )
}
