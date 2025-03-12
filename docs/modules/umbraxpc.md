# UmbraXPC Module

The UmbraXPC module provides the cross-process communication infrastructure for the UmbraCore framework, enabling secure operations between the sandboxed application and privileged XPC service.

## Overview

UmbraXPC implements the infrastructure required for secure and reliable communication between the main application and the XPC service. It handles process lifecycle management, error handling, and secure message passing to maintain the security boundaries required by macOS.

## Features

- Secure XPC service implementation
- Process lifecycle management
- Robust error handling
- Secure credential passing
- Permission validation

## Usage

```swift
import UmbraXPC

// Set up the XPC service connection
let xpcService = UmbraXPCServiceConnector.shared

// Execute a command via XPC
try await xpcService.executeCommand(
    command: "backup",
    arguments: ["--source", sourcePath, "--target", targetPath],
    environment: ["RESTIC_PASSWORD": passwordReference]
)
```

## Integration

UmbraXPC integrates with:

- XPCProtocolsCore for protocol definitions
- SecurityTypes for secure type passing
- ResticCLIHelper for command execution
- UmbraCore for main application integration

## Security Model

UmbraXPC follows a strict security model:

- Main app requests permissions
- XPC service executes commands
- Secure data passing between components
- Resource cleanup on both sides

## Source Code

The source code for this module is located in the `Sources/UmbraXPC` directory of the UmbraCore repository.
