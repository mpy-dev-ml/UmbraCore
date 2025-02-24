import Foundation
import XPC

/// Protocol defining the requirements for an XPC connection.
public protocol XPCConnectionProtocol: Sendable {
    /// The connection endpoint name.
    var endpoint: String { get }
    
    /// Establishes the XPC connection.
    /// - Throws: `XPCError` if the connection fails.
    func connect() async throws
    
    /// Disconnects the XPC connection.
    func disconnect()
    
    /// Sends a message over the XPC connection.
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Optional handler for processing the reply.
    func send(_ message: [String: Any], replyHandler: ((xpc_object_t) -> Void)?)
}

/// Errors that can occur during XPC operations.
public enum XPCError: LocalizedError, Sendable {
    /// Connection failed with the given reason.
    case connectionFailed(String)
    
    /// Message sending failed with the given reason.
    case messageFailed(String)
    
    /// Invalid message format with the given reason.
    case invalidMessage(String)
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "XPC connection failed: \(reason)"
        case .messageFailed(let reason):
            return "Failed to send XPC message: \(reason)"
        case .invalidMessage(let reason):
            return "Invalid XPC message format: \(reason)"
        }
    }
}
