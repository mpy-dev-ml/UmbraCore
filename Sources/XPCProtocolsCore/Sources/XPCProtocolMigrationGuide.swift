/**
 # XPC Protocol Migration Guide

 This file provides guidance for using the modern XPC protocol interfaces.
 The legacy XPC service interfaces have been removed and all code should now use
 the modern protocol-based approach.

 ## Modern Approach Benefits

 1. Uses SecureBytes instead of NSData/NSObject for improved security
 2. Provides protocol-based abstractions instead of concrete implementation dependencies
 3. Uses async/await instead of completion handlers for better concurrency
 4. Uses structured error types with Result return values for better error handling

 ## Timeline

 * 2025-Q1: Legacy interfaces marked as deprecated
 * 2025-Q3: Legacy interfaces triggered compiler warnings
 * 2026-Q1: Legacy interfaces removed (COMPLETED)

 ## Key Protocol Features

 * XPCServiceProtocolBasic conforms to XPCErrorHandlingProtocol and XPCDataHandlingProtocol
 * XPCServiceProtocolStandard provides modern methods using SecureBytes
 * XPCServiceProtocolComplete offers comprehensive Result-based error handling
 */

import Foundation

/// Enum containing version constants and migration guidance
public enum XPCProtocolMigration {
    /// Current version of the XPC protocol framework
    public static let currentVersion = "3.0.0"

    /// Legacy support has been removed in this version
    public static let legacySupportRemovedInVersion = "3.0.0"

    /// Target version for all clients
    public static let targetVersion = "3.0.0"

    /// Check if the current version is supported
    /// - Parameter version: The version to check
    /// - Returns: True if the version is supported
    public static func isVersionSupported(for version: String) -> Bool {
        // Only version 3.0.0 and higher are supported
        version >= targetVersion
    }
}

// MARK: - Modern APIs

/**
 * The XPCProtocolsCore module now exclusively uses modern implementations.
 * All code should use the ModernXPCService class or factory methods from
 // DEPRECATED: * XPCProtocolMigrationFactory to create protocol-compliant service objects.
 *
 * For examples of usage, see XPCMigrationExamples.swift.
 */
