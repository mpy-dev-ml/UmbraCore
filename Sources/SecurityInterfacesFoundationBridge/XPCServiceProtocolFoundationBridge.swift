import Foundation
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityInterfacesProtocols

/// Custom error for security interfaces that doesn't require Foundation
public enum XPCServiceProtocolFoundationBridgeError: Error, Sendable {
    case implementationMissing(String)
}

/// Adapter that bridges from SecurityInterfacesProtocols.XPCServiceProtocolBase to ObjCBridgingTypesFoundation
public final class CoreTypesToFoundationBridge: NSObject, ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation, @unchecked Sendable {
    private let core: any SecurityInterfacesProtocols.XPCServiceProtocolBase

    /// Create a new adapter wrapping a CoreTypes implementation
    public init(wrapping core: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
        self.core = core
        super.init()
    }

    /// Protocol identifier from the CoreTypes implementation
    @objc public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.coretypes.bridge"
    }

    /// Implement ping using the CoreTypes implementation
    @objc public func ping(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Capture core reference to avoid capturing self in the task
        let coreRef = self.core

        Task { @Sendable in
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
        // Capture core reference to avoid capturing self in the task
        let coreRef = self.core

        // Make a copy of the data to avoid capturing the original in the Task
        guard let nsData = data as? NSData else {
            reply(XPCServiceProtocolFoundationBridgeError.implementationMissing("Invalid data type"))
            return
        }
        
        // Convert NSData to [UInt8] safely outside the task
        let byteArray = nsData.toByteArray()
        
        Task { @Sendable in
            do {
                // Convert to BinaryData
                let binaryData = SecurityInterfacesProtocols.BinaryData(byteArray)
                
                // Call the core implementation
                try await coreRef.synchroniseKeys(binaryData)
                reply(nil)
            } catch {
                reply(error)
            }
        }
    }
}

/// Extension to convert NSData to [UInt8]
extension NSData {
    /// Convert to byte array safely
    func toByteArray() -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: length)
        getBytes(&buffer, length: length)
        return buffer
    }
}

/// Extension to provide convenience methods for XPCServiceProtocolBaseFoundation
extension ObjCBridgingTypesFoundation.XPCServiceProtocolBaseFoundation {
    /// Implementation for synchronising keys with byte array
    public func synchroniseKeys(_ syncData: [UInt8]) async throws {
        // Create NSData from the byte array
        let nsData = syncData.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }

        // We need to handle the optional method safely
        guard let synchroniseKeysMethod = self.synchroniseKeys(_:withReply:) else {
            throw XPCServiceProtocolFoundationBridgeError.implementationMissing("synchroniseKeys method not implemented")
        }

        // Use a continuation instead of a semaphore for better concurrency
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            synchroniseKeysMethod(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
