/**
 # CryptoError

 Defines the error types specific to cryptographic operations.

 ## Responsibilities

 * Provide specific error types for cryptographic operations
 * Ensure consistent error handling across the cryptographic services

 @Warning This error type is deprecated and has been replaced by CoreErrors.CryptoError.
 */

import CoreErrors
import Foundation

/**
 * This file previously contained a typealias for CryptoError.
 *
 * Please use CoreErrors.CryptoError directly in your code:
 * ```swift
 * import CoreErrors
 *
 * // Example usage:
 * throw CoreErrors.CryptoError.invalidKeySize(reason: "Key too small")
 * ```
 */
