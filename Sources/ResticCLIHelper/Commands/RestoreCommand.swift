import Foundation

/// Command for restoring data from Restic backups
public struct RestoreCommand: ResticCommand {
    /// Common options for the command
    public let options: CommonOptions
    
    /// Snapshot ID to restore from
    public let snapshotId: String
    
    /// Target path for restoration
    public let target: String?
    
    /// Specific paths to restore (optional)
    public let includePaths: [String]
    
    /// Paths to exclude from restore
    public let excludePaths: [String]
    
    /// Whether to overwrite existing files
    public let overwrite: Bool
    
    public var commandName: String { "restore" }
    
    public var environment: [String: String] {
        options.environmentVariables
    }
    
    public var arguments: [String] {
        var args = options.arguments
        
        // Add snapshot ID
        args.append(snapshotId)
        
        // Add target path if specified
        if let target = target {
            args.append("--target")
            args.append(target)
        }
        
        // Add include paths
        for path in includePaths {
            args.append("--include")
            args.append(path)
        }
        
        // Add exclude paths
        for path in excludePaths {
            args.append("--exclude")
            args.append(path)
        }
        
        // Add overwrite flag if needed
        if overwrite {
            args.append("--overwrite")
        }
        
        return args
    }
    
    public func validate() throws {
        // Validate snapshot ID
        guard !snapshotId.isEmpty else {
            throw ResticError.missingParameter("Snapshot ID is required")
        }
        
        // Validate target path if specified
        if let target = target {
            guard !target.isEmpty else {
                throw ResticError.invalidParameter("Target path cannot be empty")
            }
            
            // Check if target directory exists
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: target, isDirectory: &isDirectory) {
                guard isDirectory.boolValue else {
                    throw ResticError.invalidPath("Target path exists but is not a directory: \(target)")
                }
            }
        }
        
        // Validate include paths
        for path in includePaths {
            guard !path.isEmpty else {
                throw ResticError.invalidParameter("Include path cannot be empty")
            }
        }
        
        // Validate exclude paths
        for path in excludePaths {
            guard !path.isEmpty else {
                throw ResticError.invalidParameter("Exclude path cannot be empty")
            }
        }
    }
}

/// Builder for creating RestoreCommand instances
public class RestoreCommandBuilder {
    private var options: CommonOptions
    private var snapshotId: String
    private var target: String?
    private var includePaths: [String] = []
    private var excludePaths: [String] = []
    private var overwrite: Bool = false
    
    public init(repository: String, password: String, snapshotId: String) {
        self.options = CommonOptions(repository: repository, password: password)
        self.snapshotId = snapshotId
    }
    
    /// Set the target path for restoration
    @discardableResult
    public func setTarget(_ path: String) -> Self {
        target = path
        return self
    }
    
    /// Add a path to include in the restore
    @discardableResult
    public func addIncludePath(_ path: String) -> Self {
        includePaths.append(path)
        return self
    }
    
    /// Add multiple paths to include in the restore
    @discardableResult
    public func addIncludePaths(_ paths: [String]) -> Self {
        includePaths.append(contentsOf: paths)
        return self
    }
    
    /// Add a path to exclude from the restore
    @discardableResult
    public func addExcludePath(_ path: String) -> Self {
        excludePaths.append(path)
        return self
    }
    
    /// Add multiple paths to exclude from the restore
    @discardableResult
    public func addExcludePaths(_ paths: [String]) -> Self {
        excludePaths.append(contentsOf: paths)
        return self
    }
    
    /// Set whether to overwrite existing files
    @discardableResult
    public func setOverwrite(_ overwrite: Bool) -> Self {
        self.overwrite = overwrite
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
    
    /// Build the restore command
    public func build() -> RestoreCommand {
        RestoreCommand(
            options: options,
            snapshotId: snapshotId,
            target: target,
            includePaths: includePaths,
            excludePaths: excludePaths,
            overwrite: overwrite
        )
    }
}
