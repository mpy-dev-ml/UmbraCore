import Foundation

/// Command for creating backups with Restic
public struct BackupCommand: ResticCommand {
    /// Common options for the command
    public let options: CommonOptions
    
    /// Paths to backup
    public let paths: [String]
    
    /// Tags to apply to the backup
    public let tags: [String]
    
    /// Files to exclude
    public let excludes: [String]
    
    /// Host name to use
    public let host: String?
    
    public var commandName: String { "backup" }
    
    public var environment: [String: String] {
        options.environmentVariables
    }
    
    public var arguments: [String] {
        var args = options.arguments
        
        // Add paths
        args.append(contentsOf: paths)
        
        // Add tags
        if !tags.isEmpty {
            args.append("--tag")
            args.append(tags.joined(separator: ","))
        }
        
        // Add excludes
        for exclude in excludes {
            args.append("--exclude")
            args.append(exclude)
        }
        
        // Add host if specified
        if let host = host {
            args.append("--host")
            args.append(host)
        }
        
        return args
    }
    
    public func validate() throws {
        // Validate paths
        guard !paths.isEmpty else {
            throw ResticError.missingParameter("At least one backup path is required")
        }
        
        for path in paths {
            guard FileManager.default.fileExists(atPath: path) else {
                throw ResticError.invalidPath("Backup path does not exist: \(path)")
            }
        }
        
        // Validate tags
        for tag in tags {
            guard !tag.isEmpty else {
                throw ResticError.invalidParameter("Empty tag is not allowed")
            }
            guard !tag.contains(",") else {
                throw ResticError.invalidParameter("Tag cannot contain commas: \(tag)")
            }
        }
    }
}

/// Builder for creating BackupCommand instances
public class BackupCommandBuilder {
    private var options: CommonOptions
    private var paths: [String] = []
    private var tags: [String] = []
    private var excludes: [String] = []
    private var host: String?
    
    public init(repository: String, password: String) {
        self.options = CommonOptions(repository: repository, password: password)
    }
    
    /// Add a path to backup
    @discardableResult
    public func addPath(_ path: String) -> Self {
        paths.append(path)
        return self
    }
    
    /// Add multiple paths to backup
    @discardableResult
    public func addPaths(_ paths: [String]) -> Self {
        self.paths.append(contentsOf: paths)
        return self
    }
    
    /// Add a tag to the backup
    @discardableResult
    public func addTag(_ tag: String) -> Self {
        tags.append(tag)
        return self
    }
    
    /// Add multiple tags to the backup
    @discardableResult
    public func addTags(_ tags: [String]) -> Self {
        self.tags.append(contentsOf: tags)
        return self
    }
    
    /// Add a path to exclude
    @discardableResult
    public func addExclude(_ path: String) -> Self {
        excludes.append(path)
        return self
    }
    
    /// Add multiple paths to exclude
    @discardableResult
    public func addExcludes(_ paths: [String]) -> Self {
        excludes.append(contentsOf: paths)
        return self
    }
    
    /// Set the host name
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
    
    /// Build the backup command
    public func build() -> BackupCommand {
        BackupCommand(
            options: options,
            paths: paths,
            tags: tags,
            excludes: excludes,
            host: host
        )
    }
}
