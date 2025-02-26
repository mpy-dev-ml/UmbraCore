# UmbraCore Test Migration Plan

This document outlines the plan for migrating all UmbraCore tests to a centralised test suite structure using UmbraTestKit.

## Goals

1. Centralise all tests in a single, well-organized framework
2. Separate test infrastructure from test implementations
3. Reduce duplication across test modules
4. Improve test maintainability and reusability
5. Standardise test patterns and practices

## Migration Steps

### Phase 1: Infrastructure Setup (Completed)

- [x] Create the UmbraTestKit directory structure
- [x] Implement core test utilities
- [x] Create mock framework
- [x] Implement fixture system
- [x] Create async testing helpers
- [x] Set up sample category implementation (Crypto)
- [x] Create migration script

### Phase 2: Category Migration

For each test category:

1. Create category-specific test utilities in `Tests/UmbraTestKit/Sources/UmbraTestKit/Categories/<Category>`
2. Create category-specific mocks in the same directory
3. Run the migration script: `./migrate_tests.sh <Category>`
4. Update imports and base classes in the migrated tests
5. Verify that tests compile and run correctly

Migration order (based on dependencies):

1. [ ] ErrorHandling
2. [ ] UmbraLogging
3. [ ] CoreTypes
4. [ ] CryptoTypes
5. [ ] Crypto
6. [ ] SecurityUtils
7. [ ] Keychain
8. [ ] XPC
9. [ ] UmbraXPC
10. [ ] ResticTypes
11. [ ] ResticCLIHelper
12. [ ] Bookmark
13. [ ] Resources
14. [ ] Models
15. [ ] Core
16. [ ] UmbraSecurity
17. [ ] UmbraCore

### Phase 3: Test Suite Integration

1. [ ] Create a master test suite that runs all tests
2. [ ] Set up test categories and tags
3. [ ] Configure CI/CD integration
4. [ ] Add test coverage reporting

### Phase 4: Cleanup and Documentation

1. [ ] Remove old test directories
2. [ ] Update documentation
3. [ ] Create examples for writing new tests
4. [ ] Document test patterns and best practices

## Test Structure

The new test structure follows this pattern:

```
UmbraTestKit/
├── Sources/
│   └── UmbraTestKit/
│       ├── Core/              # Core test utilities
│       │   └── UmbraTestCase.swift
│       ├── Mocks/             # Mock framework
│       │   └── MockManager.swift
│       ├── Fixtures/          # Test fixtures
│       │   └── FixtureManager.swift
│       ├── Helpers/           # Test helpers
│       │   └── AsyncTestHelper.swift
│       └── Categories/        # Category-specific test support
│           ├── Crypto/
│           │   ├── CryptoTestCase.swift
│           │   └── MockCryptoService.swift
│           └── ...
└── Tests/                     # Tests for UmbraTestKit itself
```

## Best Practices

1. All test cases should extend the appropriate category-specific test case class
2. Use the mock framework for creating and managing mocks
3. Use fixtures for setting up test data
4. Use async helpers for testing asynchronous code
5. Follow the naming conventions for test methods:
   - `test<Functionality>_<Scenario>_<ExpectedResult>`
6. Group tests by functionality
7. Keep tests focused and small
8. Use appropriate assertions
9. Clean up after tests

## Commands

### Migration Script

```bash
# Migrate a specific test category
./migrate_tests.sh <Category>

# Example:
./migrate_tests.sh Crypto
```

### Running Tests

```bash
# Run all tests
bazel test //...

# Run tests for a specific category
bazel test //Tests/UmbraTestKit/...

# Run a specific test
bazel test //Tests/UmbraTestKit:<TestName>
```

## Timeline

- Phase 1: Completed
- Phase 2: 2-3 days (1-2 categories per day)
- Phase 3: 1 day
- Phase 4: 1 day

Total: 4-5 days
