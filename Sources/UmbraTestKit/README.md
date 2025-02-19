# UmbraTestKit

UmbraTestKit is a comprehensive test utilities library for UmbraCore, providing mock implementations and test infrastructure for secure, sandbox-aware testing.

## Overview

The module provides a robust set of testing utilities specifically designed for UmbraCore's security-focused features:

- Mock implementations of core services
- Sandbox-aware test infrastructure
- Security-scoped resource simulation
- Thread-safe testing utilities
- Keychain and XPC service mocks

## Module Structure

```
UmbraTestKit/
├── Core/           # Core test utilities
├── Mocks/         # Mock implementations
│   ├── Keychain/  # Keychain and XPC service mocks
│   └── Core/      # Core service mocks
├── Protocols/     # Test-specific protocols
└── TestCases/    # Base test case classes
```

## Key Components

### Mock Implementations

- `MockCryptoService`: Simulates cryptographic operations
- `MockKeychain`: Simulates secure storage operations
- `MockSecurityProvider`: Simulates security and permission checks
- `MockFileManager`: Simulates file system operations
- `MockURLProvider`: Simulates URL handling
- `MockKeychainService`: Simulates keychain XPC service
- `MockXPCServiceHelper`: Provides XPC service simulation utilities

### Test Infrastructure

- `SandboxTestCase`: Base class for sandbox-aware tests
  - Provides temporary directory management
  - Simulates security-scoped resource access
  - Handles test file creation and cleanup

## Usage

### Basic Test Setup

```swift
class MyTests: SandboxTestCase {
    func testSecureFileAccess() async throws {
        // Create a test file with specific permissions
        let fileURL = try await createTestFile(
            name: "test.txt",
            content: "Test content",
            permissions: [.readWrite]
        )
        
        // Test secure access
        try await withSecurityScopedAccess(to: fileURL) { 
            let content = try String(contentsOf: fileURL)
            XCTAssertEqual(content, "Test content")
        }
    }
}
```

### Using Keychain Mocks

```swift
class KeychainTests: XCTestCase {
    func testKeychainOperations() async throws {
        // Get mock keychain service
        let service = try await MockXPCServiceHelper.getServiceProxy()
        
        // Perform operations
        let testData = "secret".data(using: .utf8)!
        try await service.addItem(
            account: "testAccount",
            service: "testService",
            accessGroup: nil,
            data: testData
        )
        
        // Verify results
        let retrieved = try await service.findItem(
            account: "testAccount",
            service: "testService",
            accessGroup: nil
        )
        XCTAssertEqual(retrieved, testData)
    }
}
```

## Development Roadmap

### Phase 1: Core Infrastructure (Weeks 1-4)
- Implement test coverage framework
- Enhance mock capabilities with failure injection
- Create test fixture system
- Add state tracking and verification

### Phase 2: Advanced Features (Weeks 5-8)
- Add security testing capabilities
- Implement performance testing framework
- Add concurrency testing utilities
- Create benchmark baselines

### Phase 3: Documentation & Migration (Weeks 9-10)
- Complete API documentation
- Create migration guides
- Add example test suites
- Implement migration tools

### Phase 4: Integration & Validation (Weeks 11-12)
- Add cross-module test suites
- Validate test coverage
- Verify performance metrics
- Ensure documentation completeness

## Success Criteria

### Test Coverage
- 90%+ code coverage
- All critical paths tested
- Performance baselines established

### Documentation
- Full API documentation
- Migration guide complete
- Example test suites available

### Quality Metrics
- All tests passing
- No critical warnings
- Performance targets met

## Contributing

When contributing to UmbraTestKit, please:

1. Follow the Swift concurrency best practices
2. Add tests for any new functionality
3. Update documentation as needed
4. Ensure all tests pass before submitting PRs

## Integration with Test Support

UmbraTestKit is re-exported by the TestSupport module, making all functionality available through:

```swift
import TestSupport
```

This provides a single import point for all test utilities across the UmbraCore project.

## License

UmbraCore and UmbraTestKit are proprietary software. All rights reserved.
