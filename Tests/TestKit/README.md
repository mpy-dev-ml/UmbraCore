# TestKit

## Overview

TestKit provides specialised testing infrastructure for Restic CLI operations in UmbraCore. This module is designed to facilitate testing of Restic commands and CLI interactions without executing actual shell commands or requiring real repositories.

## Components

### MockableResticCLIHelper

A mock implementation of `ResticCLIHelper` that intercepts commands for testing purposes.

**Features**:
- Simulates Restic CLI execution without invoking actual processes
- Provides customisable response data for commands
- Records command execution for verification
- Supports all standard Restic CLI operations

**Usage Example**:
```swift
import TestKit

// Create a mock helper
let mockHelper = MockableResticCLIHelper()

// Configure mock responses
mockHelper.registerMockResponse(for: "init", output: "", exitCode: 0)

// Execute a command through the mock
let result = try await mockHelper.initRepository(at: "some/path", password: "password")

// Verify commands were executed as expected
XCTAssertTrue(mockHelper.commandWasExecuted("init"))
```

### ProcessExecutor

A test-specific executor for simulating process execution.

**Features**:
- Mocks system process execution
- Provides customisable output and exit codes
- Records executed commands for verification

**Usage Example**:
```swift
import TestKit

// Create a mock process executor
let executor = MockProcessExecutor()

// Configure responses
executor.registerResponse(for: "restic stats", output: "...", exitCode: 0)

// Use in tests
let output = try executor.execute("restic stats")
```

### ResticCommandTestHelpers

Utilities to assist with testing Restic commands.

**Features**:
- Helper functions for common test setups
- Test-specific command builders
- Validation utilities for command arguments

**Usage Example**:
```swift
import TestKit

// Create a testable command
let backupCommand = createTestableBackupCommand(repository: "repo", paths: ["path1"])

// Configure and validate
let command = backupCommand.tag("test").host("localhost")
XCTAssertTrue(command.arguments.contains("--tag=test"))
```

## Integration with Other Test Components

TestKit is designed to work alongside UmbraTestKit, providing specialised functionality for Restic CLI testing while UmbraTestKit provides more general-purpose mocks. When both are needed:

```swift
import TestKit
import UmbraTestKit

// Use TestKit for Restic CLI operations
let mockHelper = MockableResticCLIHelper()

// Use UmbraTestKit for system services
let securityProvider = MockSecurityProvider()

// Combine in tests
mockHelper.securityProvider = securityProvider
```

## When to Use TestKit vs. UmbraTestKit

- **Use TestKit** when specifically testing Restic commands and CLI operations
- **Use UmbraTestKit** for mocking system services like crypto, security, and file operations
- **Use both** when testing components that interact with both Restic CLI and system services

## Extending TestKit

When extending TestKit with new functionality:

1. Follow the existing architecture and naming conventions
2. Keep the focus on Restic CLI testing
3. Add documentation comments explaining the purpose and usage
4. Write tests for the new functionality

For more general testing infrastructure that isn't specific to Restic CLI, consider adding to UmbraTestKit instead.
