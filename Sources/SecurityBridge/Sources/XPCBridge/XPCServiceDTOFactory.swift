import CoreDTOs
import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// A factory for creating XPC service adapters that use Foundation-independent DTOs.
///
/// This factory makes it easy to create the appropriate adapters for different XPC service protocols,
/// handling the necessary connections and configuration behind the scenes.
public enum XPCServiceDTOFactory {
    /// Create an adapter for a standard XPC service
    /// - Parameters:
    ///   - serviceName: The name of the XPC service
    ///   - options: Options for the connection
    /// - Returns: An adapter conforming to XPCServiceProtocolStandardDTO
    public static func createStandardAdapter(
        forService serviceName: String,
        options _: XPCConnectionOptions = []
    ) -> XPCServiceProtocolStandardDTO {
        let connection = NSXPCConnection(serviceName: serviceName)
        return XPCServiceDTOAdapter(connection: connection)
    }

    /// Create an adapter for an XPC service with a machService name
    /// - Parameters:
    ///   - machServiceName: The mach service name of the XPC service
    ///   - options: Options for the connection
    /// - Returns: An adapter conforming to XPCServiceProtocolStandardDTO
    public static func createStandardAdapter(
        forMachService machServiceName: String,
        options _: XPCConnectionOptions = []
    ) -> XPCServiceProtocolStandardDTO {
        let connection = NSXPCConnection(machServiceName: machServiceName)
        return XPCServiceDTOAdapter(connection: connection)
    }

    /// Create an adapter for an endpoint
    /// - Parameters:
    ///   - endpoint: The NSXPCListenerEndpoint to connect to
    ///   - options: Options for the connection
    /// - Returns: An adapter conforming to XPCServiceProtocolStandardDTO
    public static func createStandardAdapter(
        forEndpoint endpoint: NSXPCListenerEndpoint,
        options _: XPCConnectionOptions = []
    ) -> XPCServiceProtocolStandardDTO {
        let connection = NSXPCConnection(listenerEndpoint: endpoint)
        return XPCServiceDTOAdapter(connection: connection)
    }
}

/// Options for XPC connections
public struct XPCConnectionOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// No options
    public static let none: XPCConnectionOptions = []

    /// Privileged option
    public static let privileged = XPCConnectionOptions(rawValue: 1 << 0)
}
