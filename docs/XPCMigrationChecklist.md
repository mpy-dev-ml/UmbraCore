# UmbraCore XPC Protocol Migration Checklist

## Code Standardisation
- [x] Fix spacing in Core module files
  - [x] KeyManager.swift
  - [x] XPCServiceProtocol.swift
  - [x] XPCServiceProtocolAlias.swift
- [x] Fix spacing in SecurityBridge module files
  - [x] SecurityBridgeErrorMapper.swift
  - [x] SecurityProviderProtocolAdapter.swift
- [x] Fix spacing in SecurityInterfaces files
  - [x] XPCProtocolsMigration.swift

## Error Handling Updates
- [x] Update to CoreErrors
- [x] Standardise on Result<Value, XPCSecurityError> pattern
- [x] Remove deprecated local error types

## Type Safety Improvements
- [x] Use proper typealias references
- [x] Ensure protocol inheritance follows the three-tier hierarchy
- [x] Fix parameter and return type declarations

## Documentation
- [x] Create migration guide (XPCProtocolMigration.md)
- [ ] Update README.md with migration status
- [ ] Add inline documentation to key protocol files

## Testing
- [ ] Verify all typealias references resolve correctly
- [ ] Fix build errors in dependencies
- [ ] Run unit tests for Core module
- [ ] Run integration tests for XPC communication

## Swift 6 Preparation
- [x] Remove deprecated syntax
- [x] Use modern Result type
- [x] Ensure Sendable conformance on protocol types

## Final Review
- [ ] Audit for any remaining spacing issues
- [ ] Ensure consistent import order
- [ ] Check for any remaining deprecated APIs
- [ ] Verify no circular dependencies exist
