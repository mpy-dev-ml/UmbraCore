import Foundation
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityInterfacesProtocols

/// Custom error for security interfaces that doesn't require Foundation
public enum XPCServiceProtocolAdapterError: Error, Sendable {
    case implementationMissing(String)
}

/// Adapter that bridges from SecurityInterfacesProtocols.XPCServiceProtocolBase to ObjCBridgingTypesFoundation
public final class CoreTypesToFoundationAdapter: NSObject, ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation, @unchecked Sendable {
    private let core: any SecurityInterfacesProtocols.XPCServiceProtocolBase

    /// Create a new adapter wrapping a CoreTypes implementation
    public init(wrapping core: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
        self.core = core
        super.init()
    }

    /// Protocol identifier from the CoreTypes implementation
    @objc public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.coretypes"
    }

    /// Implement ping using the CoreTypes implementation
    @objc public func ping(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Capture core reference to avoid capturing self in the task
        let coreRef = self.core

        Task {
            do {
                let result = try await coreRef.ping()
                reply(result, nil)
            } catch {
                reply(false, error)
            }
        }
    }

    /// Implement synchroniseKeys using the CoreTypes implementation
    @objc public func synchroniseKeys(_ data: Any, withReply reply: @escaping @Sendable (Error?) -> Void) {
        guard let nsData = data as? NSData else {
            reply(XPCServiceProtocolAdapterError.implementationMissing("Data must be NSData"))
            return
        }

        // Capture core reference and convert NSData to bytes outside the task to avoid capturing non-sendable types
        let coreRef = self.core
        let bytes = ObjCBridgingTypesFoundation.DataConverter.convertToBytes(fromNSData: nsData)
        let binaryData = SecurityInterfacesProtocols.BinaryData(bytes)

        Task {
            do {
                // Call the CoreTypes implementation
                try await coreRef.synchroniseKeys(binaryData)
                reply(nil)
            } catch {
                reply(error)
            }
        }
    }
}

/// Adapter that bridges from ObjCBridgingTypesFoundation to SecurityInterfacesProtocols.XPCServiceProtocolBase
public final class FoundationToCoreTypesAdapter: SecurityInterfacesProtocols.XPCServiceProtocolBase {
    // Using a class instead of struct to better handle reference semantics of NSObjectProtocol
    private let foundation: any ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation

    /// Create a new adapter wrapping a Foundation implementation
    public init(wrapping foundation: any ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation) {
        self.foundation = foundation
    }

    /// Protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.foundation"
    }

    /// Implement ping using the Foundation implementation
    public func ping() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            foundation.ping { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    /// Implement synchroniseKeys using the Foundation implementation
    public func synchroniseKeys(_ data: SecurityInterfacesProtocols.BinaryData) async throws {
        // Convert BinaryData to byte array
        let bytes = data.bytes

        // Convert byte array to NSData
        let nsData = ObjCBridgingTypesFoundation.DataConverter.convertToNSData(fromBytes: bytes)

        // Call the Foundation implementation
        return try await withCheckedThrowingContinuation { continuation in
            guard let synchroniseKeysRaw = foundation.synchroniseKeysRaw else {
                continuation.resume(throwing: XPCServiceProtocolAdapterError.implementationMissing("synchroniseKeys not implemented"))
                return
            }

            synchroniseKeysRaw(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

/// Extension for the Foundation-based XPC protocol
extension ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation {
    /// Implementation for synchronising keys with byte array
    func synchroniseKeys(_ syncData: [UInt8]) async throws {
        // Convert to BinaryData first
        let binaryData = SecurityInterfacesProtocols.BinaryData(syncData)

        // Convert BinaryData to NSData through ObjCBridgingTypesFoundation
        let nsData = ObjCBridgingTypesFoundation.DataConverter.convertToNSData(fromBytes: binaryData.bytes)

        guard let synchroniseKeysRaw = self.synchroniseKeysRaw else {
            throw XPCServiceProtocolAdapterError.implementationMissing("synchroniseKeys not implemented")
        }

        return try await withCheckedThrowingContinuation { continuation in
            // Use the type internally within ObjCBridgingTypesFoundation to handle the conversion
            synchroniseKeysRaw(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
