import Foundation

final class KeychainXPCConnection {
    private var connection: NSXPCConnection?
    private let queue = DispatchQueue(label: "com.umbracore.keychain.connection",
                                    qos: .userInitiated)
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

// MARK: - Async Extensions
extension KeychainXPCProtocol {
    func addItem(_ data: Data,
                 account: String,
                 service: String,
                 accessGroup: String?,
                 accessibility: String,
                 flags: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            addItem(data,
                   account: account,
                   service: service,
                   accessGroup: accessGroup,
                   accessibility: accessibility,
                   flags: flags) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func readItem(account: String,
                  service: String,
                  accessGroup: String?) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            readItem(account: account,
                    service: service,
                    accessGroup: accessGroup) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: KeychainError.itemNotFound)
                }
            }
        }
    }

    func updateItem(_ data: Data,
                   account: String,
                   service: String,
                   accessGroup: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            updateItem(data,
                      account: account,
                      service: service,
                      accessGroup: accessGroup) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func deleteItem(account: String,
                   service: String,
                   accessGroup: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            deleteItem(account: account,
                      service: service,
                      accessGroup: accessGroup) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func containsItem(account: String,
                     service: String,
                     accessGroup: String?) async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            containsItem(account: account,
                        service: service,
                        accessGroup: accessGroup) { exists, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: exists)
                }
            }
        }
    }
}
