import Foundation

/// Basic implementation of the RecoveryOption protocol
/// 
/// This struct provides a concrete implementation of the RecoveryOption
/// protocol that can be used directly or as a base for more specialized
/// recovery options.
public struct ErrorRecoveryOption: RecoveryOption, Sendable, Equatable, Identifiable {
  /// Unique identifier for the recovery option
  public let id: UUID
  
  /// Human-readable title for the recovery option
  public let title: String
  
  /// Optional detailed description of what the recovery option will do
  public let description: String?
  
  /// Indicates whether this recovery option is potentially disruptive to the user's workflow
  public let isDisruptive: Bool
  
  /// The action to perform for this recovery option
  private let actionHandler: @Sendable () async -> Void
  
  /// Creates a new ErrorRecoveryOption instance
  /// - Parameters:
  ///   - id: Unique identifier for the recovery option (defaults to a new UUID)
  ///   - title: Human-readable title for the recovery option
  ///   - description: Optional detailed description of what the recovery option will do
  ///   - isDisruptive: Whether this recovery option might disrupt the user's workflow
  ///   - handler: The action to perform when this option is selected
  public init(
    id: UUID = UUID(),
    title: String,
    description: String? = nil,
    isDisruptive: Bool = false,
    handler: @escaping @Sendable () async -> Void
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.isDisruptive = isDisruptive
    self.actionHandler = handler
  }
  
  /// Perform the recovery action
  public func perform() async {
    await actionHandler()
  }
  
  /// Equality check based on ID
  public static func == (lhs: ErrorRecoveryOption, rhs: ErrorRecoveryOption) -> Bool {
    lhs.id == rhs.id
  }
}

/// A recovery option that performs no action
public extension ErrorRecoveryOption {
  /// Creates a "Cancel" recovery option that performs no action
  static var cancel: ErrorRecoveryOption {
    ErrorRecoveryOption(
      title: "Cancel",
      description: "Cancel and take no action",
      isDisruptive: false,
      handler: { /* No action */ }
    )
  }
  
  /// Creates a "Try Again" recovery option
  /// - Parameter handler: The action to perform when trying again
  static func tryAgain(handler: @escaping @Sendable () async -> Void) -> ErrorRecoveryOption {
    ErrorRecoveryOption(
      title: "Try Again",
      description: "Attempt the operation again",
      isDisruptive: false,
      handler: handler
    )
  }
}
