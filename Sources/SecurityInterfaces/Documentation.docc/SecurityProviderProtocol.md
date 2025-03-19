# Security Provider Protocol

The core protocols for implementing security services in UmbraCore.

## Overview

The SecurityInterfaces module defines several key protocols for security operations:

- SecurityProvider - The core protocol for security operations
- SecurityProviderDTO - Foundation-independent version using DTOs
- SecurityProviderBase - Base implementation for security providers

## Implementation

Security providers are typically implemented by adapting platform-specific 
security capabilities to a standardized interface. This allows application code
to use security features without depending on platform-specific details.

## Topics

### Factory Patterns

- SecurityProviderFactory
- SPCProviderFactory
