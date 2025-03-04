# UmbraCore Architecture and Style Guide

## Core Principles

Our architecture and coding practices aim to support:

1. **Scalability**: As our codebase grows to potentially millions of lines
2. **Modularity**: Supporting multiple apps built on our shared foundations
3. **Readability**: Code should be self-documenting and consistent
4. **Maintainability**: Easy to understand, modify, and extend
5. **Testability**: Code designed with testing in mind from the start

## Module Organization

### Naming Conventions

- **Module names**: CamelCase, descriptive, and focused on functionality (e.g., `SecurityInterfaces`, not `SecurityStuff`)
- **Clear boundaries**: Each module should have a single, well-defined responsibility
- **Consistent depth**: Avoid deep nesting of modules; aim for a flat hierarchy with clear dependencies

### Dependency Structure

- **Diamond dependency problem**: Avoid multiple dependency paths to the same module
- **Explicit dependencies**: All dependencies must be explicitly declared in BUILD files
- **Layered architecture**: Maintain strict layering with unidirectional dependencies:
  ```
  Foundation Layer → Protocol Layer → Implementation Layer → Service Layer → Application Layer
  ```
- **No circular dependencies**: Absolutely no circular dependencies between modules

### Module Types

1. **Foundation modules**: Minimal, stable modules with few dependencies
2. **Protocol modules**: Define interfaces without implementations
3. **Implementation modules**: Concrete implementations of protocols
4. **Service modules**: Business logic that coordinates implementations
5. **Application modules**: End-user facing functionality

## Code Style (Based on Google Swift Style Guide)

### File Organization

- **File length**: Generally < 1000 lines, split logically if longer
- **Type length**: Generally < 400 lines, split into extensions if longer
- **Function length**: Generally < 40 lines
- **Standard header**: All files begin with copyright notice and import statements
- **Import organization**: Alphabetical order, Foundation and system imports first

### Naming

- **Types**: UpperCamelCase for classes, structs, enums, protocols, typealiases
- **Variables/Constants**: lowerCamelCase
- **Functions**: lowerCamelCase, verb phrases describing actions
- **Acronyms**: Treat acronyms as words (e.g., `urlString` not `URLString`)
- **Clear naming**: Names should be self-explanatory without needing comments

### Documentation

- **Module documentation**: Every module has a README.md explaining purpose and usage
- **Public APIs**: All public methods/properties have documentation comments
- **Documentation format**: Use Swift's standard documentation format:
  ```swift
  /// Returns the numeric value at the specified index.
  ///
  /// - Parameter index: The index of the value to return.
  /// - Returns: The numeric value at the specified index.
  /// - Throws: `CollectionError.outOfBounds` if the index is invalid.
  func value(at index: Int) throws -> Double
  ```

### Swift Features

- **Access control**: Be explicit about access control (`public`, `internal`, `private`)
- **Value types**: Prefer structs over classes when appropriate
- **Protocol-oriented**: Use protocols to define behavior contracts
- **Extensions**: Use extensions to organize code by functionality
- **Error handling**: Use Swift's `throw`/`catch` system, not optionals, for error cases
- **Concurrency**: Use modern Swift concurrency (async/await) where possible

## Bazel Build Practices

### BUILD File Organization

- **Target naming**: Clear, consistent naming for targets
- **Dependency specification**: Explicit, minimized dependencies
- **Visibility**: Restrict visibility appropriately
- **Clean structure**:
  ```python
  load("//:bazel/macros/swift.bzl", "umbra_swift_library")
  
  umbra_swift_library(
      name = "ModuleName",
      srcs = glob(["*.swift"]),
      deps = [
          "//Sources/DependencyOne",
          "//Sources/DependencyTwo",
      ],
      visibility = ["//visibility:public"],
  )
  ```

### Target Triple Consistency

- All Swift targets must use `arm64-apple-macos14.0` consistently
- Set at the target level, not globally

## Multi-App Architecture

### Shared Core

- **Core modules**: Maximum reuse across apps
- **Clean interfaces**: App-facing interfaces must be stable and well-documented
- **Versioning**: Clear versioning of shared components

### App-Specific Code

- **Minimal duplication**: Avoid duplicating functionality across apps
- **App-specific directories**: Clear separation of app-specific code
- **Dependency injection**: Apps should be configurable through dependency injection

## Testing Strategy

- **Unit tests**: All modules have comprehensive unit tests
- **Integration tests**: Test module interactions
- **Test-first development**: Consider writing tests before implementation
- **Test isolation**: Tests must not depend on each other
- **Test coverage**: Aim for high test coverage, especially of business logic

## Documentation

- **Architecture documentation**: Overview of system architecture, regularly updated
- **Module documentation**: Purpose, responsibilities, and usage of each module
- **API documentation**: Complete documentation of public APIs
- **Dependency graphs**: Visual representation of module dependencies

## Implementation Timeline

1. **Phase 1**: Protocol layer refactoring and circular dependency removal
2. **Phase 2**: Code style standardization across codebase
3. **Phase 3**: Documentation improvements
4. **Phase 4**: Multi-app support architecture
5. **Phase 5**: Test coverage expansion

## Tools and Enforcement

- **SwiftLint**: Automated style checking
- **Documentation generators**: Generate API docs from source comments
- **CI checks**: Automated checks for style, circular dependencies, and test coverage
- **Code review checklist**: Standard checklist for reviewers to ensure quality

## References

- [Google Swift Style Guide](https://google.github.io/swift/)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Bazel Best Practices](https://docs.bazel.build/versions/master/best-practices.html)
