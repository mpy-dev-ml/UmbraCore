// URLAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import UmbraCoreTypes

/// URLAdapter provides bidirectional conversion between Foundation URL and ResourceLocator.
///
/// This adapter serves as the bridge for resource locations between Foundation-dependent
/// and Foundation-independent code.
public enum URLAdapter {
    
    /// Convert Foundation URL to ResourceLocator
    /// - Parameter url: Foundation URL instance
    /// - Returns: A new ResourceLocator instance representing the same resource
    /// - Throws: AdapterError if the URL cannot be converted
    public static func resourceLocator(from url: URL) throws -> ResourceLocator {
        guard let scheme = url.scheme else {
            throw AdapterError.invalidURLConversion("URL is missing a scheme")
        }
        
        // Extract the components from the URL
        let path = url.path
        let query = url.query
        let fragment = url.fragment
        
        return ResourceLocator(
            scheme: scheme,
            path: path,
            query: query,
            fragment: fragment
        )
    }
    
    /// Convert ResourceLocator to Foundation URL
    /// - Parameter locator: ResourceLocator instance
    /// - Returns: A new URL instance representing the same resource
    /// - Throws: AdapterError if the ResourceLocator cannot be converted
    public static func url(from locator: ResourceLocator) throws -> URL {
        // Use the string representation to create a URL
        let urlString = locator.toString()
        
        guard let url = URL(string: urlString) else {
            throw AdapterError.invalidURLConversion("Could not create URL from locator: \(urlString)")
        }
        
        return url
    }
    
    /// Create a file URL from a file path ResourceLocator
    /// - Parameter locator: ResourceLocator with scheme "file"
    /// - Returns: A file URL
    /// - Throws: AdapterError if the ResourceLocator is not a file locator
    public static func fileURL(from locator: ResourceLocator) throws -> URL {
        guard locator.isFileResource else {
            throw AdapterError.invalidURLConversion("ResourceLocator is not a file resource")
        }
        
        return URL(fileURLWithPath: locator.path)
    }
}

/// Errors that can occur during adapter operations
public enum AdapterError: Error {
    case invalidURLConversion(String)
    case invalidDateConversion(String)
    case invalidDataConversion(String)
}
