import Foundation

/// XPC service for secure keychain operations
@objc public protocol KeychainXPCProtocol {
    /// Add a new item to the keychain
    func addItem(account: String,
                service: String,
                accessGroup: String?,
                data: Data,
                reply: @escaping @Sendable (Error?) -> Void)

    /// Update an existing item in the keychain
    func updateItem(account: String,
                   service: String,
                   accessGroup: String?,
                   data: Data,
                   reply: @escaping @Sendable (Error?) -> Void)

    /// Remove an item from the keychain
    func removeItem(account: String,
                   service: String,
                   accessGroup: String?,
                   reply: @escaping @Sendable (Error?) -> Void)

    /// Check if an item exists in the keychain
    func containsItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping @Sendable (Bool, Error?) -> Void)

    /// Retrieve an item from the keychain
    func retrieveItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping @Sendable (Data?, Error?) -> Void)
}

extension KeychainXPCProtocol {
    func addItem(account: String,
                service: String,
                accessGroup: String?,
                data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            addItem(account: account,
                   service: service,
                   accessGroup: accessGroup,
                   data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func updateItem(account: String,
                   service: String,
                   accessGroup: String?,
                   data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            updateItem(account: account,
                      service: service,
                      accessGroup: accessGroup,
                      data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func removeItem(account: String,
                   service: String,
                   accessGroup: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            removeItem(account: account,
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
                     accessGroup: String?) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            containsItem(account: account,
                        service: service,
                        accessGroup: accessGroup) { exists, _ in
                continuation.resume(returning: exists)
            }
        }
    }

    func retrieveItem(account: String,
                     service: String,
                     accessGroup: String?) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            retrieveItem(account: account,
                        service: service,
                        accessGroup: accessGroup) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: KeychainError.invalidData)
                }
            }
        }
    }
}

final class KeychainXPCService: NSObject {
    private(set) var listener: NSXPCListener
    private let exportedObject: KeychainXPCProtocol
    private let startupSemaphore = DispatchSemaphore(value: 0)

    private let stateQueue = DispatchQueue(label: "com.umbracore.xpc.state")
    private var _isStarted = false

    private var isStarted: Bool {
        get { stateQueue.sync { _isStarted } }
        set { stateQueue.sync { _isStarted = newValue } }
    }

    override init() {
        self.listener = NSXPCListener.anonymous()
        self.exportedObject = KeychainXPCImplementation()
        super.init()
        self.listener.delegate = self
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true
        listener.resume()
        startupSemaphore.signal()
    }

    func stop() {
        guard isStarted else { return }
        isStarted = false
        listener.invalidate()
    }

    func waitForStartup(timeout: TimeInterval) -> Bool {
        return startupSemaphore.wait(timeout: .now() + timeout) == .success
    }
}

extension KeychainXPCService: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // This is called on the main thread by XPC
        guard isStarted else { return false }

        newConnection.exportedInterface = NSXPCInterface(with: KeychainXPCProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()

        return true
    }
}

private final class AtomicBool {
    private var _value: Bool
    private let lock = NSLock()

    init(_ value: Bool) {
        self._value = value
    }

    var value: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func setValue(_ newValue: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _value = newValue
    }
}
