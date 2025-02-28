# Testing Foundation-Free Swift Modules

This document explains our approach to testing Foundation-free Swift modules in the UmbraCore project.

## Background

When working with Foundation-free Swift modules, we encountered challenges with the standard Bazel test execution. Specifically, Bazel's `swift_test` targets would sometimes fail due to architecture conflicts or dependency issues when attempting to execute the test bundle.

Our solution is to use Bazel to build the test bundles but execute the tests directly using `xcrun xctest`, which provides more reliable test execution for Foundation-free modules.

## Testing Strategy

### 1. Building Test Bundles

We use Bazel to build our Swift modules and their corresponding test bundles:

```bash
bazel build //Sources/ModuleName:ModuleNameTests
```

This generates an `.xctest` bundle in the Bazel output directory.

### 2. Running Tests Directly

Instead of using `bazel test`, we run the tests directly with `xcrun`:

```bash
xcrun xctest -XCTest All /path/to/ModuleNameTests.xctest
```

The test bundle path is typically:

```
/Users/mpy/.bazel/execroot/_main/bazel-out/darwin_arm64-opt/bin/Sources/ModuleName/ModuleNameTests.xctest
```

### 3. Build File Configuration

For our Foundation-free modules, we add a `tags = ["manual"]` attribute to the `swift_test` targets to ensure they aren't automatically run with `bazel test`:

```python
swift_test(
    name = "ModuleNameTests",
    srcs = glob(["Tests/*.swift"]),
    deps = [":ModuleName"],
    tags = ["manual"],  # Prevents automatic test execution with bazel test
)
```

## Automated Testing

We've created a script at `tools/scripts/run_all_foundation_free_tests.sh` that:

1. Builds all Foundation-free modules and their test bundles
2. Executes each test bundle directly with `xcrun xctest`
3. Reports a summary of test results

To run all Foundation-free tests:

```bash
./tools/scripts/run_all_foundation_free_tests.sh
```

## Module Generation

Our module generator includes the proper configuration to make new Foundation-free modules compatible with this testing approach:

- Templates include the correct `tags = ["manual"]` attribute
- The generator provides instructions for running tests directly

## Benefits

This approach provides several benefits:

1. Eliminates architecture mismatch errors in test execution
2. Provides accurate test results for Foundation-free modules
3. Gives detailed test output from XCTest
4. Maintains compatibility with our Foundation-free module architecture
5. Works consistently across macOS environments

## Troubleshooting

If you encounter issues with tests:

1. Verify the test bundle was built successfully
2. Check the path to the test bundle (it should match the pattern above)
3. Ensure your module is truly Foundation-free
4. Run tests individually if needed to isolate issues
