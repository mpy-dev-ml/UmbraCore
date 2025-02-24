# Security Guidelines

## Overview
UmbraCore handles sensitive data and requires careful attention to security. This guide outlines our security practices and requirements.

## Secure Storage

### 1. Credentials
- Always use `UmbraKeychainService` for storing:
  - Repository passwords
  - API keys
  - Access tokens
  - SSH keys

```swift
// DO THIS:
try await keychainService.store(password: "secret", forKey: "repo-key")

// DON'T DO THIS:
UserDefaults.standard.set("secret", forKey: "repo-key") // UNSAFE!
```

### 2. File System Access
- Use `UmbraBookmarkService` for persistent file access
- Never store raw file paths
- Always use security-scoped bookmarks

## Encryption

### 1. Data at Rest
- All sensitive data must be encrypted
- Use `UmbraCryptoService` for encryption/decryption
- Never store encryption keys in code

### 2. Data in Transit
- Use secure transport (HTTPS, SSH)
- Validate certificates
- Implement proper error handling

## Access Control

### 1. XPC Services
- Principle of least privilege
- Separate process for sensitive operations
- Validate all inputs

### 2. File Permissions
- Respect system permissions
- Use security-scoped resources
- Clean up temporary files

## Logging

### 1. Sensitive Data
- Never log credentials
- Mask sensitive information
- Use appropriate log levels

### 2. Audit Trail
- Log security-relevant events
- Include necessary context
- Maintain audit logs

## Error Handling

### 1. Security Errors
- Don't expose internal details
- Provide appropriate user feedback
- Log security failures

### 2. Recovery
- Implement secure fallbacks
- Clean up on failure
- Maintain system integrity

## Best Practices

### 1. Code
- Use Swift's type safety
- Implement input validation
- Follow OWASP guidelines

### 2. Testing
- Include security test cases
- Test error conditions
- Verify security boundaries

### 3. Dependencies
- Regular security updates
- Vulnerability scanning
- Dependency pinning
