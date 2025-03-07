// RepositoryErrorDomain.swift
// Repository error domain definition
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingInterfaces
import ErrorHandlingCommon

/// Domain for repository-related errors
public struct RepositoryErrorDomain: ErrorDomain {
    /// The domain identifier
    public static let identifier = "Repository"
    
    /// The domain name
    public static let name = "Repository Errors"
    
    /// The domain description
    public static let description = "Errors related to repository operations and data management"
    
    /// Common error categories in this domain
    public enum Category: String, ErrorCategory {
        /// Errors related to repository access
        case access = "Access"
        
        /// Errors related to repository data
        case data = "Data"
        
        /// Errors related to repository state
        case state = "State"
        
        /// Errors related to repository operations
        case operation = "Operation"
        
        /// The category description
        public var description: String {
            switch self {
            case .access:
                return "Errors occurring when accessing or opening repositories"
            case .data:
                return "Errors related to repository data integrity and operations"
            case .state:
                return "Errors related to the repository state and lifecycle"
            case .operation:
                return "Errors occurring during repository operations"
            }
        }
    }
    
    /// Map a RepositoryError to its category
    ///
    /// - Parameter error: The repository error
    /// - Returns: The error category
    public static func category(for error: RepositoryError) -> Category {
        switch error.errorType {
        case .repositoryNotFound, .repositoryOpenFailed, .repositoryLocked, .permissionDenied:
            return .access
        case .objectNotFound, .objectAlreadyExists, .objectCorrupt, .invalidObjectType, .invalidObjectData:
            return .data
        case .repositoryCorrupt, .invalidState:
            return .state
        case .saveFailed, .loadFailed, .deleteFailed, .timeout, .general:
            return .operation
        }
    }
}
