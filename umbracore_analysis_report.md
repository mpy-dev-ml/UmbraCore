# UmbraCore Complexity Analysis Report

## Overview

- **Total modules analysed**: 84
- **Total files analysed**: 2223
- **Total lines of code**: 598235
- **Average lines per file**: 269.1

## Top 30 Most Complex Files

These files have been identified as the most complex in the codebase based on various metrics including size, nesting depth, and control structure density. They are prime candidates for refactoring.

| Module | File | LOC | Functions | Avg Func Length | Max Nesting | Long Functions | Deep Nesting | Complexity Score |
|--------|------|-----|-----------|----------------|-------------|---------------|--------------|------------------|
| .build | JSONEncoderTests.swift | 4529 | 1 | 4529.0 | 27 | 0 | 605 | 7757.8 |
| .build | SyntaxVisitor.swift | 7085 | 1 | 7085.0 | 3 | 1 | 0 | 4364.5 |
| .build | TreeDictionary Tests.swift | 2621 | 1 | 2621.0 | 9 | 1 | 229 | 3468.6 |
| .build | SyntaxRewriter.swift | 4895 | 1 | 4895.0 | 5 | 1 | 4 | 3006.7 |
| .build | Calendar_ICU.swift | 2288 | 4 | 572.0 | 6 | 2 | 264 | 2766.8 |
| .build | Data.swift | 2855 | 9 | 317.2 | 8 | 2 | 261 | 2665.6 |
| .build | Calendar_Gregorian.swift | 3119 | 12 | 259.9 | 7 | 5 | 249 | 2664.1 |
| .build | Parser+TokenSpecSet.swift | 4225 | 0 | 0.0 | 4 | 0 | 244 | 2468.0 |
| .build | GregorianCalendarTests.swift | 3900 | 1 | 3900.0 | 3 | 1 | 0 | 2368.6 |
| .build | RawSyntaxValidation.swift | 3733 | 1 | 3733.0 | 5 | 1 | 7 | 2351.5 |
| .build | Calendar_Enumerate.swift | 2474 | 15 | 164.9 | 8 | 5 | 226 | 2343.7 |
| .build | ChildNameForKeyPath.swift | 3589 | 1 | 3589.0 | 2 | 1 | 0 | 2173.7 |
| .build | PropertyListEncoderTests.swift | 2099 | 1 | 2099.0 | 8 | 0 | 105 | 2161.9 |
| .build | Locale_ICU.swift | 1759 | 4 | 439.8 | 8 | 2 | 200 | 2123.3 |
| .build | AttributedStringTests.swift | 2602 | 1 | 2602.0 | 6 | 1 | 53 | 2060.9 |
| .build | FileOperations.swift | 1283 | 7 | 183.3 | 13 | 3 | 204 | 2019.2 |
| .build | SwitchTests.swift | 1367 | 1 | 1367.0 | 6 | 0 | 128 | 1910.2 |
| .build | XMLPlistScanner.swift | 1508 | 5 | 301.6 | 7 | 4 | 157 | 1697.4 |
| .build | Calendar_Recurrence.swift | 926 | 4 | 231.5 | 9 | 3 | 163 | 1624.2 |
| .build | BitSetTests.swift | 1569 | 2 | 784.5 | 7 | 1 | 124 | 1598.2 |
| .build | InitDeinitTests.swift | 1096 | 1 | 1096.0 | 5 | 1 | 100 | 1492.6 |
| .build | Cursor.swift | 2468 | 41 | 60.2 | 7 | 14 | 120 | 1480.3 |
| .build | SyntaxNodesAB.swift | 5802 | 27 | 214.9 | 5 | 27 | 58 | 1470.6 |
| .build | Declarations.swift | 2182 | 19 | 114.8 | 10 | 14 | 119 | 1461.4 |
| .build | SyntaxAnyVisitor.swift | 2400 | 1 | 2400.0 | 2 | 1 | 0 | 1460.0 |
| .build | Expressions.swift | 2636 | 35 | 75.3 | 7 | 12 | 116 | 1435.9 |
| .build | JSONDecoder.swift | 1861 | 16 | 116.3 | 9 | 5 | 130 | 1427.9 |
| .build | OrderedDictionaryBenchmarks.swift | 600 | 1 | 600.0 | 6 | 1 | 124 | 1401.0 |
| .build | OrderedDictionary Tests.swift | 1366 | 55 | 24.8 | 7 | 1 | 140 | 1316.4 |
| .build | ShareableDictionaryBenchmarks.swift | 532 | 1 | 532.0 | 6 | 1 | 116 | 1296.2 |

## Complexity by Module

### Top 10 Most Complex Modules

| Module | Files | Total LOC | Avg Complexity | Most Complex File | Highest Complexity |
|--------|-------|-----------|----------------|-------------------|--------------------|
| docs | 1 | 304 | 222.4 | ErrorHandlingExamples.swift | 222.4 |
| UmbraSecurityCore | 4 | 835 | 222.4 | CryptoServiceAdaptersTests.swift | 517.7 |
| .build | 1652 | 532988 | 208.4 | JSONEncoderTests.swift | 7757.8 |
| SecurityBridge | 27 | 6375 | 203.9 | XPCServiceAdapter.swift | 1059.5 |
| XPC | 4 | 666 | 194.3 | XPCServiceProtocols.swift | 554.5 |
| SecurityImplementation | 30 | 6297 | 186.6 | SecurityImplementationTests.swift | 685.2 |
| UmbraKeychainService | 7 | 1275 | 153.9 | KeychainXPCImplementation.swift | 280.2 |
| Tests/KeychainTests | 5 | 601 | 150.2 | XPCServiceHelper.swift | 229.7 |
| Tests/ResourcesTests | 1 | 155 | 143.6 | ResourcePoolTests.swift | 143.6 |
| Tests/SecurityImplementationTests | 3 | 603 | 142.6 | KeyManagementTests.swift | 210.1 |

## Refactoring Recommendations

Based on the complexity analysis, here are some recommendations for improving code quality:

### High Nesting Depth

These files contain deeply nested code blocks (more than 4 levels deep) which can be difficult to follow and maintain:

- **JSONEncoderTests.swift** in module **.build** (max nesting: 27)
- **TreeDictionary Tests.swift** in module **.build** (max nesting: 9)
- **SyntaxRewriter.swift** in module **.build** (max nesting: 5)
- **Calendar_ICU.swift** in module **.build** (max nesting: 6)
- **Data.swift** in module **.build** (max nesting: 8)

**Recommendation**: Consider extracting nested blocks into separate functions with descriptive names. Use early returns or guard clauses to reduce nesting.

### Excessively Long Functions

These files contain very long functions (over 100 lines) which can be difficult to understand and test:

- **SyntaxVisitor.swift** in module **.build** (max function length: 7058 lines)
- **TreeDictionary Tests.swift** in module **.build** (max function length: 2599 lines)
- **SyntaxRewriter.swift** in module **.build** (max function length: 4861 lines)
- **Calendar_ICU.swift** in module **.build** (max function length: 1970 lines)
- **Data.swift** in module **.build** (max function length: 2099 lines)

**Recommendation**: Break down long functions into smaller, more focused functions that each do one thing well.

### General Refactoring Strategies

1. **Extract Method**: Identify blocks of code that work together and move them into their own functions with descriptive names.

2. **Replace Conditionals with Polymorphism**: If there are large switch statements or if-else chains, consider using polymorphism instead.

3. **Introduce Parameter Object**: For functions with many parameters, group related parameters into a single object.

4. **Extract Class**: If a class has too many responsibilities, split it into multiple classes each with a single responsibility.

5. **Replace Temporary with Query**: Instead of using temporary variables, extract the expression into a function.

## Conclusion

This analysis identifies the most complex parts of the UmbraCore codebase that may benefit from refactoring. Focus on the top files and modules for the highest potential improvement in code maintainability.

Refactoring should be done incrementally with thorough testing to ensure no functionality is broken.
