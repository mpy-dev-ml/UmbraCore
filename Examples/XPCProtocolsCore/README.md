# XPC Protocols Migration Examples

This directory contains example code for working with the new DTO-based XPC protocols and migration patterns from legacy XPC protocols.

## Content

- `MigrationExamples.swift`: Demonstrates how to migrate from legacy ObjC-based XPC protocols to the modern Swift-based DTO protocols.

## Key Migration Patterns

1. **Factory Pattern Usage**:
   - Use `XPCProtocolMigrationFactory` to create the appropriate adapters
   - Example: `XPCProtocolMigrationFactory.createCompleteAdapter()`

2. **Async/Await with Result Type**:
   - Modern protocols use async/await with Result types
   - Pattern matching with switch statements for handling success/failure cases
   - Error handling with proper Swift error types

3. **Data Type Conversion**:
   - Legacy: NSData
   - Modern: SecureBytes for security-sensitive operations

4. **Key Management**:
   - Modern APIs for key generation, deletion, and listing
   - Support for different key types and algorithms

## Migrating Existing Code

When migrating existing code that uses legacy XPC protocols:

1. Replace direct usage of legacy protocols with factory methods
2. Update synchronous code to use async/await pattern
3. Replace callbacks with Result type handling
4. Use proper error handling with Swift error types

## Running Examples

These examples are meant to illustrate code patterns and are not directly runnable. Integrate these patterns into your existing codebase to migrate from legacy to modern XPC protocol usage.

## Related Documentation

For more information, see:
- XPC_PROTOCOLS_MIGRATION_GUIDE.md: Comprehensive guide for migration
- UmbraCore_Refactoring_Plan.md: Overall plan for protocol consolidation
