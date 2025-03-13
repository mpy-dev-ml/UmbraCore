# UmbraCore Build Notes

## 2025-03-13: Fixed ResticTypes Module Configuration

### Issue
The ResticTypes module was incorrectly defined as a test library (`umbra_test_library`) in its BUILD.bazel file, but it was being referenced by production code in the ResticCLIHelper modules as a standard dependency.

### Fix Applied
Changed the ResticTypes module definition from `umbra_test_library` to `umbra_swift_library` in `/Sources/ResticTypes/BUILD.bazel`.

### Modules Fixed
This change resolved build failures in the following modules:
- ResticTypes
- ResticCLIHelper
- ResticCLIHelper/Commands
- ResticCLIHelper/Models
- ResticCLIHelper/Protocols
- ResticCLIHelper/Types

### CI Configuration Update
The stable-build.yml workflow configuration was updated to include these now-fixed modules in the CI build.

### Learning Points
- When a module is required by production code, it should not be defined as a test library
- Test libraries should only be used for modules that are exclusively for testing purposes
- A module's role (production vs test) should be consistently reflected in its BUILD.bazel configuration
