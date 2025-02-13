import Foundation

public extension ServiceFactory {
    /// Configure service factory with development settings
    /// - Parameters:
    ///   - simulatePermissionFailures: Whether to simulate permission failures
    ///   - simulateBookmarkFailures: Whether to simulate bookmark failures
    ///   - artificialDelay: Artificial delay for operations in seconds
    static func configureDevelopment(
        simulatePermissionFailures: Bool = false,
        simulateBookmarkFailures: Bool = false,
        artificialDelay: TimeInterval = 0
    ) {
        queue.sync {
            configuration.developmentEnabled = true
            configuration.debugLoggingEnabled = true

            developmentConfiguration.shouldSimulatePermissionFailures = simulatePermissionFailures
            developmentConfiguration.shouldSimulateBookmarkFailures = simulateBookmarkFailures
            developmentConfiguration.artificialDelay = artificialDelay
        }
    }

    /// Configure service factory with production settings
    static func configureProduction() {
        queue.sync {
            configuration.developmentEnabled = false
            configuration.debugLoggingEnabled = false

            // Reset development configuration
            developmentConfiguration.shouldSimulatePermissionFailures = false
            developmentConfiguration.shouldSimulateBookmarkFailures = false
            developmentConfiguration.artificialDelay = 0
        }
    }

    /// Configure logging
    /// - Parameter enabled: Whether debug logging is enabled
    static func configureLogging(enabled: Bool) {
        queue.sync {
            configuration.debugLoggingEnabled = enabled
        }
    }

    /// Get the current configuration state
    /// - Returns: A tuple containing the current configuration and development configuration
    static func currentConfiguration() -> (
        configuration: Configuration,
        development: DevelopmentConfiguration
    ) {
        queue.sync {
            (configuration, developmentConfiguration)
        }
    }
}
