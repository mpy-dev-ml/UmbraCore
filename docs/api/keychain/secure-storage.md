# Secure Storage

The secure storage system in UmbraKeychainService provides a robust interface for storing sensitive data in the system keychain.

## Features

- Secure credential storage
- Biometric authentication
- Access control management
- Automatic encryption
- Secure backup/restore

## Access Control

```swift
struct KeychainAccessControl {
    let requiresBiometrics: Bool
    let accessibleMode: AccessibleMode
    let sharingMode: SharingMode
    let timeout: TimeInterval?
}
```

### Access Modes

- `whenUnlocked`: Only when device is unlocked
- `afterFirstUnlock`: After first unlock until restart
- `always`: Always accessible (use with caution)

### Sharing Options

- `none`: No sharing
- `sameUserOnly`: Share with same user
- `anyUser`: Share with any user (admin only)

## Encryption

All data is encrypted before storage:

- AES-256 encryption
- Secure key generation
- Key rotation support
- Forward secrecy

## Backup and Restore

```swift
protocol SecureBackupProvider {
    func createBackup() async throws -> BackupMetadata
    func restoreFromBackup(_ backup: BackupData) async throws
    func validateBackup(_ backup: BackupData) async throws -> Bool
}
```

### Backup Features

- Encrypted backups
- Version control
- Integrity verification
- Secure transport

## Error Handling

Common storage errors:

- `AccessDeniedError`: Permission issues
- `EncryptionError`: Encryption failures
- `BackupError`: Backup/restore issues
- `AuthenticationError`: Auth failures

## Best Practices

1. Use appropriate access controls
2. Implement regular backups
3. Rotate encryption keys
4. Monitor access patterns
5. Handle errors securely

## Examples

### Storing a Password

```swift
let storage = SecureStorage()
try await storage.store(
    password: "MySecurePass123!",
    identifier: "backup-repo",
    accessControl: .init(
        requiresBiometrics: true,
        accessibleMode: .whenUnlocked
    )
)
```

### Creating a Backup

```swift
let backupProvider = SecureBackupProvider()
let backup = try await backupProvider.createBackup()
try await backupProvider.validateBackup(backup)
```
