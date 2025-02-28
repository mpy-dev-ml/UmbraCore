import CryptoKit
import Foundation
import SecurityInterfacesFoundationBridge
import SecurityObjCProtocols
import SecurityInterfacesFoundationBase

/// Concrete implementation of SecurityProviderFoundationImpl
@objc public final class DefaultSecurityProviderFoundationImpl: NSObject, SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl {

    public override init() {
        super.init()
    }

    // MARK: - Foundation Data Methods

    @objc public func encryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        do {
            // Use CryptoKit for encryption
            // This is a simple example using AES-GCM
            guard key.count == 32 else {
                throw NSError(domain: "SecurityProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid key size"])
            }

            let symmetricKey = SymmetricKey(data: key)
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)

            // Combine nonce and ciphertext
            var combinedData = Data()
            combinedData.append(nonce.withUnsafeBytes { Data($0) })
            combinedData.append(sealedBox.ciphertext)
            combinedData.append(sealedBox.tag)

            return combinedData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 2, userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(error.localizedDescription)"])
        }
    }

    @objc public func decryptData(_ data: Foundation.Data, key: Foundation.Data) async throws -> Foundation.Data {
        do {
            // Use CryptoKit for decryption
            guard key.count == 32 else {
                throw NSError(domain: "SecurityProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid key size"])
            }

            // Extract nonce, ciphertext, and tag
            let nonceSize = AES.GCM.Nonce().count
            let tagSize = AES.GCM.TAG_SIZE
            
            guard data.count > nonceSize + tagSize else {
                throw NSError(domain: "SecurityProvider", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid encrypted data format"])
            }
            
            let nonceData = data.prefix(nonceSize)
            let ciphertextData = data.dropFirst(nonceSize).dropLast(tagSize)
            let tagData = data.suffix(tagSize)
            
            let nonce = try AES.GCM.Nonce(data: nonceData)
            let symmetricKey = SymmetricKey(data: key)
            
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertextData, tag: tagData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            return decryptedData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 4, userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(error.localizedDescription)"])
        }
    }

    @objc public func generateDataKey(length: Int) async throws -> Foundation.Data {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
        }
        
        if result == errSecSuccess {
            return keyData
        } else {
            throw NSError(domain: "SecurityProvider", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to generate random key"])
        }
    }

    @objc public func hashData(_ data: Foundation.Data) async throws -> Foundation.Data {
        // Use SHA-256 for hashing
        let hash = SHA256.hash(data: data)
        return Data(hash)
    }

    // MARK: - Bookmark Methods

    @objc public func createBookmark(for url: URL) async throws -> Data {
        do {
            // Create a security-scoped bookmark
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmarkData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to create bookmark: \(error.localizedDescription)"])
        }
    }

    @objc public func resolveBookmark(_ bookmarkData: Data) async throws -> (url: URL, isStale: Bool) {
        do {
            // Validate a security-scoped bookmark
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            return (url, isStale)
        } catch {
            throw NSError(domain: "SecurityProvider", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to resolve bookmark: \(error.localizedDescription)"])
        }
    }

    @objc public func validateBookmark(_ bookmarkData: Data) async throws -> Bool {
        do {
            // Validate a security-scoped bookmark
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            return !isStale
        } catch {
            return false
        }
    }
}
