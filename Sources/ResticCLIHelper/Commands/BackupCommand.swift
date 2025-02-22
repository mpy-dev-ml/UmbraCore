import Foundation

/// Command for creating backups
public final class BackupCommand: ResticCommand, @unchecked Sendable {
    private var paths: [String] = []
    private var tags: [String] = []
    private var host: String?
    private var excludePatterns: [String] = []
    public private(set) var options: CommonOptions

    public var commandName: String { "backup" }

    public var commandArguments: [String] {
        var args = [String]()

        // Add paths
        args.append(contentsOf: paths)

        // Add tags
        for tag in tags {
            args.append("--tag")
            args.append(tag)
        }

        // Add host
        if let host = host {
            args.append("--host")
            args.append(host)
        }

        // Add exclude patterns
        for pattern in excludePatterns {
            args.append("--exclude")
            args.append(pattern)
        }

        return args
    }

    public init(options: CommonOptions) {
        self.options = options
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

    /// Add a tag
    @discardableResult
    public func tag(_ tag: String) -> Self {
        tags.append(tag)
        return self
    }

    /// Set the host
    @discardableResult
    public func host(_ host: String) -> Self {
        self.host = host
        return self
    }

    /// Add an exclude pattern
    @discardableResult
    public func exclude(_ pattern: String) -> Self {
        excludePatterns.append(pattern)
        return self
    }

    /// Add multiple exclude patterns
    @discardableResult
    public func excludePatterns(_ patterns: [String]) -> Self {
        excludePatterns.append(contentsOf: patterns)
        return self
    }

    /// Set the cache path
    @discardableResult
    public func setCachePath(_ path: String) -> Self {
        var env = options.environmentVariables
        env["RESTIC_CACHE_DIR"] = path
        options = CommonOptions(
            repository: options.repository,
            password: options.password,
            cachePath: options.cachePath,
            validateCredentials: options.validateCredentials,
            quiet: options.quiet,
            jsonOutput: options.jsonOutput,
            environmentVariables: env,
            arguments: options.arguments
        )
        return self
    }

    public var environment: [String: String] {
        var env = options.environmentVariables
        env["RESTIC_REPOSITORY"] = options.repository
        env["RESTIC_PASSWORD"] = options.password
        if let cachePath = options.cachePath {
            env["RESTIC_CACHE_DIR"] = cachePath
        }
        return env
    }

    public func validate() throws {
        guard !paths.isEmpty else {
            throw ResticError.missingParameter("At least one backup path must be specified")
        }
        guard !options.repository.isEmpty else {
            throw ResticError.missingParameter("Repository path must not be empty")
        }
        if options.validateCredentials && options.password.isEmpty {
            throw ResticError.missingParameter("Password must not be empty when validation is enabled")
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
        let command = BackupCommand(options: options)
        command.addPaths(paths)
        command.tag(tags.joined(separator: ","))
        command.excludePatterns(excludes)
        if let host = host {
            command.host(host)
        }
        return command
    }
}
