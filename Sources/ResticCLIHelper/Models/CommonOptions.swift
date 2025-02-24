import Foundation

/// Common options for all Restic commands
@objc
public class CommonOptions: NSObject {
    /// Path to the repository
    public let repository: String

    /// Password for the repository
    public let password: String

    /// Path to cache directory
    public let cachePath: String?

    /// Whether to validate credentials before running commands
    public let validateCredentials: Bool

    /// Whether to run in quiet mode
    public let quiet: Bool

    /// Whether to output in JSON format
    public let jsonOutput: Bool

    /// Additional environment variables
    public let environmentVariables: [String: String]

    /// Additional arguments
    public let arguments: [String]

    public init(
        repository: String,
        password: String = "",
        cachePath: String? = nil,
        validateCredentials: Bool = true,
        quiet: Bool = false,
        jsonOutput: Bool = false,
        environmentVariables: [String: String] = [:],
        arguments: [String] = []
    ) {
        self.repository = repository
        self.password = password
        self.cachePath = cachePath
        self.validateCredentials = validateCredentials
        self.quiet = quiet
        self.jsonOutput = jsonOutput
        self.environmentVariables = environmentVariables
        self.arguments = arguments
        super.init()
    }
}
