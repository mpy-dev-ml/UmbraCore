import CryptoKit
import Foundation
import SecurityInterfacesFoundationBase
// Removed import SecurityInterfacesFoundationBridge to break circular dependency
import SecurityInterfacesMinimalBridge
import SecurityObjCProtocols

/// Concrete implementation of SecurityProviderFoundationImpl
@objc public final class DefaultSecurityProviderFoundationImpl: NSObject, SecurityInterfacesFoundationBase.SecurityProviderFoundationImpl {

    public override init() {
        super.init()
    }

    // MARK: - Foundation Data Methods

    @objc public func encryptData(_ data: NSData, key: NSData) async throws -> NSData {
        do {
            // Convert NSData to Data for CryptoKit
            let dataToEncrypt = Data(referencing: data)
            let keyData = Data(referencing: key)
            
            // Use CryptoKit for encryption
            // This is a simple example using AES-GCM
            guard keyData.count == 32 else {
                throw NSError(domain: "SecurityProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid key size"])
            }

            let symmetricKey = SymmetricKey(data: keyData)
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(dataToEncrypt, using: symmetricKey, nonce: nonce)

            // Combine nonce and ciphertext
            var combinedData = Data()
            combinedData.append(nonce.withUnsafeBytes { Data($0) })
            combinedData.append(sealedBox.ciphertext)
            combinedData.append(sealedBox.tag)

            // Convert back to NSData
            return combinedData as NSData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 2, userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(error.localizedDescription)"])
        }
    }

    @objc public func decryptData(_ data: NSData, key: NSData) async throws -> NSData {
        do {
            // Convert NSData to Data for CryptoKit
            let dataToDecrypt = Data(referencing: data)
            let keyData = Data(referencing: key)
            
            // Use CryptoKit for decryption
            guard keyData.count == 32 else {
                throw NSError(domain: "SecurityProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid key size"])
            }

            // Extract nonce, ciphertext, and tag
            let nonceSize = AES.GCM.Nonce().count
            let tagSize = AES.GCM.TAG_SIZE

            guard dataToDecrypt.count >= nonceSize + tagSize else {
                throw NSError(domain: "SecurityProvider", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid encrypted data format"])
            }

            let nonce = try AES.GCM.Nonce(data: dataToDecrypt.prefix(nonceSize))
            let ciphertextEndIndex = dataToDecrypt.count - tagSize
            let ciphertext = dataToDecrypt[nonceSize..<ciphertextEndIndex]
            let tag = dataToDecrypt[ciphertextEndIndex...]

            let symmetricKey = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

            // Convert back to NSData
            return decryptedData as NSData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 4, userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(error.localizedDescription)"])
        }
    }

    @objc public func generateDataKey(length: Int) async throws -> NSData {
        do {
            // Generate random bytes
            var keyData = Data(count: length)
            let result = keyData.withUnsafeMutableBytes { bytes in
                SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
            }

            guard result == errSecSuccess else {
                throw NSError(domain: "SecurityProvider", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to generate random key"])
            }

            // Convert to NSData
            return keyData as NSData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 6, userInfo: [NSLocalizedDescriptionKey: "Key generation failed: \(error.localizedDescription)"])
        }
    }

    @objc public func hashData(_ data: NSData) async throws -> NSData {
        do {
            // Convert NSData to Data for CryptoKit
            let dataToHash = Data(referencing: data)
            
            // Use SHA-256 for hashing
            let hash = SHA256.hash(data: dataToHash)
            let hashData = Data(hash)

            // Convert back to NSData
            return hashData as NSData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 7, userInfo: [NSLocalizedDescriptionKey: "Hashing failed: \(error.localizedDescription)"])
        }
    }

    // MARK: - Bookmark Methods

    @objc public func createBookmark(for url: URL) async throws -> NSData {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmarkData as NSData
        } catch {
            throw NSError(domain: "SecurityProvider", code: 8, userInfo: [NSLocalizedDescriptionKey: "Bookmark creation failed: \(error.localizedDescription)"])
        }
    }

    @objc public func resolveBookmark(_ bookmarkData: NSData) async throws -> (url: URL, isStale: Bool) {
        do {
            // Convert NSData to Data
            let data = Data(referencing: bookmarkData)
            
            var isStale = false
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            return (url, isStale)
        } catch {
            throw NSError(domain: "SecurityProvider", code: 9, userInfo: [NSLocalizedDescriptionKey: "Bookmark resolution failed: \(error.localizedDescription)"])
        }
    }

    @objc public func validateBookmark(_ bookmarkData: NSData) async throws -> Bool {
        do {
            let (_, isStale) = try await resolveBookmark(bookmarkData)
            return !isStale
        } catch {
            return false
        }
    }
}
