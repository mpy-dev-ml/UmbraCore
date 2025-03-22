import CoreDTOs
import Foundation

/// A protocol defining a Foundation-independent interface for network operations
public protocol NetworkServiceDTOProtocol: Sendable {
    /// Send a network request asynchronously
    /// - Parameter request: The request to send
    /// - Returns: A result containing either the response or an error
    func sendRequest(_ request: NetworkRequestDTO) async -> OperationResultDTO<NetworkResponseDTO>

    /// Download data from a URL
    /// - Parameters:
    ///   - urlString: The URL string to download from
    ///   - headers: Optional headers for the request
    /// - Returns: A result containing either the downloaded data or an error
    func downloadData(from urlString: String, headers: [String: String]?) async -> OperationResultDTO<[UInt8]>

    /// Download data with progress reporting
    /// - Parameters:
    ///   - urlString: The URL string to download from
    ///   - headers: Optional headers for the request
    ///   - progressHandler: A closure that will be called periodically with download progress
    /// - Returns: A result containing either the downloaded data or an error
    func downloadData(
        from urlString: String,
        headers: [String: String]?,
        progressHandler: @escaping (Double) -> Void
    ) async -> OperationResultDTO<[UInt8]>

    /// Upload data to a URL
    /// - Parameters:
    ///   - data: The data to upload
    ///   - urlString: The URL string to upload to
    ///   - method: The HTTP method to use (default: POST)
    ///   - headers: Optional headers for the request
    /// - Returns: A result containing either the server response or an error
    func uploadData(
        _ data: [UInt8],
        to urlString: String,
        method: NetworkRequestDTO.HTTPMethod,
        headers: [String: String]?
    ) async -> OperationResultDTO<NetworkResponseDTO>

    /// Upload data with progress reporting
    /// - Parameters:
    ///   - data: The data to upload
    ///   - urlString: The URL string to upload to
    ///   - method: The HTTP method to use (default: POST)
    ///   - headers: Optional headers for the request
    ///   - progressHandler: A closure that will be called periodically with upload progress
    /// - Returns: A result containing either the server response or an error
    func uploadData(
        _ data: [UInt8],
        to urlString: String,
        method: NetworkRequestDTO.HTTPMethod,
        headers: [String: String]?,
        progressHandler: @escaping (Double) -> Void
    ) async -> OperationResultDTO<NetworkResponseDTO>

    /// Checks if a URL is reachable
    /// - Parameter urlString: The URL string to check
    /// - Returns: A result containing either a boolean indicating reachability or an error
    func isReachable(urlString: String) async -> OperationResultDTO<Bool>
}
