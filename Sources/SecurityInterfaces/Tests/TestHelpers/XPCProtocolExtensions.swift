import Foundation
import SecurityInterfaces
import XPCProtocolsCore

/// Extension to provide standard protocol adapters for the mock XPC services
public extension MockXPCService {
    /// Convert this mock service to an XPCServiceProtocolStandard
    /// - Returns: An adapter implementing XPCServiceProtocolStandard
    func asXPCServiceProtocolStandard() -> any XPCServiceProtocolStandard {
        MockXPCServiceStandardAdapter(wrapping: self)
    }
}

/// Standard protocol adapter for MockXPCService
/// Bridges the gap between the SecurityInterfaces.XPCServiceProtocol and XPCServiceProtocolStandard
private final class MockXPCServiceStandardAdapter: XPCServiceProtocolStandard {
    /// The underlying service being wrapped
    private let service: MockXPCService

    /// Creates a new adapter wrapping a mock service
    /// - Parameter service: The service to wrap
    init(wrapping service: MockXPCService) {
        self.service = service
    }

    // MARK: - XPCServiceProtocolBasic Implementation

    public func ping() async -> Bool {
        await service.ping()
    }

    public func getStatus() async -> XPCProtocolTypeDefs.ServiceStatusInfo {
        XPCProtocolTypeDefs.ServiceStatusInfo(
            status: XPCProtocolTypeDefs.ServiceStatus.operational.rawValue,
            details: "Mock service is operational",
            protocolVersion: "1.0"
        )
    }

    public func generateRandomBytes(count: Int) async -> Result<Data, XPCProtocolsCore.SecurityError> {
        // Generate random bytes for testing
        var bytes = [UInt8](repeating: 0, count: count)
        for i in 0 ..< count {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
        return .success(Data(bytes))
    }

    // MARK: - XPCServiceProtocolStandard Implementation

    public func status() async -> Result<[String: Any], XPCProtocolsCore.SecurityError> {
        guard let status = await service.getServiceStatus() else {
            return .failure(.internalError(operation: "status", details: "Failed to get service status"))
        }
        return .success(status)
    }

    public func getHardwareIdentifier() async -> Result<String, XPCProtocolsCore.SecurityError> {
        let result = await TaskCompletionSource<Result<String, Error>> {
            service.getHostIdentifier(completion: $0)
        }

        switch result {
        case let .success(id):
            return .success(id)
        case let .failure(error):
            return .failure(.internalError(operation: "getHardwareIdentifier", details: error.localizedDescription))
        }
    }

    public func getServiceVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
        guard let version = await service.getServiceVersion() else {
            return .failure(.internalError(operation: "getServiceVersion", details: "Failed to get service version"))
        }
        return .success(version)
    }
}

/// A simple Task-based completion source for converting callback-based APIs to async
/// This is similar to TaskCompletionSource in Swift Concurrency, but simpler for our testing needs
private func TaskCompletionSource<T>(_ operation: @escaping (@escaping (T) -> Void) -> Void) async -> T {
    await withCheckedContinuation { continuation in
        operation { result in
            continuation.resume(returning: result)
        }
    }
}
