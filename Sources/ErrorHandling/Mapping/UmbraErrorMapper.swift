import ErrorHandlingDomains
import ErrorHandlingTypes
import Foundation

/// Central error mapper for the UmbraCore framework
/// 
/// This class provides a unified interface for mapping between different error types
/// across the UmbraCore framework.
public final class UmbraErrorMapper: @unchecked Sendable {
  /// Shared instance for convenient access
  @MainActor
  public static let shared = UmbraErrorMapper()
  
  /// Security error mapper instance
  private let securityMapper = SecurityErrorMapper()
  
  /// Private initialiser to enforce singleton pattern
  private init() {}
  
  // MARK: - Security Error Mapping
  
  /// Maps from UmbraErrors.Security.Core to SecurityError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapSecurityError(_ error: UmbraErrors.Security.Core) -> ErrorHandlingTypes.SecurityError {
    return securityMapper.mapError(error)
  }
  
  /// Maps from UmbraErrors.Security.Protocols to SecurityError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapSecurityProtocolsError(_ error: UmbraErrors.Security.Protocols) -> ErrorHandlingTypes.SecurityError {
    return .domainProtocolError(error)
  }
  
  /// Maps from UmbraErrors.Security.XPC to SecurityError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapSecurityXPCError(_ error: UmbraErrors.Security.XPC) -> ErrorHandlingTypes.SecurityError {
    return .domainXPCError(error)
  }
  
  /// Maps from SecurityError to UmbraErrors.Security.Core
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapToSecurityCore(_ error: ErrorHandlingTypes.SecurityError) -> UmbraErrors.Security.Core {
    return securityMapper.mapBtoA(error)
  }
  
  /// Maps any error to SecurityError if applicable
  /// - Parameter error: Any error
  /// - Returns: The mapped error if conversion is possible, nil otherwise
  public func mapToSecurityError(_ error: Error) -> ErrorHandlingTypes.SecurityError? {
    return securityMapper.mapToSecurityError(error)
  }
  
  // MARK: - Storage Error Mapping
  
  /// Maps from UmbraErrors.Storage.Database to StorageError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapDatabaseStorageError(_ error: UmbraErrors.Storage.Database) -> ErrorHandlingTypes.StorageError {
    switch error {
      case let .queryFailed(reason):
        return .queryFailed(reason: reason)
      case let .connectionFailed(reason):
        return .internalError(reason: "Connection failed: \(reason)")
      case let .schemaIncompatible(expected, found):
        return .invalidFormat(reason: "Schema incompatible: expected \(expected), found \(found)")
      case let .migrationFailed(reason):
        return .internalError(reason: "Migration failed: \(reason)")
      case let .transactionFailed(reason):
        return .transactionFailed(reason: reason)
      case let .constraintViolation(constraint, reason):
        return .internalError(reason: "Constraint violation \(constraint): \(reason)")
      case let .databaseLocked(reason):
        return .internalError(reason: "Database locked: \(reason)")
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .unknown(reason: "Unknown database error")
    }
  }
  
  /// Maps from UmbraErrors.Storage.FileSystem to StorageError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapFileSystemStorageError(_ error: UmbraErrors.Storage.FileSystem) -> ErrorHandlingTypes.StorageError {
    switch error {
      case let .fileNotFound(path):
        return .resourceNotFound(path: path)
      case let .directoryNotFound(path):
        return .resourceNotFound(path: path)
      case let .directoryCreationFailed(path, reason):
        return .writeFailed(reason: "Directory creation failed at \(path): \(reason)")
      case let .renameFailed(source, destination, reason):
        return .internalError(reason: "Rename failed from \(source) to \(destination): \(reason)")
      case let .copyFailed(source, destination, reason):
        return .copyFailed(source: source, destination: destination, reason: reason)
      case let .permissionDenied(path):
        return .accessDenied(reason: "Permission denied for \(path)")
      case let .invalidPath(path):
        return .invalidFormat(reason: "Invalid path: \(path)")
      case let .readOnlyFileSystem(path):
        return .accessDenied(reason: "Filesystem is read-only at \(path)")
      case let .fileInUse(path):
        return .internalError(reason: "File in use: \(path)")
      case let .unsupportedOperation(operation, filesystem):
        return .internalError(reason: "Unsupported operation \(operation) on filesystem \(filesystem)")
      case .filesystemFull:
        return .insufficientSpace(required: 1, available: 0)
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .unknown(reason: "Unknown filesystem error")
    }
  }
  
  // MARK: - Network Error Mapping
  
  /// Maps from UmbraErrors.Network.Core to NetworkError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapNetworkError(_ error: UmbraErrors.Network.Core) -> ErrorHandlingTypes.NetworkError {
    switch error {
      case let .connectionFailed(reason):
        return .connectionFailed(reason: reason)
      case let .hostUnreachable(host):
        return .internalError(reason: "Host unreachable: \(host)")
      case let .timeout(operation, durationMs):
        return .timeout(operation: operation, durationMs: durationMs)
      case let .dnsResolutionFailed(host):
        return .internalError(reason: "DNS resolution failed for host: \(host)")
      case let .authenticationFailed(reason):
        return .internalError(reason: "Authentication failed: \(reason)")
      case let .connectionClosed(reason):
        return .interrupted(reason: "Connection closed: \(reason)")
      case let .invalidRequest(reason):
        return .invalidRequest(reason: reason)
      case let .invalidResponse(reason):
        return .invalidResponse(reason: reason)
      case let .serviceUnavailable(service):
        return .serviceUnavailable(service: service, reason: "Service unavailable")
      case let .protocolError(protocolType, reason):
        return .internalError(reason: "Protocol error in \(protocolType): \(reason)")
      case let .requestRejected(code, reason):
        return .requestRejected(code: code, reason: reason)
      case let .rateLimitExceeded(limit, resetTimeSeconds):
        return .rateLimitExceeded(limitPerHour: limit, retryAfterMs: resetTimeSeconds * 1000)
      case let .insecureConnection(reason):
        return .certificateError(reason: "Insecure connection: \(reason)")
      case let .networkUnavailable(interface):
        return .internalError(reason: "Network unavailable on interface: \(interface)")
      case let .configurationError(reason):
        return .internalError(reason: "Network configuration error: \(reason)")
      case let .certificateError(reason):
        return .certificateError(reason: reason)
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .unknown(reason: "Unknown network error")
    }
  }
  
  /// Maps NetworkError to UmbraErrors.Network.Core
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapToNetworkCore(_ error: ErrorHandlingTypes.NetworkError) -> UmbraErrors.Network.Core {
    switch error {
      case let .connectionFailed(reason):
        return .connectionFailed(reason: reason)
      case let .serviceUnavailable(service, _):
        return .serviceUnavailable(service: service)
      case let .timeout(operation, durationMs):
        return .timeout(operation: operation, durationMs: durationMs)
      case let .invalidResponse(reason):
        return .invalidResponse(reason: reason)
      case let .parsingFailed(reason):
        return .invalidResponse(reason: "Parsing failed: \(reason)")
      case let .invalidRequest(reason):
        return .invalidRequest(reason: reason)
      case let .requestRejected(code, reason):
        return .requestRejected(code: code, reason: reason)
      case .requestTooLarge:
        return .internalError("Request too large")
      case let .rateLimitExceeded(limit, retryAfterMs):
        return .rateLimitExceeded(limit: limit, resetTimeSeconds: retryAfterMs / 1000)
      case let .certificateError(reason):
        return .certificateError(reason: reason)
      case let .interrupted(reason):
        return .connectionClosed(reason: reason)
      case let .dataCorruption(reason):
        return .internalError("Data corruption: \(reason)")
      case .responseTooLarge:
        return .internalError("Response too large")
      case let .untrustedHost(hostname):
        return .internalError("Untrusted host: \(hostname)")
      case let .internalError(reason):
        return .internalError(reason)
      case let .unknown(reason):
        return .internalError(reason)
      @unknown default:
        return .internalError("Unknown network error conversion")
    }
  }
  
  // MARK: - Network HTTP Error Mapping
  
  /// Maps from UmbraErrors.Network.HTTP to NetworkError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapNetworkHTTPError(_ error: UmbraErrors.Network.HTTP) -> ErrorHandlingTypes.NetworkError {
    switch error {
    case let .badRequest(reason):
      return .invalidRequest(reason: reason)
    case let .unauthorised(reason):
      return .requestRejected(code: 401, reason: reason)
    case let .forbidden(resource, reason):
      return .requestRejected(code: 403, reason: "Access to '\(resource)' is forbidden. \(reason)")
    case let .notFound(resource):
      return .requestRejected(code: 404, reason: "Resource '\(resource)' not found")
    case let .methodNotAllowed(method, allowedMethods):
      return .invalidRequest(reason: "Method '\(method)' not allowed. Supported: \(allowedMethods.joined(separator: ", "))")
    case let .requestTimeout(timeoutMs):
      return .timeout(operation: "HTTP request", durationMs: timeoutMs)
    case let .conflict(resource, reason):
      return .requestRejected(code: 409, reason: "Conflict with resource '\(resource)': \(reason)")
    case let .payloadTooLarge(sizeBytes, maxSizeBytes):
      return .requestTooLarge(sizeByte: sizeBytes, maxSizeByte: maxSizeBytes)
    case let .tooManyRequests(retryAfterMs):
      return .rateLimitExceeded(limitPerHour: 0, retryAfterMs: retryAfterMs)
    case let .internalServerError(reason):
      return .serviceUnavailable(service: "server", reason: "Internal server error: \(reason)")
    case let .notImplemented(feature):
      return .serviceUnavailable(service: "server", reason: "Feature '\(feature)' not implemented")
    case let .badGateway(reason):
      return .serviceUnavailable(service: "gateway", reason: reason)
    case let .serviceUnavailable(reason, _):
      return .serviceUnavailable(service: "server", reason: reason)
    case let .gatewayTimeout(reason):
      return .timeout(operation: "Gateway request", durationMs: 30000)
    case let .secureConnectionFailed(reason):
      return .connectionFailed(reason: "Secure connection failed: \(reason)")
    case let .redirectError(reason, _):
      return .connectionFailed(reason: "Redirect error: \(reason)")
    case let .invalidHeaders(reason):
      return .invalidRequest(reason: "Invalid headers: \(reason)")
    case let .contentTypeMismatch(expected, received):
      return .invalidResponse(reason: "Content type mismatch: expected '\(expected)', got '\(received)'")
    }
  }
  
  // MARK: - Application Error Mapping
  
  /// Maps from UmbraErrors.Application.Core to ApplicationError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapApplicationError(_ error: UmbraErrors.Application.Core) -> ErrorHandlingTypes.ApplicationError {
    switch error {
      case let .configurationError(reason):
        return .invalidConfiguration(reason: reason)
      case let .initializationError(component, reason):
        return .initialisationFailed(reason: "Failed to initialise \(component): \(reason)")
      case let .resourceNotFound(resourceType, identifier):
        return .resourceMissing(resource: "\(resourceType):\(identifier)")
      case let .resourceAlreadyExists(resourceType, identifier):
        return .internalError(reason: "Resource already exists: \(resourceType):\(identifier)")
      case let .operationTimeout(operation, durationMs):
        return .operationTimeout(operation: operation, durationMs: durationMs)
      case let .operationCancelled(operation):
        return .internalError(reason: "Operation cancelled: \(operation)")
      case let .invalidState(currentState, expectedState):
        return .invalidState(current: currentState, expected: expectedState)
      case let .dependencyError(dependency, reason):
        return .internalError(reason: "Dependency failure: \(dependency) - \(reason)")
      case let .externalServiceError(service, reason):
        return .internalError(reason: "External service error \(service): \(reason)")
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .internalError(reason: "Unknown application error")
    }
  }
  
  /// Maps from UmbraErrors.Application.UI to ApplicationError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapUIApplicationError(_ error: UmbraErrors.Application.UI) -> ErrorHandlingTypes.ApplicationError {
    switch error {
      case let .viewNotFound(identifier):
        return .viewControllerMissing(name: identifier)
      case let .invalidViewState(view, state):
        return .invalidState(current: state, expected: "valid state for \(view)")
      case let .renderingError(view, reason):
        return .internalError(reason: "Rendering error in \(view): \(reason)")
      case let .animationError(animation, reason):
        return .internalError(reason: "Animation error in \(animation): \(reason)")
      case let .constraintError(constraint, reason):
        return .internalError(reason: "Constraint error with \(constraint): \(reason)")
      case let .resourceLoadingError(resource, reason):
        return .resourceMissing(resource: "\(resource) (loading error: \(reason))")
      case let .inputValidationError(field, reason):
        return .internalError(reason: "Input validation failed for \(field): \(reason)")
      case let .componentInitializationError(component, reason):
        return .internalError(reason: "Failed to initialise UI component \(component): \(reason)")
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .internalError(reason: "Unknown UI application error")
    }
  }
  
  /// Maps from UmbraErrors.Application.Lifecycle to ApplicationError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapLifecycleApplicationError(_ error: UmbraErrors.Application.Lifecycle) -> ErrorHandlingTypes.ApplicationError {
    switch error {
      case let .launchError(reason):
        return .initialisationFailed(reason: reason)
      case .backgroundTransitionError:
        return .invalidState(current: "transitioning to background", expected: "stable state")
      case .foregroundTransitionError:
        return .invalidState(current: "transitioning to foreground", expected: "stable state")
      case let .terminationError(reason):
        return .internalError(reason: "Termination error: \(reason)")
      case let .stateRestorationError(reason):
        return .internalError(reason: "State restoration error: \(reason)")
      case let .statePreservationError(reason):
        return .internalError(reason: "State preservation error: \(reason)")
      case let .memoryWarningError(reason):
        return .internalError(reason: "Memory warning error: \(reason)")
      case let .notificationHandlingError(notification, reason):
        return .internalError(reason: "Notification handling error for \(notification): \(reason)")
      case let .internalError(reason):
        return .internalError(reason: reason)
      @unknown default:
        return .internalError(reason: "Unknown lifecycle application error")
    }
  }
  
  // MARK: - Repository Error Mapping
  
  /// Maps from UmbraErrors.Repository.Core to RepositoryErrorType
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapRepositoryError(_ error: UmbraErrors.Repository.Core) -> ErrorHandlingDomains.RepositoryErrorType {
    switch error {
    case let .repositoryNotFound(resource):
      return .repositoryNotFound(resource)
    case let .repositoryOpenFailed(reason):
      return .repositoryOpenFailed(reason)
    case let .repositoryCorrupt(reason):
      return .repositoryCorrupt(reason)
    case let .repositoryLocked(owner):
      return .repositoryLocked(owner ?? "another process")
    case let .invalidState(state, expectedState):
      return .invalidState("Current state: \(state), expected: \(expectedState)")
    case let .permissionDenied(operation, reason):
      return .permissionDenied("Operation '\(operation)' denied: \(reason)")
    case let .objectNotFound(objectId, objectType):
      let description = objectType.map { "\($0) with ID \(objectId)" } ?? objectId
      return .objectNotFound(description)
    case let .objectAlreadyExists(objectId, objectType):
      let description = objectType.map { "\($0) with ID \(objectId)" } ?? objectId
      return .objectAlreadyExists(description)
    case let .objectCorrupt(objectId, reason):
      return .objectCorrupt("Object \(objectId): \(reason)")
    case let .invalidObjectType(providedType, expectedType):
      return .invalidObjectType("Provided \(providedType), expected \(expectedType)")
    case let .invalidObjectData(objectId, reason):
      return .invalidObjectData("Object \(objectId): \(reason)")
    case let .saveFailed(objectId, reason):
      return .saveFailed("Failed to save object \(objectId): \(reason)")
    case let .deleteFailed(objectId, reason):
      return .saveFailed("Failed to delete object \(objectId): \(reason)")
    case let .updateFailed(objectId, reason):
      return .saveFailed("Failed to update object \(objectId): \(reason)")
    case .timeout, .internalError:
      return .invalidState("Repository operation failed")
    }
  }
  
  // MARK: - Resource File Error Mapping
  
  /// Maps from UmbraErrors.Resource.File to ResourceError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapResourceFileError(_ error: UmbraErrors.Resource.File) -> ErrorHandlingTypes.ResourceError {
    switch error {
    case let .fileNotFound(path):
      return .resourceNotFound(resource: path)
    case let .directoryNotFound(path):
      return .resourceNotFound(resource: path)
    case let .permissionDenied(path, operation):
      return .accessDenied(reason: "Permission denied for operation '\(operation)' on path: \(path)")
    case let .fileAlreadyExists(path):
      return .resourceAlreadyExists(resource: path)
    case let .directoryAlreadyExists(path):
      return .resourceAlreadyExists(resource: path)
    case let .readFailed(path, reason):
      return .readFailed(reason: "Failed to read from '\(path)': \(reason)")
    case let .writeFailed(path, reason):
      return .writeFailed(reason: "Failed to write to '\(path)': \(reason)")
    case let .deleteFailed(path, reason):
      return .deleteFailed(reason: "Failed to delete '\(path)': \(reason)")
    case let .createDirectoryFailed(path, reason):
      return .writeFailed(reason: "Failed to create directory '\(path)': \(reason)")
    case let .moveFailed(sourcePath, destinationPath, reason):
      return .writeFailed(reason: "Failed to move from '\(sourcePath)' to '\(destinationPath)': \(reason)")
    case let .copyFailed(sourcePath, destinationPath, reason):
      return .copyFailed(source: sourcePath, destination: destinationPath, reason: reason)
    case let .fileInUse(path, processName):
      let process = processName.map { " by process \($0)" } ?? ""
      return .resourceLocked(resource: path, reason: "File is in use\(process)")
    case let .readOnlyFileSystem(path):
      return .accessDenied(reason: "File system is read-only for path: \(path)")
    case let .diskFull(path, requiredBytes, availableBytes):
      var reason = "Disk is full for path: \(path)"
      if let required = requiredBytes, let available = availableBytes {
        reason += " (required: \(required) bytes, available: \(available) bytes)"
      }
      return .resourceExhausted(resource: "disk", reason: reason)
    case let .fileCorrupt(path, reason):
      return .resourceCorrupt(resource: path, reason: reason)
    case let .invalidPath(path, reason):
      return .invalidRequest(reason: "Invalid path '\(path)': \(reason)")
    }
  }
  
  // MARK: - Resource Pool Error Mapping
  
  /// Maps from UmbraErrors.Resource.Pool to ResourceError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapResourcePoolError(_ error: UmbraErrors.Resource.Pool) -> ErrorHandlingTypes.ResourceError {
    switch error {
    case let .poolCreationFailed(poolName, reason):
      return .internalError(reason: "Failed to create resource pool '\(poolName)': \(reason)")
    case let .poolInitialisationFailed(poolName, reason):
      return .internalError(reason: "Failed to initialise resource pool '\(poolName)': \(reason)")
    case let .poolExhausted(poolName, currentSize, maxSize):
      return .resourceExhausted(resource: poolName, reason: "Pool exhausted (current: \(currentSize), maximum: \(maxSize))")
    case let .invalidPoolState(poolName, state, expectedState):
      let expected = expectedState.map { ", expected '\($0)'" } ?? ""
      return .invalidState(reason: "Resource pool '\(poolName)' is in invalid state: '\(state)'\(expected)")
    case let .poolAlreadyExists(poolName):
      return .resourceAlreadyExists(resource: "pool:\(poolName)")
    case let .resourceAcquisitionFailed(poolName, resourceId, reason):
      let id = resourceId.map { " '\($0)'" } ?? ""
      return .acquisitionFailed(reason: "Failed to acquire resource\(id) from pool '\(poolName)': \(reason)")
    case let .resourceReleaseFailed(poolName, resourceId, reason):
      return .internalError(reason: "Failed to release resource '\(resourceId)' back to pool '\(poolName)': \(reason)")
    case let .resourceNotFound(poolName, resourceId):
      return .resourceNotFound(resource: "Resource '\(resourceId)' in pool '\(poolName)'")
    case let .resourceAlreadyInUse(poolName, resourceId, owner):
      let ownerInfo = owner.map { " by \($0)" } ?? ""
      return .resourceLocked(resource: resourceId, reason: "Already in use\(ownerInfo)")
    case let .invalidResource(poolName, resourceId, reason):
      return .invalidRequest(reason: "Resource '\(resourceId)' is invalid for pool '\(poolName)': \(reason)")
    case let .acquisitionTimeout(poolName, timeoutMs):
      return .timeout(operation: "Resource acquisition from pool '\(poolName)'", durationMs: timeoutMs)
    case let .operationFailed(poolName, operation, reason):
      return .internalError(reason: "Operation '\(operation)' failed for pool '\(poolName)': \(reason)")
    }
  }
  
  // MARK: - Logging Error Mapping
  
  /// Maps from UmbraErrors.Logging.Core to LoggingError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapLoggingError(_ error: UmbraErrors.Logging.Core) -> ErrorHandlingTypes.LoggingError {
    switch error {
    case let .initialisationFailed(reason):
      return .initialisationFailed(reason)
    case let .logFileInitialisationFailed(filePath, reason):
      return .initialisationFailed("Failed to initialise log file '\(filePath)': \(reason)")
    case let .destinationInitialisationFailed(destination, reason):
      return .initialisationFailed("Failed to initialise log destination '\(destination)': \(reason)")
    case let .writeFailed(reason):
      return .writeFailed(reason)
    case let .flushFailed(reason):
      return .writeFailed("Failed to flush log buffer: \(reason)")
    case let .rotationFailed(filePath, reason):
      return .writeFailed("Failed to rotate log file '\(filePath)': \(reason)")
    case let .entrySizeLimitExceeded(entrySize, maxSize):
      return .invalidConfiguration("Log entry size (\(entrySize) bytes) exceeds maximum size (\(maxSize) bytes)")
    case let .formatterError(reason):
      return .writeFailed("Log formatter error: \(reason)")
    case let .invalidConfiguration(reason):
      return .invalidConfiguration(reason)
    case let .invalidLogLevel(providedLevel, validLevels):
      return .invalidConfiguration("Invalid log level '\(providedLevel)'. Valid levels: \(validLevels.joined(separator: ", "))")
    case let .unsupportedDestination(destination):
      return .invalidConfiguration("Unsupported log destination: '\(destination)'")
    case let .destinationUnavailable(destination, reason):
      return .writeFailed("Log destination '\(destination)' is unavailable: \(reason)")
    case let .insufficientDiskSpace(requireBytes, availableBytes):
      return .writeFailed("Insufficient disk space for logging: required \(requireBytes) bytes, available \(availableBytes) bytes")
    case let .permissionDenied(filePath, operation):
      return .writeFailed("Permission denied for operation '\(operation)' on log file '\(filePath)'")
    }
  }
  
  // MARK: - Bookmark Error Mapping
  
  /// Maps from UmbraErrors.Bookmark.Core to BookmarkError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapBookmarkError(_ error: UmbraErrors.Bookmark.Core) -> ErrorHandlingTypes.BookmarkError {
    switch error {
    case let .creationFailed(url, reason):
      return .bookmarkCreationFailed(url: url)
    case let .resolutionFailed(reason, underlyingError):
      return .bookmarkResolutionFailed(underlyingError)
    case let .staleBookmark(url):
      return .staleBookmark(url: url)
    case let .invalidBookmarkData(reason):
      return .invalidBookmarkData
    case let .accessDenied(url, _):
      return .accessDenied(url: url)
    case let .startAccessFailed(url, _):
      return .startAccessFailed(url: url)
    case let .stopAccessFailed(url, _):
      return .startAccessFailed(url: url) // Mapping to startAccessFailed as there's no direct equivalent
    case let .fileNotFound(url):
      return .fileNotFound(url: url)
    case .permissionDenied, .fileRelocated, .unsupportedFileType, .serialisationFailed, .deserialisationFailed:
      // Map other error types to appropriate standard bookmark errors
      if case let .permissionDenied(url) = error {
        return .accessDenied(url: url)
      } else if case let .fileRelocated(originalURL, _) = error {
        return .fileNotFound(url: originalURL)
      } else if case let .unsupportedFileType(url, _) = error {
        return .bookmarkCreationFailed(url: url)
      } else if case .serialisationFailed = error || case .deserialisationFailed = error {
        return .invalidBookmarkData
      }
      return .invalidBookmarkData // Default fallback
    }
  }
  
  // MARK: - XPC Error Mapping
  
  /// Maps from UmbraErrors.XPC.Core to XPCError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapXPCCoreError(_ error: UmbraErrors.XPC.Core) -> ErrorHandlingTypes.XPCError {
    switch error {
    case let .connectionFailed(serviceName, reason):
      return .connectionFailed(service: serviceName, reason: reason)
    case let .connectionInterrupted(serviceName):
      return .connectionInterrupted(service: serviceName)
    case let .invalidConnection(serviceName, reason):
      return .invalidConnection(service: serviceName, reason: reason)
    case let .serviceUnavailable(serviceName):
      return .serviceUnavailable(service: serviceName)
    case let .messageSendFailed(serviceName, reason):
      return .messageSendFailed(service: serviceName, reason: reason)
    case let .messageReceiveFailed(serviceName, reason):
      return .messageReceiveFailed(service: serviceName, reason: reason)
    case let .messageTimeout(serviceName, timeoutMs):
      return .timeout(operation: "XPC message to \(serviceName)", durationMs: timeoutMs)
    case let .invalidMessageFormat(serviceName, reason):
      return .invalidMessageFormat(service: serviceName, reason: reason)
    case let .serialisationFailed(typeName, reason):
      return .invalidMessageFormat(service: "XPC", reason: "Failed to serialise \(typeName): \(reason)")
    case let .deserialisationFailed(typeName, reason):
      return .invalidMessageFormat(service: "XPC", reason: "Failed to deserialise \(typeName): \(reason)")
    case let .securityViolation(serviceName, reason):
      return .securityViolation(service: serviceName, reason: reason)
    case let .entitlementMissing(serviceName, entitlement):
      return .entitlementMissing(service: serviceName, entitlement: entitlement)
    case let .serviceTerminated(serviceName, reason):
      return .serviceTerminated(service: serviceName, reason: reason ?? "Unknown reason")
    case let .serviceCrashed(serviceName, exitCode):
      let exitInfo = exitCode.map { " with exit code \($0)" } ?? ""
      return .serviceCrashed(service: serviceName, reason: "Service crashed\(exitInfo)")
    case let .resourceLimitsExceeded(serviceName, resource):
      return .resourceExhausted(service: serviceName, resource: resource)
    }
  }
  
  /// Maps from UmbraErrors.XPC.Protocols to XPCError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapXPCProtocolError(_ error: UmbraErrors.XPC.Protocols) -> ErrorHandlingTypes.XPCError {
    switch error {
    case let .missingProtocolImplementation(protocolName):
      return .protocolError(reason: "Missing implementation for required protocol '\(protocolName)'")
    case let .invalidFormat(reason):
      return .invalidMessageFormat(service: "XPC Protocol", reason: reason)
    case let .unsupportedOperation(name):
      return .unsupportedOperation(name: name)
    case let .incompatibleVersion(version):
      return .protocolError(reason: "Protocol version '\(version)' is incompatible")
    case let .invalidState(state, expectedState):
      return .protocolError(reason: "Protocol is in invalid state: current '\(state)', expected '\(expectedState)'")
    case let .messageEncodingFailed(protocolName, reason):
      return .messageSendFailed(service: protocolName, reason: "Encoding failed: \(reason)")
    case let .messageDecodingFailed(protocolName, reason):
      return .messageReceiveFailed(service: protocolName, reason: "Decoding failed: \(reason)")
    case let .unsupportedMessageType(type, protocolName, supportedVersion):
      var message = "Message type '\(type)' is not supported by protocol '\(protocolName)'"
      if let version = supportedVersion {
        message += " (supported in version: \(version))"
      }
      return .protocolError(reason: message)
    case let .securityVerificationFailed(protocolName, reason):
      return .securityViolation(service: protocolName, reason: reason)
    case let .authenticationFailed(protocolName, reason):
      return .securityViolation(service: protocolName, reason: "Authentication failed: \(reason)")
    case let .entitlementMissing(protocolName, entitlement):
      return .entitlementMissing(service: protocolName, entitlement: entitlement)
    case let .internalError(message):
      return .internalError(reason: message)
    }
  }
  
  // MARK: - Crypto Error Mapping
  
  /// Maps from UmbraErrors.Crypto.Core to CryptoError
  /// - Parameter error: The source error
  /// - Returns: The mapped error
  public func mapCryptoError(_ error: UmbraErrors.Crypto.Core) -> ErrorHandlingTypes.CryptoError {
    switch error {
    case let .encryptionFailed(reason):
      return .encryptionFailed(reason: reason)
    case let .decryptionFailed(reason):
      return .decryptionFailed(reason: reason)
    case let .signatureGenerationFailed(reason):
      return .signatureGenerationFailed(reason: reason)
    case let .signatureVerificationFailed(reason):
      return .signatureVerificationFailed(reason: reason)
    case let .keyGenerationFailed(reason):
      return .keyGenerationFailed(reason: reason)
    case let .keyDerivationFailed(reason):
      return .keyGenerationFailed(reason: "Key derivation failed: \(reason)")
    case let .keyExportFailed(reason):
      return .keyManagementError(reason: "Failed to export key: \(reason)")
    case let .keyImportFailed(reason):
      return .keyManagementError(reason: "Failed to import key: \(reason)")
    case let .keyNotFound(keyId, keyType):
      let typeInfo = keyType.map { " of type \($0)" } ?? ""
      return .keyManagementError(reason: "Key\(typeInfo) with ID \(keyId) not found")
    case let .invalidKey(reason):
      return .keyManagementError(reason: "Invalid key: \(reason)")
    case let .invalidKeySize(providedSize, expectedSize):
      return .keyManagementError(reason: "Invalid key size: \(providedSize) bits (expected: \(expectedSize) bits)")
    case let .algorithmNotSupported(algorithm):
      return .invalidAlgorithm(algorithm: algorithm)
    case let .invalidAlgorithmParameters(algorithm, reason):
      return .invalidAlgorithm(algorithm: algorithm, reason: reason)
    case let .randomGenerationFailed(reason):
      return .randomGenerationFailed(reason: reason)
    case let .hashingFailed(reason):
      return .hashingFailed(reason: reason)
    case let .invalidInputData(reason):
      return .invalidInputData(reason: reason)
    case let .invalidOutputData(reason):
      return .invalidOutputData(reason: reason)
    case let .secureEnclaveError(reason):
      return .secureEnclaveError(reason: reason)
    case let .invalidCertificate(reason):
      return .certificateError(reason: reason)
    case let .certificateValidationFailed(reason):
      return .certificateError(reason: "Validation failed: \(reason)")
    case let .internalError(reason):
      return .internalError(reason: reason)
    }
  }
}
