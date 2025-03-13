import Foundation

import SecurityProtocolsCore
import UmbraCoreTypes

/// Primary entry point for the SecurityBridge module.
///
/// This module is specifically designed to include Foundation dependencies and serve
/// as the boundary layer between Foundation types and foundation-free domain types.
/// It centralises all Foundation conversions in one place, providing a clear boundary
/// between the two type systems.
///
/// Key responsibilities:
/// - Converting between Foundation types (Data, URL, Date) and domain types (SecureBytes,
/// ResourceLocator, TimePoint)
/// - Adapting Foundation-dependent implementations to foundation-free protocols
/// - Providing utilities for XPC service communication
public enum SecurityBridge {
    /// Module version
    public static let version = "1.0.0"
}
