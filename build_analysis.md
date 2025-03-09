# UmbraCore Build Analysis

## Summary

- **Total Errors:** 693
- **Total Warnings:** 36
- **Targets with Errors:** 1
- **Targets with Warnings:** 4

## Table of Contents

### Targets with Errors

- [//Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests](#__Sources_CoreTypesImplementation_Tests_CoreTypesImplementationTests) - 693 errors

### Targets with Warnings Only

- [//Sources/Repositories:Repositories](#__Sources_Repositories_Repositories) - 2 warnings
- [//Sources/ErrorHandling/Utilities:ErrorHandlingUtilities](#__Sources_ErrorHandling_Utilities_ErrorHandlingUtilities) - 2 warnings
- [//Sources/UmbraBookmarkService:UmbraBookmarkService](#__Sources_UmbraBookmarkService_UmbraBookmarkService) - 1 warnings

## Detailed Analysis

### //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests

<a name='__Sources_CoreTypesImplementation_Tests_CoreTypesImplementationTests'></a>

#### Errors

**Error 1:** emit-module command failed with exit code 1 (use -v to see invocation)
- **File:** unknown
- **Line:** 0, **Column:** 0

```swift
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityCoreAdapters/SecurityCoreAdapters.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift:68:15: error: method cannot be declared public because its result uses an internal type
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
```


**Error 2:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 68, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityCoreAdapters/SecurityCoreAdapters.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
66 |   // MARK: - CryptoServiceProtocol Implementation
67 |
68 |   public func encrypt(
69 |     data: SecureBytes,
70 |     using key: SecureBytes
```


**Error 3:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 75, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
68 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
69 |     data: SecureBytes,
70 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
73 |   }
74 |
75 |   public func decrypt(
76 |     data: SecureBytes,
77 |     using key: SecureBytes
```


**Error 4:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 82, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
75 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
76 |     data: SecureBytes,
77 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
80 |   }
81 |
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
83 |     await _hash(data)
84 |   }
```


**Error 5:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 86, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
83 |     await _hash(data)
84 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
84 |   }
85 |
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
87 |     await _generateKey()
88 |   }
```


**Error 6:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 90, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
87 |     await _generateKey()
88 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
88 |   }
89 |
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
91 |     await _generateRandomData(length)
92 |   }
```


**Error 7:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 10, **Column:** 20
- **Additional Info:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'

```swift
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
91 |     await _generateRandomData(length)
92 |   }
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
|                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
11 |   // MARK: - Private Properties
12 |
```


**Error 8:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 35, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
36 |     data: SecureBytes,
37 |     using key: SecureBytes
```


**Error 9:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 47, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
45 |   }
46 |
47 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
45 |   }
46 |
47 |   public func decrypt(
48 |     data: SecureBytes,
49 |     using key: SecureBytes
```


**Error 10:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
60 |     let transformedData=transformations.transformInputData?(data) ?? data
61 |
```


**Error 11:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
68 |     let result=await adaptee.generateKey()
69 |
```


**Error 12:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
81 |     let result=await adaptee.generateRandomData(length: length)
82 |
```


**Error 13:** property cannot be declared public because its type uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 16
- **Additional Info:** property cannot be declared public because its type uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                `- error: property cannot be declared public because its type uses an internal type
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
185 |
186 |     /// Initialize a new set of transformations
```


**Error 14:** initializer cannot be declared public because its parameter uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 196, **Column:** 12
- **Additional Info:** initializer cannot be declared public because its parameter uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
|            `- error: initializer cannot be declared public because its parameter uses an internal type
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
197 |       transformInputData: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
198 |       transformInputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
```


**Error 15:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 7, **Column:** 15
- **Additional Info:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
|               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
8 |   Adaptee: CryptoServiceProtocol &
9 |     Sendable
```


**Error 16:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 68, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
99 |   /// - Returns: Result containing hash or error
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
66 |   // MARK: - CryptoServiceProtocol Implementation
67 |
68 |   public func encrypt(
69 |     data: SecureBytes,
70 |     using key: SecureBytes
```


**Error 17:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 75, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
68 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
69 |     data: SecureBytes,
70 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
73 |   }
74 |
75 |   public func decrypt(
76 |     data: SecureBytes,
77 |     using key: SecureBytes
```


**Error 18:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 82, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
75 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
76 |     data: SecureBytes,
77 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
80 |   }
81 |
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
83 |     await _hash(data)
84 |   }
```


**Error 19:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 86, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
83 |     await _hash(data)
84 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
84 |   }
85 |
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
87 |     await _generateKey()
88 |   }
```


**Error 20:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 90, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
87 |     await _generateKey()
88 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
88 |   }
89 |
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
91 |     await _generateRandomData(length)
92 |   }
```


**Error 21:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 10, **Column:** 20
- **Additional Info:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'

```swift
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
91 |     await _generateRandomData(length)
92 |   }
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
|                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
11 |   // MARK: - Private Properties
12 |
```


**Error 22:** cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 50, **Column:** 38
- **Additional Info:** cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
48 |
49 |     // New property initializations
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
|                                      `- error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
48 |
49 |     // New property initializations
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
```


**Error 23:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 52, **Column:** 7
- **Additional Info:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'

```swift
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
|                                      `- error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
```


**Error 24:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 55, **Column:** 7
- **Additional Info:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'

```swift
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
```


**Error 25:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 58, **Column:** 7
- **Additional Info:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'

```swift
55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
```


**Error 26:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 61, **Column:** 7
- **Additional Info:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'

```swift
58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
```


**Error 27:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 63, **Column:** 46
- **Additional Info:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'

```swift
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
|                                              `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
64 |   }
65 |
```


**Error 28:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 35, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
|                                              `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
64 |   }
65 |
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
36 |     data: SecureBytes,
37 |     using key: SecureBytes
```


**Error 29:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 47, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
45 |   }
46 |
47 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
45 |   }
46 |
47 |   public func decrypt(
48 |     data: SecureBytes,
49 |     using key: SecureBytes
```


**Error 30:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
60 |     let transformedData=transformations.transformInputData?(data) ?? data
61 |
```


**Error 31:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
68 |     let result=await adaptee.generateKey()
69 |
```


**Error 32:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
81 |     let result=await adaptee.generateRandomData(length: length)
82 |
```


**Error 33:** property cannot be declared public because its type uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 16
- **Additional Info:** property cannot be declared public because its type uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                `- error: property cannot be declared public because its type uses an internal type
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
185 |
186 |     /// Initialize a new set of transformations
```


**Error 34:** initializer cannot be declared public because its parameter uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 196, **Column:** 12
- **Additional Info:** initializer cannot be declared public because its parameter uses an internal type

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
|            `- error: initializer cannot be declared public because its parameter uses an internal type
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
197 |       transformInputData: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
198 |       transformInputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
```


**Error 35:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 7, **Column:** 15
- **Additional Info:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
|               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
8 |   Adaptee: CryptoServiceProtocol &
9 |     Sendable
```


**Error 36:** cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 77, **Column:** 12
- **Additional Info:** cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
76 |
77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
|            `- error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
76 |
77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
78 |   }
79 |
```


**Error 37:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 96, **Column:** 12
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
|            `- error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
78 |   }
79 |
94 |     let transformedKey=transformations.transformInputKey?(key) ?? key
95 |
96 |     return await adaptee.encryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
94 |     let transformedKey=transformations.transformInputKey?(key) ?? key
95 |
96 |     return await adaptee.encryptSymmetric(
97 |       data: transformedData,
98 |       key: transformedKey,
```


**Error 38:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 111, **Column:** 12
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
96 |     return await adaptee.encryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
97 |       data: transformedData,
98 |       key: transformedKey,
109 |     let transformedKey=transformations.transformInputKey?(key) ?? key
110 |
111 |     return await adaptee.decryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
109 |     let transformedKey=transformations.transformInputKey?(key) ?? key
110 |
111 |     return await adaptee.decryptSymmetric(
112 |       data: transformedData,
113 |       key: transformedKey,
```


**Error 39:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 126, **Column:** 12
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
111 |     return await adaptee.decryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
112 |       data: transformedData,
113 |       key: transformedKey,
124 |     let transformedKey=transformations.transformInputKey?(publicKey) ?? publicKey
125 |
126 |     return await adaptee.encryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
124 |     let transformedKey=transformations.transformInputKey?(publicKey) ?? publicKey
125 |
126 |     return await adaptee.encryptAsymmetric(
127 |       data: transformedData,
128 |       publicKey: transformedKey,
```


**Error 40:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 141, **Column:** 12
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
126 |     return await adaptee.encryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
127 |       data: transformedData,
128 |       publicKey: transformedKey,
139 |     let transformedKey=transformations.transformInputKey?(privateKey) ?? privateKey
140 |
141 |     return await adaptee.decryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
139 |     let transformedKey=transformations.transformInputKey?(privateKey) ?? privateKey
140 |
141 |     return await adaptee.decryptAsymmetric(
142 |       data: transformedData,
143 |       privateKey: transformedKey,
```


**Error 41:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 154, **Column:** 12
- **Additional Info:** emit-module command failed with exit code 1 (use -v to see invocation)

```swift
141 |     return await adaptee.decryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |       data: transformedData,
143 |       privateKey: transformedKey,
152 |     let transformedData=transformations.transformInputData?(data) ?? data
153 |
154 |     return await adaptee.hash(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
152 |     let transformedData=transformations.transformInputData?(data) ?? data
153 |
154 |     return await adaptee.hash(
155 |       data: transformedData,
156 |       config: config
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityImplementation/SecurityImplementation.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/SecurityImplementation/Sources/CryptoService.swift:196:15: error: method cannot be declared public because its result uses an internal type
29 |
```


**Error 42:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 196, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityImplementation/SecurityImplementation.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
194 |   ///
195 |   /// The format of the returned data is: [IV (12 bytes)][Encrypted data with authentication tag]
196 |   public func encrypt(
197 |     data: SecureBytes,
198 |     using key: SecureBytes
```


**Error 43:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 230, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
196 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
197 |     data: SecureBytes,
198 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
228 |   /// AES-GCM validates the integrity of the data during decryption. If the data
229 |   /// has been tampered with, decryption will fail with an authentication error.
230 |   public func decrypt(
231 |     data: SecureBytes,
232 |     using key: SecureBytes
```


**Error 44:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 264, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
230 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
231 |     data: SecureBytes,
232 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
262 |   /// suitable for use with AES-256 encryption. The key is returned as a SecureBytes
263 |   /// object, which provides memory protection for sensitive cryptographic material.
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
```


**Error 45:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 277, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
275 |   /// The hash function is one-way (it cannot be reversed) and collision-resistant
276 |   /// (it's computationally infeasible to find two different inputs that produce the same hash).
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
```


**Error 46:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 291, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
289 |   /// This function computes the SHA-256 hash of the input data and compares it
290 |   /// with the provided hash value. Returns true if they match, false otherwise.
291 |   public nonisolated func verify(
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
```


**Error 47:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 322, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
291 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
320 |   /// The MAC provides both authentication and integrity verification for the data.
321 |   /// A valid MAC can only be generated by someone who possesses the same key.
322 |   public nonisolated func generateMAC(
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
```


**Error 48:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 341, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
322 |   public nonisolated func generateMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
339 |   /// input data and key, then comparing it with the provided MAC. Returns true
340 |   /// if they match, indicating the data is authentic and has not been tampered with.
341 |   public nonisolated func verifyMAC(
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
```


**Error 49:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 483, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
341 |   public nonisolated func verifyMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
481 |    - Using hybrid encryption for large data (encrypt data with symmetric key, then encrypt that key with asymmetric)
482 |    */
483 |   public func generateAsymmetricKeyPair() async -> Result<(
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
```


**Error 50:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 544, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
483 |   public func generateAsymmetricKeyPair() async -> Result<(
|               `- error: method cannot be declared public because its result uses an internal type
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
542 |    4. Combine the encrypted key and encrypted data
543 |    */
544 |   public func encryptAsymmetric(
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
```


**Error 51:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 642, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
544 |   public func encryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
640 |    Always handle errors appropriately, avoiding information leakage in error messages.
641 |    */
642 |   public func decryptAsymmetric(
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
```


**Error 52:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 917, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
642 |   public func decryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
915 |    - Ed25519 signatures for high performance and security
916 |    */
917 |   public nonisolated func sign(
918 |     data: SecureBytes,
919 |     using key: SecureBytes
```


**Error 53:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 966, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
917 |   public nonisolated func sign(
|                           `- error: method cannot be declared public because its result uses an internal type
918 |     data: SecureBytes,
919 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
964 |    This implementation performs time-constant comparison to prevent timing attacks.
965 |    */
966 |   public nonisolated func verify(
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
```


**Error 54:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 987, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
966 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
985 |    but it should be reviewed for production use to ensure it meets specific security requirements.
986 |    */
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
988 |     // Input validation
989 |     guard length > 0 else {
```


**Error 55:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1059, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
988 |     // Input validation
989 |     guard length > 0 else {
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
1057 |   /// cryptographic operations like key generation. It uses CryptoWrapper's
1058 |   /// secure random number generation functionality.
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
```


**Error 56:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 56, **Column:** 20
- **Additional Info:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'

```swift
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
|                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
|                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
57 |   // MARK: - Initialisation
58 |
```


**Error 57:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 14, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
15 |     data: SecureBytes,
16 |     using key: SecureBytes
```


**Error 58:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 37, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
35 |   }
36 |
37 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
35 |   }
36 |
37 |   public func decrypt(
38 |     data: SecureBytes,
39 |     using key: SecureBytes
```


**Error 59:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 60, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
61 |     // Generate a 256-bit key (32 bytes)
62 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
```


**Error 60:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 66, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
67 |     let hashedData=CryptoWrapper.sha256(data)
68 |     return .success(hashedData)
```


**Error 61:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 79, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
80 |     do {
81 |       var randomBytes=[UInt8](repeating: 0, count: length)
```


**Error 62:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 6, **Column:** 20
- **Additional Info:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
|                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
7 |
8 |   // MARK: - Initialization
```


**Error 63:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 28, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
29 |   -> Result<SecureBytes, SecurityError> {
30 |     // If secure storage is available, use it
```


**Error 64:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 55, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
53 |   }
54 |
55 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
53 |   }
54 |
55 |   public func storeKey(
56 |     _ key: SecureBytes,
57 |     withIdentifier identifier: String
```


**Error 65:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 77, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
78 |     // If secure storage is available, use it
79 |     if let secureStorage {
```


**Error 66:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 105, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
103 |   }
104 |
105 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
103 |   }
104 |
105 |   public func rotateKey(
106 |     withIdentifier identifier: String,
107 |     dataToReencrypt: SecureBytes?
```


**Error 67:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 171, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
172 |     // If secure storage is available, it should provide a way to list keys
173 |     // For now, we'll just return the in-memory keys
```


**Error 68:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 97, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
98 |   -> Result<SecureBytes, SecurityError> {
99 |     if let key=await keyStorage.get(identifier: identifier) {
```


**Error 69:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 111, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
112 |     _ key: SecureBytes,
113 |     withIdentifier identifier: String
```


**Error 70:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 122, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
123 |     if await keyStorage.contains(identifier: identifier) {
124 |       await keyStorage.remove(identifier: identifier)
```


**Error 71:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 136, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
137 |     withIdentifier identifier: String,
138 |     dataToReencrypt: SecureBytes?
```


**Error 72:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 213, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
214 |   -> Result<SecureBytes, SecurityError> {
215 |     // Delegate to the full rotation method
```


**Error 73:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 229, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
230 |     let identifiers=await keyStorage.allIdentifiers()
231 |     return .success(identifiers)
```


**Error 74:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 237, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
238 |     // Basic implementation that delegates to CryptoService
239 |     let crypto=CryptoService()
```


**Error 75:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 196, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
194 |   ///
195 |   /// The format of the returned data is: [IV (12 bytes)][Encrypted data with authentication tag]
196 |   public func encrypt(
197 |     data: SecureBytes,
198 |     using key: SecureBytes
```


**Error 76:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 230, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
196 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
197 |     data: SecureBytes,
198 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
228 |   /// AES-GCM validates the integrity of the data during decryption. If the data
229 |   /// has been tampered with, decryption will fail with an authentication error.
230 |   public func decrypt(
231 |     data: SecureBytes,
232 |     using key: SecureBytes
```


**Error 77:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 264, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
230 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
231 |     data: SecureBytes,
232 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
262 |   /// suitable for use with AES-256 encryption. The key is returned as a SecureBytes
263 |   /// object, which provides memory protection for sensitive cryptographic material.
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
```


**Error 78:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 277, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
275 |   /// The hash function is one-way (it cannot be reversed) and collision-resistant
276 |   /// (it's computationally infeasible to find two different inputs that produce the same hash).
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
```


**Error 79:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 291, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
289 |   /// This function computes the SHA-256 hash of the input data and compares it
290 |   /// with the provided hash value. Returns true if they match, false otherwise.
291 |   public nonisolated func verify(
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
```


**Error 80:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 322, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
291 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
320 |   /// The MAC provides both authentication and integrity verification for the data.
321 |   /// A valid MAC can only be generated by someone who possesses the same key.
322 |   public nonisolated func generateMAC(
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
```


**Error 81:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 341, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
322 |   public nonisolated func generateMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
339 |   /// input data and key, then comparing it with the provided MAC. Returns true
340 |   /// if they match, indicating the data is authentic and has not been tampered with.
341 |   public nonisolated func verifyMAC(
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
```


**Error 82:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 483, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
341 |   public nonisolated func verifyMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
481 |    - Using hybrid encryption for large data (encrypt data with symmetric key, then encrypt that key with asymmetric)
482 |    */
483 |   public func generateAsymmetricKeyPair() async -> Result<(
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
```


**Error 83:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 544, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
483 |   public func generateAsymmetricKeyPair() async -> Result<(
|               `- error: method cannot be declared public because its result uses an internal type
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
542 |    4. Combine the encrypted key and encrypted data
543 |    */
544 |   public func encryptAsymmetric(
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
```


**Error 84:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 642, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
544 |   public func encryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
640 |    Always handle errors appropriately, avoiding information leakage in error messages.
641 |    */
642 |   public func decryptAsymmetric(
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
```


**Error 85:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 917, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
642 |   public func decryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
915 |    - Ed25519 signatures for high performance and security
916 |    */
917 |   public nonisolated func sign(
918 |     data: SecureBytes,
919 |     using key: SecureBytes
```


**Error 86:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 966, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
917 |   public nonisolated func sign(
|                           `- error: method cannot be declared public because its result uses an internal type
918 |     data: SecureBytes,
919 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
964 |    This implementation performs time-constant comparison to prevent timing attacks.
965 |    */
966 |   public nonisolated func verify(
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
```


**Error 87:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 987, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
966 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
985 |    but it should be reviewed for production use to ensure it meets specific security requirements.
986 |    */
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
988 |     // Input validation
989 |     guard length > 0 else {
```


**Error 88:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1059, **Column:** 27
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
988 |     // Input validation
989 |     guard length > 0 else {
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
1057 |   /// cryptographic operations like key generation. It uses CryptoWrapper's
1058 |   /// secure random number generation functionality.
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
```


**Error 89:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 56, **Column:** 20
- **Additional Info:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'

```swift
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
|                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
|                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
57 |   // MARK: - Initialisation
58 |
```


**Error 90:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 85, **Column:** 19
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
83 |         return SecurityResultDTO(
84 |           success: false,
85 |           error: .invalidInput(reason: "No encryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:85:19: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
83 |         return SecurityResultDTO(
84 |           success: false,
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
86 |         )
83 |         return SecurityResultDTO(
84 |           success: false,
85 |           error: .invalidInput(reason: "No encryption key provided")
86 |         )
87 |       }
```


**Error 91:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 90, **Column:** 45
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
85 |           error: .invalidInput(reason: "No encryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
86 |         )
87 |       }
88 |
89 |       // Default to AES-GCM with a random IV if not specified
90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
88 |
89 |       // Default to AES-GCM with a random IV if not specified
90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
91 |
92 |       // Encrypt the data
```


**Error 92:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 93, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
91 |
92 |       // Encrypt the data
91 |
92 |       // Encrypt the data
93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
91 |
92 |       // Encrypt the data
93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
94 |
95 |       // Return IV + encrypted data unless IV is provided in config
```


**Error 93:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 106, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'

```swift
93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
94 |
95 |       // Return IV + encrypted data unless IV is provided in config
104 |       return SecurityResultDTO(
105 |         success: false,
106 |         error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
Sources/SecurityImplementation/Sources/CryptoService.swift:106:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
104 |       return SecurityResultDTO(
105 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
107 |       )
104 |       return SecurityResultDTO(
105 |         success: false,
106 |         error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)")
107 |       )
108 |     }
```


**Error 94:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 129, **Column:** 19
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
106 |         error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
107 |       )
108 |     }
127 |         return SecurityResultDTO(
128 |           success: false,
129 |           error: .invalidInput(reason: "No decryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:129:19: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
127 |         return SecurityResultDTO(
128 |           success: false,
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
130 |         )
127 |         return SecurityResultDTO(
128 |           success: false,
129 |           error: .invalidInput(reason: "No decryption key provided")
130 |         )
131 |       }
```


**Error 95:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 145, **Column:** 21
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
129 |           error: .invalidInput(reason: "No decryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
130 |         )
131 |       }
143 |           return SecurityResultDTO(
144 |             success: false,
145 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:145:21: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
143 |           return SecurityResultDTO(
144 |             success: false,
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
146 |           )
143 |           return SecurityResultDTO(
144 |             success: false,
145 |             error: .invalidInput(reason: "Encrypted data too short")
146 |           )
147 |         }
```


**Error 96:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 155, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
145 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
146 |           )
147 |         }
153 |
154 |       // Decrypt the data
155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
153 |
154 |       // Decrypt the data
155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
156 |
157 |       return SecurityResultDTO(success: true, data: decrypted)
```


**Error 97:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 161, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'

```swift
155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
156 |
157 |       return SecurityResultDTO(success: true, data: decrypted)
159 |       return SecurityResultDTO(
160 |         success: false,
161 |         error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
Sources/SecurityImplementation/Sources/CryptoService.swift:161:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
159 |       return SecurityResultDTO(
160 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
162 |       )
159 |       return SecurityResultDTO(
160 |         success: false,
161 |         error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)")
162 |       )
163 |     }
```


**Error 98:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 182, **Column:** 20
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
161 |         error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
162 |       )
163 |     }
180 |   ) async -> SecurityResultDTO {
181 |     // Use SHA-256 through CryptoWrapper
182 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
180 |   ) async -> SecurityResultDTO {
181 |     // Use SHA-256 through CryptoWrapper
182 |     let hashedData=CryptoWrapper.sha256(data)
183 |     return SecurityResultDTO(success: true, data: hashedData)
184 |   }
```


**Error 99:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 202, **Column:** 14
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
182 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
183 |     return SecurityResultDTO(success: true, data: hashedData)
184 |   }
200 |     do {
201 |       // Generate a random IV
202 |       let iv=CryptoWrapper.generateRandomIVSecure()
|              `- error: cannot find 'CryptoWrapper' in scope
200 |     do {
201 |       // Generate a random IV
202 |       let iv=CryptoWrapper.generateRandomIVSecure()
203 |
204 |       // Encrypt the data using AES-GCM
```


**Error 100:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 205, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
202 |       let iv=CryptoWrapper.generateRandomIVSecure()
|              `- error: cannot find 'CryptoWrapper' in scope
203 |
204 |       // Encrypt the data using AES-GCM
203 |
204 |       // Encrypt the data using AES-GCM
205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
203 |
204 |       // Encrypt the data using AES-GCM
205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
206 |
207 |       // Combine IV with encrypted data
```


**Error 101:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 213, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'

```swift
205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
206 |
207 |       // Combine IV with encrypted data
211 |     } catch {
212 |       return .failure(
213 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
211 |     } catch {
212 |       return .failure(
213 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
214 |       )
215 |     }
```


**Error 102:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 237, **Column:** 26
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
213 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
214 |       )
215 |     }
235 |       // Extract IV from combined data (first 12 bytes)
236 |       guard data.count >= 12 else {
237 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
235 |       // Extract IV from combined data (first 12 bytes)
236 |       guard data.count >= 12 else {
237 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
238 |       }
239 |
```


**Error 103:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 248, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
237 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
238 |       }
239 |
246 |
247 |       // Decrypt the data using AES-GCM
248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
246 |
247 |       // Decrypt the data using AES-GCM
248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
249 |
250 |       return .success(decrypted)
```


**Error 104:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 253, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'

```swift
248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
249 |
250 |       return .success(decrypted)
251 |     } catch {
252 |       return .failure(
253 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
251 |     } catch {
252 |       return .failure(
253 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
254 |       )
255 |     }
```


**Error 105:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 266, **Column:** 13
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
253 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
254 |       )
255 |     }
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
|             `- error: cannot find 'CryptoWrapper' in scope
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
267 |     return .success(key)
268 |   }
```


**Error 106:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 279, **Column:** 20
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
|             `- error: cannot find 'CryptoWrapper' in scope
267 |     return .success(key)
268 |   }
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
280 |     return .success(hashedData)
281 |   }
```


**Error 107:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 295, **Column:** 22
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
279 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
280 |     return .success(hashedData)
281 |   }
293 |     againstHash hash: SecureBytes
294 |   ) async -> Result<Bool, SecurityError> {
295 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
293 |     againstHash hash: SecureBytes
294 |   ) async -> Result<Bool, SecurityError> {
295 |     let computedHash=CryptoWrapper.sha256(data)
296 |     // Compare the computed hash with the expected hash
297 |     let result=computedHash == hash
```


**Error 108:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 309, **Column:** 22
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
295 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
296 |     // Compare the computed hash with the expected hash
297 |     let result=computedHash == hash
307 |   /// Simplified version that returns a boolean directly instead of a Result type.
308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
309 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
307 |   /// Simplified version that returns a boolean directly instead of a Result type.
308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
309 |     let computedHash=CryptoWrapper.sha256(data)
310 |     return computedHash == hash
311 |   }
```


**Error 109:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 327, **Column:** 17
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
309 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
310 |     return computedHash == hash
311 |   }
325 |   ) async -> Result<SecureBytes, SecurityError> {
326 |     // Use HMAC-SHA256 through CryptoWrapper
327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
|                 `- error: cannot find 'CryptoWrapper' in scope
325 |   ) async -> Result<SecureBytes, SecurityError> {
326 |     // Use HMAC-SHA256 through CryptoWrapper
327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
328 |     return .success(macData)
329 |   }
```


**Error 110:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 346, **Column:** 21
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
|                 `- error: cannot find 'CryptoWrapper' in scope
328 |     return .success(macData)
329 |   }
344 |     using key: SecureBytes
345 |   ) async -> Result<Bool, SecurityError> {
346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
|                     `- error: cannot find 'CryptoWrapper' in scope
344 |     using key: SecureBytes
345 |   ) async -> Result<Bool, SecurityError> {
346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
347 |     let result=computedMAC == mac
348 |     return .success(result)
```


**Error 111:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 375, **Column:** 45
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
|                     `- error: cannot find 'CryptoWrapper' in scope
347 |     let result=computedMAC == mac
348 |     return .success(result)
373 |     do {
374 |       // Use AES-GCM for symmetric encryption
375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
373 |     do {
374 |       // Use AES-GCM for symmetric encryption
375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
376 |
377 |       // Encrypt the data
```


**Error 112:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 378, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
376 |
377 |       // Encrypt the data
376 |
377 |       // Encrypt the data
378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
376 |
377 |       // Encrypt the data
378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
379 |
380 |       // Return IV + encrypted data unless IV is provided in config
```


**Error 113:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 391, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'

```swift
378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
379 |
380 |       // Return IV + encrypted data unless IV is provided in config
389 |       return SecurityResultDTO(
390 |         success: false,
391 |         error: .encryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
Sources/SecurityImplementation/Sources/CryptoService.swift:391:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
389 |       return SecurityResultDTO(
390 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
392 |           reason: "Symmetric encryption failed: \(error.localizedDescription)"
389 |       return SecurityResultDTO(
390 |         success: false,
391 |         error: .encryptionFailed(
392 |           reason: "Symmetric encryption failed: \(error.localizedDescription)"
393 |         )
```


**Error 114:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 430, **Column:** 21
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
391 |         error: .encryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
392 |           reason: "Symmetric encryption failed: \(error.localizedDescription)"
393 |         )
428 |           return SecurityResultDTO(
429 |             success: false,
430 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:430:21: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
428 |           return SecurityResultDTO(
429 |             success: false,
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
431 |           )
428 |           return SecurityResultDTO(
429 |             success: false,
430 |             error: .invalidInput(reason: "Encrypted data too short")
431 |           )
432 |         }
```


**Error 115:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 440, **Column:** 25
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
430 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
431 |           )
432 |         }
438 |
439 |       // Decrypt the data
440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
438 |
439 |       // Decrypt the data
440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
441 |
442 |       return SecurityResultDTO(success: true, data: decrypted)
```


**Error 116:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 446, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'

```swift
440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
441 |
442 |       return SecurityResultDTO(success: true, data: decrypted)
444 |       return SecurityResultDTO(
445 |         success: false,
446 |         error: .decryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
Sources/SecurityImplementation/Sources/CryptoService.swift:446:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
444 |       return SecurityResultDTO(
445 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
447 |           reason: "Symmetric decryption failed: \(error.localizedDescription)"
444 |       return SecurityResultDTO(
445 |         success: false,
446 |         error: .decryptionFailed(
447 |           reason: "Symmetric decryption failed: \(error.localizedDescription)"
448 |         )
```


**Error 117:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 492, **Column:** 14
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
446 |         error: .decryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
447 |           reason: "Symmetric decryption failed: \(error.localizedDescription)"
448 |         )
490 |
491 |     // Generate a seed for the "key pair"
492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
490 |
491 |     // Generate a seed for the "key pair"
492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
493 |
494 |     // Generate "public" and "private" keys from the seed
```


**Error 118:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 495, **Column:** 20
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
493 |
494 |     // Generate "public" and "private" keys from the seed
493 |
494 |     // Generate "public" and "private" keys from the seed
495 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
493 |
494 |     // Generate "public" and "private" keys from the seed
495 |     let privateKey=CryptoWrapper.sha256(seed)
496 |     var publicKeyBytes=privateKey.bytes()
497 |
```


**Error 119:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 500, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'

```swift
495 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
496 |     var publicKeyBytes=privateKey.bytes()
497 |
498 |     // Ensure we have bytes to modify
499 |     guard !publicKeyBytes.isEmpty else {
500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
498 |     // Ensure we have bytes to modify
499 |     guard !publicKeyBytes.isEmpty else {
500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
501 |     }
502 |
```


**Error 120:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 550, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
501 |     }
502 |
548 |     // Input validation
549 |     guard !data.isEmpty, !publicKey.isEmpty else {
550 |       return .failure(.invalidInput(reason: "Input data or public key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
548 |     // Input validation
549 |     guard !data.isEmpty, !publicKey.isEmpty else {
550 |       return .failure(.invalidInput(reason: "Input data or public key is empty"))
551 |     }
552 |
```


**Error 121:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 587, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
550 |       return .failure(.invalidInput(reason: "Input data or public key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
551 |     }
552 |
585 |       return SecurityResultDTO(
586 |         success: false,
587 |         error: .invalidInput(reason: "Input data or public key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:587:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
585 |       return SecurityResultDTO(
586 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
588 |       )
585 |       return SecurityResultDTO(
586 |         success: false,
587 |         error: .invalidInput(reason: "Input data or public key is empty")
588 |       )
589 |     }
```


**Error 122:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 648, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
587 |         error: .invalidInput(reason: "Input data or public key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
588 |       )
589 |     }
646 |     // Input validation
647 |     guard !data.isEmpty, !privateKey.isEmpty else {
648 |       return .failure(.invalidInput(reason: "Input data or private key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
646 |     // Input validation
647 |     guard !data.isEmpty, !privateKey.isEmpty else {
648 |       return .failure(.invalidInput(reason: "Input data or private key is empty"))
649 |     }
650 |
```


**Error 123:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 655, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
648 |       return .failure(.invalidInput(reason: "Input data or private key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
649 |     }
650 |
653 |     // Verify minimum length and marker
654 |     guard dataBytes.count >= 4 else {
655 |       return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
653 |     // Verify minimum length and marker
654 |     guard dataBytes.count >= 4 else {
655 |       return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
656 |     }
657 |
```


**Error 124:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 662, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
655 |       return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
656 |     }
657 |
660 |     let expectedMarker: [UInt8]=[0xDE, 0xAD, 0xBE, 0xEF]
661 |     guard marker == expectedMarker else {
662 |       return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
660 |     let expectedMarker: [UInt8]=[0xDE, 0xAD, 0xBE, 0xEF]
661 |     guard marker == expectedMarker else {
662 |       return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
663 |     }
664 |
```


**Error 125:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 693, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
662 |       return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
663 |     }
664 |
691 |       return SecurityResultDTO(
692 |         success: false,
693 |         error: .invalidInput(reason: "Input data or private key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:693:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
691 |       return SecurityResultDTO(
692 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
694 |       )
691 |       return SecurityResultDTO(
692 |         success: false,
693 |         error: .invalidInput(reason: "Input data or private key is empty")
694 |       )
695 |     }
```


**Error 126:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 703, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
693 |         error: .invalidInput(reason: "Input data or private key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
694 |       )
695 |     }
701 |       return SecurityResultDTO(
702 |         success: false,
703 |         error: .invalidInput(reason: "Input data too short for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:703:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
701 |       return SecurityResultDTO(
702 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
704 |       )
701 |       return SecurityResultDTO(
702 |         success: false,
703 |         error: .invalidInput(reason: "Input data too short for asymmetric decryption")
704 |       )
705 |     }
```


**Error 127:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 713, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'

```swift
703 |         error: .invalidInput(reason: "Input data too short for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
704 |       )
705 |     }
711 |       return SecurityResultDTO(
712 |         success: false,
713 |         error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/CryptoService.swift:713:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
711 |       return SecurityResultDTO(
712 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
714 |       )
711 |       return SecurityResultDTO(
712 |         success: false,
713 |         error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
714 |       )
715 |     }
```


**Error 128:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 745, **Column:** 14
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
713 |         error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
714 |       )
715 |     }
743 |
744 |     // Generate a seed for the "key pair"
745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
743 |
744 |     // Generate a seed for the "key pair"
745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
746 |
747 |     // Generate "public" and "private" keys from the seed
```


**Error 129:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 748, **Column:** 20
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
746 |
747 |     // Generate "public" and "private" keys from the seed
746 |
747 |     // Generate "public" and "private" keys from the seed
748 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
746 |
747 |     // Generate "public" and "private" keys from the seed
748 |     let privateKey=CryptoWrapper.sha256(seed)
749 |     var publicKeyBytes=privateKey.bytes()
750 |
```


**Error 130:** type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 755, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'

```swift
748 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
749 |     var publicKeyBytes=privateKey.bytes()
750 |
753 |       return SecurityResultDTO(
754 |         success: false,
755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
Sources/SecurityImplementation/Sources/CryptoService.swift:755:17: error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
753 |       return SecurityResultDTO(
754 |         success: false,
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
756 |       )
753 |       return SecurityResultDTO(
754 |         success: false,
755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
756 |       )
757 |     }
```


**Error 131:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 810, **Column:** 14
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
756 |       )
757 |     }
808 |     }
809 |
810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
|              `- error: cannot find 'CryptoWrapper' in scope
808 |     }
809 |
810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
811 |
812 |     // Get the byte arrays safely
```


**Error 132:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 864, **Column:** 14
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
|              `- error: cannot find 'CryptoWrapper' in scope
811 |
812 |     // Get the byte arrays safely
862 |     }
863 |
864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
|              `- error: cannot find 'CryptoWrapper' in scope
862 |     }
863 |
864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
865 |
866 |     // Get the byte arrays safely
```


**Error 133:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 923, **Column:** 19
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
|              `- error: cannot find 'CryptoWrapper' in scope
865 |
866 |     // Get the byte arrays safely
921 |     // Use HMAC-SHA256 as a basic signing mechanism
922 |     // In a real implementation, this would use an asymmetric signature algorithm
923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                   `- error: cannot find 'CryptoWrapper' in scope
921 |     // Use HMAC-SHA256 as a basic signing mechanism
922 |     // In a real implementation, this would use an asymmetric signature algorithm
923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
924 |     return .success(signature)
925 |   }
```


**Error 134:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 971, **Column:** 27
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                   `- error: cannot find 'CryptoWrapper' in scope
924 |     return .success(signature)
925 |   }
969 |     using key: SecureBytes
970 |   ) async -> Result<Bool, SecurityError> {
971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                           `- error: cannot find 'CryptoWrapper' in scope
969 |     using key: SecureBytes
970 |   ) async -> Result<Bool, SecurityError> {
971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
972 |     let result=computedSignature == signature
973 |     return .success(result)
```


**Error 135:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 990, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                           `- error: cannot find 'CryptoWrapper' in scope
972 |     let result=computedSignature == signature
973 |     return .success(result)
988 |     // Input validation
989 |     guard length > 0 else {
990 |       return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
988 |     // Input validation
989 |     guard length > 0 else {
990 |       return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
991 |     }
992 |
```


**Error 136:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 997, **Column:** 22
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
990 |       return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
991 |     }
992 |
995 |
996 |       // Generate random bytes using CryptoKit's secure random number generator
997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
|                      `- error: cannot find 'CryptoWrapper' in scope
995 |
996 |       // Generate random bytes using CryptoKit's secure random number generator
997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
998 |
999 |       if status {
```


**Error 137:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1002, **Column:** 26
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'

```swift
997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
|                      `- error: cannot find 'CryptoWrapper' in scope
998 |
999 |       if status {
1000 |         return .success(SecureBytes(bytes: randomBytes))
1001 |       } else {
1002 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1000 |         return .success(SecureBytes(bytes: randomBytes))
1001 |       } else {
1002 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
1003 |       }
1004 |     } catch {
```


**Error 138:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1006, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'

```swift
1002 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1003 |       }
1004 |     } catch {
1004 |     } catch {
1005 |       return .failure(
1006 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1004 |     } catch {
1005 |       return .failure(
1006 |         .randomGenerationFailed(
1007 |           reason: "Error during random generation: \(error.localizedDescription)"
1008 |         )
```


**Error 139:** cannot find 'isEmpty' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1062, **Column:** 8
- **Additional Info:** cannot find 'isEmpty' in scope

```swift
1006 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1007 |           reason: "Error during random generation: \(error.localizedDescription)"
1008 |         )
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
1062 |     if isEmpty {
|        `- error: cannot find 'isEmpty' in scope
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
1062 |     if isEmpty {
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
1064 |     }
```


**Error 140:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1063, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
1062 |     if isEmpty {
|        `- error: cannot find 'isEmpty' in scope
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
1064 |     }
1061 |     // Check for valid count
1062 |     if isEmpty {
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
1061 |     // Check for valid count
1062 |     if isEmpty {
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
1064 |     }
1065 |
```


**Error 141:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1066, **Column:** 21
- **Additional Info:** cannot find 'CryptoWrapper' in scope

```swift
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
1064 |     }
1065 |
1064 |     }
1065 |
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
|                     `- error: cannot find 'CryptoWrapper' in scope
1064 |     }
1065 |
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
1067 |   }
1068 | }
```


**Error 142:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 14, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
|                     `- error: cannot find 'CryptoWrapper' in scope
1067 |   }
1068 | }
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
15 |     data: SecureBytes,
16 |     using key: SecureBytes
```


**Error 143:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 37, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
35 |   }
36 |
37 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
35 |   }
36 |
37 |   public func decrypt(
38 |     data: SecureBytes,
39 |     using key: SecureBytes
```


**Error 144:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 60, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
61 |     // Generate a 256-bit key (32 bytes)
62 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
```


**Error 145:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 66, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
67 |     let hashedData=CryptoWrapper.sha256(data)
68 |     return .success(hashedData)
```


**Error 146:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 79, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
80 |     do {
81 |       var randomBytes=[UInt8](repeating: 0, count: length)
```


**Error 147:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 6, **Column:** 20
- **Additional Info:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
|                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
7 |
8 |   // MARK: - Initialization
```


**Error 148:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 32, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
30 |     } catch {
31 |       return .failure(
32 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
30 |     } catch {
31 |       return .failure(
32 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
33 |       )
34 |     }
```


**Error 149:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 44, **Column:** 26
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
32 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
33 |       )
34 |     }
42 |       // Extract IV from combined data (first 12 bytes)
43 |       guard data.count > 12 else {
44 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
42 |       // Extract IV from combined data (first 12 bytes)
43 |       guard data.count > 12 else {
44 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
45 |       }
46 |
```


**Error 150:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 55, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'

```swift
44 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
45 |       }
46 |
53 |     } catch {
54 |       return .failure(
55 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
53 |     } catch {
54 |       return .failure(
55 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
56 |       )
57 |     }
```


**Error 151:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 89, **Column:** 26
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'

```swift
55 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
56 |       )
57 |     }
87 |         return .success(SecureBytes(bytes: randomBytes))
88 |       } else {
89 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
87 |         return .success(SecureBytes(bytes: randomBytes))
88 |       } else {
89 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
90 |       }
91 |     } catch {
```


**Error 152:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 93, **Column:** 10
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'

```swift
89 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
90 |       }
91 |     } catch {
91 |     } catch {
92 |       return .failure(
93 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
91 |     } catch {
92 |       return .failure(
93 |         .randomGenerationFailed(
94 |           reason: "Error during random generation: \(error.localizedDescription)"
95 |         )
```


**Error 153:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 28, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
93 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
94 |           reason: "Error during random generation: \(error.localizedDescription)"
95 |         )
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
29 |   -> Result<SecureBytes, SecurityError> {
30 |     // If secure storage is available, use it
```


**Error 154:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 55, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
53 |   }
54 |
55 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
53 |   }
54 |
55 |   public func storeKey(
56 |     _ key: SecureBytes,
57 |     withIdentifier identifier: String
```


**Error 155:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 77, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
78 |     // If secure storage is available, use it
79 |     if let secureStorage {
```


**Error 156:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 105, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
103 |   }
104 |
105 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
103 |   }
104 |
105 |   public func rotateKey(
106 |     withIdentifier identifier: String,
107 |     dataToReencrypt: SecureBytes?
```


**Error 157:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 171, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
172 |     // If secure storage is available, it should provide a way to list keys
173 |     // For now, we'll just return the in-memory keys
```


**Error 158:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 39, **Column:** 32
- **Additional Info:** \(error)"))

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
37 |           switch error {
38 |             case .keyNotFound:
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
37 |           switch error {
38 |             case .keyNotFound:
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
40 |             default:
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:41:32: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
```


**Error 159:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 41, **Column:** 32
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:41:32: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
40 |             default:
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
42 |           }
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
42 |           }
43 |         @unknown default:
```


**Error 160:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 44, **Column:** 28
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
42 |           }
43 |         @unknown default:
42 |           }
43 |         @unknown default:
44 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
42 |           }
43 |         @unknown default:
44 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
45 |       }
46 |     }
```


**Error 161:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 50, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
44 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
45 |       }
46 |     }
48 |     // Fallback to in-memory storage
49 |     guard let key=keyStore[identifier] else {
50 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
48 |     // Fallback to in-memory storage
49 |     guard let key=keyStore[identifier] else {
50 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
51 |     }
52 |     return .success(key)
```


**Error 162:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 66, **Column:** 28
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
50 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
51 |     }
52 |     return .success(key)
64 |           return .success(())
65 |         case let .failure(error):
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:66:28: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
64 |           return .success(())
65 |         case let .failure(error):
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
67 |         @unknown default:
64 |           return .success(())
65 |         case let .failure(error):
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
```


**Error 163:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 68, **Column:** 28
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:68:28: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
69 |       }
70 |     }
```


**Error 164:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 87, **Column:** 32
- **Additional Info:** \(error)"))

```swift
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
69 |       }
70 |     }
85 |           switch error {
86 |             case .keyNotFound:
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
85 |           switch error {
86 |             case .keyNotFound:
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
88 |             default:
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:89:32: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
```


**Error 165:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 89, **Column:** 32
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift:89:32: error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
88 |             default:
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
90 |           }
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
90 |           }
91 |         @unknown default:
```


**Error 166:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 92, **Column:** 28
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
90 |           }
91 |         @unknown default:
90 |           }
91 |         @unknown default:
92 |           return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
90 |           }
91 |         @unknown default:
92 |           return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
93 |       }
94 |     }
```


**Error 167:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 98, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
92 |           return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
93 |       }
94 |     }
96 |     // Fallback to in-memory storage
97 |     guard keyStore[identifier] != nil else {
98 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
96 |     // Fallback to in-memory storage
97 |     guard keyStore[identifier] != nil else {
98 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
99 |     }
100 |
```


**Error 168:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 118, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
98 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
99 |     }
100 |
116 |         return .failure(error)
117 |       }
118 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
116 |         return .failure(error)
117 |       }
118 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
119 |     }
120 |
```


**Error 169:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 131, **Column:** 28
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'

```swift
118 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
119 |     }
120 |
129 |         let ivSize=12 // AES GCM IV size is 12 bytes
130 |         guard dataToReencrypt.count > ivSize else {
131 |           return .failure(.invalidInput(reason: "Data is too short to contain IV"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
129 |         let ivSize=12 // AES GCM IV size is 12 bytes
130 |         guard dataToReencrypt.count > ivSize else {
131 |           return .failure(.invalidInput(reason: "Data is too short to contain IV"))
132 |         }
133 |
```


**Error 170:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 155, **Column:** 12
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
131 |           return .failure(.invalidInput(reason: "Data is too short to contain IV"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
132 |         }
133 |
153 |       } catch {
154 |         return .failure(
155 |           .storageOperationFailed(
|            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
153 |       } catch {
154 |         return .failure(
155 |           .storageOperationFailed(
156 |             reason: "Failed to re-encrypt data: \(error.localizedDescription)"
157 |           )
```


**Error 171:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 97, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
155 |           .storageOperationFailed(
|            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
156 |             reason: "Failed to re-encrypt data: \(error.localizedDescription)"
157 |           )
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
98 |   -> Result<SecureBytes, SecurityError> {
99 |     if let key=await keyStorage.get(identifier: identifier) {
```


**Error 172:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 111, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
112 |     _ key: SecureBytes,
113 |     withIdentifier identifier: String
```


**Error 173:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 122, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
123 |     if await keyStorage.contains(identifier: identifier) {
124 |       await keyStorage.remove(identifier: identifier)
```


**Error 174:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 136, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
137 |     withIdentifier identifier: String,
138 |     dataToReencrypt: SecureBytes?
```


**Error 175:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 213, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
214 |   -> Result<SecureBytes, SecurityError> {
215 |     // Delegate to the full rotation method
```


**Error 176:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 229, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
230 |     let identifiers=await keyStorage.allIdentifiers()
231 |     return .success(identifiers)
```


**Error 177:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 237, **Column:** 15
- **Additional Info:** method cannot be declared public because its result uses an internal type

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
238 |     // Basic implementation that delegates to CryptoService
239 |     let crypto=CryptoService()
```


**Error 178:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 102, **Column:** 17
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
100 |       .success(key)
101 |     } else {
102 |       .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                 `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
100 |       .success(key)
101 |     } else {
102 |       .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
103 |     }
104 |   }
```


**Error 179:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 127, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
102 |       .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                 `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
103 |     }
104 |   }
125 |       return .success(())
126 |     } else {
127 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
125 |       return .success(())
126 |     } else {
127 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
128 |     }
129 |   }
```


**Error 180:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 145, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'

```swift
127 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
128 |     }
129 |   }
143 |     // Check if the key exists first
144 |     guard let oldKey=await keyStorage.get(identifier: identifier) else {
145 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
143 |     // Check if the key exists first
144 |     guard let oldKey=await keyStorage.get(identifier: identifier) else {
145 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
146 |     }
147 |
```


**Error 181:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 169, **Column:** 34
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'

```swift
145 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
146 |     }
147 |
167 |             case true:
168 |               guard let decryptedData=decryptResult.data else {
169 |                 return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
|                                  `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
167 |             case true:
168 |               guard let decryptedData=decryptResult.data else {
169 |                 return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
170 |               }
171 |
```


**Error 182:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 183, **Column:** 24
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'

```swift
169 |                 return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
|                                  `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
170 |               }
171 |
181 |                   guard let reencryptedData=encryptResult.data else {
182 |                     return .failure(
183 |                       .encryptionFailed(reason: "Failed to encrypt data with new key")
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
181 |                   guard let reencryptedData=encryptResult.data else {
182 |                     return .failure(
183 |                       .encryptionFailed(reason: "Failed to encrypt data with new key")
184 |                     )
185 |                   }
```


**Error 183:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 190, **Column:** 34
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'

```swift
183 |                       .encryptionFailed(reason: "Failed to encrypt data with new key")
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
184 |                     )
185 |                   }
188 |                   return .failure(
189 |                     encryptResult
190 |                       .error ?? .encryptionFailed(reason: "Unknown encryption error")
|                                  `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
188 |                   return .failure(
189 |                     encryptResult
190 |                       .error ?? .encryptionFailed(reason: "Unknown encryption error")
191 |                   )
192 |               }
```


**Error 184:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 197, **Column:** 30
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'

```swift
190 |                       .error ?? .encryptionFailed(reason: "Unknown encryption error")
|                                  `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
191 |                   )
192 |               }
195 |               return .failure(
196 |                 decryptResult
197 |                   .error ?? .decryptionFailed(reason: "Unknown decryption error")
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
195 |               return .failure(
196 |                 decryptResult
197 |                   .error ?? .decryptionFailed(reason: "Unknown decryption error")
198 |               )
199 |           }
```


**Error 185:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 52, **Column:** 57
- **Additional Info:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'

```swift
197 |                   .error ?? .decryptionFailed(reason: "Unknown decryption error")
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
198 |               )
199 |           }
50 |             return SecurityResultDTO.failure(
51 |               code: 500,
52 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
50 |             return SecurityResultDTO.failure(
51 |               code: 500,
52 |               message: "Failed to generate key: \(error.description)"
53 |             )
54 |           }
```


**Error 186:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 65, **Column:** 16
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
52 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
53 |             )
54 |           }
63 |
64 |         // Perform encryption
65 |         return await cryptoService.encryptSymmetric(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
63 |
64 |         // Perform encryption
65 |         return await cryptoService.encryptSymmetric(
66 |           data: data,
67 |           key: key,
```


**Error 187:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 90, **Column:** 16
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
65 |         return await cryptoService.encryptSymmetric(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
66 |           data: data,
67 |           key: key,
88 |
89 |         // Perform hashing
90 |         return await cryptoService.hash(data: data, config: config)
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
88 |
89 |         // Perform hashing
90 |         return await cryptoService.hash(data: data, config: config)
91 |
92 |       case .macGeneration:
```


**Error 188:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 121, **Column:** 65
- **Additional Info:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'

```swift
90 |         return await cryptoService.hash(data: data, config: config)
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
91 |
92 |       case .macGeneration:
119 |             return SecurityResultDTO.failure(
120 |               code: 500,
121 |               message: "Failed to generate random data: \(error.description)"
|                                                                 `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
119 |             return SecurityResultDTO.failure(
120 |               code: 500,
121 |               message: "Failed to generate random data: \(error.description)"
122 |             )
123 |           }
```


**Error 189:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 139, **Column:** 57
- **Additional Info:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'

```swift
121 |               message: "Failed to generate random data: \(error.description)"
|                                                                 `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
122 |             )
123 |           }
137 |             return SecurityResultDTO.failure(
138 |               code: 500,
139 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
137 |             return SecurityResultDTO.failure(
138 |               code: 500,
139 |               message: "Failed to generate key: \(error.description)"
140 |             )
141 |           }
```


**Error 190:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 130, **Column:** 22
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
139 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
140 |             )
141 |           }
128 |           switch keyResult {
129 |             case let .success(key):
130 |               return await cryptoService.encryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
128 |           switch keyResult {
129 |             case let .success(key):
130 |               return await cryptoService.encryptSymmetric(
131 |                 data: config.inputData ?? SecureBytes(bytes: []),
132 |                 key: key,
```


**Error 191:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 137, **Column:** 25
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'

```swift
130 |               return await cryptoService.encryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
131 |                 data: config.inputData ?? SecureBytes(bytes: []),
132 |                 key: key,
135 |             case .failure:
136 |               return SecurityResultDTO.failure(
137 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:137:25: error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
135 |             case .failure:
136 |               return SecurityResultDTO.failure(
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
138 |               )
135 |             case .failure:
136 |               return SecurityResultDTO.failure(
137 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
138 |               )
139 |           }
```


**Error 192:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 141, **Column:** 18
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
137 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
138 |               )
139 |           }
139 |           }
140 |         } else if let key=config.key {
141 |           return await cryptoService.encryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
139 |           }
140 |         } else if let key=config.key {
141 |           return await cryptoService.encryptSymmetric(
142 |             data: config.inputData ?? SecureBytes(bytes: []),
143 |             key: key,
```


**Error 193:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 148, **Column:** 21
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'

```swift
141 |           return await cryptoService.encryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |             data: config.inputData ?? SecureBytes(bytes: []),
143 |             key: key,
146 |         } else {
147 |           return SecurityResultDTO.failure(
148 |             error: .invalidInput(reason: "No key provided for encryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:148:21: error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
146 |         } else {
147 |           return SecurityResultDTO.failure(
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
149 |           )
146 |         } else {
147 |           return SecurityResultDTO.failure(
148 |             error: .invalidInput(reason: "No key provided for encryption")
149 |           )
150 |         }
```


**Error 194:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 157, **Column:** 22
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
148 |             error: .invalidInput(reason: "No key provided for encryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
149 |           )
150 |         }
155 |           switch keyResult {
156 |             case let .success(key):
157 |               return await cryptoService.decryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
155 |           switch keyResult {
156 |             case let .success(key):
157 |               return await cryptoService.decryptSymmetric(
158 |                 data: config.inputData ?? SecureBytes(bytes: []),
159 |                 key: key,
```


**Error 195:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 164, **Column:** 25
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'

```swift
157 |               return await cryptoService.decryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
158 |                 data: config.inputData ?? SecureBytes(bytes: []),
159 |                 key: key,
162 |             case .failure:
163 |               return SecurityResultDTO.failure(
164 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:164:25: error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
162 |             case .failure:
163 |               return SecurityResultDTO.failure(
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
165 |               )
162 |             case .failure:
163 |               return SecurityResultDTO.failure(
164 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
165 |               )
166 |           }
```


**Error 196:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 168, **Column:** 18
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
164 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
165 |               )
166 |           }
166 |           }
167 |         } else if let key=config.key {
168 |           return await cryptoService.decryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
166 |           }
167 |         } else if let key=config.key {
168 |           return await cryptoService.decryptSymmetric(
169 |             data: config.inputData ?? SecureBytes(bytes: []),
170 |             key: key,
```


**Error 197:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 175, **Column:** 21
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'

```swift
168 |           return await cryptoService.decryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
169 |             data: config.inputData ?? SecureBytes(bytes: []),
170 |             key: key,
173 |         } else {
174 |           return SecurityResultDTO.failure(
175 |             error: .invalidInput(reason: "No key provided for decryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:175:21: error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
173 |         } else {
174 |           return SecurityResultDTO.failure(
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
176 |           )
173 |         } else {
174 |           return SecurityResultDTO.failure(
175 |             error: .invalidInput(reason: "No key provided for decryption")
176 |           )
177 |         }
```


**Error 198:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 180, **Column:** 16
- **Additional Info:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'

```swift
175 |             error: .invalidInput(reason: "No key provided for decryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
176 |           )
177 |         }
178 |
179 |       case .hashing:
180 |         return await cryptoService.hash(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
178 |
179 |       case .hashing:
180 |         return await cryptoService.hash(
181 |           data: config.inputData ?? SecureBytes(bytes: []),
182 |           config: config
```


**Error 199:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 187, **Column:** 19
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'

```swift
180 |         return await cryptoService.hash(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
181 |           data: config.inputData ?? SecureBytes(bytes: []),
182 |           config: config
185 |       case .asymmetricEncryption, .asymmetricDecryption:
186 |         return SecurityResultDTO.failure(
187 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:187:19: error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
185 |       case .asymmetricEncryption, .asymmetricDecryption:
186 |         return SecurityResultDTO.failure(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
188 |         )
185 |       case .asymmetricEncryption, .asymmetricDecryption:
186 |         return SecurityResultDTO.failure(
187 |           error: .notImplemented
188 |         )
189 |
```


**Error 200:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 192, **Column:** 19
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'

```swift
187 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
188 |         )
189 |
190 |       case .macGeneration, .signatureGeneration, .signatureVerification, .randomGeneration:
191 |         return SecurityResultDTO.failure(
192 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:192:19: error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
190 |       case .macGeneration, .signatureGeneration, .signatureVerification, .randomGeneration:
191 |         return SecurityResultDTO.failure(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
193 |         )
190 |       case .macGeneration, .signatureGeneration, .signatureVerification, .randomGeneration:
191 |         return SecurityResultDTO.failure(
192 |           error: .notImplemented
193 |         )
194 |
```


**Error 201:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 197, **Column:** 19
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'

```swift
192 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
193 |         )
194 |
195 |       case .keyGeneration, .keyStorage, .keyRetrieval, .keyRotation, .keyDeletion:
196 |         return SecurityResultDTO.failure(
197 |           error: .serviceError(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:197:19: error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
195 |       case .keyGeneration, .keyStorage, .keyRetrieval, .keyRotation, .keyDeletion:
196 |         return SecurityResultDTO.failure(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
198 |             code: 104,
195 |       case .keyGeneration, .keyStorage, .keyRetrieval, .keyRotation, .keyDeletion:
196 |         return SecurityResultDTO.failure(
197 |           error: .serviceError(
198 |             code: 104,
199 |             reason: "Key management operations should be performed via KeyManagement interface"
```


**Error 202:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 205, **Column:** 19
- **Additional Info:** emit-module command failed with exit code 1 (use -v to see invocation)

```swift
197 |           error: .serviceError(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
198 |             code: 104,
199 |             reason: "Key management operations should be performed via KeyManagement interface"
203 |       @unknown default:
204 |         return SecurityResultDTO.failure(
205 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
Sources/SecurityImplementation/Sources/SecurityProvider.swift:205:19: error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
203 |       @unknown default:
204 |         return SecurityResultDTO.failure(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
206 |         )
203 |       @unknown default:
204 |         return SecurityResultDTO.failure(
205 |           error: .notImplemented
206 |         )
207 |     }
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Tests/ErrorHandlingTests/ErrorHandlingTests.swiftmodule-0.params)
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:4:18: error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
2 | @testable import ErrorHandlingCore
```


**Error 203:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 4, **Column:** 18
- **Additional Info:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Tests/ErrorHandlingTests/ErrorHandlingTests.swiftmodule-0.params)
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
```


**Error 204:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 49, **Column:** 17
- **Additional Info:** 'ErrorSeverity' is ambiguous for type lookup in this context

```swift
4 | @testable import ErrorHandlingLogging
|                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
|                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
50 |   var isRecoverable: Bool=false
51 |   var recoverySteps: [String]?
```


**Error 205:** cannot find type 'ErrorNotificationHandler' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 18, **Column:** 42
- **Additional Info:** cannot find type 'ErrorNotificationHandler' in scope

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
```


**Error 206:** 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 36, **Column:** 39
- **Additional Info:** The error to provide recovery options for

```swift
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
|                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
37 |     var requestedErrors: [Error]=[]
38 |     var optionsToReturn: RecoveryOptions?
152 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
153 |   /// Get recovery options for a specific error
/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Recovery/RecoveryOptions.swift:52:17: note: found this candidate
50 |
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
45 |
```


**Error 207:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 47, **Column:** 46
- **Additional Info:** Error, withSeverity severity: ErrorSeverity) {

```swift
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
54 |   /// - Parameter error: The error to provide recovery options for
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
3 | /// Severity level for service errors
```


**Error 208:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 46, **Column:** 29
- **Additional Info:** Error, level: ErrorSeverity)]=[]

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
48 |
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 209:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 49, **Column:** 53
- **Additional Info:** 'ErrorSeverity' is ambiguous for type lookup in this context

```swift
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
50 |       loggedErrors.append((error, severity))
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
50 |       loggedErrors.append((error, severity))
51 |     }
```


**Error 210:** cannot find type 'LogDestination' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 53, **Column:** 37
- **Additional Info:** cannot find type 'LogDestination' in scope

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
54 |       // No-op for testing
55 |     }
```


**Error 211:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 222, **Column:** 28
- **Additional Info:** cannot find type 'ErrorLoggingService' in scope

```swift
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
54 |       // No-op for testing
55 |     }
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
224 |   }
```


**Error 212:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 4, **Column:** 18
- **Additional Info:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed

```swift
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
```


**Error 213:** cannot use optional chaining on non-optional value of type '[String : String]'
- **File:** Tests/ErrorHandlingTests/CommonErrorTests.swift
- **Line:** 43, **Column:** 29
- **Additional Info:** cannot use optional chaining on non-optional value of type '[String : String]'

```swift
4 | @testable import ErrorHandlingLogging
|                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
41 |     #expect(context.source == "TestModule")
42 |     #expect(context.message.contains("Service initialization failed"))
43 |     #expect(context.metadata?["operation"] == "serviceInit")
|                             `- error: cannot use optional chaining on non-optional value of type '[String : String]'
41 |     #expect(context.source == "TestModule")
42 |     #expect(context.message.contains("Service initialization failed"))
43 |     #expect(context.metadata?["operation"] == "serviceInit")
44 |     #expect(error.localizedDescription == "Required dependency unavailable: Test service")
45 |   }
```


**Error 214:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 49, **Column:** 17
- **Additional Info:** 'ErrorSeverity' is ambiguous for type lookup in this context

```swift
43 |     #expect(context.metadata?["operation"] == "serviceInit")
|                             `- error: cannot use optional chaining on non-optional value of type '[String : String]'
44 |     #expect(error.localizedDescription == "Required dependency unavailable: Test service")
45 |   }
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
|                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
50 |   var isRecoverable: Bool=false
51 |   var recoverySteps: [String]?
```


**Error 215:** ambiguous use of 'critical'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 27, **Column:** 34
- **Additional Info:** ambiguous use of 'critical'

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
25 |
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
|                                  `- error: ambiguous use of 'critical'
25 |
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
```


**Error 216:** ambiguous use of 'error'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 28, **Column:** 34
- **Additional Info:** ambiguous use of 'error'

```swift
103 |   case critical="Critical"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
104 |
105 |   /// Error that significantly affects functionality
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
|                                  `- error: ambiguous use of 'error'
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
```


**Error 217:** ambiguous use of 'warning'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 29, **Column:** 34
- **Additional Info:** ambiguous use of 'warning'

```swift
106 |   case error="Error"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
107 |
108 |   /// Warning about potential issues or degraded service
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
|                                  `- error: ambiguous use of 'warning'
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
31 |   }
```


**Error 218:** ambiguous use of 'info'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 30, **Column:** 34
- **Additional Info:** ambiguous use of 'info'

```swift
109 |   case warning="Warning"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
110 |
111 |   /// Informational message about non-critical events
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
|                                  `- error: ambiguous use of 'info'
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
31 |   }
32 |
```


**Error 219:** cannot find type 'ErrorNotificationHandler' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 18, **Column:** 42
- **Additional Info:** cannot find type 'ErrorNotificationHandler' in scope

```swift
112 |   case info="Information"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
113 |
114 |   /// Debug information for development purposes
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
```


**Error 220:** 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 36, **Column:** 39
- **Additional Info:** The error to provide recovery options for

```swift
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
|                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
37 |     var requestedErrors: [Error]=[]
38 |     var optionsToReturn: RecoveryOptions?
152 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
153 |   /// Get recovery options for a specific error
/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Recovery/RecoveryOptions.swift:52:17: note: found this candidate
50 |
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
45 |
```


**Error 221:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 47, **Column:** 46
- **Additional Info:** Error, withSeverity severity: ErrorSeverity) {

```swift
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
54 |   /// - Parameter error: The error to provide recovery options for
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:47:46: error: 'ErrorSeverity' is ambiguous for type lookup in this context
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
/Users/mpy/.bazel/execroot/_main/Sources/ErrorHandling/Models/ServiceErrorTypes.swift:5:13: note: found this candidate
3 | /// Severity level for service errors
```


**Error 222:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 46, **Column:** 29
- **Additional Info:** Error, level: ErrorSeverity)]=[]

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
48 |
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 223:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 49, **Column:** 53
- **Additional Info:** 'ErrorSeverity' is ambiguous for type lookup in this context

```swift
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:49:53: error: 'ErrorSeverity' is ambiguous for type lookup in this context
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
50 |       loggedErrors.append((error, severity))
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
50 |       loggedErrors.append((error, severity))
51 |     }
```


**Error 224:** cannot find type 'LogDestination' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 53, **Column:** 37
- **Additional Info:** cannot find type 'LogDestination' in scope

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
54 |       // No-op for testing
55 |     }
```


**Error 225:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 222, **Column:** 28
- **Additional Info:** cannot find type 'ErrorLoggingService' in scope

```swift
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
54 |       // No-op for testing
55 |     }
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
224 |   }
```


**Error 226:** argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 80, **Column:** 41
- **Additional Info:** argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'

```swift
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }
78 |
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
|                                         `- error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
78 |
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
```


**Error 227:** argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 81, **Column:** 43
- **Additional Info:** argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'

```swift
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
|                                         `- error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
|                                           `- error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
83 |   }
```


**Error 228:** argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 82, **Column:** 28
- **Additional Info:** argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'

```swift
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
|                                           `- error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
82 |     errorHandler.setLogger(mockLogger)
83 |   }
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
|                            `- error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
83 |   }
84 |
```


**Error 229:** call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 71, **Column:** 18
- **Additional Info:** call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context

```swift
82 |     errorHandler.setLogger(mockLogger)
|                            `- error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
83 |   }
84 |
69 |
70 |     // Create a fresh ErrorHandler instance for each test
71 |     ErrorHandler.resetSharedInstance()
|                  `- error: call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
69 |
70 |     // Create a fresh ErrorHandler instance for each test
71 |     ErrorHandler.resetSharedInstance()
72 |     errorHandler=ErrorHandler.shared
73 |
```


**Error 230:** type 'ErrorSeverity' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 101, **Column:** 43
- **Additional Info:** type 'ErrorSeverity' has no member 'high'

```swift
12 |   public static let shared=ErrorHandler()
|                     `- note: class property declared here
13 |
14 |   /// The logger used for error logging
99 |
100 |     // When
101 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
99 |
100 |     // When
101 |     errorHandler.handle(error, severity: .high)
102 |
103 |     // Then
```


**Error 231:** type 'Equatable' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 105, **Column:** 55
- **Additional Info:** type 'Equatable' has no member 'high'

```swift
101 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
102 |
103 |     // Then
103 |     // Then
104 |     XCTAssertEqual(mockLogger.loggedErrors.count, 1)
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
|                                                       `- error: type 'Equatable' has no member 'high'
103 |     // Then
104 |     XCTAssertEqual(mockLogger.loggedErrors.count, 1)
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
106 |
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
```


**Error 232:** value of type 'ErrorNotification' has no member 'severity'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 109, **Column:** 33
- **Additional Info:** value of type 'ErrorNotification' has no member 'severity'

```swift
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
|                                                       `- error: type 'Equatable' has no member 'high'
106 |
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
|                                 `- error: value of type 'ErrorNotification' has no member 'severity'
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
```


**Error 233:** type 'Equatable' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 109, **Column:** 44
- **Additional Info:** type 'Equatable' has no member 'high'

```swift
109 |     XCTAssertEqual(notification.severity, .high)
|                                 `- error: value of type 'ErrorNotification' has no member 'severity'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
|                                            `- error: type 'Equatable' has no member 'high'
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
```


**Error 234:** type 'ErrorSeverity' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 125, **Column:** 43
- **Additional Info:** type 'ErrorSeverity' has no member 'high'

```swift
109 |     XCTAssertEqual(notification.severity, .high)
|                                            `- error: type 'Equatable' has no member 'high'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
123 |
124 |     // When
125 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
123 |
124 |     // When
125 |     errorHandler.handle(error, severity: .high)
126 |
127 |     // Then
```


**Error 235:** cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 133, **Column:** 48
- **Additional Info:** cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'

```swift
125 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
126 |
127 |     // Then
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                `- error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
134 |   }
135 |
```


**Error 236:** value of type '[ClosureRecoveryOption]' has no member 'actions'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 133, **Column:** 50
- **Additional Info:** value of type '[ClosureRecoveryOption]' has no member 'actions'

```swift
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                `- error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
134 |   }
135 |
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                  `- error: value of type '[ClosureRecoveryOption]' has no member 'actions'
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
134 |   }
135 |
```


**Error 237:** type 'ErrorSeverity' has no member 'medium'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 154, **Column:** 51
- **Additional Info:** type 'ErrorSeverity' has no member 'medium'

```swift
151 |       XCTAssertTrue(mappedError is SecurityError)
|                                 `- warning: 'is' test is always true
152 |
153 |       // Verify the error is handled properly
152 |
153 |       // Verify the error is handled properly
154 |       errorHandler.handle(mappedError, severity: .medium)
|                                                   `- error: type 'ErrorSeverity' has no member 'medium'
152 |
153 |       // Verify the error is handled properly
154 |       errorHandler.handle(mappedError, severity: .medium)
155 |
156 |       XCTAssertEqual(mockLogger.loggedErrors.count, 1)
```


**Error 238:** cannot find 'ErrorSource' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 168, **Column:** 17
- **Additional Info:** cannot find 'ErrorSource' in scope

```swift
154 |       errorHandler.handle(mappedError, severity: .medium)
|                                                   `- error: type 'ErrorSeverity' has no member 'medium'
155 |
156 |       XCTAssertEqual(mockLogger.loggedErrors.count, 1)
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
|                 `- error: cannot find 'ErrorSource' in scope
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
169 |           file: #file,
170 |           function: #function,
```


**Error 239:** extra argument 'description' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 166, **Column:** 20
- **Additional Info:** extra argument 'description' in call

```swift
168 |         source: ErrorSource(
|                 `- error: cannot find 'ErrorSource' in scope
169 |           file: #file,
170 |           function: #function,
164 |       domain: "TestDomain",
165 |       code: "test_error",
166 |       description: "Test error description",
|                    `- error: extra argument 'description' in call
164 |       domain: "TestDomain",
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
```


**Error 240:** missing argument for parameter 'errorDescription' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 165, **Column:** 25
- **Additional Info:** missing argument for parameter 'errorDescription' in call

```swift
166 |       description: "Test error description",
|                    `- error: extra argument 'description' in call
167 |       context: ErrorContext(
168 |         source: ErrorSource(
163 |     let error=GenericUmbraError(
164 |       domain: "TestDomain",
165 |       code: "test_error",
|                         `- error: missing argument for parameter 'errorDescription' in call
163 |     let error=GenericUmbraError(
164 |       domain: "TestDomain",
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
```


**Error 241:** cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 167, **Column:** 16
- **Additional Info:** cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'

```swift
38 |   public init(
|          `- note: 'init(domain:code:errorDescription:underlyingError:source:context:)' declared here
39 |     domain: String,
40 |     code: String,
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
|                `- error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
169 |           file: #file,
```


**Error 242:** missing argument for parameter 'message' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 174, **Column:** 7
- **Additional Info:** missing argument for parameter 'message' in call

```swift
167 |       context: ErrorContext(
|                `- error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
168 |         source: ErrorSource(
169 |           file: #file,
172 |         ),
173 |         metadata: ["key": "value"]
174 |       )
|       `- error: missing argument for parameter 'message' in call
172 |         ),
173 |         metadata: ["key": "value"]
174 |       )
175 |     )
176 |
```


**Error 243:** type of expression is ambiguous without a type annotation
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 182, **Column:** 5
- **Additional Info:** type of expression is ambiguous without a type annotation

```swift
33 |   public init(
|          `- note: 'init(source:code:message:metadata:numberValues:boolValues:)' declared here
34 |     source: String,
35 |     code: String?=nil,
180 |     XCTAssertEqual(error.errorDescription, "Test error description")
181 |     XCTAssertNotNil(error.errorContext)
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
|     `- error: type of expression is ambiguous without a type annotation
180 |     XCTAssertEqual(error.errorDescription, "Test error description")
181 |     XCTAssertNotNil(error.errorContext)
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
183 |   }
184 |
```


**Error 244:** value of type 'SecurityErrorHandler' has no member 'errorHandler'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 188, **Column:** 21
- **Additional Info:** value of type 'SecurityErrorHandler' has no member 'errorHandler'

```swift
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
|     `- error: type of expression is ambiguous without a type annotation
183 |   }
184 |
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
188 |     securityHandler.errorHandler=errorHandler
|                     `- error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
188 |     securityHandler.errorHandler=errorHandler
189 |
190 |     // When - Handle our direct SecurityError
```


**Error 245:** call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 192, **Column:** 21
- **Additional Info:** Error,

```swift
188 |     securityHandler.errorHandler=errorHandler
|                     `- error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
189 |
190 |     // When - Handle our direct SecurityError
183 |   }
184 |
185 |   func testSecurityErrorHandlerWithMixedErrors() {
|        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
190 |     // When - Handle our direct SecurityError
191 |     let ourError=SecurityError.permissionDenied("Insufficient privileges")
192 |     securityHandler.handleSecurityError(ourError)
193 |
194 |     // Then
80 |   @MainActor // Add MainActor to make this function compatible with ErrorHandler
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:207:21: error: call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
```


**Error 246:** call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 207, **Column:** 21
- **Additional Info:** Error,

```swift
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
82 |     _ error: Error,
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
183 |   }
184 |
185 |   func testSecurityErrorHandlerWithMixedErrors() {
|        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
205 |       userInfo: [NSLocalizedDescriptionKey: "Authorization failed: Access denied to resource"]
206 |     )
207 |     securityHandler.handleSecurityError(externalError)
208 |
209 |     // Then
80 |   @MainActor // Add MainActor to make this function compatible with ErrorHandler
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift:219:5: error: cannot find '_shared' in scope
```


**Error 247:** cannot find '_shared' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 219, **Column:** 5
- **Additional Info:** cannot find '_shared' in scope

```swift
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
82 |     _ error: Error,
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
|     `- error: cannot find '_shared' in scope
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
220 |   }
221 |
```


**Error 248:** 'ErrorHandler' initializer is inaccessible due to 'private' protection level
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 219, **Column:** 13
- **Additional Info:** 'ErrorHandler' initializer is inaccessible due to 'private' protection level

```swift
219 |     _shared=ErrorHandler()
|     `- error: cannot find '_shared' in scope
220 |   }
221 |
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
|             `- error: 'ErrorHandler' initializer is inaccessible due to 'private' protection level
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
220 |   }
221 |
```


**Error 249:** 'logger' is inaccessible due to 'private' protection level
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 223, **Column:** 10
- **Additional Info:** emit-module command failed with exit code 1 (use -v to see invocation)

```swift
6 |     @MainActor private init()
|                        `- note: 'init()' declared here
7 |     @MainActor public func setLogger(_ logger: any ErrorHandlingInterfaces.ErrorLoggingProtocol)
8 |     @MainActor public func setNotificationHandler(_ handler: any ErrorHandlingInterfaces.ErrorNotificationProtocol)
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
|          `- error: 'logger' is inaccessible due to 'private' protection level
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
224 |   }
225 | }
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityBridge/SecurityBridge.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:371:36: error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
369 |
```


**Error 250:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 371, **Column:** 36
- **Additional Info:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityBridge/SecurityBridge.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
```


**Error 251:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1
- **Additional Info:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'

```swift
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
573 |   @objc
574 |   public func generateRandomData(length: Int) async -> NSObject? {
```


**Error 252:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1
- **Additional Info:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
573 |   @objc
574 |   public func generateRandomData(length: Int) async -> NSObject? {
```


**Error 253:** invalid redeclaration of 'mapSecurityError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 981, **Column:** 16
- **Additional Info:** invalid redeclaration of 'mapSecurityError'

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:981:16: error: invalid redeclaration of 'mapSecurityError'
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
```


**Error 254:** invalid redeclaration of 'processSecurityResult(_:transform:)'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 994, **Column:** 16
- **Additional Info:** invalid redeclaration of 'processSecurityResult(_:transform:)'

```swift
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
```


**Error 255:** no type named 'SecurityError' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 1021, **Column:** 8
- **Additional Info:** no type named 'SecurityError' in module 'SecurityProtocolsCore'

```swift
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:1021:8: error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1019 |   private func createSecurityResultDTO(
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
```


**Error 256:** cannot find type 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 371, **Column:** 52
- **Additional Info:** cannot find type 'SecurityProtocolError' in scope

```swift
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
```


**Error 257:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22
- **Additional Info:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'

```swift
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"
```


**Error 258:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22
- **Additional Info:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"
```


**Error 259:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 102, **Column:** 19
- **Additional Info:** expression is 'async' but is not marked with 'await'

```swift
104 |     } catch {
|       `- warning: 'catch' block is unreachable because no errors are thrown in 'do' block
105 |       return .failure(mapError(error))
106 |     }
100 |
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
|                   |   `- note: call is 'async'
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
|                   |   `- note: call is 'async'
103 |       return .success(isValid)
104 |     } catch {
```


**Error 260:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 135, **Column:** 19
- **Additional Info:** cannot find 'cryptoAlgorithmFrom' in scope

```swift
|                   |   `- note: call is 'async'
|                   `- error: expression is 'async' but is not marked with 'await'
103 |       return .success(isValid)
104 |     } catch {
133 |
134 |     // Extract configuration options if present
135 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
133 |
134 |     // Extract configuration options if present
135 |     let algorithm=cryptoAlgorithmFrom(config)
136 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
137 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
```


**Error 261:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 161, **Column:** 53
- **Additional Info:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'

```swift
135 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
136 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
137 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
150 |
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
|         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
161 |       return .success(DataAdapter.secureBytes(from: resultData))
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
```


**Error 262:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 152, **Column:** 22
- **Additional Info:** expression is 'async' but is not marked with 'await'

```swift
152 |       let resultData=try implementation.encryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
153 |         data: dataToEncrypt,
154 |         key: keyData,
150 |
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|                      |   `- note: call is 'async'
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|                      |   `- note: call is 'async'
153 |         data: dataToEncrypt,
154 |         key: keyData,
```


**Error 263:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 176, **Column:** 19
- **Additional Info:** cannot find 'cryptoAlgorithmFrom' in scope

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
153 |         data: dataToEncrypt,
154 |         key: keyData,
174 |
175 |     // Extract configuration options if present
176 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
174 |
175 |     // Extract configuration options if present
176 |     let algorithm=cryptoAlgorithmFrom(config)
177 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
178 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
```


**Error 264:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 202, **Column:** 53
- **Additional Info:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'

```swift
176 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
177 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
178 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
191 |
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
|         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
202 |       return .success(DataAdapter.secureBytes(from: resultData))
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
```


**Error 265:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 193, **Column:** 22
- **Additional Info:** expression is 'async' but is not marked with 'await'

```swift
193 |       let resultData=try implementation.decryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
194 |         data: encryptedData,
195 |         key: keyData,
191 |
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|                      |   `- note: call is 'async'
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|                      |   `- note: call is 'async'
194 |         data: encryptedData,
195 |         key: keyData,
```


**Error 266:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 218, **Column:** 22
- **Additional Info:** cannot find 'cryptoAlgorithmFrom' in scope

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
194 |         data: encryptedData,
195 |         key: keyData,
216 |     // Configure options
217 |     var options: [String: Any]=[:]
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
216 |     // Configure options
217 |     var options: [String: Any]=[:]
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
219 |       options["algorithm"]=algorithm
220 |     }
```


**Error 267:** missing argument for parameter 'keySizeInBits' in call
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 226, **Column:** 36
- **Additional Info:** missing argument for parameter 'keySizeInBits' in call

```swift
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
219 |       options["algorithm"]=algorithm
220 |     }
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
226 |         algorithm: config.algorithm,
|                                    `- error: missing argument for parameter 'keySizeInBits' in call
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
226 |         algorithm: config.algorithm,
227 |         options: config.options
228 |       ).data
```


**Error 268:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 245, **Column:** 22
- **Additional Info:** cannot find 'cryptoAlgorithmFrom' in scope

```swift
223 |       let resultData=try implementation.encryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
243 |     // Configure options
244 |     var options: [String: Any]=[:]
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
243 |     // Configure options
244 |     var options: [String: Any]=[:]
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
246 |       options["algorithm"]=algorithm
247 |     }
```


**Error 269:** missing argument for parameter 'keySizeInBits' in call
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 253, **Column:** 36
- **Additional Info:** missing argument for parameter 'keySizeInBits' in call

```swift
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
246 |       options["algorithm"]=algorithm
247 |     }
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
253 |         algorithm: config.algorithm,
|                                    `- error: missing argument for parameter 'keySizeInBits' in call
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
253 |         algorithm: config.algorithm,
254 |         options: config.options
255 |       ).data
```


**Error 270:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 269, **Column:** 19
- **Additional Info:** cannot find 'cryptoAlgorithmFrom' in scope

```swift
250 |       let resultData=try implementation.decryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
267 |
268 |     // Extract hash algorithm if specified
269 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
267 |
268 |     // Extract hash algorithm if specified
269 |     let algorithm=cryptoAlgorithmFrom(config)
270 |
271 |     // Configure options
```


**Error 271:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 283, **Column:** 53
- **Additional Info:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'

```swift
269 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
270 |
271 |     // Configure options
276 |
277 |     do {
278 |       let resultData=try implementation.hash(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
|         |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|         `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
283 |       return .success(DataAdapter.secureBytes(from: resultData))
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
```


**Error 272:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 278, **Column:** 22
- **Additional Info:** expression is 'async' but is not marked with 'await'

```swift
278 |       let resultData=try implementation.hash(
|                      `- warning: no calls to throwing functions occur within 'try' expression
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
276 |
277 |     do {
278 |       let resultData=try implementation.hash(
|                      |   `- note: call is 'async'
277 |     do {
278 |       let resultData=try implementation.hash(
|                      |   `- note: call is 'async'
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
```


**Error 273:** value of type 'Result<Data, any Error>' has no member 'data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 35, **Column:** 27
- **Additional Info:** value of type 'Result<Data, any Error>' has no member 'data'

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
33 |     let result=await implementation.retrieveKey(withIdentifier: identifier)
34 |
35 |     if let keyData=result.data {
|                           `- error: value of type 'Result<Data, any Error>' has no member 'data'
33 |     let result=await implementation.retrieveKey(withIdentifier: identifier)
34 |
35 |     if let keyData=result.data {
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
```


**Error 274:** cannot find 'KMError' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 38, **Column:** 32
- **Additional Info:** cannot find 'KMError' in scope

```swift
35 |     if let keyData=result.data {
|                           `- error: value of type 'Result<Data, any Error>' has no member 'data'
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
38 |       return .failure(mapError(KMError.keyNotFound))
|                                `- error: cannot find 'KMError' in scope
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
38 |       return .failure(mapError(KMError.keyNotFound))
39 |     }
40 |   }
```


**Error 275:** enum case 'success' cannot be used as an instance member
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 49, **Column:** 8
- **Additional Info:** enum case 'success' cannot be used as an instance member

```swift
38 |       return .failure(mapError(KMError.keyNotFound))
|                                `- error: cannot find 'KMError' in scope
39 |     }
40 |   }
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
|        `- error: enum case 'success' cannot be used as an instance member
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
50 |       return .success(())
51 |     } else {
```


**Error 276:** cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 49, **Column:** 15
- **Additional Info:** cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'

```swift
49 |     if result.success {
|        `- error: enum case 'success' cannot be used as an instance member
50 |       return .success(())
51 |     } else {
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
|               `- error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
50 |       return .success(())
51 |     } else {
```


**Error 277:** value of type 'Result<Void, any Error>' has no member 'errorMessage'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 52, **Column:** 26
- **Additional Info:** value of type 'Result<Void, any Error>' has no member 'errorMessage'

```swift
49 |     if result.success {
|               `- error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
50 |       return .success(())
51 |     } else {
50 |       return .success(())
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
|                          `- error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
50 |       return .success(())
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
53 |       let error=KMError.keyStorageFailed(reason: message)
54 |       return .failure(mapError(error))
```


**Error 278:** cannot find 'KMError' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 53, **Column:** 17
- **Additional Info:** cannot find 'KMError' in scope

```swift
52 |       let message=result.errorMessage ?? "Unknown key storage error"
|                          `- error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
53 |       let error=KMError.keyStorageFailed(reason: message)
54 |       return .failure(mapError(error))
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
53 |       let error=KMError.keyStorageFailed(reason: message)
|                 `- error: cannot find 'KMError' in scope
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
53 |       let error=KMError.keyStorageFailed(reason: message)
54 |       return .failure(mapError(error))
55 |     }
```


**Error 279:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 371, **Column:** 36
- **Additional Info:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'

```swift
53 |       let error=KMError.keyStorageFailed(reason: message)
|                 `- error: cannot find 'KMError' in scope
54 |       return .failure(mapError(error))
55 |     }
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
```


**Error 280:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1
- **Additional Info:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'

```swift
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
573 |   @objc
574 |   public func generateRandomData(length: Int) async -> NSObject? {
```


**Error 281:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1
- **Additional Info:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
573 |   @objc
574 |   public func generateRandomData(length: Int) async -> NSObject? {
```


**Error 282:** invalid redeclaration of 'mapSecurityError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 981, **Column:** 16
- **Additional Info:** invalid redeclaration of 'mapSecurityError'

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:981:16: error: invalid redeclaration of 'mapSecurityError'
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
```


**Error 283:** invalid redeclaration of 'processSecurityResult(_:transform:)'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 994, **Column:** 16
- **Additional Info:** invalid redeclaration of 'processSecurityResult(_:transform:)'

```swift
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
```


**Error 284:** no type named 'SecurityError' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 1021, **Column:** 8
- **Additional Info:** no type named 'SecurityError' in module 'SecurityProtocolsCore'

```swift
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:1021:8: error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1019 |   private func createSecurityResultDTO(
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
```


**Error 285:** missing argument for parameter 'completionHandler' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 84, **Column:** 61
- **Additional Info:** missing argument for parameter 'completionHandler' in call

```swift
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                             `- error: missing argument for parameter 'completionHandler' in call
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
85 |         switch result {
86 |           case .success:
```


**Error 286:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 84, **Column:** 55
- **Additional Info:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 |
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                       `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
85 |         switch result {
86 |           case .success:
```


**Error 287:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 116, **Column:** 13
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'

```swift
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                       `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
85 |         switch result {
86 |           case .success:
114 |       case .keyGenerationFailed:
115 |         UmbraErrors.Security.Protocols.internalError("Key generation failed")
116 |       case .invalidData:
|             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
114 |       case .keyGenerationFailed:
115 |         UmbraErrors.Security.Protocols.internalError("Key generation failed")
116 |       case .invalidData:
117 |         UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data format")
118 |       case .notImplemented:
```


**Error 288:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 193, **Column:** 50
- **Additional Info:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')

```swift
116 |       case .invalidData:
|             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
117 |         UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data format")
118 |       case .notImplemented:
191 |       Task {
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
191 |       Task {
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
```


**Error 289:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 194, **Column:** 29
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'NSData'

```swift
193 |         let result=await serviceProxy.encryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
196 |         )
```


**Error 290:** cannot convert value of type 'Data' to expected argument type 'String?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 195, **Column:** 24
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'String?'

```swift
194 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
195 |           key: keyData ?? Data()
196 |         )
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
196 |         )
197 |
```


**Error 291:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 225, **Column:** 50
- **Additional Info:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')

```swift
195 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
196 |         )
197 |
223 |       Task {
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
223 |       Task {
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
```


**Error 292:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 226, **Column:** 29
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'NSData'

```swift
225 |         let result=await serviceProxy.decryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
228 |         )
```


**Error 293:** cannot convert value of type 'Data' to expected argument type 'String?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 227, **Column:** 24
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'String?'

```swift
226 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
227 |           key: keyData ?? Data()
228 |         )
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
228 |         )
229 |
```


**Error 294:** extraneous argument label 'data:' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 253, **Column:** 47
- **Additional Info:** extraneous argument label 'data:' in call

```swift
227 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
228 |         )
229 |
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                               `- error: extraneous argument label 'data:' in call
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
254 |
255 |         // Map the XPC result to the protocol result
```


**Error 295:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 253, **Column:** 66
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'NSData'

```swift
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                               `- error: extraneous argument label 'data:' in call
254 |
255 |         // Map the XPC result to the protocol result
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                                                  `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
254 |
255 |         // Map the XPC result to the protocol result
```


**Error 296:** argument 'success' must precede argument 'data'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 273, **Column:** 72
- **Additional Info:** error)

```swift
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                                                  `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
254 |
255 |         // Map the XPC result to the protocol result
271 |     switch result {
272 |       case let .success(hashData):
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
|                                                                        `- error: argument 'success' must precede argument 'data'
271 |     switch result {
272 |       case let .success(hashData):
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
274 |       case let .failure(error):
275 |         return SecurityProtocolsCore.SecurityResultDTO(success: false, error: error)
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
|                                                                        `- error: argument 'success' must precede argument 'data'
274 |       case let .failure(error):
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift:285:41: error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
283 |     await withCheckedContinuation { continuation in
```


**Error 297:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 285, **Column:** 41
- **Additional Info:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'

```swift
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
|                                                                        `- error: argument 'success' must precede argument 'data'
274 |       case let .failure(error):
275 |         return SecurityProtocolsCore.SecurityResultDTO(success: false, error: error)
283 |     await withCheckedContinuation { continuation in
284 |       Task {
285 |         let result = await serviceProxy.verify(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
283 |     await withCheckedContinuation { continuation in
284 |       Task {
285 |         let result = await serviceProxy.verify(
286 |           data: DataAdapter.data(from: data),
287 |           signature: DataAdapter.data(from: signature)
```


**Error 298:** missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 358, **Column:** 52
- **Additional Info:** missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call

```swift
285 |         let result = await serviceProxy.verify(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
286 |           data: DataAdapter.data(from: data),
287 |           signature: DataAdapter.data(from: signature)
356 |     await withCheckedContinuation { continuation in
357 |       Task {
358 |         let result = await serviceProxy.generateKey()
|                                                    `- error: missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
356 |     await withCheckedContinuation { continuation in
357 |       Task {
358 |         let result = await serviceProxy.generateKey()
359 |         // Map the XPC result to the protocol result
360 |         switch result {
```


**Error 299:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 379, **Column:** 41
- **Additional Info:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'

```swift
97 |   func generateKey(
|        `- note: 'generateKey(keyType:keyIdentifier:metadata:)' declared here
98 |     keyType: KeyType,
99 |     keyIdentifier: String?,
377 |     await withCheckedContinuation { continuation in
378 |       Task {
379 |         let result = await serviceProxy.generateKeyPair(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
377 |     await withCheckedContinuation { continuation in
378 |       Task {
379 |         let result = await serviceProxy.generateKeyPair(
380 |           type: keyType.rawValue,
381 |           identifier: keyIdentifier ?? ""
```


**Error 300:** cannot convert value of type 'Data' to expected argument type 'SecureBytes'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 442, **Column:** 11
- **Additional Info:** cannot convert value of type 'Data' to expected argument type 'SecureBytes'

```swift
379 |         let result = await serviceProxy.generateKeyPair(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
380 |           type: keyType.rawValue,
381 |           identifier: keyIdentifier ?? ""
440 |         // Use storeSecurely which is the correct XPC method name
441 |         let result=await serviceProxy.storeSecurely(
442 |           dataBytes,
|           `- error: cannot convert value of type 'Data' to expected argument type 'SecureBytes'
440 |         // Use storeSecurely which is the correct XPC method name
441 |         let result=await serviceProxy.storeSecurely(
442 |           dataBytes,
443 |           identifier: identifier,
444 |           metadata: nil
```


**Error 301:** initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 464, **Column:** 12
- **Additional Info:** initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')

```swift
467 |           } else if let data=nsObject as? NSData {
|                                       `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
468 |             // Convert NSData to SecureBytes
469 |             let dataBytes=[UInt8](Data(referencing: data))
462 |
463 |         // Handle the result appropriately
464 |         if let nsObject=result {
|            `- error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
462 |
463 |         // Handle the result appropriately
464 |         if let nsObject=result {
465 |           if let nsError=nsObject as? NSError {
466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
```


**Error 302:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 520, **Column:** 39
- **Additional Info:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'

```swift
464 |         if let nsObject=result {
|            `- error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
465 |           if let nsError=nsObject as? NSError {
466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
518 |         let nsData=dataToReencrypt.map { convertSecureBytesToNSData($0) }
519 |
520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
|                                       `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
518 |         let nsData=dataToReencrypt.map { convertSecureBytesToNSData($0) }
519 |
520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
521 |
522 |         if let nsObject=result {
```


**Error 303:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 582, **Column:** 40
- **Additional Info:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'

```swift
520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
|                                       `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
521 |
522 |         if let nsObject=result {
580 |           with: NSNumber(value: length)
581 |         )?.takeRetainedValue()
582 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
580 |           with: NSNumber(value: length)
581 |         )?.takeRetainedValue()
582 |         continuation.resume(returning: result)
583 |       }
584 |     }
```


**Error 304:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 597, **Column:** 40
- **Additional Info:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'

```swift
582 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
583 |       }
584 |     }
595 |           with: keyIdentifier as NSString?
596 |         )?.takeRetainedValue()
597 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
595 |           with: keyIdentifier as NSString?
596 |         )?.takeRetainedValue()
597 |         continuation.resume(returning: result)
598 |       }
599 |     }
```


**Error 305:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 612, **Column:** 40
- **Additional Info:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'

```swift
597 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
598 |       }
599 |     }
610 |           with: keyIdentifier as NSString?
611 |         )?.takeRetainedValue()
612 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
610 |           with: keyIdentifier as NSString?
611 |         )?.takeRetainedValue()
612 |         continuation.resume(returning: result)
613 |       }
614 |     }
```


**Error 306:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 624, **Column:** 40
- **Additional Info:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'

```swift
612 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
613 |       }
614 |     }
622 |         let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?
623 |           .takeRetainedValue()
624 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
622 |         let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?
623 |           .takeRetainedValue()
624 |         continuation.resume(returning: result)
625 |       }
626 |     }
```


**Error 307:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 639, **Column:** 40
- **Additional Info:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'

```swift
624 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
625 |       }
626 |     }
637 |           with: keyIdentifier
638 |         )?.takeRetainedValue()
639 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
637 |           with: keyIdentifier
638 |         )?.takeRetainedValue()
639 |         continuation.resume(returning: result)
640 |       }
641 |     }
```


**Error 308:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 657, **Column:** 17
- **Additional Info:** extra argument 'with' in call

```swift
639 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
640 |       }
641 |     }
655 |           with: signature,
656 |           with: data,
657 |           with: keyIdentifier
|                 `- error: extra argument 'with' in call
655 |           with: signature,
656 |           with: data,
657 |           with: keyIdentifier
658 |         )?.takeRetainedValue()
659 |         continuation.resume(returning: result)
```


**Error 309:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 731, **Column:** 26
- **Additional Info:** extra argument 'with' in call

```swift
657 |           with: keyIdentifier
|                 `- error: extra argument 'with' in call
658 |         )?.takeRetainedValue()
659 |         continuation.resume(returning: result)
729 |           with: nsData,
730 |           with: identifier,
731 |           with: metadata as NSObject?
|                          `- error: extra argument 'with' in call
729 |           with: nsData,
730 |           with: identifier,
731 |           with: metadata as NSObject?
732 |         )
733 |
```


**Error 310:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 752, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
731 |           with: metadata as NSObject?
|                          `- error: extra argument 'with' in call
732 |         )
733 |
750 |             .resume(returning: .failure(
751 |               UmbraErrors.Security.Protocols
752 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
750 |             .resume(returning: .failure(
751 |               UmbraErrors.Security.Protocols
752 |                 .invalidFormat(reason: "Invalid data")
753 |             ))
754 |           return
```


**Error 311:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 787, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
752 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
753 |             ))
754 |           return
785 |             .resume(returning: .failure(
786 |               UmbraErrors.Security.Protocols
787 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
785 |             .resume(returning: .failure(
786 |               UmbraErrors.Security.Protocols
787 |                 .invalidFormat(reason: "Invalid data")
788 |             ))
789 |           return
```


**Error 312:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 826, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
787 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
788 |             ))
789 |           return
824 |             .resume(returning: .failure(
825 |               UmbraErrors.Security.Protocols
826 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
824 |             .resume(returning: .failure(
825 |               UmbraErrors.Security.Protocols
826 |                 .invalidFormat(reason: "Invalid data")
827 |             ))
828 |         }
```


**Error 313:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 849, **Column:** 26
- **Additional Info:** extra argument 'with' in call

```swift
826 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
827 |             ))
828 |         }
847 |           with: keyType.rawValue,
848 |           with: keyIdentifier as NSString?,
849 |           with: metadata as NSDictionary?
|                          `- error: extra argument 'with' in call
847 |           with: keyType.rawValue,
848 |           with: keyIdentifier as NSString?,
849 |           with: metadata as NSDictionary?
850 |         )?.takeRetainedValue() as? NSString
851 |
```


**Error 314:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 883, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
849 |           with: metadata as NSDictionary?
|                          `- error: extra argument 'with' in call
850 |         )?.takeRetainedValue() as? NSString
851 |
881 |             .resume(returning: .failure(
882 |               UmbraErrors.Security.Protocols
883 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
881 |             .resume(returning: .failure(
882 |               UmbraErrors.Security.Protocols
883 |                 .invalidFormat(reason: "Invalid data")
884 |             ))
885 |           return
```


**Error 315:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 922, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
883 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
884 |             ))
885 |           return
920 |             .resume(returning: .failure(
921 |               UmbraErrors.Security.Protocols
922 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
920 |             .resume(returning: .failure(
921 |               UmbraErrors.Security.Protocols
922 |                 .invalidFormat(reason: "Invalid data")
923 |             ))
924 |         }
```


**Error 316:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 944, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
922 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
923 |             ))
924 |         }
942 |             .resume(returning: .failure(
943 |               UmbraErrors.Security.Protocols
944 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
942 |             .resume(returning: .failure(
943 |               UmbraErrors.Security.Protocols
944 |                 .invalidFormat(reason: "Invalid data")
945 |             ))
946 |           return
```


**Error 317:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 966, **Column:** 18
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
944 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
945 |             ))
946 |           return
964 |             .resume(returning: .failure(
965 |               UmbraErrors.Security.Protocols
966 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
964 |             .resume(returning: .failure(
965 |               UmbraErrors.Security.Protocols
966 |                 .invalidFormat(reason: "Invalid data")
967 |             ))
968 |           return
```


**Error 318:** cannot find type 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 371, **Column:** 52
- **Additional Info:** cannot find type 'SecurityProtocolError' in scope

```swift
966 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
967 |             ))
968 |           return
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
968 |           return
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift:371:52: error: cannot find type 'SecurityProtocolError' in scope
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
```


**Error 319:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22
- **Additional Info:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'

```swift
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"
```


**Error 320:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22
- **Additional Info:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
169 |   @unchecked Sendable {
170 |     public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"
```


**Error 321:** missing argument for parameter 'completionHandler' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 101, **Column:** 60
- **Additional Info:** missing argument for parameter 'completionHandler' in call

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                            `- error: missing argument for parameter 'completionHandler' in call
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
102 |
103 |         // Process the result
```


**Error 322:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 101, **Column:** 54
- **Additional Info:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 |
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                      `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
102 |
103 |         // Process the result
```


**Error 323:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 200, **Column:** 56
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                      `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
102 |
103 |         // Process the result
198 |         return .success(nsNumber.boolValue)
199 |       } else {
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
198 |         return .success(nsNumber.boolValue)
199 |       } else {
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
201 |       }
202 |     }
```


**Error 324:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 276, **Column:** 56
- **Additional Info:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
201 |       }
202 |     }
274 |         return .success(nsString as String)
275 |       } else {
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
274 |         return .success(nsString as String)
275 |       } else {
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
277 |       }
278 |     }
```


**Error 325:** cannot find 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 312, **Column:** 21
- **Additional Info:** cannot find 'SecurityProtocolError' in scope

```swift
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
277 |       }
278 |     }
310 |                 returning: .failure(
311 |                   self.mapSecurityProtocolError(
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
|                     `- error: cannot find 'SecurityProtocolError' in scope
310 |                 returning: .failure(
311 |                   self.mapSecurityProtocolError(
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
313 |                   )
314 |                 )
```


**Error 326:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 337, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'

```swift
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
|                     `- error: cannot find 'SecurityProtocolError' in scope
313 |                   )
314 |                 )
335 |         // (CoreErrors.SecurityError)
336 |         switch securityError {
337 |           case .encryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
335 |         // (CoreErrors.SecurityError)
336 |         switch securityError {
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
```


**Error 327:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 339, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'

```swift
337 |           case .encryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
```


**Error 328:** type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 341, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'

```swift
339 |           case .decryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
```


**Error 329:** type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 343, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'

```swift
341 |           case .keyGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
```


**Error 330:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 343, **Column:** 30
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'

```swift
343 |           case .invalidKey, .invalidInput:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
```


**Error 331:** type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 345, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'

```swift
343 |           case .invalidKey, .invalidInput:
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
```


**Error 332:** type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 345, **Column:** 42
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'

```swift
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                                          `- error: type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
```


**Error 333:** type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 347, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'

```swift
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                                          `- error: type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
```


**Error 334:** type 'UmbraErrors.Security.Protocols' has no member 'timeout'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 349, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'timeout'

```swift
347 |           case .storageOperationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
```


**Error 335:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 349, **Column:** 27
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'

```swift
349 |           case .timeout, .serviceError:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
|                           `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
```


**Error 336:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 353, **Column:** 17
- **Additional Info:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'

```swift
349 |           case .timeout, .serviceError:
|                           `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
```


**Error 337:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 338, **Column:** 45
- **Additional Info:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
353 |           case .notImplemented:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
336 |         switch securityError {
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
336 |         switch securityError {
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
```


**Error 338:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 340, **Column:** 45
- **Additional Info:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
338 |             return CoreErrors.SecurityError.encryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
```


**Error 339:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 342, **Column:** 45
- **Additional Info:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
340 |             return CoreErrors.SecurityError.decryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
```


**Error 340:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 344, **Column:** 51
- **Additional Info:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
342 |             return CoreErrors.SecurityError.keyGenerationFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
```


**Error 341:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 346, **Column:** 45
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'

```swift
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
```


**Error 342:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 348, **Column:** 45
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'

```swift
346 |             return CoreErrors.SecurityError.hashingFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
```


**Error 343:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 350, **Column:** 45
- **Additional Info:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'

```swift
348 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
```


**Error 344:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 352, **Column:** 51
- **Additional Info:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
350 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
```


**Error 345:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 354, **Column:** 45
- **Additional Info:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
```


**Error 346:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 356, **Column:** 51
- **Additional Info:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
354 |             return CoreErrors.SecurityError.notImplemented
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
357 |         }
358 |       } else {
```


**Error 347:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 360, **Column:** 47
- **Additional Info:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')

```swift
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
357 |         }
358 |       } else {
358 |       } else {
359 |         // Map generic error to appropriate error
360 |         return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                               `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
358 |       } else {
359 |         // Map generic error to appropriate error
360 |         return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
361 |       }
362 |     }
```


**Error 348:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 68, **Column:** 15

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityCoreAdapters/SecurityCoreAdapters.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
```


**Error 349:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 75, **Column:** 15

```swift
68 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
69 |     data: SecureBytes,
70 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 350:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 82, **Column:** 15

```swift
75 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
76 |     data: SecureBytes,
77 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 351:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 86, **Column:** 15

```swift
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
83 |     await _hash(data)
84 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 352:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 90, **Column:** 15

```swift
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
87 |     await _generateKey()
88 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 353:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 10, **Column:** 20

```swift
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
91 |     await _generateRandomData(length)
92 |   }
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
|                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 354:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 35, **Column:** 15

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 355:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 47, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
45 |   }
46 |
47 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 356:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 357:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 358:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 359:** property cannot be declared public because its type uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 16

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                `- error: property cannot be declared public because its type uses an internal type
```


**Error 360:** initializer cannot be declared public because its parameter uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 196, **Column:** 12

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
|            `- error: initializer cannot be declared public because its parameter uses an internal type
```


**Error 361:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 7, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
|               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 362:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 68, **Column:** 15

```swift
99 |   /// - Returns: Result containing hash or error
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
```


**Error 363:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 75, **Column:** 15

```swift
68 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
69 |     data: SecureBytes,
70 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 364:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 82, **Column:** 15

```swift
75 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
76 |     data: SecureBytes,
77 |     using key: SecureBytes
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 365:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 86, **Column:** 15

```swift
82 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
83 |     await _hash(data)
84 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 366:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 90, **Column:** 15

```swift
86 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
87 |     await _generateKey()
88 |   }
4 |
5 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 367:** type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 10, **Column:** 20

```swift
90 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
91 |     await _generateRandomData(length)
92 |   }
8 | /// Type-erased wrapper for CryptoServiceProtocol
9 | /// This allows for cleaner interfaces without exposing implementation details
10 | public final class AnyCryptoService: CryptoServiceProtocol {
|                    `- error: type 'AnyCryptoService' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 368:** cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 50, **Column:** 38

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
48 |
49 |     // New property initializations
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
|                                      `- error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
```


**Error 369:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 52, **Column:** 7

```swift
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
|                                      `- error: cannot convert value of type 'Result<Bool, UmbraErrors.Security.Protocols>' to closure result type 'Bool'
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
50 |     _verify={ @Sendable [service] in await service.verify(data: $0, against: $1) }
51 |     _encryptSymmetric={ @Sendable [service] in
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
```


**Error 370:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 55, **Column:** 7

```swift
52 |       await service.encryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
53 |     }
54 |     _decryptSymmetric={ @Sendable [service] in
55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
```


**Error 371:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 58, **Column:** 7

```swift
55 |       await service.decryptSymmetric(data: $0, key: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
56 |     }
57 |     _encryptAsymmetric={ @Sendable [service] in
58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
```


**Error 372:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 61, **Column:** 7

```swift
58 |       await service.encryptAsymmetric(data: $0, publicKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
59 |     }
60 |     _decryptAsymmetric={ @Sendable [service] in
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
```


**Error 373:** cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift
- **Line:** 63, **Column:** 46

```swift
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
|       `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
61 |       await service.decryptAsymmetric(data: $0, privateKey: $1, config: $2)
62 |     }
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
|                                              `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
```


**Error 374:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 35, **Column:** 15

```swift
63 |     _hashWithConfig={ @Sendable [service] in await service.hash(data: $0, config: $1) }
|                                              `- error: cannot convert value of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to closure result type 'SecurityResultDTO'
64 |   }
65 |
33 |   // MARK: - CryptoServiceProtocol Implementation
34 |
35 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 375:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 47, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
45 |   }
46 |
47 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 376:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 377:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 378:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 379:** property cannot be declared public because its type uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 16

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                `- error: property cannot be declared public because its type uses an internal type
```


**Error 380:** initializer cannot be declared public because its parameter uses an internal type
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 196, **Column:** 12

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
194 |     ///   - transformOutputSignature: Transform output signatures
195 |     ///   - transformError: Transform errors
196 |     public init(
|            `- error: initializer cannot be declared public because its parameter uses an internal type
```


**Error 381:** type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 7, **Column:** 15

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
5 | /// This allows us to adapt between different implementations of crypto services
6 | /// without requiring them to directly implement each other's interfaces
7 | public struct CryptoServiceTypeAdapter<
|               `- error: type 'CryptoServiceTypeAdapter<Adaptee>' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 382:** cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 77, **Column:** 12

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
75 |     let transformedHash=transformations.transformInputData?(hash) ?? hash
76 |
77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
|            `- error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
```


**Error 383:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 96, **Column:** 12

```swift
77 |     return await adaptee.verify(data: transformedData, against: transformedHash)
|            `- error: cannot convert return expression of type 'Result<Bool, UmbraErrors.Security.Protocols>' to return type 'Bool'
78 |   }
79 |
94 |     let transformedKey=transformations.transformInputKey?(key) ?? key
95 |
96 |     return await adaptee.encryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 384:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 111, **Column:** 12

```swift
96 |     return await adaptee.encryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
97 |       data: transformedData,
98 |       key: transformedKey,
109 |     let transformedKey=transformations.transformInputKey?(key) ?? key
110 |
111 |     return await adaptee.decryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 385:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 126, **Column:** 12

```swift
111 |     return await adaptee.decryptSymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
112 |       data: transformedData,
113 |       key: transformedKey,
124 |     let transformedKey=transformations.transformInputKey?(publicKey) ?? publicKey
125 |
126 |     return await adaptee.encryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 386:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 141, **Column:** 12

```swift
126 |     return await adaptee.encryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
127 |       data: transformedData,
128 |       publicKey: transformedKey,
139 |     let transformedKey=transformations.transformInputKey?(privateKey) ?? privateKey
140 |
141 |     return await adaptee.decryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 387:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 154, **Column:** 12

```swift
141 |     return await adaptee.decryptAsymmetric(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |       data: transformedData,
143 |       privateKey: transformedKey,
152 |     let transformedData=transformations.transformInputData?(data) ?? data
153 |
154 |     return await adaptee.hash(
|            `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 388:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 196, **Column:** 15

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityImplementation/SecurityImplementation.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
```


**Error 389:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 230, **Column:** 15

```swift
196 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
197 |     data: SecureBytes,
198 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 390:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 264, **Column:** 27

```swift
230 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
231 |     data: SecureBytes,
232 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 391:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 277, **Column:** 27

```swift
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 392:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 291, **Column:** 27

```swift
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 393:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 322, **Column:** 27

```swift
291 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 394:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 341, **Column:** 27

```swift
322 |   public nonisolated func generateMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 395:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 483, **Column:** 15

```swift
341 |   public nonisolated func verifyMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 396:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 544, **Column:** 15

```swift
483 |   public func generateAsymmetricKeyPair() async -> Result<(
|               `- error: method cannot be declared public because its result uses an internal type
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 397:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 642, **Column:** 15

```swift
544 |   public func encryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 398:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 917, **Column:** 27

```swift
642 |   public func decryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 399:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 966, **Column:** 27

```swift
917 |   public nonisolated func sign(
|                           `- error: method cannot be declared public because its result uses an internal type
918 |     data: SecureBytes,
919 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 400:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 987, **Column:** 15

```swift
966 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 401:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1059, **Column:** 27

```swift
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
988 |     // Input validation
989 |     guard length > 0 else {
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 402:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 56, **Column:** 20

```swift
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
|                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
|                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 403:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 14, **Column:** 15

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 404:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 37, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
35 |   }
36 |
37 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 405:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 60, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 406:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 66, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 407:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 79, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 408:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 6, **Column:** 20

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
|                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 409:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 28, **Column:** 15

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 410:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 55, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
53 |   }
54 |
55 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 411:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 77, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 412:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 105, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
103 |   }
104 |
105 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 413:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 171, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 414:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 97, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 415:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 111, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 416:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 122, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 417:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 136, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 418:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 213, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 419:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 229, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 420:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 237, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 421:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 196, **Column:** 15

```swift
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
```


**Error 422:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 230, **Column:** 15

```swift
196 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
197 |     data: SecureBytes,
198 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 423:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 264, **Column:** 27

```swift
230 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
231 |     data: SecureBytes,
232 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 424:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 277, **Column:** 27

```swift
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 425:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 291, **Column:** 27

```swift
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                           `- error: method cannot be declared public because its result uses an internal type
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 426:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 322, **Column:** 27

```swift
291 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
292 |     data: SecureBytes,
293 |     againstHash hash: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 427:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 341, **Column:** 27

```swift
322 |   public nonisolated func generateMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
323 |     for data: SecureBytes,
324 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 428:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 483, **Column:** 15

```swift
341 |   public nonisolated func verifyMAC(
|                           `- error: method cannot be declared public because its result uses an internal type
342 |     _ mac: SecureBytes,
343 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 429:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 544, **Column:** 15

```swift
483 |   public func generateAsymmetricKeyPair() async -> Result<(
|               `- error: method cannot be declared public because its result uses an internal type
484 |     publicKey: SecureBytes,
485 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 430:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 642, **Column:** 15

```swift
544 |   public func encryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
545 |     data: SecureBytes,
546 |     publicKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 431:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 917, **Column:** 27

```swift
642 |   public func decryptAsymmetric(
|               `- error: method cannot be declared public because its result uses an internal type
643 |     data: SecureBytes,
644 |     privateKey: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 432:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 966, **Column:** 27

```swift
917 |   public nonisolated func sign(
|                           `- error: method cannot be declared public because its result uses an internal type
918 |     data: SecureBytes,
919 |     using key: SecureBytes
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 433:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 987, **Column:** 15

```swift
966 |   public nonisolated func verify(
|                           `- error: method cannot be declared public because its result uses an internal type
967 |     signature: SecureBytes,
968 |     for data: SecureBytes,
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 434:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1059, **Column:** 27

```swift
987 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
988 |     // Input validation
989 |     guard length > 0 else {
29 |
30 | // Alias UmbraErrors.Security.Protocols as SecurityError to match the existing code expectations
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
```


**Error 435:** type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 56, **Column:** 20

```swift
1059 |   public nonisolated func generateSecureRandomBytes(count: Int) async
|                           `- error: method cannot be declared public because its result uses an internal type
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
54 | /// All instance methods are marked as isolated to ensure proper actor isolation.
55 | @available(macOS 15.0, iOS 17.0, *)
56 | public final class CryptoService: CryptoServiceProtocol, Sendable {
|                    `- error: type 'CryptoService' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 436:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 85, **Column:** 19

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
83 |         return SecurityResultDTO(
84 |           success: false,
85 |           error: .invalidInput(reason: "No encryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 437:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 90, **Column:** 45

```swift
85 |           error: .invalidInput(reason: "No encryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
86 |         )
87 |       }
88 |
89 |       // Default to AES-GCM with a random IV if not specified
90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
```


**Error 438:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 93, **Column:** 25

```swift
90 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
91 |
92 |       // Encrypt the data
91 |
92 |       // Encrypt the data
93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 439:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 106, **Column:** 17

```swift
93 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
94 |
95 |       // Return IV + encrypted data unless IV is provided in config
104 |       return SecurityResultDTO(
105 |         success: false,
106 |         error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
```


**Error 440:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 129, **Column:** 19

```swift
106 |         error: .encryptionFailed(reason: "Encryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
107 |       )
108 |     }
127 |         return SecurityResultDTO(
128 |           success: false,
129 |           error: .invalidInput(reason: "No decryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 441:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 145, **Column:** 21

```swift
129 |           error: .invalidInput(reason: "No decryption key provided")
|                   `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
130 |         )
131 |       }
143 |           return SecurityResultDTO(
144 |             success: false,
145 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 442:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 155, **Column:** 25

```swift
145 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
146 |           )
147 |         }
153 |
154 |       // Decrypt the data
155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 443:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 161, **Column:** 17

```swift
155 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
156 |
157 |       return SecurityResultDTO(success: true, data: decrypted)
159 |       return SecurityResultDTO(
160 |         success: false,
161 |         error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
```


**Error 444:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 182, **Column:** 20

```swift
161 |         error: .decryptionFailed(reason: "Decryption failed: \(error.localizedDescription)")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
162 |       )
163 |     }
180 |   ) async -> SecurityResultDTO {
181 |     // Use SHA-256 through CryptoWrapper
182 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
```


**Error 445:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 202, **Column:** 14

```swift
182 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
183 |     return SecurityResultDTO(success: true, data: hashedData)
184 |   }
200 |     do {
201 |       // Generate a random IV
202 |       let iv=CryptoWrapper.generateRandomIVSecure()
|              `- error: cannot find 'CryptoWrapper' in scope
```


**Error 446:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 205, **Column:** 25

```swift
202 |       let iv=CryptoWrapper.generateRandomIVSecure()
|              `- error: cannot find 'CryptoWrapper' in scope
203 |
204 |       // Encrypt the data using AES-GCM
203 |
204 |       // Encrypt the data using AES-GCM
205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 447:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 213, **Column:** 10

```swift
205 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
206 |
207 |       // Combine IV with encrypted data
211 |     } catch {
212 |       return .failure(
213 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
```


**Error 448:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 237, **Column:** 26

```swift
213 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
214 |       )
215 |     }
235 |       // Extract IV from combined data (first 12 bytes)
236 |       guard data.count >= 12 else {
237 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 449:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 248, **Column:** 25

```swift
237 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
238 |       }
239 |
246 |
247 |       // Decrypt the data using AES-GCM
248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 450:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 253, **Column:** 10

```swift
248 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
249 |
250 |       return .success(decrypted)
251 |     } catch {
252 |       return .failure(
253 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
```


**Error 451:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 266, **Column:** 13

```swift
253 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
254 |       )
255 |     }
264 |   public nonisolated func generateKey() async -> Result<SecureBytes, SecurityError> {
265 |     // Generate a 256-bit key (32 bytes) using CryptoWrapper
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
|             `- error: cannot find 'CryptoWrapper' in scope
```


**Error 452:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 279, **Column:** 20

```swift
266 |     let key=CryptoWrapper.generateRandomKeySecure(size: 32)
|             `- error: cannot find 'CryptoWrapper' in scope
267 |     return .success(key)
268 |   }
277 |   public nonisolated func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
278 |     // Use SHA-256 through CryptoWrapper
279 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
```


**Error 453:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 295, **Column:** 22

```swift
279 |     let hashedData=CryptoWrapper.sha256(data)
|                    `- error: cannot find 'CryptoWrapper' in scope
280 |     return .success(hashedData)
281 |   }
293 |     againstHash hash: SecureBytes
294 |   ) async -> Result<Bool, SecurityError> {
295 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
```


**Error 454:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 309, **Column:** 22

```swift
295 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
296 |     // Compare the computed hash with the expected hash
297 |     let result=computedHash == hash
307 |   /// Simplified version that returns a boolean directly instead of a Result type.
308 |   public nonisolated func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
309 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
```


**Error 455:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 327, **Column:** 17

```swift
309 |     let computedHash=CryptoWrapper.sha256(data)
|                      `- error: cannot find 'CryptoWrapper' in scope
310 |     return computedHash == hash
311 |   }
325 |   ) async -> Result<SecureBytes, SecurityError> {
326 |     // Use HMAC-SHA256 through CryptoWrapper
327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
|                 `- error: cannot find 'CryptoWrapper' in scope
```


**Error 456:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 346, **Column:** 21

```swift
327 |     let macData=CryptoWrapper.hmacSHA256(data: data, key: key)
|                 `- error: cannot find 'CryptoWrapper' in scope
328 |     return .success(macData)
329 |   }
344 |     using key: SecureBytes
345 |   ) async -> Result<Bool, SecurityError> {
346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
|                     `- error: cannot find 'CryptoWrapper' in scope
```


**Error 457:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 375, **Column:** 45

```swift
346 |     let computedMAC=CryptoWrapper.hmacSHA256(data: data, key: key)
|                     `- error: cannot find 'CryptoWrapper' in scope
347 |     let result=computedMAC == mac
348 |     return .success(result)
373 |     do {
374 |       // Use AES-GCM for symmetric encryption
375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
```


**Error 458:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 378, **Column:** 25

```swift
375 |       let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()
|                                             `- error: cannot find 'CryptoWrapper' in scope
376 |
377 |       // Encrypt the data
376 |
377 |       // Encrypt the data
378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 459:** type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 391, **Column:** 17

```swift
378 |       let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
379 |
380 |       // Return IV + encrypted data unless IV is provided in config
389 |       return SecurityResultDTO(
390 |         success: false,
391 |         error: .encryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
```


**Error 460:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 430, **Column:** 21

```swift
391 |         error: .encryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'encryptionFailed'
392 |           reason: "Symmetric encryption failed: \(error.localizedDescription)"
393 |         )
428 |           return SecurityResultDTO(
429 |             success: false,
430 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 461:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 440, **Column:** 25

```swift
430 |             error: .invalidInput(reason: "Encrypted data too short")
|                     `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
431 |           )
432 |         }
438 |
439 |       // Decrypt the data
440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
```


**Error 462:** type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 446, **Column:** 17

```swift
440 |       let decrypted=try CryptoWrapper.decryptAES_GCM(data: dataToDecrypt, key: key, iv: iv)
|                         `- error: cannot find 'CryptoWrapper' in scope
441 |
442 |       return SecurityResultDTO(success: true, data: decrypted)
444 |       return SecurityResultDTO(
445 |         success: false,
446 |         error: .decryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
```


**Error 463:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 492, **Column:** 14

```swift
446 |         error: .decryptionFailed(
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'decryptionFailed'
447 |           reason: "Symmetric decryption failed: \(error.localizedDescription)"
448 |         )
490 |
491 |     // Generate a seed for the "key pair"
492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
```


**Error 464:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 495, **Column:** 20

```swift
492 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
493 |
494 |     // Generate "public" and "private" keys from the seed
493 |
494 |     // Generate "public" and "private" keys from the seed
495 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
```


**Error 465:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 500, **Column:** 24

```swift
495 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
496 |     var publicKeyBytes=privateKey.bytes()
497 |
498 |     // Ensure we have bytes to modify
499 |     guard !publicKeyBytes.isEmpty else {
500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
```


**Error 466:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 550, **Column:** 24

```swift
500 |       return .failure(.keyGenerationFailed(reason: "Failed to generate key material"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'keyGenerationFailed'
501 |     }
502 |
548 |     // Input validation
549 |     guard !data.isEmpty, !publicKey.isEmpty else {
550 |       return .failure(.invalidInput(reason: "Input data or public key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 467:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 587, **Column:** 17

```swift
550 |       return .failure(.invalidInput(reason: "Input data or public key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
551 |     }
552 |
585 |       return SecurityResultDTO(
586 |         success: false,
587 |         error: .invalidInput(reason: "Input data or public key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 468:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 648, **Column:** 24

```swift
587 |         error: .invalidInput(reason: "Input data or public key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
588 |       )
589 |     }
646 |     // Input validation
647 |     guard !data.isEmpty, !privateKey.isEmpty else {
648 |       return .failure(.invalidInput(reason: "Input data or private key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 469:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 655, **Column:** 24

```swift
648 |       return .failure(.invalidInput(reason: "Input data or private key is empty"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
649 |     }
650 |
653 |     // Verify minimum length and marker
654 |     guard dataBytes.count >= 4 else {
655 |       return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 470:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 662, **Column:** 24

```swift
655 |       return .failure(.invalidInput(reason: "Input data too short for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
656 |     }
657 |
660 |     let expectedMarker: [UInt8]=[0xDE, 0xAD, 0xBE, 0xEF]
661 |     guard marker == expectedMarker else {
662 |       return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 471:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 693, **Column:** 17

```swift
662 |       return .failure(.invalidInput(reason: "Invalid data format for asymmetric decryption"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
663 |     }
664 |
691 |       return SecurityResultDTO(
692 |         success: false,
693 |         error: .invalidInput(reason: "Input data or private key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 472:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 703, **Column:** 17

```swift
693 |         error: .invalidInput(reason: "Input data or private key is empty")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
694 |       )
695 |     }
701 |       return SecurityResultDTO(
702 |         success: false,
703 |         error: .invalidInput(reason: "Input data too short for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 473:** type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 713, **Column:** 17

```swift
703 |         error: .invalidInput(reason: "Input data too short for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
704 |       )
705 |     }
711 |       return SecurityResultDTO(
712 |         success: false,
713 |         error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
```


**Error 474:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 745, **Column:** 14

```swift
713 |         error: .invalidInput(reason: "Invalid data format for asymmetric decryption")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'invalidInput'
714 |       )
715 |     }
743 |
744 |     // Generate a seed for the "key pair"
745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
```


**Error 475:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 748, **Column:** 20

```swift
745 |     let seed=CryptoWrapper.generateRandomKeySecure(size: 32)
|              `- error: cannot find 'CryptoWrapper' in scope
746 |
747 |     // Generate "public" and "private" keys from the seed
746 |
747 |     // Generate "public" and "private" keys from the seed
748 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
```


**Error 476:** type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 755, **Column:** 17

```swift
748 |     let privateKey=CryptoWrapper.sha256(seed)
|                    `- error: cannot find 'CryptoWrapper' in scope
749 |     var publicKeyBytes=privateKey.bytes()
750 |
753 |       return SecurityResultDTO(
754 |         success: false,
755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
```


**Error 477:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 810, **Column:** 14

```swift
755 |         error: .keyGenerationFailed(reason: "Failed to generate key material")
|                 `- error: type 'UmbraErrors.Security.Protocols?' has no member 'keyGenerationFailed'
756 |       )
757 |     }
808 |     }
809 |
810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
|              `- error: cannot find 'CryptoWrapper' in scope
```


**Error 478:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 864, **Column:** 14

```swift
810 |     let hmac=CryptoWrapper.hmacSHA256(data: key, key: publicKey)
|              `- error: cannot find 'CryptoWrapper' in scope
811 |
812 |     // Get the byte arrays safely
862 |     }
863 |
864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
|              `- error: cannot find 'CryptoWrapper' in scope
```


**Error 479:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 923, **Column:** 19

```swift
864 |     let hmac=CryptoWrapper.hmacSHA256(data: encryptedKey, key: privateKey)
|              `- error: cannot find 'CryptoWrapper' in scope
865 |
866 |     // Get the byte arrays safely
921 |     // Use HMAC-SHA256 as a basic signing mechanism
922 |     // In a real implementation, this would use an asymmetric signature algorithm
923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                   `- error: cannot find 'CryptoWrapper' in scope
```


**Error 480:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 971, **Column:** 27

```swift
923 |     let signature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                   `- error: cannot find 'CryptoWrapper' in scope
924 |     return .success(signature)
925 |   }
969 |     using key: SecureBytes
970 |   ) async -> Result<Bool, SecurityError> {
971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                           `- error: cannot find 'CryptoWrapper' in scope
```


**Error 481:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 990, **Column:** 24

```swift
971 |     let computedSignature=CryptoWrapper.hmacSHA256(data: data, key: key)
|                           `- error: cannot find 'CryptoWrapper' in scope
972 |     let result=computedSignature == signature
973 |     return .success(result)
988 |     // Input validation
989 |     guard length > 0 else {
990 |       return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 482:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 997, **Column:** 22

```swift
990 |       return .failure(.invalidInput(reason: "Random data length must be greater than zero"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
991 |     }
992 |
995 |
996 |       // Generate random bytes using CryptoKit's secure random number generator
997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
|                      `- error: cannot find 'CryptoWrapper' in scope
```


**Error 483:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1002, **Column:** 26

```swift
997 |       let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)
|                      `- error: cannot find 'CryptoWrapper' in scope
998 |
999 |       if status {
1000 |         return .success(SecureBytes(bytes: randomBytes))
1001 |       } else {
1002 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
```


**Error 484:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1006, **Column:** 10

```swift
1002 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1003 |       }
1004 |     } catch {
1004 |     } catch {
1005 |       return .failure(
1006 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
```


**Error 485:** cannot find 'isEmpty' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1062, **Column:** 8

```swift
1006 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
1007 |           reason: "Error during random generation: \(error.localizedDescription)"
1008 |         )
1060 |   -> Result<SecureBytes, SecurityError> {
1061 |     // Check for valid count
1062 |     if isEmpty {
|        `- error: cannot find 'isEmpty' in scope
```


**Error 486:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1063, **Column:** 24

```swift
1062 |     if isEmpty {
|        `- error: cannot find 'isEmpty' in scope
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
1064 |     }
1061 |     // Check for valid count
1062 |     if isEmpty {
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 487:** cannot find 'CryptoWrapper' in scope
- **File:** Sources/SecurityImplementation/Sources/CryptoService.swift
- **Line:** 1066, **Column:** 21

```swift
1063 |       return .failure(.invalidInput(reason: "Byte count must be positive"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
1064 |     }
1065 |
1064 |     }
1065 |
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
|                     `- error: cannot find 'CryptoWrapper' in scope
```


**Error 488:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 14, **Column:** 15

```swift
1066 |     return .success(CryptoWrapper.generateRandomKeySecure(size: count))
|                     `- error: cannot find 'CryptoWrapper' in scope
1067 |   }
1068 | }
12 |   // MARK: - CryptoServiceProtocol Implementation
13 |
14 |   public func encrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 489:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 37, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
35 |   }
36 |
37 |   public func decrypt(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 490:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 60, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
58 |   }
59 |
60 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 491:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 66, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
64 |   }
65 |
66 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 492:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 79, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
77 |   /// - Parameter length: The length of random data to generate in bytes
78 |   /// - Returns: Result containing random data or error
79 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 493:** type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 6, **Column:** 20

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
4 |
5 | /// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
6 | public final class CryptoServiceImpl: CryptoServiceProtocol {
|                    `- error: type 'CryptoServiceImpl' does not conform to protocol 'CryptoServiceProtocol'
```


**Error 494:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 32, **Column:** 10

```swift
100 |   func hash(
|        `- note: protocol requires function 'hash(data:config:)' with type '(SecureBytes, SecurityConfigDTO) async -> Result<SecureBytes, UmbraErrors.Security.Protocols>'
101 |     data: SecureBytes,
102 |     config: SecurityConfigDTO
30 |     } catch {
31 |       return .failure(
32 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
```


**Error 495:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 44, **Column:** 26

```swift
32 |         .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
33 |       )
34 |     }
42 |       // Extract IV from combined data (first 12 bytes)
43 |       guard data.count > 12 else {
44 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 496:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 55, **Column:** 10

```swift
44 |         return .failure(.invalidInput(reason: "Encrypted data too short"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
45 |       }
46 |
53 |     } catch {
54 |       return .failure(
55 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
```


**Error 497:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 89, **Column:** 26

```swift
55 |         .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
56 |       )
57 |     }
87 |         return .success(SecureBytes(bytes: randomBytes))
88 |       } else {
89 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
```


**Error 498:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
- **File:** Sources/SecurityImplementation/Sources/CryptoService/CryptoServiceImpl.swift
- **Line:** 93, **Column:** 10

```swift
89 |         return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
|                          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
90 |       }
91 |     } catch {
91 |     } catch {
92 |       return .failure(
93 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
```


**Error 499:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 28, **Column:** 15

```swift
93 |         .randomGenerationFailed(
|          `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'randomGenerationFailed'
94 |           reason: "Error during random generation: \(error.localizedDescription)"
95 |         )
26 |   // MARK: - KeyManagementProtocol Implementation
27 |
28 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 500:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 55, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
53 |   }
54 |
55 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 501:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 77, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
75 |   }
76 |
77 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 502:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 105, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
103 |   }
104 |
105 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 503:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 171, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
169 |   }
170 |
171 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 504:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 39, **Column:** 32

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
37 |           switch error {
38 |             case .keyNotFound:
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 505:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 41, **Column:** 32

```swift
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
39 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
40 |             default:
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 506:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 44, **Column:** 28

```swift
41 |               return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
42 |           }
43 |         @unknown default:
42 |           }
43 |         @unknown default:
44 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 507:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 50, **Column:** 24

```swift
44 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
45 |       }
46 |     }
48 |     // Fallback to in-memory storage
49 |     guard let key=keyStore[identifier] else {
50 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 508:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 66, **Column:** 28

```swift
50 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
51 |     }
52 |     return .success(key)
64 |           return .success(())
65 |         case let .failure(error):
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 509:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 68, **Column:** 28

```swift
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
66 |           return .failure(.storageOperationFailed(reason: "Storage error: \(error)"))
67 |         @unknown default:
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 510:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 87, **Column:** 32

```swift
68 |           return .failure(.storageOperationFailed(reason: "Unknown storage result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
69 |       }
70 |     }
85 |           switch error {
86 |             case .keyNotFound:
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 511:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 89, **Column:** 32

```swift
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
87 |               return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
88 |             default:
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 512:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 92, **Column:** 28

```swift
89 |               return .failure(.storageOperationFailed(reason: "Deletion error: \(error)"))
|                                `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
90 |           }
91 |         @unknown default:
90 |           }
91 |         @unknown default:
92 |           return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 513:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 98, **Column:** 24

```swift
92 |           return .failure(.storageOperationFailed(reason: "Unknown deletion result"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
93 |       }
94 |     }
96 |     // Fallback to in-memory storage
97 |     guard keyStore[identifier] != nil else {
98 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 514:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 118, **Column:** 24

```swift
98 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
99 |     }
100 |
116 |         return .failure(error)
117 |       }
118 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 515:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 131, **Column:** 28

```swift
118 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
119 |     }
120 |
129 |         let ivSize=12 // AES GCM IV size is 12 bytes
130 |         guard dataToReencrypt.count > ivSize else {
131 |           return .failure(.invalidInput(reason: "Data is too short to contain IV"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
```


**Error 516:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManagement/KeyManagementImpl.swift
- **Line:** 155, **Column:** 12

```swift
131 |           return .failure(.invalidInput(reason: "Data is too short to contain IV"))
|                            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'invalidInput'
132 |         }
133 |
153 |       } catch {
154 |         return .failure(
155 |           .storageOperationFailed(
|            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 517:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 97, **Column:** 15

```swift
155 |           .storageOperationFailed(
|            `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
156 |             reason: "Failed to re-encrypt data: \(error.localizedDescription)"
157 |           )
95 |   /// - Parameter identifier: The identifier of the key to retrieve
96 |   /// - Returns: The key or an error if the key does not exist
97 |   public func retrieveKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 518:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 111, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
109 |   ///   - identifier: The identifier to store the key under
110 |   /// - Returns: Success or failure
111 |   public func storeKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 519:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 122, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
120 |   /// - Parameter identifier: The identifier of the key to delete
121 |   /// - Returns: Success or failure
122 |   public func deleteKey(withIdentifier identifier: String) async -> Result<Void, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 520:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 136, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
134 |   ///   - dataToReencrypt: Optional data to re-encrypt with the new key.
135 |   /// - Returns: The new key and re-encrypted data (if provided) or an error.
136 |   public func rotateKey(
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 521:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 213, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
211 |   /// - Parameter identifier: The identifier of the key to rotate
212 |   /// - Returns: The new key or an error if the key does not exist
213 |   public func rotateKey(withIdentifier identifier: String) async
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 522:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 229, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
227 |   /// List all key identifiers
228 |   /// - Returns: A list of all key identifiers
229 |   public func listKeyIdentifiers() async -> Result<[String], SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 523:** method cannot be declared public because its result uses an internal type
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 237, **Column:** 15

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
235 |   /// - Parameter keySize: The size of the key to generate in bits
236 |   /// - Returns: The generated key
237 |   public func generateKey(keySize: Int) async -> Result<SecureBytes, SecurityError> {
|               `- error: method cannot be declared public because its result uses an internal type
```


**Error 524:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 102, **Column:** 17

```swift
31 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
32 |
33 | /// Implementation of CryptoServiceProtocol that provides cryptographic operations
100 |       .success(key)
101 |     } else {
102 |       .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                 `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 525:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 127, **Column:** 24

```swift
102 |       .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                 `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
103 |     }
104 |   }
125 |       return .success(())
126 |     } else {
127 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 526:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 145, **Column:** 24

```swift
127 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
128 |     }
129 |   }
143 |     // Check if the key exists first
144 |     guard let oldKey=await keyStorage.get(identifier: identifier) else {
145 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
```


**Error 527:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 169, **Column:** 34

```swift
145 |       return .failure(.storageOperationFailed(reason: "Key not found: \(identifier)"))
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'storageOperationFailed'
146 |     }
147 |
167 |             case true:
168 |               guard let decryptedData=decryptResult.data else {
169 |                 return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
|                                  `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
```


**Error 528:** type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 183, **Column:** 24

```swift
169 |                 return .failure(.decryptionFailed(reason: "Failed to decrypt data with old key"))
|                                  `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'decryptionFailed'
170 |               }
171 |
181 |                   guard let reencryptedData=encryptResult.data else {
182 |                     return .failure(
183 |                       .encryptionFailed(reason: "Failed to encrypt data with new key")
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
```


**Error 529:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 190, **Column:** 34

```swift
183 |                       .encryptionFailed(reason: "Failed to encrypt data with new key")
|                        `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Protocols') has no member 'encryptionFailed'
184 |                     )
185 |                   }
188 |                   return .failure(
189 |                     encryptResult
190 |                       .error ?? .encryptionFailed(reason: "Unknown encryption error")
|                                  `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
```


**Error 530:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
- **File:** Sources/SecurityImplementation/Sources/KeyManager.swift
- **Line:** 197, **Column:** 30

```swift
190 |                       .error ?? .encryptionFailed(reason: "Unknown encryption error")
|                                  `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
191 |                   )
192 |               }
195 |               return .failure(
196 |                 decryptResult
197 |                   .error ?? .decryptionFailed(reason: "Unknown decryption error")
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
```


**Error 531:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 52, **Column:** 57

```swift
197 |                   .error ?? .decryptionFailed(reason: "Unknown decryption error")
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
198 |               )
199 |           }
50 |             return SecurityResultDTO.failure(
51 |               code: 500,
52 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
```


**Error 532:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 65, **Column:** 16

```swift
52 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
53 |             )
54 |           }
63 |
64 |         // Perform encryption
65 |         return await cryptoService.encryptSymmetric(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 533:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 90, **Column:** 16

```swift
65 |         return await cryptoService.encryptSymmetric(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
66 |           data: data,
67 |           key: key,
88 |
89 |         // Perform hashing
90 |         return await cryptoService.hash(data: data, config: config)
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 534:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 121, **Column:** 65

```swift
90 |         return await cryptoService.hash(data: data, config: config)
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
91 |
92 |       case .macGeneration:
119 |             return SecurityResultDTO.failure(
120 |               code: 500,
121 |               message: "Failed to generate random data: \(error.description)"
|                                                                 `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
```


**Error 535:** value of type 'UmbraErrors.Security.Protocols' has no member 'description'
- **File:** Sources/SecurityImplementation/Sources/Provider/SecurityProviderImpl.swift
- **Line:** 139, **Column:** 57

```swift
121 |               message: "Failed to generate random data: \(error.description)"
|                                                                 `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
122 |             )
123 |           }
137 |             return SecurityResultDTO.failure(
138 |               code: 500,
139 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
```


**Error 536:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 130, **Column:** 22

```swift
139 |               message: "Failed to generate key: \(error.description)"
|                                                         `- error: value of type 'UmbraErrors.Security.Protocols' has no member 'description'
140 |             )
141 |           }
128 |           switch keyResult {
129 |             case let .success(key):
130 |               return await cryptoService.encryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 537:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 137, **Column:** 25

```swift
130 |               return await cryptoService.encryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
131 |                 data: config.inputData ?? SecureBytes(bytes: []),
132 |                 key: key,
135 |             case .failure:
136 |               return SecurityResultDTO.failure(
137 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
```


**Error 538:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 141, **Column:** 18

```swift
137 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
138 |               )
139 |           }
139 |           }
140 |         } else if let key=config.key {
141 |           return await cryptoService.encryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 539:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 148, **Column:** 21

```swift
141 |           return await cryptoService.encryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
142 |             data: config.inputData ?? SecureBytes(bytes: []),
143 |             key: key,
146 |         } else {
147 |           return SecurityResultDTO.failure(
148 |             error: .invalidInput(reason: "No key provided for encryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
```


**Error 540:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 157, **Column:** 22

```swift
148 |             error: .invalidInput(reason: "No key provided for encryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
149 |           )
150 |         }
155 |           switch keyResult {
156 |             case let .success(key):
157 |               return await cryptoService.decryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 541:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 164, **Column:** 25

```swift
157 |               return await cryptoService.decryptSymmetric(
|                      `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
158 |                 data: config.inputData ?? SecureBytes(bytes: []),
159 |                 key: key,
162 |             case .failure:
163 |               return SecurityResultDTO.failure(
164 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
```


**Error 542:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 168, **Column:** 18

```swift
164 |                 error: .serviceError(code: 100, reason: "Key not found: \(keyID)")
|                         `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
165 |               )
166 |           }
166 |           }
167 |         } else if let key=config.key {
168 |           return await cryptoService.decryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 543:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 175, **Column:** 21

```swift
168 |           return await cryptoService.decryptSymmetric(
|                  `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
169 |             data: config.inputData ?? SecureBytes(bytes: []),
170 |             key: key,
173 |         } else {
174 |           return SecurityResultDTO.failure(
175 |             error: .invalidInput(reason: "No key provided for decryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
```


**Error 544:** cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 180, **Column:** 16

```swift
175 |             error: .invalidInput(reason: "No key provided for decryption")
|                     `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
176 |           )
177 |         }
178 |
179 |       case .hashing:
180 |         return await cryptoService.hash(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
```


**Error 545:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 187, **Column:** 19

```swift
180 |         return await cryptoService.hash(
|                `- error: cannot convert return expression of type 'Result<SecureBytes, UmbraErrors.Security.Protocols>' to return type 'SecurityResultDTO'
181 |           data: config.inputData ?? SecureBytes(bytes: []),
182 |           config: config
185 |       case .asymmetricEncryption, .asymmetricDecryption:
186 |         return SecurityResultDTO.failure(
187 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
```


**Error 546:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 192, **Column:** 19

```swift
187 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
188 |         )
189 |
190 |       case .macGeneration, .signatureGeneration, .signatureVerification, .randomGeneration:
191 |         return SecurityResultDTO.failure(
192 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
```


**Error 547:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 197, **Column:** 19

```swift
192 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
193 |         )
194 |
195 |       case .keyGeneration, .keyStorage, .keyRetrieval, .keyRotation, .keyDeletion:
196 |         return SecurityResultDTO.failure(
197 |           error: .serviceError(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
```


**Error 548:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityImplementation/Sources/SecurityProvider.swift
- **Line:** 205, **Column:** 19

```swift
197 |           error: .serviceError(
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
198 |             code: 104,
199 |             reason: "Key management operations should be performed via KeyManagement interface"
203 |       @unknown default:
204 |         return SecurityResultDTO.failure(
205 |           error: .notImplemented
|                   `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
```


**Error 549:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 4, **Column:** 18

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Tests/ErrorHandlingTests/ErrorHandlingTests.swiftmodule-0.params)
# Configuration: b7d4d276ffdb4a998574d8c2dc59bd44eee1e28ad941724b3b91b270374054a3
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
```


**Error 550:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 49, **Column:** 17

```swift
4 | @testable import ErrorHandlingLogging
|                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
|                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 551:** cannot find type 'ErrorNotificationHandler' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 18, **Column:** 42

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
```


**Error 552:** 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 36, **Column:** 39

```swift
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
|                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
```


**Error 553:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 47, **Column:** 46

```swift
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
54 |   /// - Parameter error: The error to provide recovery options for
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 554:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 46, **Column:** 29

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
```


**Error 555:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 49, **Column:** 53

```swift
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 556:** cannot find type 'LogDestination' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 53, **Column:** 37

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
```


**Error 557:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 222, **Column:** 28

```swift
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
54 |       // No-op for testing
55 |     }
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
```


**Error 558:** module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 4, **Column:** 18

```swift
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }
2 | @testable import ErrorHandlingCore
3 | @testable import ErrorHandlingDomains
4 | @testable import ErrorHandlingLogging
```


**Error 559:** cannot use optional chaining on non-optional value of type '[String : String]'
- **File:** Tests/ErrorHandlingTests/CommonErrorTests.swift
- **Line:** 43, **Column:** 29

```swift
4 | @testable import ErrorHandlingLogging
|                  `- error: module 'ErrorHandlingLogging' was not compiled with library evolution support; using it means binary compatibility for 'ErrorHandlingTests' can't be guaranteed
5 | @testable import ErrorHandlingMapping
6 | @testable import ErrorHandlingModels
41 |     #expect(context.source == "TestModule")
42 |     #expect(context.message.contains("Service initialization failed"))
43 |     #expect(context.metadata?["operation"] == "serviceInit")
|                             `- error: cannot use optional chaining on non-optional value of type '[String : String]'
```


**Error 560:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 49, **Column:** 17

```swift
43 |     #expect(context.metadata?["operation"] == "serviceInit")
|                             `- error: cannot use optional chaining on non-optional value of type '[String : String]'
44 |     #expect(error.localizedDescription == "Required dependency unavailable: Test service")
45 |   }
47 |   let contextInfo: [String: String]
48 |   let message: String
49 |   var severity: ErrorSeverity = .error
|                 `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 561:** ambiguous use of 'critical'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 27, **Column:** 34

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
25 |
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
|                                  `- error: ambiguous use of 'critical'
```


**Error 562:** ambiguous use of 'error'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 28, **Column:** 34

```swift
103 |   case critical="Critical"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
104 |
105 |   /// Error that significantly affects functionality
26 |   func testErrorSeverityLevels() {
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
|                                  `- error: ambiguous use of 'error'
```


**Error 563:** ambiguous use of 'warning'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 29, **Column:** 34

```swift
106 |   case error="Error"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
107 |
108 |   /// Warning about potential issues or degraded service
27 |     XCTAssertEqual(ErrorSeverity.critical.rawValue, "critical")
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
|                                  `- error: ambiguous use of 'warning'
```


**Error 564:** ambiguous use of 'info'
- **File:** Tests/ErrorHandlingTests/CoreErrorTests.swift
- **Line:** 30, **Column:** 34

```swift
109 |   case warning="Warning"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
110 |
111 |   /// Informational message about non-critical events
28 |     XCTAssertEqual(ErrorSeverity.error.rawValue, "error")
29 |     XCTAssertEqual(ErrorSeverity.warning.rawValue, "warning")
30 |     XCTAssertEqual(ErrorSeverity.info.rawValue, "info")
|                                  `- error: ambiguous use of 'info'
```


**Error 565:** cannot find type 'ErrorNotificationHandler' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 18, **Column:** 42

```swift
112 |   case info="Information"
|        `- note: found this candidate in module 'ErrorHandlingProtocols'
113 |
114 |   /// Debug information for development purposes
16 |   // MARK: - Test Mocks
17 |
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
```


**Error 566:** 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 36, **Column:** 39

```swift
18 |   private class MockNotificationHandler: ErrorNotificationHandler {
|                                          `- error: cannot find type 'ErrorNotificationHandler' in scope
19 |     var presentedNotifications: [ErrorNotification]=[]
20 |     var dismissedIds: [UUID]=[]
34 |   }
35 |
36 |   private class MockRecoveryProvider: RecoveryOptionsProvider {
|                                       `- error: 'RecoveryOptionsProvider' is ambiguous for type lookup in this context
```


**Error 567:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 47, **Column:** 46

```swift
52 | public protocol RecoveryOptionsProvider {
|                 `- note: found this candidate
53 |   /// Provides recovery options for the specified error
54 |   /// - Parameter error: The error to provide recovery options for
45 |
46 |   private class MockLogger: ErrorLoggingService {
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
|                                              `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 568:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 46, **Column:** 29

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
44 |   }
45 |
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
```


**Error 569:** 'ErrorSeverity' is ambiguous for type lookup in this context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 49, **Column:** 53

```swift
46 |   private class MockLogger: ErrorLoggingService {
|                             `- error: cannot find type 'ErrorLoggingService' in scope
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
47 |     var loggedErrors: [(error: Error, level: ErrorSeverity)]=[]
48 |
49 |     func log(_ error: Error, withSeverity severity: ErrorSeverity) {
|                                                     `- error: 'ErrorSeverity' is ambiguous for type lookup in this context
```


**Error 570:** cannot find type 'LogDestination' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 53, **Column:** 37

```swift
101 | public enum ErrorSeverity: String, Comparable, Sendable {
|             `- note: found this candidate
102 |   /// Critical error that requires immediate attention
103 |   case critical="Critical"
51 |     }
52 |
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
```


**Error 571:** cannot find type 'ErrorLoggingService' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 222, **Column:** 28

```swift
53 |     func configure(destinations _: [LogDestination]) {
|                                     `- error: cannot find type 'LogDestination' in scope
54 |       // No-op for testing
55 |     }
220 |   }
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
```


**Error 572:** argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 80, **Column:** 41

```swift
222 |   func setLogger(_ logger: ErrorLoggingService) {
|                            `- error: cannot find type 'ErrorLoggingService' in scope
223 |     self.logger=logger
224 |   }
78 |
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
|                                         `- error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
```


**Error 573:** argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 81, **Column:** 43

```swift
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
|                                         `- error: argument type 'ErrorHandlingSystemTests.MockNotificationHandler?' does not conform to expected type 'ErrorNotificationProtocol'
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
79 |     // Configure the error handler with mocks
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
|                                           `- error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
```


**Error 574:** argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 82, **Column:** 28

```swift
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
|                                           `- error: argument type 'ErrorHandlingSystemTests.MockRecoveryProvider?' does not conform to expected type 'RecoveryOptionsProvider'
82 |     errorHandler.setLogger(mockLogger)
83 |   }
80 |     errorHandler.setNotificationHandler(mockNotificationHandler)
81 |     errorHandler.registerRecoveryProvider(mockRecoveryProvider)
82 |     errorHandler.setLogger(mockLogger)
|                            `- error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
```


**Error 575:** call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 71, **Column:** 18

```swift
82 |     errorHandler.setLogger(mockLogger)
|                            `- error: argument type 'ErrorHandlingSystemTests.MockLogger?' does not conform to expected type 'ErrorLoggingProtocol'
83 |   }
84 |
69 |
70 |     // Create a fresh ErrorHandler instance for each test
71 |     ErrorHandler.resetSharedInstance()
|                  `- error: call to main actor-isolated static method 'resetSharedInstance()' in a synchronous nonisolated context
```


**Error 576:** type 'ErrorSeverity' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 101, **Column:** 43

```swift
12 |   public static let shared=ErrorHandler()
|                     `- note: class property declared here
13 |
14 |   /// The logger used for error logging
99 |
100 |     // When
101 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
```


**Error 577:** type 'Equatable' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 105, **Column:** 55

```swift
101 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
102 |
103 |     // Then
103 |     // Then
104 |     XCTAssertEqual(mockLogger.loggedErrors.count, 1)
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
|                                                       `- error: type 'Equatable' has no member 'high'
```


**Error 578:** value of type 'ErrorNotification' has no member 'severity'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 109, **Column:** 33

```swift
105 |     XCTAssertEqual(mockLogger.loggedErrors[0].level, .high)
|                                                       `- error: type 'Equatable' has no member 'high'
106 |
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
|                                 `- error: value of type 'ErrorNotification' has no member 'severity'
```


**Error 579:** type 'Equatable' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 109, **Column:** 44

```swift
109 |     XCTAssertEqual(notification.severity, .high)
|                                 `- error: value of type 'ErrorNotification' has no member 'severity'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
107 |     XCTAssertEqual(mockNotificationHandler.presentedNotifications.count, 1)
108 |     let notification=mockNotificationHandler.presentedNotifications[0]
109 |     XCTAssertEqual(notification.severity, .high)
|                                            `- error: type 'Equatable' has no member 'high'
```


**Error 580:** type 'ErrorSeverity' has no member 'high'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 125, **Column:** 43

```swift
109 |     XCTAssertEqual(notification.severity, .high)
|                                            `- error: type 'Equatable' has no member 'high'
110 |     XCTAssertTrue(notification.message.contains("Invalid credentials"))
111 |   }
123 |
124 |     // When
125 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
```


**Error 581:** cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 133, **Column:** 48

```swift
125 |     errorHandler.handle(error, severity: .high)
|                                           `- error: type 'ErrorSeverity' has no member 'high'
126 |
127 |     // Then
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                `- error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
```


**Error 582:** value of type '[ClosureRecoveryOption]' has no member 'actions'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 133, **Column:** 50

```swift
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                `- error: cannot use optional chaining on non-optional value of type '[ClosureRecoveryOption]'
134 |   }
135 |
131 |     let notification=mockNotificationHandler.presentedNotifications[0]
132 |     XCTAssertNotNil(notification.recoveryOptions)
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                  `- error: value of type '[ClosureRecoveryOption]' has no member 'actions'
```


**Error 583:** type 'ErrorSeverity' has no member 'medium'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 154, **Column:** 51

```swift
151 |       XCTAssertTrue(mappedError is SecurityError)
|                                 `- warning: 'is' test is always true
152 |
153 |       // Verify the error is handled properly
152 |
153 |       // Verify the error is handled properly
154 |       errorHandler.handle(mappedError, severity: .medium)
|                                                   `- error: type 'ErrorSeverity' has no member 'medium'
```


**Error 584:** cannot find 'ErrorSource' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 168, **Column:** 17

```swift
154 |       errorHandler.handle(mappedError, severity: .medium)
|                                                   `- error: type 'ErrorSeverity' has no member 'medium'
155 |
156 |       XCTAssertEqual(mockLogger.loggedErrors.count, 1)
166 |       description: "Test error description",
167 |       context: ErrorContext(
168 |         source: ErrorSource(
|                 `- error: cannot find 'ErrorSource' in scope
```


**Error 585:** extra argument 'description' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 166, **Column:** 20

```swift
168 |         source: ErrorSource(
|                 `- error: cannot find 'ErrorSource' in scope
169 |           file: #file,
170 |           function: #function,
164 |       domain: "TestDomain",
165 |       code: "test_error",
166 |       description: "Test error description",
|                    `- error: extra argument 'description' in call
```


**Error 586:** missing argument for parameter 'errorDescription' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 165, **Column:** 25

```swift
166 |       description: "Test error description",
|                    `- error: extra argument 'description' in call
167 |       context: ErrorContext(
168 |         source: ErrorSource(
163 |     let error=GenericUmbraError(
164 |       domain: "TestDomain",
165 |       code: "test_error",
|                         `- error: missing argument for parameter 'errorDescription' in call
```


**Error 587:** cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 167, **Column:** 16

```swift
38 |   public init(
|          `- note: 'init(domain:code:errorDescription:underlyingError:source:context:)' declared here
39 |     domain: String,
40 |     code: String,
165 |       code: "test_error",
166 |       description: "Test error description",
167 |       context: ErrorContext(
|                `- error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
```


**Error 588:** missing argument for parameter 'message' in call
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 174, **Column:** 7

```swift
167 |       context: ErrorContext(
|                `- error: cannot convert value of type 'ErrorContext' to expected argument type 'ErrorContext?'
168 |         source: ErrorSource(
169 |           file: #file,
172 |         ),
173 |         metadata: ["key": "value"]
174 |       )
|       `- error: missing argument for parameter 'message' in call
```


**Error 589:** type of expression is ambiguous without a type annotation
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 182, **Column:** 5

```swift
33 |   public init(
|          `- note: 'init(source:code:message:metadata:numberValues:boolValues:)' declared here
34 |     source: String,
35 |     code: String?=nil,
180 |     XCTAssertEqual(error.errorDescription, "Test error description")
181 |     XCTAssertNotNil(error.errorContext)
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
|     `- error: type of expression is ambiguous without a type annotation
```


**Error 590:** value of type 'SecurityErrorHandler' has no member 'errorHandler'
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 188, **Column:** 21

```swift
182 |     XCTAssertEqual(error.errorContext?.metadata["key"] as? String, "value")
|     `- error: type of expression is ambiguous without a type annotation
183 |   }
184 |
186 |     // Given
187 |     let securityHandler=SecurityErrorHandler.shared
188 |     securityHandler.errorHandler=errorHandler
|                     `- error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
```


**Error 591:** call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 192, **Column:** 21

```swift
188 |     securityHandler.errorHandler=errorHandler
|                     `- error: value of type 'SecurityErrorHandler' has no member 'errorHandler'
189 |
190 |     // When - Handle our direct SecurityError
183 |   }
184 |
185 |   func testSecurityErrorHandlerWithMixedErrors() {
|        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
```


**Error 592:** call to main actor-isolated instance method 'handleSecurityError(_:severity:file:function:line:)' in a synchronous nonisolated context
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 207, **Column:** 21

```swift
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
82 |     _ error: Error,
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
183 |   }
184 |
185 |   func testSecurityErrorHandlerWithMixedErrors() {
|        `- note: add '@MainActor' to make instance method 'testSecurityErrorHandlerWithMixedErrors()' part of global actor 'MainActor'
```


**Error 593:** cannot find '_shared' in scope
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 219, **Column:** 5

```swift
81 |   public func handleSecurityError(
|               `- note: calls to instance method 'handleSecurityError(_:severity:file:function:line:)' from outside of its actor context are implicitly asynchronous
82 |     _ error: Error,
83 |     severity: ErrorHandlingInterfaces.ErrorSeverity = .error,
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
|     `- error: cannot find '_shared' in scope
```


**Error 594:** 'ErrorHandler' initializer is inaccessible due to 'private' protection level
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 219, **Column:** 13

```swift
219 |     _shared=ErrorHandler()
|     `- error: cannot find '_shared' in scope
220 |   }
221 |
217 |   static func resetSharedInstance() {
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
|             `- error: 'ErrorHandler' initializer is inaccessible due to 'private' protection level
```


**Error 595:** 'logger' is inaccessible due to 'private' protection level
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 223, **Column:** 10

```swift
6 |     @MainActor private init()
|                        `- note: 'init()' declared here
7 |     @MainActor public func setLogger(_ logger: any ErrorHandlingInterfaces.ErrorLoggingProtocol)
8 |     @MainActor public func setNotificationHandler(_ handler: any ErrorHandlingInterfaces.ErrorNotificationProtocol)
221 |
222 |   func setLogger(_ logger: ErrorLoggingService) {
223 |     self.logger=logger
|          `- error: 'logger' is inaccessible due to 'private' protection level
```


**Error 596:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 371, **Column:** 36

```swift
XCODE_VERSION_OVERRIDE=16.2.0.16C5032a \
bazel-out/darwin_arm64-opt-exec-ST-d57f47055a04/bin/external/rules_swift+/tools/worker/worker swiftc @bazel-out/darwin_arm64-fastbuild/bin/Sources/SecurityBridge/SecurityBridge.swiftmodule-0.params)
# Configuration: b560fe9a12dbfd17e6ef810dc356d9a5665b4086d7d77994fce922d6283cc880
# Execution platform: @@platforms//host:host
error: emit-module command failed with exit code 1 (use -v to see invocation)
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
```


**Error 597:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1

```swift
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
```


**Error 598:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
```


**Error 599:** invalid redeclaration of 'mapSecurityError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 981, **Column:** 16

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
```


**Error 600:** invalid redeclaration of 'processSecurityResult(_:transform:)'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 994, **Column:** 16

```swift
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
```


**Error 601:** no type named 'SecurityError' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 1021, **Column:** 8

```swift
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
```


**Error 602:** cannot find type 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 371, **Column:** 52

```swift
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
```


**Error 603:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22

```swift
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
```


**Error 604:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
```


**Error 605:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 102, **Column:** 19

```swift
104 |     } catch {
|       `- warning: 'catch' block is unreachable because no errors are thrown in 'do' block
105 |       return .failure(mapError(error))
106 |     }
100 |
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
|                   |   `- note: call is 'async'
```


**Error 606:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 135, **Column:** 19

```swift
|                   |   `- note: call is 'async'
|                   `- error: expression is 'async' but is not marked with 'await'
103 |       return .success(isValid)
104 |     } catch {
133 |
134 |     // Extract configuration options if present
135 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
```


**Error 607:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 161, **Column:** 53

```swift
135 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
136 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
137 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
150 |
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
```


**Error 608:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 152, **Column:** 22

```swift
152 |       let resultData=try implementation.encryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
153 |         data: dataToEncrypt,
154 |         key: keyData,
150 |
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|                      |   `- note: call is 'async'
```


**Error 609:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 176, **Column:** 19

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
153 |         data: dataToEncrypt,
154 |         key: keyData,
174 |
175 |     // Extract configuration options if present
176 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
```


**Error 610:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 202, **Column:** 53

```swift
176 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
177 |     let ivData=config.initializationVector.map { DataAdapter.data(from: $0) }
178 |     let aadData=config.additionalAuthenticatedData.map { DataAdapter.data(from: $0) }
191 |
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
```


**Error 611:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 193, **Column:** 22

```swift
193 |       let resultData=try implementation.decryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
194 |         data: encryptedData,
195 |         key: keyData,
191 |
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|                      |   `- note: call is 'async'
```


**Error 612:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 218, **Column:** 22

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
194 |         data: encryptedData,
195 |         key: keyData,
216 |     // Configure options
217 |     var options: [String: Any]=[:]
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
```


**Error 613:** missing argument for parameter 'keySizeInBits' in call
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 226, **Column:** 36

```swift
218 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
219 |       options["algorithm"]=algorithm
220 |     }
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
226 |         algorithm: config.algorithm,
|                                    `- error: missing argument for parameter 'keySizeInBits' in call
```


**Error 614:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 245, **Column:** 22

```swift
223 |       let resultData=try implementation.encryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
224 |         data: dataToEncrypt,
225 |         publicKey: publicKeyData,
243 |     // Configure options
244 |     var options: [String: Any]=[:]
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
```


**Error 615:** missing argument for parameter 'keySizeInBits' in call
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 253, **Column:** 36

```swift
245 |     if let algorithm=cryptoAlgorithmFrom(config) {
|                      `- error: cannot find 'cryptoAlgorithmFrom' in scope
246 |       options["algorithm"]=algorithm
247 |     }
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
253 |         algorithm: config.algorithm,
|                                    `- error: missing argument for parameter 'keySizeInBits' in call
```


**Error 616:** cannot find 'cryptoAlgorithmFrom' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 269, **Column:** 19

```swift
250 |       let resultData=try implementation.decryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
251 |         data: encryptedData,
252 |         privateKey: privateKeyData,
267 |
268 |     // Extract hash algorithm if specified
269 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
```


**Error 617:** value of optional type 'Data?' must be unwrapped to a value of type 'Data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 283, **Column:** 53

```swift
269 |     let algorithm=cryptoAlgorithmFrom(config)
|                   `- error: cannot find 'cryptoAlgorithmFrom' in scope
270 |
271 |     // Configure options
276 |
277 |     do {
278 |       let resultData=try implementation.hash(
|           `- note: short-circuit using 'guard' to exit this function early if the optional value contains 'nil'
```


**Error 618:** expression is 'async' but is not marked with 'await'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 278, **Column:** 22

```swift
278 |       let resultData=try implementation.hash(
|                      `- warning: no calls to throwing functions occur within 'try' expression
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
276 |
277 |     do {
278 |       let resultData=try implementation.hash(
|                      |   `- note: call is 'async'
```


**Error 619:** value of type 'Result<Data, any Error>' has no member 'data'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 35, **Column:** 27

```swift
|                      |   `- note: call is 'async'
|                      `- error: expression is 'async' but is not marked with 'await'
279 |         data: dataToHash,
280 |         algorithm: config.algorithm,
33 |     let result=await implementation.retrieveKey(withIdentifier: identifier)
34 |
35 |     if let keyData=result.data {
|                           `- error: value of type 'Result<Data, any Error>' has no member 'data'
```


**Error 620:** cannot find 'KMError' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 38, **Column:** 32

```swift
35 |     if let keyData=result.data {
|                           `- error: value of type 'Result<Data, any Error>' has no member 'data'
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
36 |       return .success(DataAdapter.secureBytes(from: keyData))
37 |     } else {
38 |       return .failure(mapError(KMError.keyNotFound))
|                                `- error: cannot find 'KMError' in scope
```


**Error 621:** enum case 'success' cannot be used as an instance member
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 49, **Column:** 8

```swift
38 |       return .failure(mapError(KMError.keyNotFound))
|                                `- error: cannot find 'KMError' in scope
39 |     }
40 |   }
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
|        `- error: enum case 'success' cannot be used as an instance member
```


**Error 622:** cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 49, **Column:** 15

```swift
49 |     if result.success {
|        `- error: enum case 'success' cannot be used as an instance member
50 |       return .success(())
51 |     } else {
47 |     let result=await implementation.storeKey(keyData, withIdentifier: identifier)
48 |
49 |     if result.success {
|               `- error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
```


**Error 623:** value of type 'Result<Void, any Error>' has no member 'errorMessage'
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 52, **Column:** 26

```swift
49 |     if result.success {
|               `- error: cannot convert value of type '(Void) -> Result<Void, any Error>' to expected condition type 'Bool'
50 |       return .success(())
51 |     } else {
50 |       return .success(())
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
|                          `- error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
```


**Error 624:** cannot find 'KMError' in scope
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift
- **Line:** 53, **Column:** 17

```swift
52 |       let message=result.errorMessage ?? "Unknown key storage error"
|                          `- error: value of type 'Result<Void, any Error>' has no member 'errorMessage'
53 |       let error=KMError.keyStorageFailed(reason: message)
54 |       return .failure(mapError(error))
51 |     } else {
52 |       let message=result.errorMessage ?? "Unknown key storage error"
53 |       let error=KMError.keyStorageFailed(reason: message)
|                 `- error: cannot find 'KMError' in scope
```


**Error 625:** no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 371, **Column:** 36

```swift
53 |       let error=KMError.keyStorageFailed(reason: message)
|                 `- error: cannot find 'KMError' in scope
54 |       return .failure(mapError(error))
55 |     }
369 |
370 |   public func generateKeyPair(
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
```


**Error 626:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1

```swift
371 |     keyType: SecurityProtocolsCore.AsymmetricKeyType,
|                                    `- error: no type named 'AsymmetricKeyType' in module 'SecurityProtocolsCore'
372 |     keyIdentifier: String? = nil
373 |   ) async -> Result<
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
```


**Error 627:** type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 572, **Column:** 1

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
570 | // MARK: - XPCServiceProtocolStandard Conformance
571 |
572 | extension XPCServiceAdapter: XPCServiceProtocolStandard {
| `- error: type 'XPCServiceAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
```


**Error 628:** invalid redeclaration of 'mapSecurityError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 981, **Column:** 16

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
979 | extension XPCServiceAdapter {
980 |   /// Convert SecurityBridgeErrors to UmbraErrors.Security.Protocols
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
```


**Error 629:** invalid redeclaration of 'processSecurityResult(_:transform:)'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 994, **Column:** 16

```swift
981 |   private func mapSecurityError(_ error: NSError) -> UmbraErrors.Security.Protocols {
|                `- error: invalid redeclaration of 'mapSecurityError'
982 |     if error.domain == "com.umbra.security.xpc" {
983 |       if let message=error.userInfo[NSLocalizedDescriptionKey] as? String {
992 |
993 |   /// Process security operation result for Swift-based code
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
```


**Error 630:** no type named 'SecurityError' in module 'SecurityProtocolsCore'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 1021, **Column:** 8

```swift
994 |   private func processSecurityResult<T>(
|                `- error: invalid redeclaration of 'processSecurityResult(_:transform:)'
995 |     _ result: NSObject?,
996 |     transform: (NSData) -> T
1019 |   private func createSecurityResultDTO(
1020 |     error: SecurityProtocolsCore
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
```


**Error 631:** missing argument for parameter 'completionHandler' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 84, **Column:** 61

```swift
1021 |       .SecurityError
|        `- error: no type named 'SecurityError' in module 'SecurityProtocolsCore'
1022 |   ) -> SecurityProtocolsCore.SecurityResultDTO {
1023 |     SecurityProtocolsCore.SecurityResultDTO(errorCode: 500, errorMessage: String(describing: error))
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                             `- error: missing argument for parameter 'completionHandler' in call
```


**Error 632:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 84, **Column:** 55

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 |
82 |         // Convert SecureBytes to NSData since serviceProxy expects NSData
83 |         let nsData=convertSecureBytesToNSData(secureBytes)
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                       `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
```


**Error 633:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 116, **Column:** 13

```swift
84 |         let result=await serviceProxy.synchroniseKeys(nsData)
|                                                       `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
85 |         switch result {
86 |           case .success:
114 |       case .keyGenerationFailed:
115 |         UmbraErrors.Security.Protocols.internalError("Key generation failed")
116 |       case .invalidData:
|             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
```


**Error 634:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 193, **Column:** 50

```swift
116 |       case .invalidData:
|             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'invalidData'
117 |         UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data format")
118 |       case .notImplemented:
191 |       Task {
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
```


**Error 635:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 194, **Column:** 29

```swift
193 |         let result=await serviceProxy.encryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
192 |         // Use encryptData instead of encrypt
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
```


**Error 636:** cannot convert value of type 'Data' to expected argument type 'String?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 195, **Column:** 24

```swift
194 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
195 |           key: keyData ?? Data()
196 |         )
193 |         let result=await serviceProxy.encryptData(
194 |           data: DataAdapter.data(from: data),
195 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
```


**Error 637:** incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 225, **Column:** 50

```swift
195 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
196 |         )
197 |
223 |       Task {
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
```


**Error 638:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 226, **Column:** 29

```swift
225 |         let result=await serviceProxy.decryptData(
|                                                  `- error: incorrect argument labels in call (have 'data:key:', expected '_:keyIdentifier:')
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
224 |         // Use decryptData instead of decrypt
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
```


**Error 639:** cannot convert value of type 'Data' to expected argument type 'String?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 227, **Column:** 24

```swift
226 |           data: DataAdapter.data(from: data),
|                             `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
227 |           key: keyData ?? Data()
228 |         )
225 |         let result=await serviceProxy.decryptData(
226 |           data: DataAdapter.data(from: data),
227 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
```


**Error 640:** extraneous argument label 'data:' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 253, **Column:** 47

```swift
227 |           key: keyData ?? Data()
|                        `- error: cannot convert value of type 'Data' to expected argument type 'String?'
228 |         )
229 |
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                               `- error: extraneous argument label 'data:' in call
```


**Error 641:** cannot convert value of type 'Data' to expected argument type 'NSData'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 253, **Column:** 66

```swift
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                               `- error: extraneous argument label 'data:' in call
254 |
255 |         // Map the XPC result to the protocol result
251 |       Task {
252 |         // Use hashData instead of hash
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                                                  `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
```


**Error 642:** argument 'success' must precede argument 'data'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 273, **Column:** 72

```swift
253 |         let result=await serviceProxy.hashData(data: DataAdapter.data(from: data))
|                                                                  `- error: cannot convert value of type 'Data' to expected argument type 'NSData'
254 |
255 |         // Map the XPC result to the protocol result
271 |     switch result {
272 |       case let .success(hashData):
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
|                                                                        `- error: argument 'success' must precede argument 'data'
```


**Error 643:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 285, **Column:** 41

```swift
273 |         return SecurityProtocolsCore.SecurityResultDTO(data: hashData, success: true)
|                                                                        `- error: argument 'success' must precede argument 'data'
274 |       case let .failure(error):
275 |         return SecurityProtocolsCore.SecurityResultDTO(success: false, error: error)
283 |     await withCheckedContinuation { continuation in
284 |       Task {
285 |         let result = await serviceProxy.verify(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
```


**Error 644:** missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 358, **Column:** 52

```swift
285 |         let result = await serviceProxy.verify(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'verify'
286 |           data: DataAdapter.data(from: data),
287 |           signature: DataAdapter.data(from: signature)
356 |     await withCheckedContinuation { continuation in
357 |       Task {
358 |         let result = await serviceProxy.generateKey()
|                                                    `- error: missing arguments for parameters 'keyType', 'keyIdentifier', 'metadata' in call
```


**Error 645:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 379, **Column:** 41

```swift
97 |   func generateKey(
|        `- note: 'generateKey(keyType:keyIdentifier:metadata:)' declared here
98 |     keyType: KeyType,
99 |     keyIdentifier: String?,
377 |     await withCheckedContinuation { continuation in
378 |       Task {
379 |         let result = await serviceProxy.generateKeyPair(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
```


**Error 646:** cannot convert value of type 'Data' to expected argument type 'SecureBytes'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 442, **Column:** 11

```swift
379 |         let result = await serviceProxy.generateKeyPair(
|                                         `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'generateKeyPair'
380 |           type: keyType.rawValue,
381 |           identifier: keyIdentifier ?? ""
440 |         // Use storeSecurely which is the correct XPC method name
441 |         let result=await serviceProxy.storeSecurely(
442 |           dataBytes,
|           `- error: cannot convert value of type 'Data' to expected argument type 'SecureBytes'
```


**Error 647:** initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 464, **Column:** 12

```swift
467 |           } else if let data=nsObject as? NSData {
|                                       `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
468 |             // Convert NSData to SecureBytes
469 |             let dataBytes=[UInt8](Data(referencing: data))
462 |
463 |         // Handle the result appropriately
464 |         if let nsObject=result {
|            `- error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
```


**Error 648:** value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 520, **Column:** 39

```swift
464 |         if let nsObject=result {
|            `- error: initializer for conditional binding must have Optional type, not 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>')
465 |           if let nsError=nsObject as? NSError {
466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
518 |         let nsData=dataToReencrypt.map { convertSecureBytesToNSData($0) }
519 |
520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
|                                       `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
```


**Error 649:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 582, **Column:** 40

```swift
520 |         let result=await serviceProxy.rotateKey(withIdentifier: identifier, dataToReencrypt: nsData)
|                                       `- error: value of type 'any ComprehensiveSecurityServiceProtocol' has no member 'rotateKey'
521 |
522 |         if let nsObject=result {
580 |           with: NSNumber(value: length)
581 |         )?.takeRetainedValue()
582 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
```


**Error 650:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 597, **Column:** 40

```swift
582 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
583 |       }
584 |     }
595 |           with: keyIdentifier as NSString?
596 |         )?.takeRetainedValue()
597 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
```


**Error 651:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 612, **Column:** 40

```swift
597 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
598 |       }
599 |     }
610 |           with: keyIdentifier as NSString?
611 |         )?.takeRetainedValue()
612 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
```


**Error 652:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 624, **Column:** 40

```swift
612 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
613 |       }
614 |     }
622 |         let result=(connection.remoteObjectProxy as AnyObject).perform(selector, with: data)?
623 |           .takeRetainedValue()
624 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
```


**Error 653:** cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 639, **Column:** 40

```swift
624 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
625 |       }
626 |     }
637 |           with: keyIdentifier
638 |         )?.takeRetainedValue()
639 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
```


**Error 654:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 657, **Column:** 17

```swift
639 |         continuation.resume(returning: result)
|                                        `- error: cannot convert value of type 'AnyObject?' to expected argument type 'NSObject?'
640 |       }
641 |     }
655 |           with: signature,
656 |           with: data,
657 |           with: keyIdentifier
|                 `- error: extra argument 'with' in call
```


**Error 655:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 731, **Column:** 26

```swift
657 |           with: keyIdentifier
|                 `- error: extra argument 'with' in call
658 |         )?.takeRetainedValue()
659 |         continuation.resume(returning: result)
729 |           with: nsData,
730 |           with: identifier,
731 |           with: metadata as NSObject?
|                          `- error: extra argument 'with' in call
```


**Error 656:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 752, **Column:** 18

```swift
731 |           with: metadata as NSObject?
|                          `- error: extra argument 'with' in call
732 |         )
733 |
750 |             .resume(returning: .failure(
751 |               UmbraErrors.Security.Protocols
752 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 657:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 787, **Column:** 18

```swift
752 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
753 |             ))
754 |           return
785 |             .resume(returning: .failure(
786 |               UmbraErrors.Security.Protocols
787 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 658:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 826, **Column:** 18

```swift
787 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
788 |             ))
789 |           return
824 |             .resume(returning: .failure(
825 |               UmbraErrors.Security.Protocols
826 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 659:** extra argument 'with' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 849, **Column:** 26

```swift
826 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
827 |             ))
828 |         }
847 |           with: keyType.rawValue,
848 |           with: keyIdentifier as NSString?,
849 |           with: metadata as NSDictionary?
|                          `- error: extra argument 'with' in call
```


**Error 660:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 883, **Column:** 18

```swift
849 |           with: metadata as NSDictionary?
|                          `- error: extra argument 'with' in call
850 |         )?.takeRetainedValue() as? NSString
851 |
881 |             .resume(returning: .failure(
882 |               UmbraErrors.Security.Protocols
883 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 661:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 922, **Column:** 18

```swift
883 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
884 |             ))
885 |           return
920 |             .resume(returning: .failure(
921 |               UmbraErrors.Security.Protocols
922 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 662:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 944, **Column:** 18

```swift
922 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
923 |             ))
924 |         }
942 |             .resume(returning: .failure(
943 |               UmbraErrors.Security.Protocols
944 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 663:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 966, **Column:** 18

```swift
944 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
945 |             ))
946 |           return
964 |             .resume(returning: .failure(
965 |               UmbraErrors.Security.Protocols
966 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 664:** cannot find type 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 371, **Column:** 52

```swift
966 |                 .invalidFormat(reason: "Invalid data")
|                  `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
967 |             ))
968 |           return
369 |     /// - Parameter error: The protocol error to map
370 |     /// - Returns: A properly mapped XPCSecurityError
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
```


**Error 665:** non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22

```swift
371 |     private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
|                                                    `- error: cannot find type 'SecurityProtocolError' in scope
372 |       CoreErrors.SecurityErrorMapper.mapToXPCError(error)
373 |     }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: non-'@objc' method 'ping()' does not satisfy requirement of '@objc' protocol 'XPCServiceProtocolBasic'
```


**Error 666:** type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 168, **Column:** 22

```swift
32 |   public func ping() async -> Bool {
|               `- note: add '@objc' to expose this instance method to Objective-C
33 |     true
34 |   }
166 |   }
167 |
168 |   public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
|                      `- error: type 'SecurityBridge.FoundationToCoreTypesBridgeAdapter' does not conform to protocol 'XPCServiceProtocolBasic'
```


**Error 667:** missing argument for parameter 'completionHandler' in call
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 101, **Column:** 60

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                            `- error: missing argument for parameter 'completionHandler' in call
```


**Error 668:** cannot convert value of type 'NSData' to expected argument type '[UInt8]'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 101, **Column:** 54

```swift
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: 'synchroniseKeys(_:completionHandler:)' declared here
22 | }
23 |
99 |
100 |         // Use the @objc compatible version that takes NSData
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                      `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
```


**Error 669:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 200, **Column:** 56

```swift
101 |         let result=await coreService.synchroniseKeys(nsData)
|                                                      `- error: cannot convert value of type 'NSData' to expected argument type '[UInt8]'
102 |
103 |         // Process the result
198 |         return .success(nsNumber.boolValue)
199 |       } else {
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 670:** cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 276, **Column:** 56

```swift
200 |         return .failure(UmbraErrors.Security.Protocols.internalError("Unknown result type"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
201 |       }
202 |     }
274 |         return .success(nsString as String)
275 |       } else {
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 671:** cannot find 'SecurityProtocolError' in scope
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 312, **Column:** 21

```swift
276 |         return .failure(UmbraErrors.Security.Protocols.internalError("Invalid version format"))
|                                                        `- error: cannot convert value of type 'UmbraErrors.Security.Protocols' to expected argument type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
277 |       }
278 |     }
310 |                 returning: .failure(
311 |                   self.mapSecurityProtocolError(
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
|                     `- error: cannot find 'SecurityProtocolError' in scope
```


**Error 672:** type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 337, **Column:** 17

```swift
312 |                     SecurityProtocolError.implementationMissing("Random data generation failed")
|                     `- error: cannot find 'SecurityProtocolError' in scope
313 |                   )
314 |                 )
335 |         // (CoreErrors.SecurityError)
336 |         switch securityError {
337 |           case .encryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
```


**Error 673:** type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 339, **Column:** 17

```swift
337 |           case .encryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'encryptionFailed'
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
```


**Error 674:** type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 341, **Column:** 17

```swift
339 |           case .decryptionFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'decryptionFailed'
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
```


**Error 675:** type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 343, **Column:** 17

```swift
341 |           case .keyGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'keyGenerationFailed'
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
```


**Error 676:** type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 343, **Column:** 30

```swift
343 |           case .invalidKey, .invalidInput:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidKey'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
```


**Error 677:** type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 345, **Column:** 17

```swift
343 |           case .invalidKey, .invalidInput:
|                              `- error: type 'UmbraErrors.Security.Protocols' has no member 'invalidInput'
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
```


**Error 678:** type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 345, **Column:** 42

```swift
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'hashVerificationFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                                          `- error: type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
```


**Error 679:** type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 347, **Column:** 17

```swift
345 |           case .hashVerificationFailed, .randomGenerationFailed:
|                                          `- error: type 'UmbraErrors.Security.Protocols' has no member 'randomGenerationFailed'
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
```


**Error 680:** type 'UmbraErrors.Security.Protocols' has no member 'timeout'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 349, **Column:** 17

```swift
347 |           case .storageOperationFailed:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'storageOperationFailed'
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
```


**Error 681:** type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 349, **Column:** 27

```swift
349 |           case .timeout, .serviceError:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'timeout'
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
|                           `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
```


**Error 682:** type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 353, **Column:** 17

```swift
349 |           case .timeout, .serviceError:
|                           `- error: type 'UmbraErrors.Security.Protocols' has no member 'serviceError'
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
```


**Error 683:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 338, **Column:** 45

```swift
353 |           case .notImplemented:
|                 `- error: type 'UmbraErrors.Security.Protocols' has no member 'notImplemented'
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
336 |         switch securityError {
337 |           case .encryptionFailed:
338 |             return CoreErrors.SecurityError.encryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 684:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 340, **Column:** 45

```swift
338 |             return CoreErrors.SecurityError.encryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
338 |             return CoreErrors.SecurityError.encryptionFailed
339 |           case .decryptionFailed:
340 |             return CoreErrors.SecurityError.decryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 685:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 342, **Column:** 45

```swift
340 |             return CoreErrors.SecurityError.decryptionFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
340 |             return CoreErrors.SecurityError.decryptionFailed
341 |           case .keyGenerationFailed:
342 |             return CoreErrors.SecurityError.keyGenerationFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 686:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 344, **Column:** 51

```swift
342 |             return CoreErrors.SecurityError.keyGenerationFailed
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
342 |             return CoreErrors.SecurityError.keyGenerationFailed
343 |           case .invalidKey, .invalidInput:
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 687:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 346, **Column:** 45

```swift
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
344 |             return UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid data")
345 |           case .hashVerificationFailed, .randomGenerationFailed:
346 |             return CoreErrors.SecurityError.hashingFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
```


**Error 688:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 348, **Column:** 45

```swift
346 |             return CoreErrors.SecurityError.hashingFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'hashingFailed'
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
346 |             return CoreErrors.SecurityError.hashingFailed
347 |           case .storageOperationFailed:
348 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
```


**Error 689:** type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 350, **Column:** 45

```swift
348 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
348 |             return CoreErrors.SecurityError.serviceFailed
349 |           case .timeout, .serviceError:
350 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
```


**Error 690:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 352, **Column:** 51

```swift
350 |             return CoreErrors.SecurityError.serviceFailed
|                                             `- error: type 'SecurityError' (aka 'UmbraErrors.Security.Core') has no member 'serviceFailed'
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
350 |             return CoreErrors.SecurityError.serviceFailed
351 |           case .internalError:
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 691:** cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 354, **Column:** 45

```swift
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
352 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
353 |           case .notImplemented:
354 |             return CoreErrors.SecurityError.notImplemented
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 692:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 356, **Column:** 51

```swift
354 |             return CoreErrors.SecurityError.notImplemented
|                                             `- error: cannot convert return expression of type '(String) -> UmbraErrors.Security.Core' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
354 |             return CoreErrors.SecurityError.notImplemented
355 |           @unknown default:
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


**Error 693:** cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceProtocolFoundationBridge.swift
- **Line:** 360, **Column:** 47

```swift
356 |             return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                                   `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
357 |         }
358 |       } else {
358 |       } else {
359 |         // Map generic error to appropriate error
360 |         return UmbraErrors.Security.Protocols.internalError(error.localizedDescription)
|                                               `- error: cannot convert return expression of type 'UmbraErrors.Security.Protocols' to return type 'XPCSecurityError' (aka 'UmbraErrors.Security.XPC')
```


#### Warnings

**Warning 1:** 'is' test is always true
- **File:** Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift
- **Line:** 119, **Column:** 17

```swift
107 |     Task { @MainActor in
|          `- warning: task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
108 |       // Since we're now in a MainActor-isolated context, we can safely access
109 |       // the weak reference without crossing actor boundaries
INFO: From Compiling Swift module //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests:
117 |       case let .failure(error):
118 |         XCTAssertTrue(
119 |           error is CoreErrors.SecurityError,
```


**Warning 2:** 'is' test is always true
- **File:** Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift
- **Line:** 119, **Column:** 17

```swift
118 |         XCTAssertTrue(
119 |           error is CoreErrors.SecurityError,
|                 `- warning: 'is' test is always true
120 |           "Error should be mapped to SecurityError"
121 |         )
117 |       case let .failure(error):
118 |         XCTAssertTrue(
119 |           error is CoreErrors.SecurityError,
```


**Warning 3:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 38, **Column:** 34

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
36 |     data: SecureBytes,
37 |     using key: SecureBytes
38 |   ) async -> Result<SecureBytes, SecurityError> {
|                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 4:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 50, **Column:** 34

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
48 |     data: SecureBytes,
49 |     using key: SecureBytes
50 |   ) async -> Result<SecureBytes, SecurityError> {
|                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 5:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 68

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                                                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 6:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 58

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|                                                          |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 7:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 76

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|                                                                            |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 8:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 45

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                                             |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 9:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 63

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                                                               |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 10:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 203, **Column:** 36

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
|                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 11:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 203, **Column:** 54

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
|                                                      |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 12:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 38, **Column:** 34

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
36 |     data: SecureBytes,
37 |     using key: SecureBytes
38 |   ) async -> Result<SecureBytes, SecurityError> {
|                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 13:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 50, **Column:** 34

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
48 |     data: SecureBytes,
49 |     using key: SecureBytes
50 |   ) async -> Result<SecureBytes, SecurityError> {
|                                  |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 14:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 59, **Column:** 68

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
57 |   }
58 |
59 |   public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
|                                                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 15:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 67, **Column:** 58

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
65 |   }
66 |
67 |   public func generateKey() async -> Result<SecureBytes, SecurityError> {
|                                                          |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 16:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 80, **Column:** 76

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
78 |   }
79 |
80 |   public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
|                                                                            |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 17:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 45

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                                             |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 18:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 184, **Column:** 63

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
182 |
183 |     /// Transform errors if needed between the wrapped and exposed service
184 |     public let transformError: ((@Sendable (SecurityError) -> SecurityError))?
|                                                               |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 19:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 203, **Column:** 36

```swift
6 | typealias SecurityError=UmbraErrors.Security.Protocols
|           `- note: type declared here
7 |
8 | /// Type-erased wrapper for CryptoServiceProtocol
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
|                                    |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 20:** 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
- **File:** Sources/SecurityCoreAdapters/Sources/Adapters/CryptoServiceTypeAdapter.swift
- **Line:** 203, **Column:** 54

```swift
70 |     public enum Protocols: Error, Sendable, Equatable {
|                 `- note: type declared here
71 |       /// Data format does not conform to protocol expectations
72 |       case invalidFormat(reason: String)
201 |       transformOutputKey: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
202 |       transformOutputSignature: ((@Sendable (SecureBytes) -> SecureBytes))?=nil,
203 |       transformError: ((@Sendable (SecurityError) -> SecurityError))?=nil
|                                                      |- warning: 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' and cannot be used here because 'ErrorHandlingDomains' was not imported by this file; this is an error in the Swift 6 language mode
```


**Warning 21:** main actor-isolated class property 'shared' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 72, **Column:** 31

```swift
217 |   static func resetSharedInstance() {
|               `- note: calls to static method 'resetSharedInstance()' from outside of its actor context are implicitly asynchronous
218 |     // This is a testing utility to reset the shared instance
219 |     _shared=ErrorHandler()
70 |     // Create a fresh ErrorHandler instance for each test
71 |     ErrorHandler.resetSharedInstance()
72 |     errorHandler=ErrorHandler.shared
|                               `- warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
```


**Warning 22:** 'is' test is always true
- **File:** Tests/ErrorHandlingTests/ErrorHandlingSystemTests.swift
- **Line:** 151, **Column:** 33

```swift
133 |     XCTAssertEqual(notification.recoveryOptions?.actions.count, 2)
|                                                  `- error: value of type '[ClosureRecoveryOption]' has no member 'actions'
134 |   }
135 |
149 |     XCTAssertNotNil(mappedError)
150 |     if let mappedError {
151 |       XCTAssertTrue(mappedError is SecurityError)
|                                 `- warning: 'is' test is always true
```


**Warning 23:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 102, **Column:** 19

```swift
20 |   @objc
21 |   func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void)
|        `- note: protocol requires function 'synchroniseKeys(_:completionHandler:)' with type '([UInt8], @escaping (NSError?) -> Void) -> ()'
22 | }
23 |
100 |
101 |     do {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
```


**Warning 24:** 'catch' block is unreachable because no errors are thrown in 'do' block
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 104, **Column:** 7

```swift
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
|                   `- warning: no calls to throwing functions occur within 'try' expression
103 |       return .success(isValid)
104 |     } catch {
102 |       let isValid=try implementation.verify(data: dataToVerify, against: hashData)
103 |       return .success(isValid)
104 |     } catch {
|       `- warning: 'catch' block is unreachable because no errors are thrown in 'do' block
```


**Warning 25:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 152, **Column:** 22

```swift
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
162 |     } catch {
163 |       return .failure(mapError(error))
150 |
151 |     do {
152 |       let resultData=try implementation.encryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
```


**Warning 26:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 193, **Column:** 22

```swift
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
203 |     } catch {
204 |       return .failure(mapError(error))
191 |
192 |     do {
193 |       let resultData=try implementation.decryptSymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
```


**Warning 27:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 223, **Column:** 22

```swift
339 |   func encryptAsymmetric(
|        `- note: 'encryptAsymmetric(data:publicKey:algorithm:keySizeInBits:options:)' declared here
340 |     data: Data,
341 |     publicKey: Data,
221 |
222 |     do {
223 |       let resultData=try implementation.encryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
```


**Warning 28:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 250, **Column:** 22

```swift
348 |   func decryptAsymmetric(
|        `- note: 'decryptAsymmetric(data:privateKey:algorithm:keySizeInBits:options:)' declared here
349 |     data: Data,
350 |     privateKey: Data,
248 |
249 |     do {
250 |       let resultData=try implementation.decryptAsymmetric(
|                      `- warning: no calls to throwing functions occur within 'try' expression
```


**Warning 29:** no calls to throwing functions occur within 'try' expression
- **File:** Sources/SecurityBridge/Sources/ProtocolAdapters/CryptoServiceAdapter.swift
- **Line:** 278, **Column:** 22

```swift
|                                                     |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
|                                                     `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
284 |     } catch {
285 |       return .failure(mapError(error))
276 |
277 |     do {
278 |       let resultData=try implementation.hash(
|                      `- warning: no calls to throwing functions occur within 'try' expression
```


**Warning 30:** cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSError' always fails
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 465, **Column:** 35

```swift
442 |           dataBytes,
|           `- error: cannot convert value of type 'Data' to expected argument type 'SecureBytes'
443 |           identifier: identifier,
444 |           metadata: nil
463 |         // Handle the result appropriately
464 |         if let nsObject=result {
465 |           if let nsError=nsObject as? NSError {
|                                   `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSError' always fails
```


**Warning 31:** cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
- **File:** Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift
- **Line:** 467, **Column:** 39

```swift
465 |           if let nsError=nsObject as? NSError {
|                                   `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSError' always fails
466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
467 |           } else if let data=nsObject as? NSData {
465 |           if let nsError=nsObject as? NSError {
466 |             continuation.resume(returning: .failure(mapSecurityError(nsError)))
467 |           } else if let data=nsObject as? NSData {
|                                       `- warning: cast from 'Result<SecureBytes, XPCSecurityError>' (aka 'Result<SecureBytes, UmbraErrors.Security.XPC>') to unrelated type 'NSData' always fails
```


---

### //Sources/Repositories:Repositories

<a name='__Sources_Repositories_Repositories'></a>

#### Warnings

**Warning 1:** non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
- **File:** Sources/Repositories/FileSystemRepository.swift
- **Line:** 145, **Column:** 10

```swift
Loading: 0 packages loaded
Analyzing: 171 targets (0 packages loaded, 0 targets configured)
Analyzing: 171 targets (0 packages loaded, 22 targets configured)
INFO: From Compiling Swift module //Sources/Repositories:Repositories:
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
|          `- warning: non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
```


**Warning 2:** non-sendable type 'any Decoder' in parameter of the protocol requirement satisfied by nonisolated initializer 'init(from:)' cannot cross actor boundary; this is an error in the Swift 6 language mode
- **File:** Sources/Repositories/FileSystemRepository.swift
- **Line:** 145, **Column:** 10

```swift
Swift.Decoder:1:17: note: protocol 'Decoder' does not conform to the 'Sendable' protocol
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
143 |   @preconcurrency
144 |   @available(*, deprecated, message: "Will need to be refactored for Swift 6")
145 |   public init(from decoder: Decoder) throws {
```


---

### //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities

<a name='__Sources_ErrorHandling_Utilities_ErrorHandlingUtilities'></a>

#### Warnings

**Warning 1:** no 'async' operations occur within 'await' expression
- **File:** Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift
- **Line:** 128, **Column:** 7

```swift
1 | public protocol Decoder {
|                 `- note: protocol 'Decoder' does not conform to the 'Sendable' protocol
2 |     var codingPath: [any CodingKey] { get }
3 |     var userInfo: [CodingUserInfoKey : Any] { get }
INFO: From Compiling Swift module //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities:
126 |     // Report the error
127 |     Task {
128 |       await errorHandler.handle(wrappedError)
```


**Warning 2:** no 'async' operations occur within 'await' expression
- **File:** Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift
- **Line:** 234, **Column:** 19

```swift
128 |       await errorHandler.handle(wrappedError)
|       `- warning: no 'async' operations occur within 'await' expression
129 |       print("Security error handled.")
130 |
232 |         title: action.title,
233 |         description: action.description,
234 |         action: { await action.perform() }
|                   `- warning: no 'async' operations occur within 'await' expression
```


---

### //Sources/UmbraBookmarkService:UmbraBookmarkService

<a name='__Sources_UmbraBookmarkService_UmbraBookmarkService'></a>

#### Warnings

**Warning 1:** task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
- **File:** Sources/UmbraBookmarkService/BookmarkService.swift
- **Line:** 107, **Column:** 10

```swift
234 |         action: { await action.perform() }
|                   `- warning: no 'async' operations occur within 'await' expression
235 |       )
236 |     }
INFO: From Compiling Swift module //Sources/UmbraBookmarkService:UmbraBookmarkService:
105 |     // Use a detached task to handle MainActor-isolated work
106 |     // TODO: Swift 6 compatibility - refactor actor isolation
107 |     Task { @MainActor in
```


---

