import UmbraCryptoService
import SecurityUtils
import UmbraKeychainService
import SecurityTypes
import Foundation
import CommonCrypto
import Security

/// Mock implementation of CryptoXPCServiceDependencies for testing
final class MockCryptoXPCServiceDependencies: CryptoXPCServiceDependencies {
    public let securityUtils: SecurityUtils
    public let keychain: UmbraKeychainService
    
    init() {
        self.securityUtils = SecurityUtils.shared
        self.keychain = MockKeychainService()
    }
}

/// Mock implementation of UmbraKeychainService for testing
class MockKeychainService: UmbraKeychainService {
    init() {
        super.init(identifier: "com.umbra.test.keychain")
    }
    
    // Override methods as needed for testing
}
