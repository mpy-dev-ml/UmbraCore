import Foundation
import UmbraCoreTypes

// MARK: - Network DTO Converters for Foundation Types

public extension NetworkRequestDTO {
    /// Create a URLRequest from this NetworkRequestDTO
    /// - Returns: A URLRequest configured with the contents of this DTO
    func toURLRequest() -> URLRequest? {
        // Validate URL
        guard let url = URL(string: url) else {
            return nil
        }
        
        // Create base request with URL
        var request = URLRequest(url: url)
        
        // Set HTTP method
        request.httpMethod = httpMethod
        
        // Add headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add query parameters if present
        if !queryParameters.isEmpty {
            // Check if URL already has query components
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            // Build query items
            var queryItems = [URLQueryItem]()
            for (key, value) in queryParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            // Append to any existing query items
            if let existingItems = urlComponents?.queryItems {
                queryItems.append(contentsOf: existingItems)
            }
            
            urlComponents?.queryItems = queryItems
            
            // Update URL if we have a valid one with query parameters
            if let updatedURL = urlComponents?.url {
                request.url = updatedURL
            }
        }
        
        // Set body data if present
        if !bodyData.isEmpty {
            request.httpBody = Data(bodyData)
        }
        
        // Set timeout
        request.timeoutInterval = TimeInterval(timeoutSeconds)
        
        // Set cache policy
        if let cacheStr = metadata["cachePolicy"], let cacheValue = Int(cacheStr) {
            // Use the numeric value if provided
            if let cachePolicy = URLRequest.CachePolicy(rawValue: UInt(cacheValue)) {
                request.cachePolicy = cachePolicy
            }
        } else if let cacheStr = metadata["cachePolicy"] {
            // Parse string representation
            switch cacheStr.lowercased() {
            case "usecacheifsynchronous", "usecacheifsynchronized":
                request.cachePolicy = .returnCacheDataElseLoad
            case "skiplocal", "skiplocacache":
                request.cachePolicy = .reloadIgnoringLocalCacheData
            case "returnLocal", "returncache":
                request.cachePolicy = .returnCacheDataDontLoad
            default:
                request.cachePolicy = .useProtocolCachePolicy
            }
        }
        
        // Set authentication
        if authType == "basic", let username = metadata["username"], let password = metadata["password"] {
            let loginString = "\(username):\(password)"
            guard let loginData = loginString.data(using: .utf8) else {
                return request
            }
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        } else if authType == "bearer", let token = metadata["token"] {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if authType == "custom", let authHeader = metadata["authorizationHeader"] {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// Create a NetworkRequestDTO from a URLRequest
    /// - Parameter urlRequest: The URLRequest to convert
    /// - Returns: A NetworkRequestDTO configured from the URLRequest
    static func fromURLRequest(_ urlRequest: URLRequest) -> NetworkRequestDTO {
        // Extract URL
        let urlString = urlRequest.url?.absoluteString ?? ""
        
        // Extract HTTP method
        let method = urlRequest.httpMethod ?? "GET"
        
        // Extract headers
        var headers = [String: String]()
        if let allHeaders = urlRequest.allHTTPHeaderFields {
            headers = allHeaders
        }
        
        // Extract query parameters
        var queryParams = [String: String]()
        if let url = urlRequest.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            for item in queryItems {
                queryParams[item.name] = item.value ?? ""
            }
        }
        
        // Extract body data
        var bodyData = [UInt8]()
        if let httpBody = urlRequest.httpBody {
            bodyData = [UInt8](httpBody)
        }
        
        // Extract timeout
        let timeout = Int(urlRequest.timeoutInterval)
        
        // Extract authentication type and credentials
        var authType = "none"
        var metadata = [String: String]()
        
        // Add cache policy
        metadata["cachePolicy"] = String(urlRequest.cachePolicy.rawValue)
        
        // Determine auth type if present
        if let authHeader = headers["Authorization"] ?? headers["authorization"] {
            if authHeader.starts(with: "Basic ") {
                authType = "basic"
                // Could extract username/password but not necessary and secure
                metadata["authPresent"] = "true"
            } else if authHeader.starts(with: "Bearer ") {
                authType = "bearer"
                // Could extract token but not necessary and secure
                metadata["authPresent"] = "true"
            } else {
                authType = "custom"
                metadata["authPresent"] = "true"
            }
        }
        
        // Generate unique request ID if needed
        let requestId = UUID().uuidString
        
        return NetworkRequestDTO(
            requestId: requestId,
            url: urlString,
            httpMethod: method,
            headers: headers,
            queryParameters: queryParams,
            bodyData: bodyData,
            timeoutSeconds: timeout > 0 ? timeout : 60,
            authType: authType,
            metadata: metadata
        )
    }
}

public extension NetworkResponseDTO {
    /// Create an HTTPURLResponse from this NetworkResponseDTO
    /// - Parameter request: The original URLRequest
    /// - Returns: An HTTPURLResponse configured from this DTO
    func toHTTPURLResponse(for request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else {
            return nil
        }
        
        // Create HTTP URL Response
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )
    }
    
    /// Create a NetworkResponseDTO from an HTTPURLResponse
    /// - Parameters:
    ///   - response: The HTTPURLResponse to convert
    ///   - data: The response data
    ///   - requestId: The ID of the original request
    ///   - duration: The duration of the request in seconds
    ///   - timestamp: The timestamp when the response was received
    /// - Returns: A NetworkResponseDTO configured from the response
    static func fromHTTPURLResponse(
        _ response: HTTPURLResponse,
        data: Data,
        requestId: String,
        duration: Double,
        timestamp: UInt64,
        isFromCache: Bool = false
    ) -> NetworkResponseDTO {
        // Extract status code and message
        let statusCode = response.statusCode
        
        // Generate status message based on code
        let statusMessage: String
        switch statusCode {
        case 200: statusMessage = "OK"
        case 201: statusMessage = "Created"
        case 204: statusMessage = "No Content"
        case 400: statusMessage = "Bad Request"
        case 401: statusMessage = "Unauthorized"
        case 403: statusMessage = "Forbidden"
        case 404: statusMessage = "Not Found"
        case 500: statusMessage = "Internal Server Error"
        default: statusMessage = "HTTP Status \(statusCode)"
        }
        
        // Extract headers
        let headers = response.allHeaderFields as? [String: String] ?? [:]
        
        // Convert body data
        let bodyData = [UInt8](data)
        
        // Extract MIME type and text encoding
        let mimeType = response.mimeType
        let textEncodingName = response.textEncodingName
        
        return NetworkResponseDTO(
            requestId: requestId,
            statusCode: statusCode,
            statusMessage: statusMessage,
            headers: headers,
            bodyData: bodyData,
            mimeType: mimeType,
            textEncodingName: textEncodingName,
            isFromCache: isFromCache,
            duration: max(0.0, duration),
            timestamp: timestamp
        )
    }
    
    /// Convert the response body to a Foundation Data object
    /// - Returns: Data object from the response body
    func bodyAsData() -> Data {
        Data(bodyData)
    }
}

// MARK: - OperationProgressDTO Extensions for Network

public extension OperationProgressDTO {
    /// Create a progress DTO for a network operation
    /// - Parameters:
    ///   - bytesTransferred: Bytes transferred so far
    ///   - totalBytes: Total bytes to transfer (if known)
    ///   - requestId: ID of the network request
    ///   - isUpload: Whether this is an upload or download
    ///   - timestamp: Current timestamp
    /// - Returns: A NetworkProgressDTO representing the operation's progress
    static func forNetworkOperation(
        bytesTransferred: Int64,
        totalBytes: Int64?,
        requestId: String,
        isUpload: Bool,
        timestamp: UInt64
    ) -> OperationProgressDTO {
        // Calculate percentage if we know the total
        let percentage: Double
        if let total = totalBytes, total > 0 {
            percentage = min(100.0, Double(bytesTransferred) / Double(total) * 100.0)
        } else {
            percentage = -1  // Indeterminate
        }
        
        // Determine operation type
        let operationType = isUpload ? "network.upload" : "network.download"
        
        // Create operation progress
        return OperationProgressDTO(
            operationType: operationType,
            percentage: percentage,
            message: isUpload ? "Uploading data..." : "Downloading data...",
            timestamp: timestamp,
            operationId: requestId
        ).withMetadata([
            "bytesTransferred": String(bytesTransferred),
            "totalBytes": totalBytes != nil ? String(totalBytes!) : "unknown",
            "requestId": requestId,
            "isUpload": isUpload ? "true" : "false"
        ])
    }
}
