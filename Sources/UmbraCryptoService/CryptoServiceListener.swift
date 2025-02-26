import Core
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraKeychainService
import UmbraXPC
import XPC

@available(macOS 14.0, *)
@MainActor
public final class CryptoServiceListener: NSObject, NSXPCListenerDelegate {
    private let listener: NSXPCListener
    private let cryptoService: CryptoXPCService

    public override init() {
        // Initialize dependencies
        let dependencies = DefaultCryptoXPCServiceDependencies(
            securityUtils: SecurityUtils.shared,
            keychain: UmbraKeychainService(
                identifier: "com.umbracore.crypto.xpc"
            )
        )

        // Initialize service
        self.cryptoService = CryptoXPCService(dependencies: dependencies)

        // Create and configure listener
        self.listener = NSXPCListener(machServiceName: "com.umbracore.crypto.xpc")
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

    nonisolated public func listener(
        _ listener: NSXPCListener,
        shouldAcceptNewConnection connection: NSXPCConnection
    ) -> Bool {
        Task { @MainActor in
            // Configure the connection
            let interface = NSXPCInterface(with: CryptoXPCServiceProtocol.self)

            // Set up the connection interfaces
            connection.exportedInterface = interface
            connection.exportedObject = cryptoService

            // Configure remote interface
            connection.remoteObjectInterface = NSXPCInterface(with: CryptoXPCServiceProtocol.self)

            // Resume the connection
            connection.resume()

            // Store the connection
            cryptoService.connection = connection

            // Set up error handling
            connection.invalidationHandler = {
                print("[CryptoService] Connection invalidated")
            }

            connection.interruptionHandler = {
                print("[CryptoService] Connection interrupted")
            }
        }

        return true
    }
}

// MARK: - Main Entry Point
@available(macOS 14.0, *)
@MainActor
public func startService() {
    // Create and start the listener
    let listener = CryptoServiceListener()
    listener.start()

    // Run the main loop
    dispatchMain()
}
