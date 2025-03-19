# UmbraCore Examples

This directory contains example implementations that showcase the proper usage of UmbraCore APIs, protocols, and patterns. These examples are separated from the main codebase to:

1. Prevent build and test errors from example code
2. Provide clean, focused implementations for learning purposes
3. Avoid cluttering the main modules with demonstration code

## Structure

The directory is organized by module name, with each module's examples contained in its respective subdirectory:

- `ErrorHandling/` - Examples of how to use the error handling system
- `SecurityInterfaces/` - Example implementations of security providers and DTOs
- `UmbraErrors/` - Examples of error handling specific to UmbraErrors
- `XPCMigration/` - Examples for XPC protocol migration
- `XPCProtocolsCore/` - Examples of XPC service implementations

## Usage

These examples are meant to be referenced as part of the development process. They are not included in the main build targets and should not be imported directly into production code.

To use these examples:

1. Review the implementation for the relevant module
2. Understand the patterns and practices demonstrated
3. Apply similar approaches in your production code, adapting as needed

## Maintenance

When adding new examples:

1. Place them in the appropriate module directory
2. Ensure they are well-documented with comments explaining key concepts
3. Keep examples focused on demonstrating specific functionality
4. Do not introduce dependencies that aren't needed for the example

## Testing

While these examples are not part of the main test suite, they should still compile correctly. Consider adding a separate validation mechanism to ensure examples remain functional as the codebase evolves.
