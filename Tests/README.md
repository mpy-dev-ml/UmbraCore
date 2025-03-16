# UmbraCore Testing Infrastructure

This document provides an overview of the UmbraCore testing infrastructure, explaining the modular organisation of test components and guidelines for their proper usage.

## Testing Infrastructure Overview

The UmbraCore testing infrastructure is organised into several distinct layers to promote code reuse, separation of concerns, and maintainability:

### 1. TestKit

**Location**: `/Tests/TestKit`

**Purpose**: Provides specialised testing infrastructure for Restic CLI operations.

**Key Components**:
- `MockableResticCLIHelper.swift`: Implementation of ResticCLIHelper that intercepts commands for testing
- `ProcessExecutor.swift`: Test-specific executor for simulating process execution
- `ResticCommandTestHelpers.swift`: Helpers and utilities for testing Restic commands

**Usage**: Import this module when writing tests that specifically need to verify Restic CLI operations without executing actual shell commands.

```swift
import TestKit

// Creating a mock CLI helper
let mockHelper = MockableResticCLIHelper()
```

### 2. UmbraTestKit

**Location**: `/Tests/UmbraTestKit`

**Purpose**: Provides comprehensive, reusable mock implementations of core system components.

**Structure**:
- `/Sources`: Public-facing interfaces and protocols
- `/TestKit`: Implementation of test infrastructure
  - `/Common`: Common utilities shared across test implementations
  - `/Extensions`: Extensions to standard types for testing
  - `/Helpers`: Helper functions and classes for test setup
  - `/Mocks`: Mock implementations of core system components
  - `/TestCases`: Base test case classes for common testing patterns
- `/Tests`: Tests for the test kit itself

**Key Mock Implementations**:
- `MockCryptoService`: Mock implementation of cryptographic operations
- `MockFileManager`: Mock file system operations
- `MockSecurityProvider`: Mock security services
- `MockResticRepository`: Mock repository implementation

**Usage**: Import this module when you need to test components that depend on system services without accessing actual system resources.

```swift
import UmbraTestKit

// Creating a mock crypto service
let cryptoService = MockCryptoService()
```

### 3. Module-Specific Mocks

**Location**: `/Tests/{ModuleName}Tests/Mocks`

**Purpose**: Provides module-specific mock implementations that are not generally reusable.

**Example**:
- `ResticCLIHelperTests/Mocks/MockUmbraLoggingAdapters.swift`: Mock implementation of logging adapters specifically for ResticCLIHelper tests

**Usage**: These are generally imported automatically when you import the test module.

## Guidelines for Choosing the Appropriate Testing Components

When writing tests for UmbraCore, follow these guidelines to determine which testing components to use:

1. **For Core System Services** (crypto, security, file system operations):
   - Use mocks from UmbraTestKit
   - Example: `MockCryptoService`, `MockFileManager`, `MockSecurityProvider`

2. **For Restic CLI Operations**:
   - Use TestKit components for mocking the CLI interaction
   - Example: `MockableResticCLIHelper`, `TestableResticCommand` classes

3. **For Module-Specific Functionality**:
   - First check if a suitable mock exists in UmbraTestKit
   - If not, create a module-specific mock in the module's test directory

4. **For Test Cases**:
   - Place test cases in the appropriate module's test directory
   - Use descriptive names that indicate what is being tested

## Creating New Mocks

When creating new mock implementations:

1. **Determine the Appropriate Location**:
   - If the mock is generally reusable across modules, add it to UmbraTestKit
   - If it's specific to Restic CLI operations, consider TestKit
   - If it's specific to a single module, add it to that module's tests

2. **Follow Naming Conventions**:
   - Prefix with "Mock" (e.g., `MockCryptoService`)
   - Place in a "Mocks" directory
   - Use clear, descriptive names

3. **Implement Required Interfaces**:
   - Ensure the mock correctly implements all required protocol methods
   - Add test-specific methods that allow verifying interactions

4. **Document Usage**:
   - Add clear documentation comments explaining the purpose and usage of the mock
   - Include examples if the usage is complex

## Running Tests

All tests can be run using Bazel:

```bash
bazelisk test --config=withtests //Tests/...
```

To run specific test modules:

```bash
bazelisk test --config=withtests //Tests/ResticCLIHelperTests:ResticCLIHelperTests
```

To run tests with a specific tag:

```bash
bazelisk test --config=withtests --test_tag_filters="integration" //Tests/...
```

## Debugging Failed Tests

When tests fail:

1. Check the test output for specific error messages
2. Verify that mock implementations correctly implement required interfaces
3. Ensure that test data matches expectations
4. Check for changes in module interfaces that might affect test behaviour
