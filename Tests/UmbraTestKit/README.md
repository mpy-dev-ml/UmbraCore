# UmbraCore Test Suite

This directory contains the centralised test suite for UmbraCore. The goal is to provide a unified testing framework that makes it easier to write, maintain, and run tests across the entire codebase.

## Directory Structure

```
UmbraTestKit/
├── BUILD.bazel                # Main build file for the test kit
├── Sources/
│   └── UmbraTestKit/          # Main test kit sources
│       ├── Core/              # Core test utilities
│       ├── Mocks/             # Mock implementations
│       ├── Fixtures/          # Test fixtures
│       ├── Helpers/           # Test helpers
│       └── Categories/        # Category-specific test support
│           ├── Bookmark/      # Bookmark-specific test utilities
│           ├── Core/          # Core-specific test utilities
│           ├── Crypto/        # Crypto-specific test utilities
│           └── ...            # Other categories
└── Tests/                     # Tests for the test kit itself
```

## Migration Plan

The migration of existing tests to the centralised test suite will be done in phases:

### Phase 1: Infrastructure Setup

- [x] Create the basic directory structure
- [x] Set up the core test utilities
- [x] Create the mock framework
- [x] Set up the fixture system
- [x] Create helpers for async testing

### Phase 2: Category-Specific Test Support

- [ ] Create category-specific test utilities
- [ ] Move existing test utilities to the appropriate categories
- [ ] Update BUILD files for each category

### Phase 3: Test Migration

- [ ] Create a template for new tests
- [ ] Migrate existing tests one category at a time
- [ ] Update BUILD files for each test
- [ ] Verify that all tests pass

### Phase 4: Cleanup and Documentation

- [ ] Remove old test directories
- [ ] Update documentation
- [ ] Create examples for writing new tests

## Usage

To use the test kit in your tests, add a dependency on `//Tests/UmbraTestKit` to your BUILD file:

```python
umbra_swift_test(
    name = "MyTests",
    srcs = glob(["**/*.swift"]),
    deps = [
        "//Tests/UmbraTestKit",
        # Other dependencies
    ],
)
```

Then import the test kit in your Swift files:

```swift
import UmbraTestKit
```

## Best Practices

1. Extend `UmbraTestCase` for all test cases
2. Use the provided mock framework for creating mocks
3. Use fixtures for setting up test data
4. Use the async helpers for testing asynchronous code
5. Follow the category-specific patterns for each module
