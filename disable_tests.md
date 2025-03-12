# Disabling Tests for Clean UmbraCore Build

This document outlines strategies for disabling test builds in the UmbraCore project to achieve a clean build focused only on production code.

## Recommended Approaches

### 1. Create a Custom .bazelrc Configuration

Create a `.bazelrc.notests` file in the root of the project with the following content:

```
# Disable test targets
build --build_tests_only=false
build --compilation_mode=opt

# Tag all test targets and exclude them
build --build_tag_filters=-test,-tests
```

You can then invoke Bazel with this configuration:

```bash
bazelisk build --config=notests //Sources/...
```

### 2. Using Explicit Target Exclusions

For a more direct approach, you can explicitly exclude test targets in your build command:

```bash
bazelisk build //Sources/... -//Sources/...:*Tests -//Sources/...:*Tests_* -//Sources/...:*ForTesting
```

### 3. Creating a Custom Build Target Set

Create a file called `production_targets.txt` containing only the production targets:

```
# Generate this list with:
# bazelisk query 'kind(".*_library rule", //Sources/...)' | grep -v "Test\|ForTesting" > production_targets.txt

//Sources/SecureBytes:SecureBytes
//Sources/CoreTypesInterfaces:CoreTypesInterfaces
# ... and so on
```

Then build using this file:

```bash
bazelisk build $(cat production_targets.txt)
```

## Complete Solution for UmbraCore

For the most reliable solution, combine approaches 1 and 3:

1. **Generate a clean list of non-test targets**

```bash
# Run from project root
bazelisk query 'kind(".*_library rule", //Sources/...)' | \
  grep -v "Test\|ForTesting\|_runner" > production_targets.txt
```

2. **Build only those targets with optimized settings**

```bash
# Create .bazelrc.prodonly
echo "build --compilation_mode=opt" > .bazelrc.prodonly
echo "build --build_tests_only=false" >> .bazelrc.prodonly

# Build production targets
bazelisk build --config=prodonly $(cat production_targets.txt)
```

## Specific Test Targets to Exclude

Based on our build issues summary, these test targets are particularly problematic:

- `//Sources/XPCProtocolsCore:XPCProtocolsCoreTests`
- `//Sources/SecurityInterfaces/Tests:SecurityProviderTests` 
- `//Sources/SecurityImplementation:SecurityImplementationTests`
- `//Sources/SecurityImplementation:SecurityImplementationTests_runner`
- `//Sources/ErrorHandling/Examples:ErrorHandlingExamples`
- `//Sources/UmbraSecurityCore:UmbraSecurityCoreTests`
- `//Sources/KeyManagementTypes/Tests:KeyManagementTypesTests`
- `//Sources/SecureString:SecureStringTests`

## Temporary Tag-Based Solution

If you want to quickly disable specific tests without creating full configuration files:

1. Edit the `BUILD.bazel` files for problematic test targets and add tags:

```python
swift_test(
    name = "ProblemTestTarget",
    # ... other attributes
    tags = ["manual", "no_build"],  # Add these tags
)
```

2. Build with tag filtering:

```bash
bazelisk build //Sources/... --build_tag_filters=-no_build
```

This will skip building any target tagged with "no_build".

## Next Steps

1. Generate the production targets list
2. Create the custom build configuration
3. Verify you can build all production code cleanly
4. Address test issues systematically after establishing a clean production build
