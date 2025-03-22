/// Protocol defining a Restic command
public protocol ResticCommand: Sendable {
  /// Name of the command
  var commandName: String { get }

  /// Arguments for the command
  var commandArguments: [String] { get }

  /// Validate command parameters
  /// - Throws: ResticError if validation fails
  func validate() throws
}
