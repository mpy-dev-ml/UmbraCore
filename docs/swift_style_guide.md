# UmbraCore Swift Style Guide

This style guide is adapted from the [Google Swift Style Guide](https://google.github.io/swift/) and customized for UmbraCore development. It's designed to ensure consistency and maintainability as our codebase grows.

## File Basics

### File Names

- Match the name of the primary type declared in the file
- Use `.swift` extension
- Use UpperCamelCase (PascalCase)
- Be descriptive and avoid abbreviations

```
// Good
NetworkManager.swift
UserAuthentication.swift

// Bad
NetMgr.swift
UserAuth.swift
```

### File Organization

1. Copyright notice and license information
2. Import statements
3. Type and extension declarations

### Import Statements

- Sort imports alphabetically
- Foundation and system imports first, then other imports
- No duplicate imports

```swift
import Foundation
import OSLog
import SwiftUI

import CoreServices
import SecurityTypes
import UmbraLogging
```

## Naming

### General Naming Rules

- Names should be self-explanatory and descriptive
- Avoid abbreviations except for widely accepted ones (URL, ID)
- Use British English for user-facing strings
- Use American English for code identifiers to match Swift standard library

### Type Names

- Use UpperCamelCase (PascalCase) for all types
- Use nouns for types that represent things
- Prefix protocols that describe what something is with a noun
- Suffix protocols that describe a capability with `-able`, `-ible`, or `-ing`

```swift
// Types
struct DatabaseConnection
class SecurityManager

// Protocols
protocol Document  // describes what something is
protocol Searchable  // describes a capability
protocol Encrypting  // describes a capability
```

### Variable and Constant Names

- Use lowerCamelCase
- Be descriptive but concise
- Avoid single-letter names except in mathematical contexts
- Include type information in the name only when it adds clarity

```swift
// Good
let maxRetryCount = 3
var currentUserProfile: UserProfile

// Bad
let max = 3
var profile = UserProfile()
```

### Function and Method Names

- Use lowerCamelCase
- Use verb phrases to describe what the function does
- Use descriptive parameter labels
- When the first parameter is part of the natural phrase, omit its label

```swift
// Good
func remove(at index: Int)
func convertToMeters(from length: Double, unit: LengthUnit) -> Double

// Bad
func remove(index: Int)
func convertToMeters(length: Double, unit: LengthUnit) -> Double
```

## Formatting

### Indentation and Line Wrapping

- Use 4 spaces for indentation (not tabs)
- Limit line length to 100 characters where possible
- When wrapping lines, indent continuation lines by 4 spaces

### Braces

- Opening braces on the same line as the statement
- Closing braces on a new line
- Always include braces for control flow statements, even for single-line bodies

```swift
if condition {
    doSomething()
} else {
    doSomethingElse()
}
```

### Spacing

- Single space after keywords (if, guard, for, etc.)
- No space between function name and opening parenthesis
- No spaces inside parentheses
- Single space around binary operators

```swift
let result = (a + b) * (c - d)
if condition {
    func(param1, param2)
}
```

## Types and Declarations

### Value vs. Reference Types

- Prefer structs over classes when:
  - The primary purpose is to encapsulate data
  - Copying behavior is desired
  - There's no need for inheritance

- Use classes when:
  - Identity is important
  - Inheritance is needed
  - The lifetime of instances needs to be controlled

### Properties

- Use computed properties rather than methods when the operation:
  - Does not modify self
  - Is cheap to compute
  - Returns the same value each time it's called with the same inputs
  - Does not have side effects

```swift
// Good
var diameter: Double {
    return radius * 2
}

// Instead of
func calculateDiameter() -> Double {
    return radius * 2
}
```

### Access Control

- Be explicit about access control modifiers
- Use the most restrictive level that makes sense
- Order from most restrictive to least restrictive: `private`, `fileprivate`, `internal`, `public`, `open`

```swift
public class NetworkManager {
    private let apiKey: String
    internal var session: URLSession
    
    public func fetch(url: URL) -> Data { ... }
}
```

## Functions and Methods

### Parameter Lists

- Keep parameter lists short when possible
- Consider grouping related parameters into structures
- Use default parameter values when appropriate

### In-Out Parameters

- Use sparingly and only when the behavior would be otherwise surprising
- Place in-out parameters at the end of the parameter list when possible

```swift
func swap(_ a: inout Int, _ b: inout Int)
```

## Control Flow

### Guard Statements

- Use `guard` statements for early returns
- Handle the "failure" case immediately after the guard
- Keep the guarded code at the same indentation level as the guard

```swift
guard let value = optionalValue else {
    return
}
// Use value...
```

### Optionals

- Avoid force unwrapping (`!`) except in tests or when you're certain
- Prefer optional binding and nil coalescing over force unwrapping
- Use implicitly unwrapped optionals (`!` in type) only when appropriate

```swift
// Good
if let value = optionalValue {
    use(value)
}

let value = optionalValue ?? defaultValue

// Avoid when possible
let value = optionalValue!
```

## Documentation

### Documentation Comments

- Document all public declarations
- Use Swift's standard documentation format (triple-slash `///` comments)
- Include parameter, returns, and throws descriptions
- Document edge cases and preconditions

```swift
/// Retrieves the user profile from the server.
///
/// - Parameters:
///   - userId: The ID of the user to fetch
///   - includeDetails: Whether to include detailed information
/// - Returns: The user profile
/// - Throws: `NetworkError` if the request fails
public func fetchUserProfile(userId: String, includeDetails: Bool = false) throws -> UserProfile
```

### Code Comments

- Use comments to explain "why", not "what"
- Keep comments up to date when code changes
- Use `// MARK: - Section Name` to organize code into logical sections

## Swift Specific Features

### Error Handling

- Use Swift's `throw`/`catch` system for error handling
- Define dedicated error types with clear case names
- Provide descriptive error messages

```swift
enum NetworkError: Error {
    case invalidURL
    case connectionFailed(reason: String)
    case serverError(statusCode: Int)
}
```

### Extensions

- Use extensions to organize code by functionality
- Put protocol conformances in separate extensions
- Name extensions for clarity when extending external types

```swift
// Protocol conformance in extension
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// Functionality extension
extension User {
    func promoteToAdmin() {
        role = .admin
        permissionLevel = .full
    }
}
```

### Concurrency

- Prefer modern Swift concurrency (async/await) over completion handlers
- Mark functions that can throw or suspend with appropriate keywords
- Use task groups for concurrent operations
- Avoid explicit use of `DispatchQueue` when Swift concurrency can be used

```swift
// Modern concurrency
func fetchData() async throws -> Data {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NetworkError.invalidResponse
    }
    return data
}
```

## Bazel and Build System

### BUILD File Organization

- Sort dependencies alphabetically
- Group dependencies by type (internal, external)
- Keep BUILD files minimal and focused

```python
umbra_swift_library(
    name = "NetworkService",
    srcs = glob(["*.swift"]),
    deps = [
        # Internal dependencies
        "//Sources/CoreTypes",
        "//Sources/LoggingService",
        
        # External dependencies
        "@swift_protobuf//:SwiftProtobuf",
    ],
)
```

## Memory Management

### Capturing Variables

- Be explicit about capturing variables in closures to avoid retain cycles
- Use `[weak self]` or `[unowned self]` when appropriate
- Always check if `[weak self]` is nil before using it

```swift
networkManager.fetchData { [weak self] result in
    guard let self = self else { return }
    self.handleResult(result)
}
```

## Testing

### Test Structure

- Use descriptive names for test methods
- Structure tests as "given-when-then" or "arrange-act-assert"
- Test edge cases and error conditions
- One assertion per test when possible

```swift
func testUserAuthentication_WithValidCredentials_ReturnsSuccess() {
    // Given
    let validCredentials = Credentials(username: "test", password: "password")
    
    // When
    let result = authenticator.authenticate(credentials: validCredentials)
    
    // Then
    XCTAssertEqual(result, .success)
}
```

## References

- [Google Swift Style Guide](https://google.github.io/swift/)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Swift.org Documentation](https://swift.org/documentation/)
