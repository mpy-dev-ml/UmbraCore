import Foundation

/// A Foundation-independent representation of a user defaults value.
public enum UserDefaultsValueDTO: Sendable, Equatable, Hashable {
    /// String value
    case string(String)
    /// Integer value
    case integer(Int)
    /// Double value
    case double(Double)
    /// Boolean value
    case boolean(Bool)
    /// Data value as bytes
    case data([UInt8])
    /// URL value as string
    case url(String)
    /// Date value as timestamp
    case date(TimeInterval)
    /// String array
    case stringArray([String])
    /// Dictionary with string keys and supported values
    case dictionary([String: UserDefaultsValueDTO])
    /// Array of supported values
    case array([UserDefaultsValueDTO])
    /// Null value
    case null
    
    // MARK: - Conversion Methods
    
    /// Get as string if possible
    public var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .integer(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .boolean(let value):
            return String(value)
        case .url(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Get as integer if possible
    public var integerValue: Int? {
        switch self {
        case .integer(let value):
            return value
        case .string(let value):
            return Int(value)
        case .double(let value):
            return Int(value)
        case .boolean(let value):
            return value ? 1 : 0
        default:
            return nil
        }
    }
    
    /// Get as double if possible
    public var doubleValue: Double? {
        switch self {
        case .double(let value):
            return value
        case .integer(let value):
            return Double(value)
        case .string(let value):
            return Double(value)
        case .boolean(let value):
            return value ? 1.0 : 0.0
        default:
            return nil
        }
    }
    
    /// Get as boolean if possible
    public var booleanValue: Bool? {
        switch self {
        case .boolean(let value):
            return value
        case .integer(let value):
            return value != 0
        case .string(let value):
            return value.lowercased() == "true" || value == "1"
        case .double(let value):
            return value != 0
        default:
            return nil
        }
    }
    
    /// Get as data if possible
    public var dataValue: [UInt8]? {
        if case .data(let value) = self {
            return value
        }
        return nil
    }
    
    /// Get as URL if possible
    public var urlValue: URL? {
        switch self {
        case .url(let value):
            return URL(string: value)
        case .string(let value):
            return URL(string: value)
        default:
            return nil
        }
    }
    
    /// Get as date if possible
    public var dateValue: Date? {
        if case .date(let value) = self {
            return Date(timeIntervalSince1970: value)
        }
        return nil
    }
    
    /// Get as string array if possible
    public var stringArrayValue: [String]? {
        switch self {
        case .stringArray(let value):
            return value
        case .array(let array):
            // Attempt to convert each element to string
            var strings: [String] = []
            for item in array {
                if let string = item.stringValue {
                    strings.append(string)
                } else {
                    return nil // Return nil if any element isn't convertible to string
                }
            }
            return strings
        default:
            return nil
        }
    }
    
    /// Get as dictionary if possible
    public var dictionaryValue: [String: UserDefaultsValueDTO]? {
        if case .dictionary(let value) = self {
            return value
        }
        return nil
    }
    
    /// Get as array if possible
    public var arrayValue: [UserDefaultsValueDTO]? {
        switch self {
        case .array(let value):
            return value
        case .stringArray(let strings):
            return strings.map { .string($0) }
        default:
            return nil
        }
    }
    
    /// Check if the value is null
    public var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
}
