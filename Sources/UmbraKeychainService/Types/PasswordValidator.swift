import Foundation

/// A type that validates passwords against a set of requirements
public struct PasswordValidator {
    /// The requirements that passwords must meet
    public let requirements: PasswordRequirements

    /// Initialize a new password validator
    /// - Parameter requirements: The requirements to validate against
    public init(requirements: PasswordRequirements = .default) {
        self.requirements = requirements
    }

    /// Validate a password
    /// - Parameter password: The password to validate
    /// - Returns: The strength of the password if it meets all requirements
    /// - Throws: SecurityError if the password fails to meet requirements
    public func validate(_ password: String) throws -> PasswordStrength {
        // TODO: Implement password validation
        return .strong
    }
}

/// Requirements that passwords must meet
public struct PasswordRequirements: Sendable {
    /// Minimum length of the password
    public let minLength: Int

    /// Whether uppercase letters are required
    public let requiresUppercase: Bool

    /// Whether lowercase letters are required
    public let requiresLowercase: Bool

    /// Whether numbers are required
    public let requiresNumbers: Bool

    /// Whether special characters are required
    public let requiresSpecialCharacters: Bool

    /// Default password requirements
    public static let `default` = PasswordRequirements(
        minLength: 12,
        requiresUppercase: true,
        requiresLowercase: true,
        requiresNumbers: true,
        requiresSpecialCharacters: true
    )

    /// Initialize password requirements
    public init(
        minLength: Int = 12,
        requiresUppercase: Bool = true,
        requiresLowercase: Bool = true,
        requiresNumbers: Bool = true,
        requiresSpecialCharacters: Bool = true
    ) {
        self.minLength = minLength
        self.requiresUppercase = requiresUppercase
        self.requiresLowercase = requiresLowercase
        self.requiresNumbers = requiresNumbers
        self.requiresSpecialCharacters = requiresSpecialCharacters
    }
}

/// The strength of a password
public enum PasswordStrength: String, Sendable {
    /// Password is weak and should be changed
    case weak

    /// Password meets minimum requirements but could be stronger
    case medium

    /// Password exceeds minimum requirements
    case strong

    /// Password is very strong and exceeds all requirements
    case veryStrong
}
