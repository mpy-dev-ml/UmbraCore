import Foundation

@objc(KeychainXPCImplementation)
final class KeychainXPCImplementation: NSObject, KeychainXPCProtocol {
    private let keychain = KeychainService()
    private let queue = DispatchQueue(label: "com.umbracore.keychain.impl",
                                    qos: .userInitiated)

    func addItem(_ data: Data,
                 account: String,
                 service: String,
                 accessGroup: String?,
                 accessibility: String,
                 flags: Int,
                 withReply reply: @escaping (Error?) -> Void) {
        queue.async {
            Task {
                do {
                    // Create SecAccessControlCreateFlags from raw value
                    let accessFlags = SecAccessControlCreateFlags(rawValue: UInt(flags))

                    // Create SecAccessControl
                    var error: Unmanaged<CFError>?
                    guard let access = SecAccessControlCreateWithFlags(
                        kCFAllocatorDefault,
                        accessibility as CFString,
                        accessFlags,
                        &error
                    ) else {
                        if let error = error?.takeRetainedValue() {
                            print("Failed to create access control: \(error)")
                        }
                        reply(KeychainError.unexpectedStatus(errSecParam))
                        return
                    }

                    // Create query with access control
                    var query: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrAccount as String: account,
                        kSecAttrService as String: service,
                        kSecValueData as String: data,
                        kSecAttrAccessControl as String: access
                    ]

                    if let accessGroup = accessGroup {
                        query[kSecAttrAccessGroup as String] = accessGroup
                    }

                    // Add item to keychain
                    let status = SecItemAdd(query as CFDictionary, nil)
                    if status == errSecDuplicateItem {
                        reply(KeychainError.duplicateItem)
                        return
                    }
                    guard status == errSecSuccess else {
                        reply(KeychainError.unexpectedStatus(status))
                        return
                    }

                    reply(nil)
                } catch {
                    reply(error)
                }
            }
        }
    }

    func readItem(account: String,
                  service: String,
                  accessGroup: String?,
                  withReply reply: @escaping (Data?, Error?) -> Void) {
        queue.async {
            Task {
                do {
                    let data = try await self.keychain.readItem(account: account,
                                                              service: service,
                                                              accessGroup: accessGroup)
                    reply(data, nil)
                } catch {
                    reply(nil, error)
                }
            }
        }
    }

    func updateItem(_ data: Data,
                   account: String,
                   service: String,
                   accessGroup: String?,
                   withReply reply: @escaping (Error?) -> Void) {
        queue.async {
            Task {
                do {
                    try await self.keychain.updateItem(data,
                                                     account: account,
                                                     service: service,
                                                     accessGroup: accessGroup)
                    reply(nil)
                } catch {
                    reply(error)
                }
            }
        }
    }

    func deleteItem(account: String,
                   service: String,
                   accessGroup: String?,
                   withReply reply: @escaping (Error?) -> Void) {
        queue.async {
            Task {
                do {
                    try await self.keychain.deleteItem(account: account,
                                                     service: service,
                                                     accessGroup: accessGroup)
                    reply(nil)
                } catch {
                    reply(error)
                }
            }
        }
    }

    func containsItem(account: String,
                     service: String,
                     accessGroup: String?,
                     withReply reply: @escaping (Bool, Error?) -> Void) {
        queue.async {
            Task {
                let exists = await self.keychain.containsItem(account: account,
                                                            service: service,
                                                            accessGroup: accessGroup)
                reply(exists, nil)
            }
        }
    }
}
