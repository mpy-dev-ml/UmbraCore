import Foundation

final class KeychainXPCConnection {
    private var connection: NSXPCConnection?
    private let queue = DispatchQueue(
        label: "com.umbracore.keychain.connection",
        qos: .userInitiated
    )
    private let semaphore = DispatchSemaphore(value: 1)
    private let listener: NSXPCListener?
    private var isInvalidated = false

    init(listener: NSXPCListener? = nil) {
        self.listener = listener
    }

    func connect() throws -> any KeychainXPCProtocol {
        semaphore.wait()
        defer { semaphore.signal() }

        // Check if connection was invalidated
        if isInvalidated {
            throw KeychainError.xpcConnectionFailed
        }

        // Check existing connection
        if let existingConnection = connection,
           let proxy = existingConnection.remoteObjectProxy as? any KeychainXPCProtocol {
            return proxy
        }

        // Create new connection
        let newConnection: NSXPCConnection
        if let listener = listener {
            newConnection = NSXPCConnection(listenerEndpoint: listener.endpoint)
        } else {
            newConnection = NSXPCConnection(serviceName: "com.umbracore.keychain")
        }

        newConnection.remoteObjectInterface = NSXPCInterface(with: KeychainXPCProtocol.self)

        // Set up error handling
        newConnection.invalidationHandler = { [weak self] in
            self?.handleConnectionError()
        }

        newConnection.interruptionHandler = { [weak self] in
            self?.handleConnectionError()
        }

        // Start the connection
        newConnection.resume()

        guard let proxy = newConnection.remoteObjectProxy as? any KeychainXPCProtocol else {
            throw KeychainError.xpcConnectionFailed
        }

        connection = newConnection
        isInvalidated = false
        return proxy
    }

    private func handleConnectionError() {
        semaphore.wait()
        defer { semaphore.signal() }

        if let connection = connection {
            connection.invalidate()
        }
        connection = nil
        isInvalidated = true
    }

    func disconnect() {
        semaphore.wait()
        defer { semaphore.signal() }

        if let connection = connection {
            connection.invalidate()
        }
        connection = nil
        isInvalidated = true
    }

    deinit {
        disconnect()
    }
}

// MARK: - KeychainXPCProtocol Implementation
extension KeychainXPCConnection: KeychainXPCProtocol {
    func addItem(account: String,
                service: String,
                accessGroup: String?,
                data: Data,
                reply: @escaping @Sendable (Error?) -> Void) {
        // Implementation
    }

    func updateItem(account: String,
                   service: String,
                   accessGroup: String?,
                   data: Data,
                   reply: @escaping @Sendable (Error?) -> Void) {
        // Implementation
    }

    func removeItem(account: String,
                   service: String,
                   accessGroup: String?,
                   reply: @escaping @Sendable (Error?) -> Void) {
        // Implementation
    }

    func containsItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Implementation
    }

    func retrieveItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping @Sendable (Data?, Error?) -> Void) {
        // Implementation
    }
}
