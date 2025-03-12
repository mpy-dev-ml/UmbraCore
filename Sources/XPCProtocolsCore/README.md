# XPCProtocolsCore

This module provides the foundation-free XPC protocol definitions for UmbraCore, serving as a central location for all XPC communication protocols.

## Overview

The XPCProtocolsCore module is a critical part of the UmbraCore XPC Protocol Consolidation effort. It defines standardised and foundation-free protocol interfaces for secure cross-process communication.

## Features

- Foundation-free protocol definitions
- Standardised error types
- Cross-module protocol compatibility
- Adaptors for legacy protocol support

## Integration

This module is designed to be imported by any component that needs to participate in XPC communication without introducing a dependency on Foundation.

```swift
import XPCProtocolsCore

// Define a service conforming to XPC protocols
class MyService: XPCServiceProtocolComplete {
    // Implementation
}
```

## Migration

When migrating from legacy XPC protocols, refer to the `XPC_PROTOCOLS_MIGRATION_GUIDE.md` document for step-by-step guidance.
