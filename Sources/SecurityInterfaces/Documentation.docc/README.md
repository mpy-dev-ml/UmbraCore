# DocC Documentation for SecurityInterfaces

This directory contains DocC documentation for the SecurityInterfaces module in UmbraCore.

## Structure

- `SecurityInterfaces.md`: Main documentation file for the module
- `SecurityInterfaces.docc`: DocC tutorials and organisation
- `ErrorHandlingGuide.md`: Guide for handling security errors
- `TypealiasRefactoring.md`: Guide for refactoring typealiases
- `SecurityErrorMigration.md`: Guide for migrating between error types

## Building Documentation

To build the documentation using Bazel:

```bash
# From project root
./tools/scripts/build_docc.sh build SecurityInterfaces
```

## Viewing Documentation

After building, you can view the documentation locally:

```bash
# From project root
./tools/scripts/build_docc.sh serve SecurityInterfaces
```

Then open a browser to http://localhost:8000/

## Adding Documentation

### 1. For Types and Functions

Add DocC-style comments to your code:

```swift
/// A protocol defining security operations.
///
/// This protocol provides a comprehensive set of security operations
/// including encryption, decryption, and key management.
///
/// ## Topics
///
/// ### Encryption
///
/// - ``encrypt(_:using:)``
/// - ``decrypt(_:using:)``
public protocol SecurityProvider {
    // Protocol methods...
}
```

### 2. For Guides and Articles

Create new markdown files in the Documentation.docc directory:

```markdown
# My Guide Title

Learn about specific security features.

## Overview

This guide explains...
```

### 3. Add to Topics List

Update the topics list in `SecurityInterfaces.md` to include new symbols or guides.

## Code Examples

DocC supports code examples in documentation:

```swift
/// Example:
/// ```swift
/// let provider = SecurityProvider()
/// let result = try provider.encrypt(data)
/// ```
```
