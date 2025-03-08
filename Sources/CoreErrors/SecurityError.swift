import Foundation
import ErrorHandling
import ErrorHandlingDomains

// This file now re-exports UmbraErrors.Security.Core
// The original SecurityError enum has been replaced by UmbraErrors.Security.Core

/// Type alias for backward compatibility during migration
/// @available(*, deprecated, message: "Use UmbraErrors.Security.Core directly")
public typealias SecurityError = UmbraErrors.Security.Core
