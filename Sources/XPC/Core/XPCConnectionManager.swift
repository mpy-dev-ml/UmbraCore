import Foundation

@available(macOS 14.0, *)
public actor XPCConnectionManager {
    private var connections: [String: NSXPCConnection] = [:]
    private let serviceName: String
    private let interfaceProtocol: Protocol

    public init(serviceName: String, interfaceProtocol: Protocol) {
        self.serviceName = serviceName
        self.interfaceProtocol = interfaceProtocol
    }

    public func connection() async throws -> NSXPCConnection {
        if let existingConnection = connections[serviceName] {
            return existingConnection
        }

        return try await createNewConnection()
    }

    private func createNewConnection() async throws -> NSXPCConnection {
        let connection = NSXPCConnection(serviceName: serviceName)

        // Configure the connection
        connection.remoteObjectInterface = NSXPCInterface(with: interfaceProtocol)

        // Set up error handling
        let serviceName = self.serviceName // Capture in local variable
        let weakSelf = self as XPCConnectionManager? // Capture as optional for weak reference
        connection.invalidationHandler = { [serviceName] in
            // Create a new detached task to avoid potential data races
            Task.detached {
                if let strongSelf = weakSelf {
                    await strongSelf.handleInvalidation(for: serviceName)
                }
            }
        }

        connection.interruptionHandler = { [serviceName] in
            // Create a new detached task to avoid potential data races
            Task.detached {
                if let strongSelf = weakSelf {
                    await strongSelf.handleInterruption(for: serviceName)
                }
            }
        }

        // Resume the connection
        connection.resume()

        // Store the connection
        connections[serviceName] = connection

        return connection
    }

    private func handleInvalidation(for serviceName: String) {
        connections.removeValue(forKey: serviceName)
    }

    private func handleInterruption(for serviceName: String) {
        // Handle interruption - could implement retry logic here
        connections.removeValue(forKey: serviceName)
    }

    public func invalidateConnection(for serviceName: String) {
        if let connection = connections.removeValue(forKey: serviceName) {
            connection.invalidate()
        }
    }

    public func invalidateAll() {
        // Take a snapshot of the connections to avoid mutation during iteration
        let connectionsToInvalidate = connections
        connections.removeAll()

        for connection in connectionsToInvalidate.values {
            connection.invalidate()
        }
    }

    deinit {
        // Note: We can't use async/await in deinit, so we'll invalidate synchronously
        // Take a snapshot of the connections to avoid mutation during iteration
        let connectionsToInvalidate = connections
        connections.removeAll()

        for connection in connectionsToInvalidate.values {
            connection.invalidate()
        }
    }
}
