# UmbraXPC

The UmbraXPC module provides the infrastructure for secure cross-process communication in UmbraCore applications.

## Overview

UmbraXPC implements a secure communication layer allowing sandboxed main applications to perform privileged operations through an XPC service. This separation is crucial for maintaining macOS security boundaries while enabling full backup functionality.

## Key Features

- Secure message passing between application and XPC service
- Structured command execution framework
- Permission management and validation
- Resource lifecycle management
- Error handling and recovery

## Architecture

UmbraXPC follows a client-service architecture:

1. **Main App (Sandboxed)**
   - Uses XPC for executing Restic commands
   - No direct command execution
   - Handles security-scoped bookmarks
   - Implements proper permission management

2. **XPC Service**
   - Handles all command-line operations
   - Has necessary entitlements
   - Communicates securely with main app
   - Manages process lifecycle

## Integration

```swift
import UmbraXPC

// Create a client connection to the XPC service
let xpcClient = XPCServiceClient()

// Execute a command through the XPC service
try await xpcClient.executeCommand(
    command: "backup",
    arguments: ["--tag", "daily", "/Users/Documents"],
    environment: ["RESTIC_PASSWORD": passwordRef]
)
```

## Security Considerations

- All commands are validated before execution
- Environment variables are securely passed between processes
- Resources are properly cleaned up after operations
- Security boundaries are maintained throughout operations
