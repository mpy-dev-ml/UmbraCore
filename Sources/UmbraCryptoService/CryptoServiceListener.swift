import Core
import Foundation
import UmbraXPC
import XPC

@available(macOS 14.0, *)
@MainActor
public final class CryptoServiceListener: NSObject, NSXPCListenerDelegate {
    private let listener: NSXPCListener
    private let cryptoService: CryptoXPCService

    public init(machServiceName: String) {
        self.listener = NSXPCListener(machServiceName: machServiceName)
        self.cryptoService = CryptoXPCService()
        super.init()
        self.listener.delegate = self
    }

    public func start() {
        listener.resume()
    }

    public func stop() {
        listener.suspend()
    }

    // MARK: - NSXPCListenerDelegate

    nonisolated public func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        Task { @MainActor in
            // Configure the connection
            connection.exportedInterface = NSXPCInterface(with: Core.CryptoXPCServiceProtocol.self)

            // Create and set the exported object
            connection.exportedObject = cryptoService

            // Set up error handling
            connection.invalidationHandler = {
                print("[CryptoService] Connection invalidated")
            }

            connection.interruptionHandler = {
                print("[CryptoService] Connection interrupted")
            }

            // Start the connection
            connection.resume()
        }

        return true
    }
}

// MARK: - Main Entry Point
@available(macOS 14.0, *)
@MainActor
public func startService() {
    // Create and start the listener
    let listener = CryptoServiceListener(machServiceName: "com.umbracore.cryptoservice")
    listener.start()

    // Run the main loop
    dispatchMain()
}
