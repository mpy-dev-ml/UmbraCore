import ErrorHandlingInterfaces
import Foundation
import UmbraLogging

// MARK: - Domain-Specific Filters

/// Extension to provide domain-specific filtering capabilities for ErrorLogger
extension ErrorLogger {
  /// Sets up domain-specific logging filter for a certain domain
  /// - Parameters:
  ///   - domain: The domain to filter
  ///   - level: The minimum log level for this domain
  /// - Returns: Configured logger
  public func setupDomainFilter(
    domain: String,
    level: UmbraLogLevel
  ) -> ErrorLogger {
    configure { config in
      // Capture the minimum log level value - not the config itself
      let configMinLevel=config.minimumLevel

      // Create a filter that checks domain and applies level-based filtering
      let domainFilter: (Error) -> Bool={ error in
        guard let umbraError=error as? ErrorHandlingInterfaces.UmbraError else {
          return false
        }

        // Check if this error matches the domain
        if umbraError.domain == domain {
          // Simply check against the configured level - we filter based on minimum level
          // Return true if the error should be filtered out
          return configMinLevel.rawValue > level.rawValue
        }

        return false
      }

      // Add this filter to the existing filters
      config.filters.append(domainFilter)
    }
  }

  /// Sets up error code specific logging filters
  /// - Parameters:
  ///   - code: The specific error code to filter
  ///   - level: The minimum log level for this code
  /// - Returns: Configured logger
  public func setupCodeFilter(
    code: String,
    level: UmbraLogLevel
  ) -> ErrorLogger {
    configure { config in
      // Capture the minimum log level value - not the config itself
      let configMinLevel=config.minimumLevel

      // Create a filter that checks error code and applies level-based filtering
      let codeFilter: (Error) -> Bool={ error in
        guard let umbraError=error as? ErrorHandlingInterfaces.UmbraError else {
          return false
        }

        // Check if this error matches the code
        if umbraError.code == code {
          // Simply check against the configured level - we filter based on minimum level
          // Return true if the error should be filtered out
          return configMinLevel.rawValue > level.rawValue
        }

        return false
      }

      // Add this filter to the existing filters
      config.filters.append(codeFilter)
    }
  }

  /// Sets up source-based logging filters
  /// - Parameters:
  ///   - sourcePattern: String pattern to match against source file paths
  ///   - level: The minimum log level for errors from this source
  /// - Returns: Configured logger
  public func setupSourceFilter(
    sourcePattern: String,
    level: UmbraLogLevel
  ) -> ErrorLogger {
    configure { config in
      // Capture the minimum log level value - not the config itself
      let configMinLevel=config.minimumLevel

      let sourceFilter: (Error) -> Bool={ error in
        guard
          let umbraError=error as? ErrorHandlingInterfaces.UmbraError,
          let source=umbraError.source
        else {
          return false
        }

        // Check if source file matches pattern
        if source.file.contains(sourcePattern) {
          // Simply check against the configured level - we filter based on minimum level
          // Return true if the error should be filtered out
          return configMinLevel.rawValue > level.rawValue
        }

        return false
      }

      // Add this filter to the existing filters
      config.filters.append(sourceFilter)
    }
  }

  /// Sets up system information logging
  /// - Returns: Configured logger
  public func setupSystemInfoLogging() -> ErrorLogger {
    configure { config in
      // Add system information as metadata
      let systemInfoFilter: (Error) -> Bool={ _ in
        // Return false to never filter out errors based on system info
        // This is just used to add system info as metadata
        false
      }

      // Set the filter
      config.filters=[systemInfoFilter]
    }
  }
}
