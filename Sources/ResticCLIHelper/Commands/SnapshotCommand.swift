import Foundation

/// Command for managing Restic snapshots
public struct SnapshotCommand: ResticCommand {
    /// Type of snapshot operation
    public enum Operation {
        /// List snapshots
        case list
        /// Delete snapshots
        case delete([String])
        
        var commandName: String {
            switch self {
            case .list: return "snapshots"
            case .delete: return "forget"
            }
        }
    }
    
    /// Common options for the command
    public let options: CommonOptions
    
    /// Operation to perform
    public let operation: Operation
    
    /// Filter by path
    public let path: String?
    
    /// Filter by tags
    public let tags: [String]
    
    /// Filter by host
    public let host: String?
    
    public var commandName: String {
        operation.commandName
    }
    
    public var environment: [String: String] {
        options.environmentVariables
    }
    
    public var arguments: [String] {
        var args = options.arguments
        
        // Add path filter
        if let path = path {
            args.append("--path")
            args.append(path)
        }
        
        // Add tags filter
        if !tags.isEmpty {
            args.append("--tag")
            args.append(tags.joined(separator: ","))
        }
        
        // Add host filter
        if let host = host {
            args.append("--host")
            args.append(host)
        }
        
        // Add snapshot IDs for delete operation
        if case .delete(let ids) = operation {
            args.append(contentsOf: ids)
        }
        
        return args
    }
    
    public func validate() throws {
        // Validate tags
        for tag in tags {
            guard !tag.isEmpty else {
                throw ResticError.invalidParameter("Empty tag is not allowed")
            }
            guard !tag.contains(",") else {
                throw ResticError.invalidParameter("Tag cannot contain commas: \(tag)")
            }
        }
        
        // Validate snapshot IDs for delete operation
        if case .delete(let ids) = operation {
            guard !ids.isEmpty else {
                throw ResticError.missingParameter("At least one snapshot ID is required for delete operation")
            }
            for id in ids {
                guard !id.isEmpty else {
                    throw ResticError.invalidParameter("Empty snapshot ID is not allowed")
                }
            }
        }
    }
}

/// Builder for creating SnapshotCommand instances
public class SnapshotCommandBuilder {
    private var options: CommonOptions
    private var operation: SnapshotCommand.Operation = .list
    private var path: String?
    private var tags: [String] = []
    private var host: String?
    
    public init(repository: String, password: String) {
        self.options = CommonOptions(repository: repository, password: password)
    }
    
    /// Set to list operation (default)
    @discardableResult
    public func list() -> Self {
        operation = .list
        return self
    }
    
    /// Set to delete operation with specified snapshot IDs
    @discardableResult
    public func delete(snapshots: [String]) -> Self {
        operation = .delete(snapshots)
        return self
    }
    
    /// Filter by path
    @discardableResult
    public func setPath(_ path: String) -> Self {
        self.path = path
        return self
    }
    
    /// Add a tag filter
    @discardableResult
    public func addTag(_ tag: String) -> Self {
        tags.append(tag)
        return self
    }
    
    /// Add multiple tag filters
    @discardableResult
    public func addTags(_ tags: [String]) -> Self {
        self.tags.append(contentsOf: tags)
        return self
    }
    
    /// Filter by host
    @discardableResult
    public func setHost(_ host: String) -> Self {
        self.host = host
        return self
    }
    
    /// Set the cache directory
    @discardableResult
    public func setCachePath(_ path: String) -> Self {
        options = CommonOptions(
            repository: options.repository,
            password: options.password,
            cachePath: path,
            quiet: options.quiet,
            jsonOutput: options.jsonOutput
        )
        return self
    }
    
    /// Enable or disable quiet mode
    @discardableResult
    public func setQuiet(_ quiet: Bool) -> Self {
        options = CommonOptions(
            repository: options.repository,
            password: options.password,
            cachePath: options.cachePath,
            quiet: quiet,
            jsonOutput: options.jsonOutput
        )
        return self
    }
    
    /// Enable or disable JSON output
    @discardableResult
    public func setJsonOutput(_ enabled: Bool) -> Self {
        options = CommonOptions(
            repository: options.repository,
            password: options.password,
            cachePath: options.cachePath,
            quiet: options.quiet,
            jsonOutput: enabled
        )
        return self
    }
    
    /// Build the snapshot command
    public func build() -> SnapshotCommand {
        SnapshotCommand(
            options: options,
            operation: operation,
            path: path,
            tags: tags,
            host: host
        )
    }
}
