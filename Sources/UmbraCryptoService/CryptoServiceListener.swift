import Core
import CoreErrors
import CryptoTypes
import CryptoTypesServices
import Foundation
import SecurityUtils
import UmbraCoreTypes
import UmbraKeychainService
import UmbraXPC
import XPC
import XPCProtocolsCore

/// XPC listener for the Crypto service
///
/// This class sets up an NSXPCListener to provide cryptographic
/// operations via XPC for client applications.
@available(macOS 14.0, *)
public final class CryptoServiceListener: NSObject, NSXPCListenerDelegate {
  /// The XPC listener instance
  private let listener: NSXPCListener

  /// Dependencies required by the cryptographic service
  private let dependencies: CryptoXPCServiceDependencies

  /// Service provider type for Swift Concurrency
  public static var serviceType: ModernCryptoXPCServiceProtocol.Type {
    ModernCryptoXPCServiceProtocol.self
  }

  /// Initialize a new crypto service listener
  /// - Parameter dependencies: Dependencies required by the service
  public init(dependencies: CryptoXPCServiceDependencies) {
    self.dependencies=dependencies
    listener=NSXPCListener(machServiceName: CryptoXPCService.protocolIdentifier)
    super.init()
    listener.delegate=self
  }

  /// Start the XPC listener
  public func start() {
    listener.resume()
  }

  /// Stop the XPC listener
  public func stop() {
    listener.suspend()
  }

  // MARK: - NSXPCListenerDelegate

  /// Configure the connection when a new client connects
  /// - Parameter newConnection: The new connection
  /// - Returns: A Boolean indicating whether the connection should proceed
  public func listener(
    _: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    // Create the service implementation
    let service=CryptoXPCService(dependencies: dependencies)
    service.connection=newConnection

    // Configure the connection
    newConnection.exportedInterface=NSXPCInterface(with: ModernCryptoXPCServiceProtocol.self)
    newConnection.exportedObject=service

    // Handle invalidation
    newConnection.invalidationHandler={
      service.connection=nil
    }

    // Resume the connection
    newConnection.resume()

    return true
  }
}

/// Start the XPC service in the main process
/// This function creates and starts the XPC listener
@available(macOS 14.0, *)
@MainActor
public func startService() {
  // Create and start the listener
  let dependencies=DefaultCryptoXPCServiceDependencies(
    securityUtils: SecurityUtils.shared,
    keychain: UmbraKeychainService(
      identifier: "com.umbracore.crypto.xpc"
    )
  )
  let listener=CryptoServiceListener(dependencies: dependencies)
  listener.start()

  // Run the main loop
  RunLoop.main.run()
}
