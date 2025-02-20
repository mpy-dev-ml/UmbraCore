/// Base protocol for all Restic commands
public protocol ResticCommand {
    /// The command name as used in the Restic CLI
    var commandName: String { get }
    
    /// Additional arguments for the command
    var arguments: [String] { get }
    
    /// Environment variables required for the command
    var environment: [String: String] { get }
    
    /// Validates the command parameters
    /// - Throws: ResticError if validation fails
    func validate() throws
}

/// Common command options supported by multiple Restic commands
public struct CommonOptions {
    /// Repository location
    public let repository: String
    
    /// Password for the repository
    public let password: String
    
    /// Cache directory location (optional)
    public let cachePath: String?
    
    /// Quiet mode flag
    public let quiet: Bool
    
    /// JSON output flag
    public let jsonOutput: Bool
    
    public init(
        repository: String,
        password: String,
        cachePath: String? = nil,
        quiet: Bool = false,
        jsonOutput: Bool = true
    ) {
        self.repository = repository
        self.password = password
        self.cachePath = cachePath
        self.quiet = quiet
        self.jsonOutput = jsonOutput
    }
    
    /// Convert options to environment variables
    var environmentVariables: [String: String] {
        var env = [
            "RESTIC_REPOSITORY": repository,
            "RESTIC_PASSWORD": password
        ]
        
        if let cachePath = cachePath {
            env["RESTIC_CACHE_DIR"] = cachePath
        }
        
        return env
    }
    
    /// Convert options to command-line arguments
    var arguments: [String] {
        var args: [String] = []
        
        if quiet {
            args.append("--quiet")
        }
        
        if jsonOutput {
            args.append("--json")
        }
        
        return args
    }
}

/// Errors that can occur during Restic operations
public enum ResticError: Error {
    /// Invalid parameter value provided
    case invalidParameter(String)
    
    /// Required parameter is missing
    case missingParameter(String)
    
    /// Path validation failed
    case invalidPath(String)
    
    /// Command execution failed
    case executionFailed(String)
    
    /// Output parsing failed
    case outputParsingFailed(String)
    
    /// Repository error
    case repositoryError(String)
}
