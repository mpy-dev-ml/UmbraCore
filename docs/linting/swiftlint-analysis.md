# SwiftLint Analysis Report
Generated: 24 February 2025
Last Updated: 24 February 2025

## Overview
This document tracks SwiftLint violations in the UmbraCore project. Each section lists violations by category and file, making it easier to track progress as we address them.

## Current Status
- Initial Violations: 264
- Current Violations: 237
- Reduction: 27 violations (10.2% improvement)

## Violation Categories

### 1. Vertical Parameter Alignment
Files with parameter alignment issues:
- [x] `Sources/UmbraKeychainService/KeychainXPCImplementation.swift` (Fixed)
- [ ] `Sources/UmbraKeychainService/KeychainXPCConnection.swift`
  - Multiple instances of misaligned parameters in function declarations

### 2. Identifier Naming
Files with naming issues:
- [x] `Tests/CryptoTests/CryptoServiceTests.swift` (Fixed)
- [x] `Tests/CryptoTypesTests/DefaultCryptoServiceTests.swift` (Fixed)
- [ ] `Tests/XPCTests/CryptoXPCServiceTests.swift`
  - Variable 'iv' too short
- [ ] `Tests/UmbraTestKit/Sources/UmbraTestKit/TestUtilities.swift`
  - Variable 'fm' and 'i' too short

### 3. String to Data Conversion
Files with non-optimal conversions:
- [x] `Tests/CryptoTests/CryptoServiceTests.swift` (Fixed)
- [x] `Tests/CryptoTypesTests/DefaultCryptoServiceTests.swift` (Fixed)
- [ ] `Tests/SecurityTypesTests/MockSecurityProviderTests.swift`
- [ ] `Tests/CoreTests/CryptoTests.swift`
- [ ] `Tests/KeychainTests/KeychainServiceTests.swift`

### 4. Line Length
Files exceeding line length limits:
- [ ] `Sources/Core/Services/ServiceContainer.swift`
  - Line 170: 132 characters (limit: 120)
- [ ] `Tests/ResticCLIHelperTests/Support/TestUtilities.swift`
  - Line 39: 124 characters
- [ ] `Tests/CryptoTests/CryptoServiceTests.swift`
  - Line 35: 124 characters

### 5. Attributes
Files with attribute placement issues:
- [x] `Sources/Core/Services/CoreService.swift` (Fixed)
- [ ] `Sources/Core/Services/UmbraService.swift`

### 6. TODOs
Files with TODO comments to resolve:
- [ ] `Sources/Core/Core.swift`
- [ ] `Sources/Core/Services/KeyManager.swift` (multiple TODOs)

### 7. Other Issues
- [ ] Unused enumerated in `Tests/ResticCLIHelperTests/Support/TestUtilities.swift`

## Progress Tracking

### Completion Status
- [x] Initial vertical parameter alignment in KeychainXPCImplementation.swift
- [x] Initial identifier naming issues in crypto test files
- [x] Initial String to Data conversion issues in main crypto test files
- [x] Attribute placement in CoreService.swift
- [ ] Remaining vertical parameter alignment issues
- [ ] Remaining identifier naming issues
- [ ] Remaining String to Data conversion issues
- [ ] Line length issues
- [ ] Remaining attribute placement issues
- [ ] TODO comments
- [ ] Other minor issues

## Next Steps
1. Address vertical parameter alignment in KeychainXPCConnection.swift
2. Fix remaining short variable names in test files
3. Update remaining String to Data conversions
4. Fix line length violations
5. Correct remaining attribute placements
6. Review and address TODO comments
7. Fix miscellaneous issues

## Notes
- All fixes should maintain existing functionality
- Test coverage should be maintained or improved
- Document any architectural decisions made during refactoring
- Consider creating tickets for addressing TODO comments separately
