import ErrorHandlingDomains
import Foundation

/// Maps between different UmbraErrors domains
/// Provides utility methods to convert errors between different security domains
public enum UmbraErrorMapper {

  // MARK: - Security Error Mapping

  public enum Security {
    /// Maps from XPC security errors to Core security errors
    /// Use this when propagating XPC errors to higher-level components
    /// - Parameter error: The XPC-specific error
    /// - Returns: An equivalent Core security error
    public static func mapXPCToCore(_ error: UmbraErrors.Security.XPC) -> UmbraErrors.Security
    .Core {
      switch error {
        case let .connectionFailed(reason):
          return .serviceError(code: 1001, reason: "XPC connection failed: \(reason)")
        case .serviceUnavailable:
          return .serviceError(code: 1002, reason: "XPC service unavailable")
        case let .invalidResponse(reason):
          return .invalidInput(reason: "Invalid XPC response: \(reason)")
        case let .unexpectedSelector(name):
          return .serviceError(code: 1003, reason: "Unexpected XPC selector: \(name)")
        case let .versionMismatch(expected, found):
          return .serviceError(
            code: 1004,
            reason: "XPC version mismatch: expected \(expected), found \(found)"
          )
        case .invalidServiceIdentifier:
          return .serviceError(code: 1005, reason: "Invalid XPC service identifier")
        case let .internalError(message):
          return .internalError("XPC internal error: \(message)")
        @unknown default:
          return .internalError("Unknown XPC error: \(error)")
      }
    }

    /// Maps from Protocol security errors to Core security errors
    /// Use this when propagating Protocol errors to higher-level components
    /// - Parameter error: The Protocol-specific error
    /// - Returns: An equivalent Core security error
    public static func mapProtocolToCore(_ error: UmbraErrors.Security.Protocols) -> UmbraErrors
    .Security.Core {
      switch error {
        case let .invalidFormat(reason):
          return .invalidInput(reason: "Protocol format error: \(reason)")
        case let .unsupportedOperation(name):
          return .notImplemented(feature: "Protocol operation: \(name)")
        case let .incompatibleVersion(version):
          return .serviceError(code: 2001, reason: "Incompatible protocol version: \(version)")
        case let .missingProtocolImplementation(protocolName):
          return .serviceError(
            code: 2002,
            reason: "Missing protocol implementation: \(protocolName)"
          )
        case let .invalidState(state, expectedState):
          return .serviceError(
            code: 2003,
            reason: "Invalid protocol state: \(state), expected: \(expectedState)"
          )
        case let .invalidInput(reason):
          return .invalidInput(reason: reason)
        case let .encryptionFailed(reason):
          return .encryptionFailed(reason: reason)
        case let .decryptionFailed(reason):
          return .decryptionFailed(reason: reason)
        case let .randomGenerationFailed(reason):
          return .randomGenerationFailed(reason: reason)
        case let .storageOperationFailed(reason):
          return .storageOperationFailed(reason: reason)
        case let .serviceError(code, reason):
          return .serviceError(code: code, reason: reason)
        case .notImplemented:
          return .notImplemented(feature: "Protocol operation")
        case let .internalError(message):
          return .internalError("Protocol internal error: \(message)")
        @unknown default:
          return .internalError("Unknown protocol error: \(error)")
      }
    }

    /// Maps from NSError to Core security errors
    /// Use this when integrating system errors into our error domain
    /// - Parameter error: The system NSError
    /// - Returns: An equivalent Core security error
    public static func mapFromNSError(_ error: NSError) -> UmbraErrors.Security.Core {
      // Map based on error domain and code
      switch error.domain {
        case NSURLErrorDomain:
          .serviceError(code: error.code, reason: "Network error: \(error.localizedDescription)")
        case NSOSStatusErrorDomain:
          .serviceError(code: error.code, reason: "System error: \(error.localizedDescription)")
        default:
          .internalError("System error: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - Storage Error Mapping

  public enum Storage {
    /// Maps from Database storage errors to Core storage errors
    /// Use this when propagating Database errors to higher-level components
    /// - Parameter error: The Database-specific error
    /// - Returns: An equivalent Core storage error
    public static func mapDatabaseToCore(_ error: UmbraErrors.Storage.Database) -> UmbraErrors
    .Storage.Core {
      switch error {
        case let .queryFailed(reason):
          return .readFailed(reason: "Database query failed: \(reason)")
        case let .connectionFailed(reason):
          return .locationUnavailable(path: "Database connection failed: \(reason)")
        case let .schemaIncompatible(expected, found):
          return .invalidFormat(
            reason: "Database schema incompatible: expected \(expected), found \(found)"
          )
        case let .migrationFailed(reason):
          return .corrupted(reason: "Database migration failed: \(reason)")
        case let .transactionFailed(reason):
          return .writeFailed(reason: "Database transaction failed: \(reason)")
        case let .constraintViolation(constraint, reason):
          return .writeFailed(reason: "Database constraint violation (\(constraint)): \(reason)")
        case let .databaseLocked(reason):
          return .accessDenied(reason: "Database is locked: \(reason)")
        case let .internalError(message):
          return .internalError("Database error: \(message)")
        @unknown default:
          return .internalError("Unknown database error: \(error)")
      }
    }

    /// Maps from FileSystem storage errors to Core storage errors
    /// Use this when propagating FileSystem errors to higher-level components
    /// - Parameter error: The FileSystem-specific error
    /// - Returns: An equivalent Core storage error
    public static func mapFileSystemToCore(_ error: UmbraErrors.Storage.FileSystem) -> UmbraErrors
    .Storage.Core {
      switch error {
        case let .permissionDenied(path):
          return .accessDenied(reason: "Permission denied for path: \(path)")
        case let .invalidPath(path):
          return .invalidFormat(reason: "Invalid path: \(path)")
        case let .directoryNotFound(path):
          return .itemNotFound(identifier: "Directory not found: \(path)")
        case let .fileNotFound(path):
          return .itemNotFound(identifier: "File not found: \(path)")
        case let .directoryCreationFailed(path, reason):
          return .creationFailed(reason: "Failed to create directory at \(path): \(reason)")
        case let .renameFailed(source, destination, reason):
          return .writeFailed(
            reason: "Failed to rename from \(source) to \(destination): \(reason)"
          )
        case let .copyFailed(source, destination, reason):
          return .writeFailed(reason: "Failed to copy from \(source) to \(destination): \(reason)")
        case let .readOnlyFileSystem(path):
          return .accessDenied(reason: "File system is read-only at \(path)")
        case let .fileInUse(path):
          return .accessDenied(reason: "File is in use: \(path)")
        case let .unsupportedOperation(operation, filesystem):
          return .internalError("Unsupported operation \(operation) on filesystem \(filesystem)")
        case .filesystemFull:
          return .outOfSpace(bytesRequired: 0, bytesAvailable: 0) // Exact bytes unknown
        case let .internalError(message):
          return .internalError("File system error: \(message)")
        @unknown default:
          return .internalError("Unknown file system error: \(error)")
      }
    }

    /// Maps from NSError to Core storage errors
    /// Use this when integrating system storage errors into our error domain
    /// - Parameter error: The system NSError
    /// - Returns: An equivalent Core storage error
    public static func mapFromNSError(_ error: NSError) -> UmbraErrors.Storage.Core {
      // Map based on error domain and code
      switch error.domain {
        case NSCocoaErrorDomain:
          switch error.code {
            case NSFileNoSuchFileError:
              .itemNotFound(identifier: error.localizedDescription)
            case NSFileWriteOutOfSpaceError:
              .outOfSpace(bytesRequired: 0, bytesAvailable: 0) // Exact bytes unknown
            case NSFileWriteNoPermissionError:
              .accessDenied(reason: error.localizedDescription)
            case NSFileReadCorruptFileError:
              .corrupted(reason: error.localizedDescription)
            default:
              .internalError("Cocoa error: \(error.localizedDescription)")
          }
        case NSPOSIXErrorDomain:
          .internalError("POSIX error: \(error.localizedDescription)")
        default:
          .internalError("System error: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - Network Error Mapping

  public enum Network {
    /// Maps from HTTP network errors to Core network errors
    /// Use this when propagating HTTP errors to higher-level components
    /// - Parameter error: The HTTP-specific error
    /// - Returns: An equivalent Core network error
    public static func mapHTTPToCore(_ error: UmbraErrors.Network.HTTP) -> UmbraErrors.Network
    .Core {
      switch error {
        case let .invalidMethod(method):
          return .invalidRequest(reason: "Invalid HTTP method: \(method)")
        case let .invalidURL(url):
          return .invalidRequest(reason: "Invalid URL: \(url)")
        case let .invalidHeader(name, value):
          return .invalidRequest(reason: "Invalid HTTP header - \(name): \(value)")
        case let .clientError(statusCode, message):
          return .requestRejected(code: statusCode, reason: message)
        case let .serverError(statusCode, message):
          return .serviceUnavailable(service: "HTTP server error \(statusCode): \(message)")
        case let .redirectError(statusCode, location, message):
          let locationInfo=location != nil ? " to \(location!)" : ""
          return .protocolError(
            protocol: "HTTP",
            reason: "Redirect error \(statusCode)\(locationInfo): \(message)"
          )
        case let .invalidContentType(expected, received):
          return .invalidResponse(
            reason: "Invalid content type: expected \(expected), received \(received)"
          )
        case let .invalidResponseFormat(reason):
          return .invalidResponse(reason: "Invalid response format: \(reason)")
        case let .requestTooLarge(size, maxSize):
          return .invalidRequest(
            reason: "Request too large: \(size) bytes (maximum \(maxSize) bytes)"
          )
        case let .responseTooLarge(size, maxSize):
          return .invalidResponse(
            reason: "Response too large: \(size) bytes (maximum \(maxSize) bytes)"
          )
        case let .missingHeader(name):
          return .invalidRequest(reason: "Missing required header: \(name)")
        case let .missingParameter(name):
          return .invalidRequest(reason: "Missing required parameter: \(name)")
        case let .tooManyRedirects(count, maxRedirects):
          return .protocolError(
            protocol: "HTTP",
            reason: "Too many redirects: \(count) (maximum \(maxRedirects))"
          )
        case let .invalidCookie(name, reason):
          return .invalidRequest(reason: "Invalid cookie \(name): \(reason)")
        case let .contentEncodingError(encoding, reason):
          return .invalidResponse(reason: "Content encoding error (\(encoding)): \(reason)")
        case let .internalError(message):
          return .internalError("HTTP error: \(message)")
        @unknown default:
          return .internalError("Unknown HTTP error: \(error)")
      }
    }

    /// Maps from Socket network errors to Core network errors
    /// Use this when propagating Socket errors to higher-level components
    /// - Parameter error: The Socket-specific error
    /// - Returns: An equivalent Core network error
    public static func mapSocketToCore(_ error: UmbraErrors.Network.Socket) -> UmbraErrors.Network
    .Core {
      switch error {
        case let .creationFailed(reason):
          return .networkUnavailable(interface: "Socket creation failed: \(reason)")
        case let .bindFailed(address, port, reason):
          return .configurationError(
            reason: "Failed to bind socket to \(address):\(port) - \(reason)"
          )
        case let .listenFailed(reason):
          return .configurationError(reason: "Failed to listen on socket: \(reason)")
        case let .acceptFailed(reason):
          return .connectionFailed(reason: "Failed to accept connection: \(reason)")
        case let .connectFailed(address, port, reason):
          return .connectionFailed(reason: "Failed to connect to \(address):\(port) - \(reason)")
        case let .readFailed(reason):
          return .connectionClosed(reason: "Socket read failed: \(reason)")
        case let .writeFailed(reason):
          return .connectionClosed(reason: "Socket write failed: \(reason)")
        case let .timeout(operation, durationMs):
          return .timeout(operation: "Socket \(operation)", durationMs: durationMs)
        case .unexpectedlyClosed:
          return .connectionClosed(reason: "Socket was closed unexpectedly")
        case let .addressInUse(address, port):
          return .configurationError(reason: "Address already in use: \(address):\(port)")
        case let .connectionRefused(address, port):
          return .hostUnreachable(host: "\(address):\(port) - connection refused")
        case let .invalidOption(option, value):
          return .configurationError(reason: "Invalid socket option: \(option)=\(value)")
        case .notConnected:
          return .connectionFailed(reason: "Socket is not connected")
        case .alreadyConnected:
          return .configurationError(reason: "Socket is already connected")
        case let .invalidAddress(address):
          return .configurationError(reason: "Invalid socket address: \(address)")
        case .wouldBlock:
          return .internalError("Socket operation would block")
        case let .internalError(message):
          return .internalError("Socket error: \(message)")
        @unknown default:
          return .internalError("Unknown socket error: \(error)")
      }
    }

    /// Maps from NSError to Core network errors
    /// Use this when integrating system network errors into our error domain
    /// - Parameter error: The system NSError
    /// - Returns: An equivalent Core network error
    public static func mapFromNSError(_ error: NSError) -> UmbraErrors.Network.Core {
      // Map based on error domain and code
      switch error.domain {
        case NSURLErrorDomain:
          switch error.code {
            case NSURLErrorTimedOut:
              .timeout(operation: "URL request", durationMs: 0) // Exact timeout unknown
            case NSURLErrorCannotFindHost:
              .dnsResolutionFailed(
                host: error
                  .userInfo[NSURLErrorFailingURLStringErrorKey] as? String ?? "unknown"
              )
            case NSURLErrorCannotConnectToHost:
              .hostUnreachable(
                host: error
                  .userInfo[NSURLErrorFailingURLStringErrorKey] as? String ?? "unknown"
              )
            case NSURLErrorNetworkConnectionLost:
              .connectionClosed(reason: "Network connection lost")
            case NSURLErrorNotConnectedToInternet:
              .networkUnavailable(interface: "Internet connection")
            case NSURLErrorSecureConnectionFailed:
              .certificateError(reason: "Secure connection failed")
            case NSURLErrorServerCertificateHasBadDate,
                 NSURLErrorServerCertificateUntrusted,
                 NSURLErrorServerCertificateHasUnknownRoot,
                 NSURLErrorServerCertificateNotYetValid:
              .certificateError(
                reason: "Certificate validation failed: \(error.localizedDescription)"
              )
            case NSURLErrorBadServerResponse:
              .invalidResponse(reason: error.localizedDescription)
            case NSURLErrorUserCancelledAuthentication:
              .authenticationFailed(reason: "User cancelled authentication")
            case NSURLErrorUserAuthenticationRequired:
              .authenticationFailed(reason: "Authentication required")
            default:
              .internalError("URL error: \(error.localizedDescription)")
          }
        case NSPOSIXErrorDomain:
          .internalError("POSIX network error: \(error.localizedDescription)")
        default:
          .internalError("System network error: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - Application Error Mapping

  public struct Application {
    private init() {}

    /// Maps the given error to an Application.Core error if possible
    /// - Parameter error: The error to map
    /// - Returns: An Application.Core error or nil if the error cannot be mapped
    public static func mapToCore(_ error: Error) -> UmbraErrors.Application.Core? {
      switch error {
        case let appError as UmbraErrors.Application.Core:
          appError

        case let uiError as UmbraErrors.Application.UI:
          mapUIErrorToCore(uiError)

        case let lifecycleError as UmbraErrors.Application.Lifecycle:
          mapLifecycleErrorToCore(lifecycleError)

        case let settingsError as UmbraErrors.Application.Settings:
          mapSettingsErrorToCore(settingsError)

        default:
          nil
      }
    }

    // MARK: - Private Mapping Methods

    /// Maps a UI error to a Core error
    /// - Parameter error: The UI error to map
    /// - Returns: An equivalent Core error
    private static func mapUIErrorToCore(_ error: UmbraErrors.Application.UI) -> UmbraErrors
    .Application.Core {
      switch error {
        case let .viewNotFound(identifier):
          return .resourceNotFound(resourceType: "View", identifier: identifier)

        case let .invalidViewState(view, state):
          return .invalidState(currentState: state, expectedState: "Valid state for \(view)")

        case let .renderingError(view, reason):
          return .internalError(reason: "Rendering error in \(view): \(reason)")

        case let .animationError(animation, reason):
          return .internalError(reason: "Animation error in \(animation): \(reason)")

        case let .constraintError(constraint, reason):
          return .internalError(reason: "Constraint error in \(constraint): \(reason)")

        case let .resourceLoadingError(resource, reason):
          return .resourceNotFound(resourceType: resource, identifier: reason)

        case let .inputValidationError(field, reason):
          return .internalError(reason: "Validation error in \(field): \(reason)")

        case let .componentInitializationError(component, reason):
          return .initializationError(component: component, reason: reason)

        case let .internalError(reason):
          return .internalError(reason: "UI error: \(reason)")

        @unknown default:
          return .internalError(reason: "Unknown UI error: \(error)")
      }
    }

    private static func mapLifecycleErrorToCore(
      _ error: UmbraErrors.Application
        .Lifecycle
    ) -> UmbraErrors.Application.Core {
      switch error {
        case let .launchError(reason):
          return .initializationError(component: "Application", reason: reason)

        case let .backgroundTransitionError(reason):
          return .internalError(reason: "Background transition error: \(reason)")

        case let .foregroundTransitionError(reason):
          return .internalError(reason: "Foreground transition error: \(reason)")

        case let .terminationError(reason):
          return .internalError(reason: "Termination error: \(reason)")

        case let .stateRestorationError(reason):
          return .internalError(reason: "State restoration error: \(reason)")

        case let .statePreservationError(reason):
          return .internalError(reason: "State preservation error: \(reason)")

        case let .memoryWarningError(reason):
          return .internalError(reason: "Memory warning error: \(reason)")

        case let .notificationHandlingError(notification, reason):
          return .internalError(
            reason: "Notification handling error for \(notification): \(reason)"
          )

        case let .internalError(reason):
          return .internalError(reason: "Lifecycle error: \(reason)")

        @unknown default:
          return .internalError(reason: "Unknown lifecycle error: \(error)")
      }
    }

    private static func mapSettingsErrorToCore(
      _ error: UmbraErrors.Application
        .Settings
    ) -> UmbraErrors.Application.Core {
      switch error {
        case let .settingsNotFound(key):
          return .resourceNotFound(resourceType: "Settings", identifier: key)

        case let .invalidValue(key, value, reason):
          return .internalError(reason: "Invalid setting value for \(key): \(value) - \(reason)")

        case let .accessError(key, reason):
          return .internalError(reason: "Settings access error for \(key): \(reason)")

        case let .persistenceError(reason):
          return .internalError(reason: "Settings persistence error: \(reason)")

        case let .migrationError(fromVersion, toVersion, reason):
          return .internalError(
            reason: "Settings migration error from \(fromVersion) to \(toVersion): \(reason)"
          )

        case let .synchronizationError(reason):
          return .internalError(reason: "Settings synchronization error: \(reason)")

        case let .defaultSettingsError(reason):
          return .internalError(reason: "Default settings error: \(reason)")

        case let .schemaValidationError(reason):
          return .internalError(reason: "Settings schema validation error: \(reason)")

        case let .internalError(reason):
          return .internalError(reason: "Settings error: \(reason)")

        @unknown default:
          return .internalError(reason: "Unknown settings error: \(error)")
      }
    }
  }
}
