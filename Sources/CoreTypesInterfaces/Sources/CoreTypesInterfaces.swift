import CoreErrors
import ErrorHandlingDomains

/// Type alias to support legacy code that uses BinaryData
public typealias BinaryData=SecureData

/// Module initialisation function
/// Call this to ensure all components are properly registered
public func initialiseModule() {
  CoreTypesExtensions.registerModule()
}

/// Legacy type for compatibility with older code
/// New code should use CoreSecurityError directly
public typealias SecurityErrorBase=CoreSecurityError
