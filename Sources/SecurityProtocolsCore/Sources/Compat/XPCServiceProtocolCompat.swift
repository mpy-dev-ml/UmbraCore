// MARK: - Migration Guide

/// This file serves as a guide for migrating from SecurityProtocolsCore's XPC protocols
/// to the new XPCProtocolsCore module. Instead of using typealiases (which create
/// naming conflicts), this file documents the migration path.
///
/// Old protocol                    New protocol
/// ----------------------------    -----------------------------
/// XPCServiceProtocolBase          XPCServiceProtocolBasic
/// XPCServiceProtocolCore          XPCServiceProtocolComplete
/// XPCServiceProtocolExtended      XPCServiceProtocolStandard
///
/// To migrate your code:
/// 1. Import XPCProtocolsCore instead of SecurityProtocolsCore for XPC protocols
/// 2. Update protocol names according to the mapping above
/// 3. Update any implementations to conform to the new protocols
///
/// Example:
/// ```
/// // Old code
/// import SecurityProtocolsCore
/// class MyImplementation: XPCServiceProtocolBase { ... }
///
/// // New code
/// import XPCProtocolsCore
/// class MyImplementation: XPCServiceProtocolBasic { ... }
/// ```

// MARK: - Protocol Forward Declarations

/// These functions help with discovering the new protocol types during migration.
/// They are not meant to be called and will trigger a fatal error if invoked.

@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
public func migrateFromXPCServiceProtocolBase() -> Never {
  fatalError(
    "This is a migration helper function. Use XPCServiceProtocolBasic from XPCProtocolsCore instead."
  )
}

@available(*, deprecated, message: "Use XPCServiceProtocolComplete from XPCProtocolsCore instead")
public func migrateFromXPCServiceProtocolCore() -> Never {
  fatalError(
    "This is a migration helper function. Use XPCServiceProtocolComplete from XPCProtocolsCore instead."
  )
}

@available(*, deprecated, message: "Use XPCServiceProtocolStandard from XPCProtocolsCore instead")
public func migrateFromXPCServiceProtocolExtended() -> Never {
  fatalError(
    "This is a migration helper function. Use XPCServiceProtocolStandard from XPCProtocolsCore instead."
  )
}
