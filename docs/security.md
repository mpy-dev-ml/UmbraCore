---
layout: default
title: Security
nav_order: 5
description: Security features and best practices for UmbraCore
---

# Security Guidelines

## Overview

UmbraCore handles sensitive data and requires careful attention to security. This guide outlines our security practices and requirements for developers integrating UmbraCore into their applications.

## Secure Storage

### Credentials Management

UmbraCore provides secure storage mechanisms for sensitive data:

```swift
// Recommended: Use UmbraKeychainService
try await keychainService.store(password: "secret", forKey: "repo-key")

// Never do this:
UserDefaults.standard.set("secret", forKey: "repo-key") // UNSAFE!
```

Always use `UmbraKeychainService` for storing:
- Repository passwords
- API keys
- Access tokens
- SSH keys

### File System Access

UmbraCore implements secure file system access through:
- `UmbraBookmarkService` for persistent file access
- Security-scoped bookmarks
- Proper permission handling

Never store raw file paths - always use security-scoped bookmarks for persistent access.

## Encryption

### Data at Rest

UmbraCore ensures data security through:
- Mandatory encryption of all sensitive data
- `UmbraCryptoService` for encryption/decryption operations
- Secure key management (never stored in code)

### Data in Transit

Network security is maintained by:
- Enforcing secure transport (HTTPS, SSH)
- Certificate validation
- Comprehensive error handling
- Rate limiting and timeout management

## Access Control

### XPC Services

UmbraCore uses XPC services to:
- Implement the principle of least privilege
- Isolate sensitive operations in separate processes
- Validate all inputs and outputs
- Maintain process boundaries

### File Permissions

The framework respects system security by:
- Honouring system permissions
- Using security-scoped resources
- Implementing proper cleanup of temporary files
- Validating access rights

## Logging and Auditing

### Sensitive Data Handling

UmbraCore implements secure logging practices:
- No credentials in logs
- Automatic masking of sensitive information
- Appropriate log levels for different contexts
- Privacy-aware debug information

### Audit Trail

Security events are tracked through:
- Comprehensive event logging
- Contextual information capture
- Secure audit log maintenance
- Structured log formats

## Error Handling

### Security Errors

The framework handles security errors by:
- Abstracting internal details
- Providing appropriate user feedback
- Logging security failures securely
- Implementing secure fallbacks

### Recovery Procedures

Error recovery includes:
- Clean state maintenance
- Secure cleanup procedures
- System integrity verification
- Graceful degradation

## Best Practices

### Code Security

Developers should follow these practices:
- Leverage Swift's type safety
- Implement thorough input validation
- Follow OWASP guidelines
- Use strong types for sensitive data

### Security Testing

UmbraCore requires:
- Comprehensive security test cases
- Error condition testing
- Security boundary verification
- Regular security audits

### Dependency Management

Maintain security through:
- Regular security updates
- Vulnerability scanning
- Strict dependency pinning
- Supply chain security

## Getting Help

If you discover a security vulnerability:

1. **DO NOT** create a public issue
2. Email security@mpy-dev.ml with details
3. Expect a response within 24 hours
4. Follow responsible disclosure practices

For general security questions, refer to:
- [Configuration Guide](configuration.md)
- [API Reference](api-reference.md)
- [Troubleshooting Guide](troubleshooting.md)
