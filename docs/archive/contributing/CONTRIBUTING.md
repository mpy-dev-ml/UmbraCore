# Contributing to UmbraCore

## Getting Started

### 1. Development Environment
- macOS 14.0+
- Xcode 15.2+
- Swift 6.0.3+
- SwiftLint
- Restic

### 2. Setup
1. Fork the repository
2. Clone your fork
3. Install dependencies
4. Run tests

## Development Process

### 1. Branching
- `main`: Production-ready code
- `develop`: Integration branch
- Feature branches: `feature/description`
- Bug fixes: `fix/description`

### 2. Commit Messages
Follow conventional commits:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

### 3. Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint rules
- Document public APIs
- Write meaningful comments

### 4. Testing
- Write unit tests
- Include integration tests
- Maintain test coverage
- Test error conditions

### 5. Documentation
- Update API documentation
- Include code examples
- Document breaking changes
- Update guides if needed

## Pull Requests

### 1. Preparation
- Update from upstream
- Run all tests
- Check code coverage
- Run SwiftLint

### 2. Submission
- Clear description
- Link related issues
- Include test cases
- Update documentation

### 3. Review Process
- Address feedback
- Keep changes focused
- Maintain clean history
- Update as needed

## Release Process

### 1. Versioning
Follow semantic versioning:
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

### 2. Release Checklist
- Update changelog
- Update version
- Run full test suite
- Update documentation
- Create release notes

## Additional Resources
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
