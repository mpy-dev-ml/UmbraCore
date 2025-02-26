// Foundation-free adapter for XPC services
// Provides a bridge between Foundation-dependent and Foundation-free implementations

/// Protocol for Foundation-based XPC service interfaces
/// Use this to define what we expect from Foundation-based XPC implementations
public protocol FoundationBasedXPCService: Sendable {
    func ping() async throws -> Bool
    func synchroniseKeys(_ data: Any) async throws
}

/// Adapter that implements XPCServiceProtocolBase from any FoundationBasedXPCService
public final class XPCServiceAdapter: XPCServiceProtocolBase {
    private let service: any FoundationBasedXPCService

    /// Create a new adapter wrapping a Foundation-based service implementation
    public init(wrapping service: any FoundationBasedXPCService) {
        self.service = service
    }

    /// Implement ping method
    public func ping() async throws -> Bool {
        return try await service.ping()
    }

    /// Implement synchroniseKeys with any data type
    public func synchroniseKeys(_ data: Any) async throws {
        try await service.synchroniseKeys(data)
    }

    /// Protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter"
    }
}
