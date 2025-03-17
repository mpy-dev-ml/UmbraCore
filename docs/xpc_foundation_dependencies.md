# XPCProtocolsCore Foundation Dependencies

## Current Status

Despite being designated as a "foundation-free" module in our architecture, XPCProtocolsCore currently has several dependencies on Foundation due to historical and compatibility reasons. This document outlines these dependencies and our plan to reduce or eliminate them over time.

### Core Foundation Dependencies

#### Required for Objective-C Interoperability

- **NSObject** and **NSObjectProtocol**: Required for legacy Objective-C protocol conformance
- **NSData**: Used for binary data interchange with Objective-C APIs
- **NSXPCConnection**: The underlying Apple XPC mechanism requires Foundation
- **@objc** attribute on protocols for exposing Swift types to Objective-C

#### Error Handling Dependencies

- **NSError** and error dictionaries (e.g., NSLocalizedDescriptionKey)
- **NSURLErrorDomain** and related constants for network error mapping

#### Other Foundation Types Used

- **Data**: For modern Swift binary data handling
- **Date**: For timestamps in service status
- **UUID**: For unique identifiers
- **String** extensions and JSON handling

## Migration Strategy

### Short-term Approach

In the short term, we are maintaining Foundation imports where necessary to support legacy code and the ongoing migration process. The `LegacyXPCServiceAdapter` and similar bridge components explicitly require Foundation due to their role in transitioning from Objective-C based services to modern Swift implementations.

### Medium-term Goals

1. **Separate Concerns**: Clearly distinguish between core protocol definitions (which could be Foundation-free) and implementation details that require Foundation
2. **Minimize Foundation Usage**: Even where Foundation is required, limit its usage to the smallest subset possible
3. **Create Foundation-Free Alternatives**: Expand the `SecureBytes` pattern to provide Foundation-free alternatives for other common types

### Long-term Vision

Our aspiration is to move to a fully modern Swift implementation with minimal or no requirement for Objective-C compatibility:

1. **Eliminate NS-prefixed Types**: Replace all `NSObject` and NS-prefixed dependencies with Swift-native protocols and types
   - Replace `NSData` with Swift's `Data` or our custom `SecureBytes`
   - Replace `NSError` with Swift's native error handling

2. **Swift-native XPC**: Investigate options for a more Swift-native approach to XPC communication that reduces dependency on `NSXPCConnection`

3. **True Foundation Independence**: For the most security-critical components, develop alternatives to remaining Foundation types:
   - Custom replacements for `Data` (expanding `SecureBytes`)
   - Custom timestamp and identifier implementations
   - Pure Swift serialization mechanisms

## Exceptions and Practical Considerations

While the "foundation-free" designation is aspirational, some practical considerations may require continued use of Foundation:

1. **Apple Platform Integration**: XPC itself is an Apple technology and may always require some level of Foundation
2. **Developer Ergonomics**: In non-security-critical areas, the benefits of Foundation may outweigh the cost of creating custom alternatives
3. **Maintenance Burden**: Custom alternatives to Foundation types require ongoing maintenance and security review

## Current Roadmap

1. **Documentation**: Complete audit of Foundation dependencies and document them (this document)
2. **Isolation**: Move Foundation-dependent code into clearly marked adapters and extensions
3. **Deprecation**: Continue marking legacy Objective-C interfaces as deprecated with migration paths
4. **Alternative Implementations**: Develop and test Foundation-free alternatives where feasible

## Conclusion

The XPCProtocolsCore module's designation as "foundation-free" represents our architectural goal rather than the current implementation reality. Through careful migration and refactoring, we are working toward reducing Foundation dependencies while maintaining compatibility with existing code.
