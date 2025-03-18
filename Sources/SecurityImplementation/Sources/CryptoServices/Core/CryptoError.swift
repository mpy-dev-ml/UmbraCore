/**
 # CryptoError

 Defines the error types specific to cryptographic operations.

 ## Responsibilities

 * Provide specific error types for cryptographic operations
 * Ensure consistent error handling across the cryptographic services
 
 @Warning This error type is deprecated and will be replaced by CoreErrors.CryptoError.
 */

import CoreErrors
import Foundation

/// Errors that can occur during cryptographic operations
/// @deprecated This will be replaced by CoreErrors.CryptoError in a future version.
/// New code should use CoreErrors.CryptoError directly.
@available(
    *,
    deprecated,
    message: "This will be replaced by CoreErrors.CryptoError in a future version. Use CoreErrors.CryptoError directly."
)
public typealias CryptoError = CoreErrors.CryptoError
