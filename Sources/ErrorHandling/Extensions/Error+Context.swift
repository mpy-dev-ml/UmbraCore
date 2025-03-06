import ErrorHandlingModels
import Foundation

/// Adds contextual information to Swift errors.
///
/// This extension allows any error to be wrapped with additional context
/// about where and how the error occurred, making debugging and error
/// handling more effective.
///
/// Example:
/// ```swift
/// do {
///     try performOperation()
/// } catch let error {
///     throw error.withContext(
///         source: "PaymentProcessor",
///         operation: "processRefund",
///         details: "Failed to connect to payment gateway"
///     )
/// }
/// ```
extension Error {
  /// Creates a detailed error context from this error.
  ///
  /// This method wraps the current error with additional contextual information
  /// that can help with debugging and error reporting. The context includes
  /// both user-provided information and automatically captured details about
  /// where the error occurred.
  ///
  /// - Parameters:
  ///   - source: The component or module where the error occurred
  ///             (e.g., "PaymentProcessor", "DatabaseService").
  ///   - operation: The specific operation that failed
  ///                (e.g., "processRefund", "queryUser").
  ///   - details: Optional additional information about the error.
  ///             Use this to provide more context about what went wrong.
  ///   - file: The source file where the error occurred. Defaults to the current file.
  ///   - line: The line number where the error occurred. Defaults to the current line.
  ///   - function: The function name where the error occurred. Defaults to the current function.
  /// - Returns: An `ErrorContext` containing the original error and all contextual information.
  public func withContext(
    source: String,
    operation: String,
    details: String? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> ErrorContext {
    var metadata: [String: String] = [:]
    metadata["operation"] = operation
    if let details {
      metadata["details"] = details
    }
    metadata["file"] = file
    metadata["line"] = String(line)
    metadata["function"] = function
    metadata["error"] = String(describing: self)

    return ErrorContext(
      source: source,
      message: localizedDescription,
      metadata: metadata
    )
  }
}
