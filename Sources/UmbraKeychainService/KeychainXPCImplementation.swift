import Foundation

@objc(KeychainXPCImplementation)
@available(macOS 14.0, *)
final class KeychainXPCImplementation: NSObject, KeychainXPCProtocol {
    private let keychain = KeychainService()
    private let queue = DispatchQueue(label: "com.umbracore.keychain.xpc", qos: .userInitiated)

    override init() {
        super.init()
    }

    func addItem(account: String,
                 service: String,
                 accessGroup: String?,
                 data: Data,
                 reply: @escaping (Error?) -> Void) {
        Task {
            do {
                try await keychain.addItem(account: account,
                                       service: service,
                                       accessGroup: accessGroup,
                                       data: data)
                queue.async { reply(nil) }
            } catch {
                queue.async { reply(error as? KeychainError ?? KeychainError.unknown) }
            }
        }
    }

    func updateItem(account: String,
                   service: String,
                   accessGroup: String?,
                   data: Data,
                   reply: @escaping (Error?) -> Void) {
        Task {
            do {
                try await keychain.updateItem(account: account,
                                          service: service,
                                          accessGroup: accessGroup,
                                          data: data)
                queue.async { reply(nil) }
            } catch {
                queue.async { reply(error as? KeychainError ?? KeychainError.unknown) }
            }
        }
    }

    func removeItem(account: String,
                   service: String,
                   accessGroup: String?,
                   reply: @escaping (Error?) -> Void) {
        Task {
            do {
                try await keychain.removeItem(account: account,
                                          service: service,
                                          accessGroup: accessGroup)
                queue.async { reply(nil) }
            } catch {
                queue.async { reply(error as? KeychainError ?? KeychainError.unknown) }
            }
        }
    }

    func containsItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping (Bool, Error?) -> Void) {
        Task {
            do {
                let exists = try await keychain.containsItem(account: account,
                                                         service: service,
                                                         accessGroup: accessGroup)
                queue.async { reply(exists, nil) }
            } catch {
                queue.async { reply(false, error as? KeychainError ?? KeychainError.unknown) }
            }
        }
    }

    func retrieveItem(account: String,
                     service: String,
                     accessGroup: String?,
                     reply: @escaping (Data?, Error?) -> Void) {
        Task {
            do {
                let data = try await keychain.retrieveItem(account: account,
                                                       service: service,
                                                       accessGroup: accessGroup)
                queue.async { reply(data, nil) }
            } catch {
                queue.async { reply(nil, error as? KeychainError ?? KeychainError.unknown) }
            }
        }
    }
}
