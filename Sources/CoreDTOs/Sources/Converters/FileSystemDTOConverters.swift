import Foundation
import UmbraCoreTypes

// MARK: - File System DTO Converters

/// Extensions for converting between Foundation types and DTOs
public extension FilePathDTO {
    /// Create a FilePathDTO from a Foundation URL
    /// - Parameters:
    ///   - url: The URL to convert
    ///   - resourceType: Optional resource type, otherwise inferred
    /// - Returns: A FilePathDTO representing the URL
    static func from(url: URL, resourceType: ResourceType? = nil) -> FilePathDTO {
        var type = resourceType
        
        // Try to determine resource type if not provided
        if type == nil {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                type = isDirectory.boolValue ? .directory : .file
            } else {
                type = .unknown
            }
        }
        
        return FilePathDTO(
            path: url.path,
            fileName: url.lastPathComponent,
            directoryPath: url.deletingLastPathComponent().path,
            resourceType: type ?? .unknown,
            isAbsolute: url.path.hasPrefix("/")
        )
    }
    
    /// Convert this FilePathDTO to a Foundation URL
    /// - Returns: A URL representing this path, or nil if conversion fails
    func toURL() -> URL? {
        URL(fileURLWithPath: path)
    }
}

public extension BookmarkDTO {
    /// Create a BookmarkDTO from Foundation Data
    /// - Parameters:
    ///   - data: The bookmark data
    ///   - displayPath: A string representation of the path
    ///   - hasSecurityScope: Whether this bookmark has a security scope
    /// - Returns: A BookmarkDTO
    static func from(data: Data, displayPath: String, hasSecurityScope: Bool = false) -> BookmarkDTO {
        BookmarkDTO(
            data: [UInt8](data),
            displayPath: displayPath,
            hasSecurityScope: hasSecurityScope
        )
    }
    
    /// Convert this BookmarkDTO to Foundation Data
    /// - Returns: Data representing the bookmark
    func toData() -> Data {
        Data(data)
    }
}

// MARK: - Standard path utilities

public extension FilePathDTO {
    /// Get the home directory path
    /// - Returns: A FilePathDTO representing the user's home directory
    static func homeDirectory() -> FilePathDTO {
        let homePath = NSHomeDirectory()
        return FilePathDTO.fromString(homePath).withResourceType(.directory)
    }
    
    /// Get the temporary directory path
    /// - Returns: A FilePathDTO representing the temporary directory
    static func temporaryDirectory() -> FilePathDTO {
        let tempPath = NSTemporaryDirectory()
        return FilePathDTO.fromString(tempPath).withResourceType(.directory)
    }
    
    /// Get the documents directory path
    /// - Returns: A FilePathDTO representing the documents directory
    static func documentsDirectory() -> FilePathDTO {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsPath = paths.first ?? ""
        return FilePathDTO.fromString(documentsPath).withResourceType(.directory)
    }
    
    /// Get the application support directory path
    /// - Returns: A FilePathDTO representing the application support directory
    static func applicationSupportDirectory() -> FilePathDTO {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let appSupportPath = paths.first ?? ""
        return FilePathDTO.fromString(appSupportPath).withResourceType(.directory)
    }
}
