import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityBridgeTypes
import UmbraCoreTypes

/// Protocol for bookmark service DTOs, providing Foundation-independent bookmark operations
public protocol BookmarkServiceDTOProtocol {
    /// Create a bookmark for a file path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: A result containing the bookmark or an error
    func createBookmark(for path: FilePathDTO) -> OperationResultDTO<BookmarkDTO>
    
    /// Resolve a bookmark to a file path
    /// - Parameter bookmark: The bookmark to resolve
    /// - Returns: A result containing the resolved path and whether the bookmark was stale
    func resolveBookmark(_ bookmark: BookmarkDTO) -> OperationResultDTO<(FilePathDTO, Bool)>
    
    /// Start accessing the resource at the given path
    /// - Parameter path: The path to the resource
    /// - Returns: Result indicating success or failure
    func startAccessing(_ path: FilePathDTO) -> OperationResultDTO<Bool>
    
    /// Stop accessing the resource at the given path
    /// - Parameter path: The path to the resource
    /// - Returns: Result indicating success or failure
    func stopAccessing(_ path: FilePathDTO) -> OperationResultDTO<Void>
}

/// Adapter for BookmarkService that provides a Foundation-independent interface
public final class BookmarkServiceDTOAdapter: BookmarkServiceDTOProtocol {
    // MARK: - Properties
    
    /// The underlying bookmark service
    private let bookmarkService: BookmarkServiceType
    
    // MARK: - Initialization
    
    /// Initialize with a bookmark service
    /// - Parameter bookmarkService: The bookmark service to adapt
    public init(bookmarkService: BookmarkServiceType) {
        self.bookmarkService = bookmarkService
    }
    
    // MARK: - BookmarkServiceDTOProtocol Implementation
    
    /// Create a bookmark for a file path
    /// - Parameter path: The path to create a bookmark for
    /// - Returns: A result containing the bookmark or an error
    public func createBookmark(for path: FilePathDTO) -> OperationResultDTO<BookmarkDTO> {
        do {
            // Convert the DTO path to a URL
            guard let url = URL(string: path.path) else {
                return .failure(.init(error: SecurityErrorDTO.invalidPath(
                    path: path.path,
                    details: ["reason": "Could not convert to URL"]
                )))
            }
            
            // Create the bookmark
            let bookmarkData = try bookmarkService.createBookmark(for: url)
            
            // Create the BookmarkDTO
            let bookmarkDTO = BookmarkDTO(
                data: bookmarkData,
                displayPath: path.path,
                hasSecurityScope: true
            )
            
            return .success(bookmarkDTO)
        } catch let error as UmbraErrors.Security.Core {
            return .failure(.init(error: mapCoreError(error)))
        } catch {
            return .failure(.init(error: SecurityErrorDTO.bookmarkCreationFailed(
                path: path.path,
                details: ["error": error.localizedDescription]
            )))
        }
    }
    
    /// Resolve a bookmark to a file path
    /// - Parameter bookmark: The bookmark to resolve
    /// - Returns: A result containing the resolved path and whether the bookmark was stale
    public func resolveBookmark(_ bookmark: BookmarkDTO) -> OperationResultDTO<(FilePathDTO, Bool)> {
        do {
            // Resolve the bookmark
            let (url, wasStale) = try bookmarkService.resolveBookmark(bookmark.data)
            
            // Create a FilePathDTO from the resolved URL
            let pathDTO = FilePathDTO(
                path: url.path,
                fileName: url.lastPathComponent,
                directoryPath: url.deletingLastPathComponent().path,
                resourceType: determineResourceType(url),
                isAbsolute: true
            )
            
            return .success((pathDTO, wasStale))
        } catch let error as UmbraErrors.Security.Core {
            return .failure(.init(error: mapCoreError(error)))
        } catch {
            return .failure(.init(error: SecurityErrorDTO.bookmarkResolutionFailed(
                details: ["error": error.localizedDescription]
            )))
        }
    }
    
    /// Start accessing the resource at the given path
    /// - Parameter path: The path to the resource
    /// - Returns: Result indicating success or failure
    public func startAccessing(_ path: FilePathDTO) -> OperationResultDTO<Bool> {
        do {
            // Convert the DTO path to a URL
            guard let url = URL(string: path.path) else {
                return .failure(.init(error: SecurityErrorDTO.invalidPath(
                    path: path.path,
                    details: ["reason": "Could not convert to URL"]
                )))
            }
            
            // Start accessing the resource
            let success = try bookmarkService.startAccess(to: url)
            return .success(success)
        } catch let error as UmbraErrors.Security.Core {
            return .failure(.init(error: mapCoreError(error)))
        } catch {
            return .failure(.init(error: SecurityErrorDTO.accessFailed(
                path: path.path,
                operation: "start",
                details: ["error": error.localizedDescription]
            )))
        }
    }
    
    /// Stop accessing the resource at the given path
    /// - Parameter path: The path to the resource
    /// - Returns: Result indicating success or failure
    public func stopAccessing(_ path: FilePathDTO) -> OperationResultDTO<Void> {
        do {
            // Convert the DTO path to a URL
            guard let url = URL(string: path.path) else {
                return .failure(.init(error: SecurityErrorDTO.invalidPath(
                    path: path.path,
                    details: ["reason": "Could not convert to URL"]
                )))
            }
            
            // Stop accessing the resource
            try bookmarkService.stopAccess(to: url)
            return .success(())
        } catch let error as UmbraErrors.Security.Core {
            return .failure(.init(error: mapCoreError(error)))
        } catch {
            return .failure(.init(error: SecurityErrorDTO.accessFailed(
                path: path.path,
                operation: "stop",
                details: ["error": error.localizedDescription]
            )))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Determine the resource type of a URL
    /// - Parameter url: The URL to check
    /// - Returns: The resource type
    private func determineResourceType(_ url: URL) -> FilePathDTO.ResourceType {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return .directory
            } else {
                // Check if it's a symbolic link
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    if attributes[.type] as? FileAttributeType == .typeSymbolicLink {
                        return .symbolicLink
                    }
                } catch {
                    // Ignore errors
                }
                return .file
            }
        }
        return .unknown
    }
    
    /// Map security core errors to DTOs
    /// - Parameter error: The core error to map
    /// - Returns: A security error DTO
    private func mapCoreError(_ error: UmbraErrors.Security.Core) -> SecurityErrorDTO {
        switch error {
        case .bookmarkCreationFailed(let message, let info):
            return SecurityErrorDTO.bookmarkCreationFailed(
                path: info?["path"] as? String ?? "unknown",
                details: ["message": message]
            )
        case .bookmarkResolutionFailed(let message, let info):
            return SecurityErrorDTO.bookmarkResolutionFailed(
                details: ["message": message, "path": info?["path"] as? String ?? "unknown"]
            )
        case .secureStorageFailed(let operation, let reason):
            return SecurityErrorDTO.storageError(
                message: "Secure storage failed: \(operation)",
                details: ["reason": reason]
            )
        case .internalError(let reason):
            return SecurityErrorDTO.internalError(
                message: reason,
                details: [:]
            )
        default:
            return SecurityErrorDTO.unknown(
                message: "Unknown core error",
                details: ["description": error.localizedDescription]
            )
        }
    }
}

// MARK: - Factory Methods for SecurityErrorDTO

public extension SecurityErrorDTO {
    /// Create an error for invalid path
    /// - Parameters:
    ///   - path: The invalid path
    ///   - details: Additional details
    /// - Returns: A security error DTO
    static func invalidPath(
        path: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 2001,
            domain: "security.bookmark",
            message: "Invalid path: \(path)",
            details: details
        )
    }
    
    /// Create an error for bookmark creation failure
    /// - Parameters:
    ///   - path: The path that failed
    ///   - details: Additional details
    /// - Returns: A security error DTO
    static func bookmarkCreationFailed(
        path: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 2002,
            domain: "security.bookmark",
            message: "Failed to create bookmark for path: \(path)",
            details: details
        )
    }
    
    /// Create an error for bookmark resolution failure
    /// - Parameters:
    ///   - details: Additional details
    /// - Returns: A security error DTO
    static func bookmarkResolutionFailed(
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 2003,
            domain: "security.bookmark",
            message: "Failed to resolve bookmark",
            details: details
        )
    }
    
    /// Create an error for access failure
    /// - Parameters:
    ///   - path: The path that failed
    ///   - operation: The operation that failed
    ///   - details: Additional details
    /// - Returns: A security error DTO
    static func accessFailed(
        path: String,
        operation: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 2004,
            domain: "security.bookmark",
            message: "Failed to \(operation) access to path: \(path)",
            details: details
        )
    }
}
