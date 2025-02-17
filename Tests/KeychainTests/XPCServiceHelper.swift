import Foundation
import XCTest
@testable import UmbraKeychainService

enum XPCError: Error {
    case serviceNotResponsive
}

/// Helper class for managing XPC service lifecycle in tests
@available(macOS 10.15, *)
final class XPCServiceHelper {
    private static let timeout: TimeInterval = 10.0
    private static let state = ServiceState()

    /// Manages XPC connections in a thread-safe manner
    private final class ConnectionManager {
        private let lock = NSLock()
        private var connections: [ObjectIdentifier: NSXPCConnection] = [:]

        func add(_ connection: NSXPCConnection) {
            lock.lock()
            defer { lock.unlock() }

            let identifier = ObjectIdentifier(connection)
            connections[identifier] = connection

            // Set up invalidation handler
            connection.invalidationHandler = { [weak self, weak connection] in
                guard let self = self, let connection = connection else { return }
                self.remove(connection)
            }
        }

        func remove(_ connection: NSXPCConnection) {
            lock.lock()
            defer { lock.unlock() }

            let identifier = ObjectIdentifier(connection)
            if connections.removeValue(forKey: identifier) != nil {
                connection.invalidate()
            }
        }

        func invalidateAll() {
            lock.lock()
            defer { lock.unlock() }

            for connection in connections.values {
                connection.invalidate()
            }
            connections.removeAll()
        }
    }

    private actor ServiceState {
        var isStarted = false
        var service: KeychainXPCService?
        private var startupTask: Task<KeychainXPCService, Error>?
        private let connectionManager = ConnectionManager()

        func start() async throws -> KeychainXPCService {
            if let existingService = service, isStarted {
                return existingService
            }

            // Cancel any existing startup task
            startupTask?.cancel()

            let task = Task {
                let newService = KeychainXPCService()
                service = newService

                let startTime = Date()
                while !newService.waitForStartup(timeout: 1.0) {
                    if Task.isCancelled { throw XPCError.serviceNotResponsive }
                    if Date().timeIntervalSince(startTime) >= timeout {
                        service = nil
                        throw XPCError.serviceNotResponsive
                    }
                    try await Task.sleep(nanoseconds: 100_000_000)
                }

                isStarted = true
                return newService
            }

            startupTask = task

            do {
                let result = try await task.value
                return result
            } catch {
                service = nil
                isStarted = false
                startupTask = nil
                throw error
            }
        }

        func stop() async {
            startupTask?.cancel()
            startupTask = nil

            // Invalidate all connections
            connectionManager.invalidateAll()

            guard let xpcService = service else { return }

            // Create a task with timeout for stopping
            let stopTask = Task {
                xpcService.stop()
                let startTime = Date()
                while xpcService.waitForStartup(timeout: 0.1) {
                    if Task.isCancelled { break }
                    if Date().timeIntervalSince(startTime) >= timeout { break }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
            }

            // Wait for stop with timeout
            _ = try? await withTimeout(seconds: timeout) {
                try await stopTask.value
            }

            stopTask.cancel()
            service = nil
            isStarted = false
        }

        func trackConnection(_ connection: NSXPCConnection) {
            connectionManager.add(connection)
        }

        func untrackConnection(_ connection: NSXPCConnection) {
            connectionManager.remove(connection)
        }

        var isRunning: Bool {
            isStarted && service?.waitForStartup(timeout: 0.1) == true
        }
    }

    static func startService() async throws {
        _ = try await state.start()
    }

    static func stopService() async {
        await state.stop()
    }

    static var service: KeychainXPCService? {
        get async {
            return await state.service
        }
    }

    static func isServiceRunning() async -> Bool {
        await state.isRunning
    }

    static func addConnection(_ connection: NSXPCConnection) async {
        await state.trackConnection(connection)
    }

    static func removeConnection(_ connection: NSXPCConnection) async {
        await state.untrackConnection(connection)
    }

    static func checkServiceResponsive(service: KeychainXPCService) async -> Bool {
        return service.waitForStartup(timeout: 1.0)
    }

    static func cleanupTestItems() async throws {
        guard let service = await state.service else {
            throw XPCError.serviceNotResponsive
        }

        let connection = KeychainXPCConnection(listener: service.listener)
        defer { connection.disconnect() }

        let proxy = try connection.connect()

        // Clean up all test accounts
        for index in 0...10 {
            let account = "testAccount_\(index)"
            do {
                try await proxy.deleteItem(account: account,
                                         service: "com.umbracore.tests",
                                         accessGroup: nil)
            } catch let error as KeychainError {
                // Only throw if it's not an itemNotFound error
                if case .itemNotFound = error {
                    continue
                }
                if case .unexpectedStatus(errSecMissingEntitlement) = error {
                    print("Warning: Missing entitlements for cleanup, skipping")
                    continue
                }
                throw error
            }
        }

        // Clean up main test account
        do {
            try await proxy.deleteItem(account: "testAccount",
                                     service: "com.umbracore.tests",
                                     accessGroup: nil)
        } catch let error as KeychainError {
            // Only throw if it's not an itemNotFound error
            if case .itemNotFound = error {
                return
            }
            if case .unexpectedStatus(errSecMissingEntitlement) = error {
                print("Warning: Missing entitlements for cleanup, skipping")
                return
            }
            throw error
        }
    }

    // Helper function for timeout
    private static func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError(seconds: seconds)
            }

            let result = try await group.next()
            group.cancelAll()
            return try result ?? { throw TimeoutError(seconds: seconds) }()
        }
    }

    // Custom error for timeout
    private struct TimeoutError: LocalizedError {
        let seconds: TimeInterval
        var errorDescription: String? {
            return "Operation timed out after \(seconds) seconds"
        }
    }
}
