import Foundation
import UmbraCoreTypes
import XPCProtocolsCore

/// XPC Service Migration Examples
///
/// This file contains concrete examples of migrating from legacy XPC service protocols
/// to the modern XPCProtocolsCore implementations.
///
/// The examples show side-by-side comparisons of code before and after migration,
/// highlighting the improvements in error handling, async/await usage, and type safety.
public enum XPCMigrationExamples {
    
    // MARK: - Client Usage Examples
    
    /// Example of how to use legacy vs modern XPC service protocols in client code
    public static func clientUsageExample() {
        /*
         // BEFORE: Using legacy XPC service with completion handlers
         let legacyService = obtainLegacyXPCService()
         
         // Legacy API call with nested completion handlers - prone to callback hell
         legacyService.validateConnection { isValid, error in
             guard isValid, error == nil else {
                 handleError(error)
                 return
             }
             
             legacyService.encryptData(sensitiveData) { encryptedData, encryptError in
                 guard let encryptedData = encryptedData, encryptError == nil else {
                     handleError(encryptError)
                     return
                 }
                 
                 // More nested completion handlers...
                 legacyService.storeSecurely(encryptedData, identifier: "user-data") { storeError in
                     if let storeError = storeError {
                         handleError(storeError)
                     } else {
                         operationComplete()
                     }
                 }
             }
         }
         */
        
        /*
         // AFTER: Using modern XPC service with async/await and structured concurrency
         
         // Option 1: Create a new modern service
         let modernService = ModernXPCService()
         
         // Option 2: Migrate an existing legacy service using the factory
         // let modernService = XPCProtocolMigrationFactory.createCompleteAdapter()
         
         Task {
             // Modern API call with async/await - sequential, readable code
             let pingResult = await modernService.ping()
             
             guard case .success(true) = pingResult else {
                 if case .failure(let error) = pingResult {
                     handleError(error)
                 }
                 return
             }
             
             // Clean error handling with Result type
             let encryptResult = await modernService.encrypt(data: sensitiveData)
             
             switch encryptResult {
             case .success(let encryptedData):
                 // Store the encrypted data
                 let storeResult = await modernService.storeSecurely(
                     encryptedData,
                     identifier: "user-data",
                     metadata: ["created": Date().ISO8601Format()]
                 )
                 
                 if case .failure(let error) = storeResult {
                     handleError(error)
                 } else {
                     operationComplete()
                 }
                 
             case .failure(let error):
                 handleError(error)
             }
         }
         */
    }
    
    // MARK: - Service Implementation Examples
    
    /// Example of implementing a legacy vs modern XPC service
    public static func serviceImplementationExample() {
        /*
         // BEFORE: Legacy XPC service implementation with @objc compatibility
         
         @objc
         class LegacyXPCService: NSObject, XPCServiceProtocol {
             func validateConnection(withReply reply: @escaping (Bool, Error?) -> Void) {
                 // Implementation
                 reply(true, nil)
             }
             
             func getServiceVersion(withReply reply: @escaping (String) -> Void) {
                 reply("1.0.0")
             }
             
             func encryptData(_ data: Data, withReply reply: @escaping (Data?, Error?) -> Void) {
                 do {
                     let encryptedData = try performEncryption(data)
                     reply(encryptedData, nil)
                 } catch {
                     reply(nil, error)
                 }
             }
             
             func storeSecurely(_ data: Data, identifier: String, withReply reply: @escaping (Error?) -> Void) {
                 do {
                     try saveToSecureStorage(data, identifier: identifier)
                     reply(nil)
                 } catch {
                     reply(error)
                 }
             }
         }
         */
        
        /*
         // AFTER: Modern XPC service implementation using protocol conformance
         
         class ModernXPCServiceImpl: XPCServiceProtocolComplete {
             // Implement required methods
             
             func ping() async -> Result<Bool, XPCSecurityError> {
                 return .success(true)
             }
             
             func getVersion() async -> Result<String, XPCSecurityError> {
                 return .success("2.0.0")
             }
             
             func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
                 do {
                     let encryptedData = try performModernEncryption(data)
                     return .success(encryptedData)
                 } catch {
                     return .failure(.encryptionError(reason: error.localizedDescription))
                 }
             }
             
             func storeSecurely(
                 _ data: SecureBytes,
                 identifier: String,
                 metadata: [String: String]?
             ) async -> Result<Void, XPCSecurityError> {
                 do {
                     try saveToModernSecureStorage(data, identifier: identifier, metadata: metadata)
                     return .success(())
                 } catch {
                     return .failure(.storageError(reason: error.localizedDescription))
                 }
             }
         }
         */
    }
    
    // MARK: - Gradual Migration Examples
    
    /// Example of gradually migrating from legacy to modern XPC services
    public static func gradualMigrationExample() {
        /*
         // Step 1: Start with legacy service
         class MyAppXPCManager {
             private let legacyService: LegacyXPCService
             
             init() {
                 self.legacyService = LegacyXPCService()
             }
             
             func encryptUserData(_ data: Data, completion: @escaping (Data?, Error?) -> Void) {
                 legacyService.encryptData(data, withReply: completion)
             }
         }
         
         // Step 2: Add modern service alongside legacy service
         class MyAppXPCManager {
             private let legacyService: LegacyXPCService
             private let modernService: any XPCServiceProtocolComplete
             private let useModernAPI: Bool
             
             init(useModernAPI: Bool = false) {
                 self.legacyService = LegacyXPCService()
                 self.modernService = ModernXPCService()
                 self.useModernAPI = useModernAPI
             }
             
             // Legacy interface preserved for backward compatibility
             func encryptUserData(_ data: Data, completion: @escaping (Data?, Error?) -> Void) {
                 if useModernAPI {
                     Task {
                         let secureData = SecureBytes(data: data)
                         let result = await modernService.encrypt(data: secureData)
                         
                         switch result {
                         case .success(let encryptedData):
                             completion(encryptedData.data, nil)
                         case .failure(let error):
                             completion(nil, error)
                         }
                     }
                 } else {
                     legacyService.encryptData(data, withReply: completion)
                 }
             }
             
             // New async interface for modern code
             func encryptUserDataAsync(_ data: Data) async -> Result<Data, Error> {
                 let secureData = SecureBytes(data: data)
                 let result = await modernService.encrypt(data: secureData)
                 
                 switch result {
                 case .success(let encryptedData):
                     return .success(encryptedData.data)
                 case .failure(let error):
                     return .failure(error)
                 }
             }
         }
         
         // Step 3: Fully migrated to modern API
         class MyAppXPCManager {
             private let service: any XPCServiceProtocolComplete
             
             init() {
                 self.service = ModernXPCService()
             }
             
             // Legacy interface maintained only for backward compatibility
             func encryptUserData(_ data: Data, completion: @escaping (Data?, Error?) -> Void) {
                 Task {
                     let result = await encryptUserDataAsync(data)
                     switch result {
                     case .success(let data):
                         completion(data, nil)
                     case .failure(let error):
                         completion(nil, error)
                     }
                 }
             }
             
             // Primary modern interface
             func encryptUserDataAsync(_ data: Data) async -> Result<Data, Error> {
                 let secureData = SecureBytes(data: data)
                 let result = await service.encrypt(data: secureData)
                 
                 switch result {
                 case .success(let encryptedData):
                     return .success(encryptedData.data)
                 case .failure(let error):
                     return .failure(error)
                 }
             }
         }
         */
    }
    
    // MARK: - Helper Functions
    
    private static func handleError(_ error: Error?) {
        // Example implementation
    }
    
    private static func operationComplete() {
        // Example implementation
    }
}

// MARK: - Migration Helper Functions

/// Extension providing helper functions for use in migrations
extension XPCMigrationExamples {
    
    /// Demo helper to convert NSData to SecureBytes
    /// 
    /// This is provided as a reference for migrating legacy code that uses NSData
    /// to modern code that uses SecureBytes
    static func convertNSDataToSecureBytes(_ nsData: NSData) -> SecureBytes {
        return SecureBytes(data: nsData as Data)
    }
    
    /// Demo helper to convert NSError to XPCSecurityError
    ///
    /// This is provided as a reference for migrating legacy code that uses NSError
    /// to modern code that uses XPCSecurityError
    static func convertLegacyError(_ error: NSError) -> XPCSecurityError {
        let errorDomain = error.domain
        let code = error.code
        let description = error.localizedDescription
        
        if errorDomain.contains("encryption") {
            return .encryptionError(reason: "Error \(code): \(description)")
        } else if errorDomain.contains("storage") {
            return .storageError(reason: "Error \(code): \(description)")
        } else if errorDomain.contains("key") {
            return .keyError(reason: "Error \(code): \(description)")
        } else if errorDomain.contains("signature") {
            return .signatureError(reason: "Error \(code): \(description)")
        } else {
            return .internalError(reason: "Error \(code): \(description)")
        }
    }
}
