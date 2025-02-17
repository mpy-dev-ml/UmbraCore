import Foundation

/// XPC service for secure keychain operations
@objc public protocol KeychainXPCProtocol {
    func addItem(_ data: Data,
                 account: String,
                 service: String,
                 accessGroup: String?,
                 accessibility: String,
                 flags: Int,
                 withReply reply: @escaping (Error?) -> Void)

    func readItem(account: String,
                  service: String,
                  accessGroup: String?,
                  withReply reply: @escaping (Data?, Error?) -> Void)

    func updateItem(_ data: Data,
                    account: String,
                    service: String,
                    accessGroup: String?,
                    withReply reply: @escaping (Error?) -> Void)

    func deleteItem(account: String,
                    service: String,
                    accessGroup: String?,
                    withReply reply: @escaping (Error?) -> Void)

    func containsItem(account: String,
                      service: String,
                      accessGroup: String?,
                      withReply reply: @escaping (Bool, Error?) -> Void)
}

final class KeychainXPCService: NSObject {
    private(set) var listener: NSXPCListener
    private let queue = DispatchQueue(label: "com.umbracore.keychain.service",
                                    qos: .userInitiated)
    private let startupSemaphore = DispatchSemaphore(value: 0)
    private var isRunning = false
    private let exportedObject: KeychainXPCProtocol
    private var activeConnections = Set<NSXPCConnection>()
    private let connectionQueue = DispatchQueue(label: "com.umbracore.keychain.service.connections",
                                              qos: .userInitiated)

    override init() {
        listener = NSXPCListener.anonymous()
        exportedObject = KeychainXPCImplementation()
        super.init()
        listener.delegate = self
    }

    func start() {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard !self.isRunning else { return }

            self.listener.resume()
            self.isRunning = true
            self.startupSemaphore.signal()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard self.isRunning else { return }

            // Invalidate all active connections
            self.connectionQueue.sync {
                for connection in self.activeConnections {
                    connection.invalidate()
                }
                self.activeConnections.removeAll()
            }

            self.listener.suspend()
            self.isRunning = false
        }
    }

    func waitForStartup(timeout: TimeInterval) -> Bool {
        return startupSemaphore.wait(timeout: .now() + timeout) == .success
    }

    private func handleConnectionError(_ connection: NSXPCConnection) {
        connectionQueue.async { [weak self] in
            self?.activeConnections.remove(connection)
        }
    }
}

extension KeychainXPCService: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener,
                 shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // Configure the connection
        newConnection.exportedInterface = NSXPCInterface(with: KeychainXPCProtocol.self)
        newConnection.exportedObject = exportedObject

        // Set up error handling
        newConnection.invalidationHandler = { [weak self, weak newConnection] in
            guard let connection = newConnection else { return }
            self?.handleConnectionError(connection)
        }

        newConnection.interruptionHandler = { [weak self, weak newConnection] in
            guard let connection = newConnection else { return }
            self?.handleConnectionError(connection)
        }

        // Track the connection
        _ = connectionQueue.sync {
            activeConnections.insert(newConnection)
        }

        // Resume the connection
        newConnection.resume()

        return true
    }
}
