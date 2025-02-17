import Foundation

public struct SecureStorageData: Codable {
    public let encryptedData: Data
    public let iv: Data
    
    public init(encryptedData: Data, iv: Data) {
        self.encryptedData = encryptedData
        self.iv = iv
    }
}
