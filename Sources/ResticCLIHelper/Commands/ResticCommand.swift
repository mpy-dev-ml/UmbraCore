/// Base protocol for all Restic commands
public protocol ResticCommand: Sendable {
    /// The command name as used in the Restic CLI
    var commandName: String { get }

    /// The command arguments
    var commandArguments: [String] { get }

    /// The command environment variables
    var environment: [String: String] { get }

    /// The common options for this command
    var options: CommonOptions { get }

    /// Required environment variables that should not be filtered out even if empty
    var requiredEnvironmentVariables: Set<String> { get }

    /// Validates the command parameters
    /// - Throws: ResticError if validation fails
    func validate() throws
}

extension ResticCommand {
    /// Default implementation for required environment variables
    public var requiredEnvironmentVariables: Set<String> {
        ["RESTIC_REPOSITORY", "RESTIC_PASSWORD"]
    }

    /// The actual command arguments to pass to restic
    public var arguments: [String] {
        var args = [commandName]
        args.append(contentsOf: commandArguments)
        if options.jsonOutput {
            args.append("--json")
        }
        #if DEBUG
        print("Full command arguments: \(args)")
        #endif
        return args
    }

    public var environment: [String: String] {
        var env = [String: String]()

        // Set repository path
        env["RESTIC_REPOSITORY"] = options.repository

        // Set password if provided
        if !options.password.isEmpty {
            env["RESTIC_PASSWORD"] = options.password
        }

        // Set cache directory if provided
        if let cachePath = options.cachePath {
            env["RESTIC_CACHE_DIR"] = cachePath
        }

        // Add any additional environment variables
        for (key, value) in options.environmentVariables {
            env[key] = value
        }

        return env
    }

    /// Default validation implementation
    public func validate() throws {
        // By default, validate that we have a repository
        guard !options.repository.isEmpty else {
            throw ResticError.missingParameter("Repository path is required")
        }

        // If we're validating credentials, ensure we have a password
        if options.validateCredentials && options.password.isEmpty {
            throw ResticError.missingParameter("Password is required when validateCredentials is true")
        }
    }
}
