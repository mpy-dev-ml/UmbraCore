import Foundation
@testable import UmbraKeychainService

@objc
final class MockKeychainService: NSObject, KeychainXPCProtocol {
  private var storage: [String: Data] = [:]
  private let queue = DispatchQueue(label: "com.umbracore.mock-keychain", attributes: .concurrent)

  private func key(account: String, service: String, accessGroup: String?) -> String {
    [service, account, accessGroup].compactMap { $0 }.joined(separator: "_")
  }

  func addItem(
    account: String,
    service: String,
    accessGroup: String?,
    data: Data,
    reply: @escaping (Error?) -> Void
  ) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else { return }
      let key = key(account: account, service: service, accessGroup: accessGroup)
      if storage[key] != nil {
        reply(KeychainError.duplicateItem)
        return
      }
      storage[key] = data
      reply(nil)
    }
  }

  func updateItem(
    account: String,
    service: String,
    accessGroup: String?,
    data: Data,
    reply: @escaping (Error?) -> Void
  ) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else { return }
      let key = key(account: account, service: service, accessGroup: accessGroup)
      guard storage[key] != nil else {
        reply(KeychainError.itemNotFound)
        return
      }
      storage[key] = data
      reply(nil)
    }
  }

  func retrieveItem(
    account: String,
    service: String,
    accessGroup: String?,
    reply: @escaping (Data?, Error?) -> Void
  ) {
    queue.async { [weak self] in
      guard let self else { return }
      let key = key(account: account, service: service, accessGroup: accessGroup)
      guard let data = storage[key] else {
        reply(nil, KeychainError.itemNotFound)
        return
      }
      reply(data, nil)
    }
  }

  func containsItem(
    account: String,
    service: String,
    accessGroup: String?,
    reply: @escaping (Bool, Error?) -> Void
  ) {
    queue.async { [weak self] in
      guard let self else { return }
      let key = key(account: account, service: service, accessGroup: accessGroup)
      reply(storage[key] != nil, nil)
    }
  }

  func removeItem(
    account: String,
    service: String,
    accessGroup: String?,
    reply: @escaping (Error?) -> Void
  ) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else { return }
      let key = key(account: account, service: service, accessGroup: accessGroup)
      guard storage[key] != nil else {
        reply(KeychainError.itemNotFound)
        return
      }
      storage.removeValue(forKey: key)
      reply(nil)
    }
  }

  func removeAllItems(reply: @escaping (Error?) -> Void) {
    queue.async(flags: .barrier) { [weak self] in
      self?.storage.removeAll()
      reply(nil)
    }
  }

  // Test helper methods
  func reset() {
    queue.async(flags: .barrier) { [weak self] in
      self?.storage.removeAll()
    }
  }
}
