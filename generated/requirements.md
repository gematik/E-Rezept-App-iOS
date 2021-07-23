# Requirements

## gemSpec_IDP_Frontend

### [A_19908-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19908-01)


#### `../Sources/IDP/DefaultIDPSession.swift:397`:  Signature check

```
// [REQ:gemSpec_Krypt:A_17207] Only implemented for brainpoolP256r1
// [REQ:gemSpec_IDP_Frontend:A_19908-01] Signature check
guard let verified = try? challenge.challenge.verify(with: document.authentication.cert),
```



### [A_19937](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19937)


#### `../Sources/IDP/internal/RealIDPClient.swift:129`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:180`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:231`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: data) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:279`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:319`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:396`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: data) else {
```



#### `../Sources/IDP/Models/IDPError.swift:58`:  Error formatting

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Error formatting
public var description: String {
```



#### `../Sources/IDP/Models/IDPError.swift:109`:  Localized description of server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Localized description of server errors
case let .internalError(string): return "IDPError.internalError method \(String(describing: string))"
```



### [A_19938-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19938-01)


#### `../Sources/IDP/DefaultIDPSession.swift:181`:  Decrypt, fails if wrong aes key

```
// [REQ:gemSpec_IDP_Frontend:A_19938-01,A_20283-01] Decrypt, fails if wrong aes key
guard let decrypted = try? token.decrypted(with: cryptoBox.aesKey) else {
```



#### `../Sources/IDP/DefaultIDPSession.swift:197`:  Usage

```
idToken: decrypted.idToken, // [REQ:gemSpec_IDP_Frontend:A_19938-01] Usage
ssoToken: exchange.sso,
```



### [A_20068-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20068-01)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:95`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



### [A_20079](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20079)


#### `../Sources/IDP/internal/RealIDPClient.swift:293`:  Network timeouts will traverse the queue as `HTTPError`s.

```
// [REQ:gemSpec_IDP_Frontend:A_20079] Network timeouts will traverse the queue as `HTTPError`s.
$0.asIDPError()
```



### [A_20085](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20085)


#### `../Sources/IDP/Models/IDPError.swift:58`:  Error formatting

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Error formatting
public var description: String {
```



#### `../Sources/IDP/Models/IDPError.swift:99`:  Error localization is not done yet, this is the place to localize

```
// [REQ:gemSpec_IDP_Frontend:A_20085] Error localization is not done yet, this is the place to localize
// accordingly.
switch self {
```



#### `../Sources/IDP/Models/IDPError.swift:109`:  Localized description of server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Localized description of server errors
case let .internalError(string): return "IDPError.internalError method \(String(describing: string))"
```



### [A_20283-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20283-01)


#### `../Sources/IDP/DefaultIDPSession.swift:181`:  Decrypt, fails if wrong aes key

```
// [REQ:gemSpec_IDP_Frontend:A_19938-01,A_20283-01] Decrypt, fails if wrong aes key
guard let decrypted = try? token.decrypted(with: cryptoBox.aesKey) else {
```



#### `../Sources/IDP/DefaultIDPSession.swift:195`:  Usage

```
accessToken: decrypted.accessToken, // [REQ:gemSpec_IDP_Frontend:A_20283-01] Usage
expires: self.time().addingTimeInterval(TimeInterval(token.expiresIn)),
```



### [A_20309](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20309)


#### `../Sources/IDP/DefaultIDPSession.swift:376`:  generation and hashing for codeChallenge

```
// Generate a verifierCode
// [REQ:gemSpec_IDP_Frontend:A_20309] generation and hashing for codeChallenge
guard let verifierCode = try? cryptoBox.generateRandomVerifier(),
```



#### `../Sources/IDP/internal/IDPCrypto.swift:61`:  verifierLength is 32 bytes, encoded to base64 this results in 43 chars

```
// [REQ:gemSpec_IDP_Frontend:A_20309] verifierLength is 32 bytes, encoded to base64 this results in 43 chars
// (32 * 4 / 3 = 42,6)
try randomGenerator(verifierLength).encodeBase64urlsafe().utf8string
```



### [A_20483](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20483)


#### `../Sources/IDP/DefaultIDPSession.swift:385`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20483]
return self.client.requestChallenge(
```



### [A_20499](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20499)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:58`:  Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN

```
// [REQ:gemSpec_IDP_Frontend:A_20499] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
// [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
changeableUserSessionContainer.userSession.secureUserStore.set(token: nil)
```



### [A_20512](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20512)


#### `../Sources/IDP/DefaultIDPSession.swift:231`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20512]
self.storage.set(discovery: nil)
```



#### `../Sources/IDP/Models/DiscoveryDocument.swift:148`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20512]
func isValid(on date: Date) -> Bool {
```



### [A_20526-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20526-01)


#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.swift:130`:  sign and verify with idp

```
// [REQ:gemSpec_eRp_FdV:A_20172]
// [REQ:gemSpec_IDP_Frontend:A_20526-01] sign and verify with idp
func signChallengeWithNFCCard(can: CAN, pin: Format2Pin,
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.swift:156`:  verify with idp

```
// [REQ:gemSpec_eRp_FdV:A_20172]
// [REQ:gemSpec_IDP_Frontend:A_20526-01] verify with idp
private func verifyResultWithIDP(_ signedChallenge: SignedChallenge,
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:164`:  sign

```
// [REQ:gemSpec_IDP_Frontend:A_20526-01] sign
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
func sign(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession)
```



### [A_20527](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20527)


#### `../Sources/IDP/DefaultIDPSession.swift:153`:  Returning the AUTHORIZATION_CODE

```
// [REQ:gemSpec_IDP_Frontend:A_20527] Returning the AUTHORIZATION_CODE
return Just(exchangeToken).setFailureType(to: IDPError.self).eraseToAnyPublisher()
```



### [A_20529-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20529-01)


#### `../Sources/IDP/DefaultIDPSession.swift:166`:  Encryption

```
// [REQ:gemSpec_IDP_Frontend:A_20529-01] Encryption
guard let encryptedKeyVerifier = try? KeyVerifier(
```



### [A_20600](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20600)


#### `../Sources/IDP/internal/RealIDPClient.swift:177`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20600]
return IDPExchangeToken(code: code, sso: sso, state: state)
```



### [A_20601](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20601)


#### `../Sources/IDP/internal/RealIDPClient.swift:97`:  transfer

```
// [REQ:gemSpec_IDP_Frontend:A_20603,A_20601] transfer
URLQueryItem(name: "client_id", value: clientConfig.clientId.urlPercentEscapedString()),
```



### [A_20602](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20602)


#### `../Sources/IDP/IDPInterceptor.swift:56`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20602]
request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
```



### [A_20603](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20603)


#### `../Sources/IDP/internal/RealIDPClient.swift:97`:  transfer

```
// [REQ:gemSpec_IDP_Frontend:A_20603,A_20601] transfer
URLQueryItem(name: "client_id", value: clientConfig.clientId.urlPercentEscapedString()),
```



#### `../Sources/IDP/internal/RealIDPClient.swift:269`:  transfer

```
// [REQ:gemSpec_IDP_Frontend:A_20603] transfer
"client_id": clientConfig.clientId,
```



#### `../Sources/eRpApp/AppConfiguration.swift:15`:  Actual ID

```
// [REQ:gemSpec_IDP_Frontend:A_20603] Actual ID
private static let defaultClientId: String = "eRezeptApp"
```



#### `../Sources/eRpApp/AppConfiguration.swift:56`:  Actual ID

```
// clientId
// [REQ:gemSpec_IDP_Frontend:A_20603] Actual ID
let clientId: String = defaultClientId
```



### [A_20605](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20605)


#### `../Sources/IDP/internal/RealIDPClient.swift:129`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:180`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:231`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: data) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:279`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:319`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
```



#### `../Sources/IDP/internal/RealIDPClient.swift:396`:  Decoding server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605] Decoding server errors
guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: data) else {
```



#### `../Sources/IDP/Models/IDPError.swift:58`:  Error formatting

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Error formatting
public var description: String {
```



#### `../Sources/IDP/Models/IDPError.swift:109`:  Localized description of server errors

```
// [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Localized description of server errors
case let .internalError(string): return "IDPError.internalError method \(String(describing: string))"
```



### [A_20606](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20606)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:38`:  Live URLs not present in NSAppTransportSecurity exception list for allowed

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [A_20608](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20608)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:95`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:207`:  pinned certificates

```
// [REQ:gemSpec_IDP_Frontend:A_20608] pinned certificates
// [REQ:gemSpec_eRp_FdV:A_20033] pinned certificates
"idp.app.ti-dienste.de": [
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:243`:  pinned certificates

```
// [REQ:gemSpec_IDP_Frontend:A_20608] pinned certificates
// [REQ:gemSpec_eRp_FdV:A_20033] pinned certificates
"erp.app.ti-dienste.de": [
```



### [A_20608-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20608-01)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:95`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



### [A_20609](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20609)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:95`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



### [A_20614](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20614)


#### `../Sources/IDP/DefaultIDPSession.swift:224`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623,A_20614]
.validateOrNil(with: trustStoreSession, timeProvider: time)
```



### [A_20617-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20617-01)


#### `../Sources/IDP/DefaultIDPSession.swift:224`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623,A_20614]
.validateOrNil(with: trustStoreSession, timeProvider: time)
```



#### `../Sources/IDP/DefaultIDPSession.swift:249`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
.validate(with: self.trustStoreSession, timeProvider: self.time)
```



#### `../Sources/IDP/DefaultIDPSession.swift:454`: 

```
/// Returns a Publisher that validates the input streams discoveryDocument against the given trustStoreSession. If
/// the validity cannot be verified, the publisher fails with an `IDPError.trustStore` error.
///
/// [REQ:gemSpec_IDP_Frontend:A_20617-01]
/// [REQ:gemSpec_IDP_Frontend:A_20623]
///
/// - Parameter trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the
/// discoveryDocument.
/// - Returns: An AnyPublisher of `DiscoveryDocument`and `IDPError`
func validate(with trustStoreSession: TrustStoreSession,
```



#### `../Sources/IDP/DefaultIDPSession.swift:486`: 

```
/// Returns a Publisher that validates the input streams discoveryDocument and returns nil if validity cannot be
/// checked. All Errors are caught and result in an empty discoveryDocument.
///
/// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
///
/// - Parameters:
///   - trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the disoveryDocument.
///   - time: Time provider to check the discovery document against.
/// - Returns: An AnyPublisher of `DiscoveryDocument`and `Never`.
func validateOrNil(with trustStoreSession: TrustStoreSession,
```



### [A_20618](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20618)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:95`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



### [A_20623](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20623)


#### `../Sources/IDP/DefaultIDPSession.swift:224`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623,A_20614]
.validateOrNil(with: trustStoreSession, timeProvider: time)
```



#### `../Sources/IDP/DefaultIDPSession.swift:249`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
.validate(with: self.trustStoreSession, timeProvider: self.time)
```



#### `../Sources/IDP/DefaultIDPSession.swift:455`: 

```
/// Returns a Publisher that validates the input streams discoveryDocument against the given trustStoreSession. If
/// the validity cannot be verified, the publisher fails with an `IDPError.trustStore` error.
///
/// [REQ:gemSpec_IDP_Frontend:A_20617-01]
/// [REQ:gemSpec_IDP_Frontend:A_20623]
///
/// - Parameter trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the
/// discoveryDocument.
/// - Returns: An AnyPublisher of `DiscoveryDocument`and `IDPError`
func validate(with trustStoreSession: TrustStoreSession,
```



#### `../Sources/IDP/DefaultIDPSession.swift:458`:  Validation call

```
// [REQ:gemSpec_IDP_Frontend:A_20623] Validation call
return trustStoreSession.validate(discoveryDocument: document)
```



#### `../Sources/IDP/DefaultIDPSession.swift:486`: 

```
/// Returns a Publisher that validates the input streams discoveryDocument and returns nil if validity cannot be
/// checked. All Errors are caught and result in an empty discoveryDocument.
///
/// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
///
/// - Parameters:
///   - trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the disoveryDocument.
///   - time: Time provider to check the discovery document against.
/// - Returns: An AnyPublisher of `DiscoveryDocument`and `Never`.
func validateOrNil(with trustStoreSession: TrustStoreSession,
```



#### `../Sources/IDP/DefaultIDPSession.swift:516`:  Validation

```
/// Returns a publisher that checks a discoveryDocument against the trust store. The Stream contains an output
/// boolean for the plain check or an TrustStoreError in case the TrustStoreSession sub streams failed.
///
/// [REQ:gemSpec_IDP_Frontend:A_20623] Validation
///
/// - Parameter discoveryDocument: The DiscoveryDocument that needs to be checked.
/// - Returns: A publisher that contains an output with the check value or an failure if the check failed
/// due to an unerlying error.
func validate(discoveryDocument: DiscoveryDocument) -> AnyPublisher<Bool, TrustStoreError> {
```



#### `../Sources/TrustStore/X509TrustStore.swift:157`:  oid check

```
} else if eeCert.contains(oidBytes: .oidIdpd) { // [REQ:gemSpec_IDP_Frontend:A_20623] oid check
return (vauCerts, idpCerts + [eeCert])
```



#### `../Sources/TrustStore/X509TrustStore.swift:171`:  IDP oid

```
case oidErpVau // 1.2.276.0.76.4.258 == 0x06082A8214004C048202
// [REQ:gemSpec_IDP_Frontend:A_20623] IDP oid
case oidIdpd // 1.2.276.0.76.4.260 == 0x06082A8214004C048204
}
```



### [A_20625](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20625)


#### `../Sources/IDP/DefaultIDPSession.swift:188`:  Validate ID_TOKEN signature

```
// [REQ:gemSpec_IDP_Frontend:A_20625] Validate ID_TOKEN signature
guard let jwt = try? JWT(from: decrypted.idToken),
```



### [A_20700-07](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20700-07)


#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:127`:  Biometrics only, other modes currently not supported

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] Biometrics only, other modes currently not supported
amr: [
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:21`:  sign with C.CH.AUT

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] sign with C.CH.AUT
return challengeSession.sign(
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:109`:  C.CH.AUT

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.sign(challengeSession: challengeSession)
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:267`:  C.CH.AUT

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.readAutCertificate()
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:274`:  sign with C.CH.AUT

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] sign with C.CH.AUT
return session.sign(
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:305`:  perform signature with OpenHealthCardKit

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] perform signature with OpenHealthCardKit
card.sign(data: message)
```



### [A_20740](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20740)


#### `../Sources/IDP/internal/RealIDPClient.swift:106`:  transfer

```
// [REQ:gemSpec_IDP_Frontend:A_20740] transfer
name: "redirect_uri",
```



#### `../Sources/IDP/internal/RealIDPClient.swift:266`:  transfer

```
// [REQ:gemSpec_IDP_Frontend:A_20740] transfer
"redirect_uri": clientConfig.redirectURL.absoluteString,
```



#### `../Sources/eRpApp/AppConfiguration.swift:58`:  Actual redirect uri

```
// [REQ:gemSpec_IDP_Frontend:A_20740] Actual redirect uri
let redirectUri = URL(string: "https://redirect.gematik.de/erezept")! // swiftlint:disable:this force_unwrapping

```



### [A_21322](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21322)


#### `../Sources/eRpApp/Session/KeychainStorage.swift:18`:  Storage implementation uses iOS Keychain

```
// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
```



### [A_21323](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21323)


#### `../Sources/IDP/DefaultIDPSession.swift:161`:  Crypto box contains `Token-Key`

```
// [REQ:gemSpec_IDP_Frontend:A_21323] Crypto box contains `Token-Key`
let cryptoBox = self.cryptoBox
```



### [A_21414](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21414)


#### `../Sources/IDP/DefaultIDPSession.swift:271`:  Encrypt ACCESS_TOKEN when requesting the pairing endpoint

```
// [REQ:gemSpec_IDP_Frontend:A_21414] Encrypt ACCESS_TOKEN when requesting the pairing endpoint
guard let tokenJWT = try? JWT(from: token.accessToken),
```



### [A_21416](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21416)


#### `../Sources/IDP/DefaultIDPSession.swift:265`:  Encryption

```
/// [REQ:gemSpec_IDP_Frontend:A_21416] Encryption
guard let jwe = try? registrationData.encrypted(with: document.encryptionPublicKey,
```



#### `../Sources/IDP/Models/RegistrationData.swift:14`:  Data Structure

```
/// Bundles data needed for creating and verifiying a pairing.
/// [REQ:gemF_Biometrie:A_21415:Registration_Data]
/// [REQ:gemSpec_IDP_Frontend:A_21416] Data Structure
public struct RegistrationData: Claims, Codable {
```



#### `../Sources/IDP/Models/RegistrationData.swift:105`:  Encryption

```
/// [REQ:gemF_Biometrie:A_21415:Encrypted_Registration_Data] Returns JWE encrypted Registration_Data
/// [REQ:gemSpec_IDP_Frontend:A_21416] Encryption
func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
```



### [A_21431](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21431)


#### `../Sources/IDP/DefaultIDPSession.swift:317`:  Encryption

```
/// [REQ:gemSpec_IDP_Frontend:A_21431] Encryption
guard let jwe = try? signedChallenge.encrypted(with: document.encryptionPublicKey,
```



#### `../Sources/IDP/Models/SignedAuthenticationData.swift:33`:  exp header

```
/// [REQ:gemSpec_IDP_Frontend:A_21431] exp header
expiry: originalChallenge.challenge.exp,
```



### [A_21443](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21443)


#### `../Sources/IDP/DefaultIDPSession.swift:297`:  Encrypt ACCESS_TOKEN when requesting the unregister endpoint

```
// [REQ:gemSpec_IDP_Frontend:A_21443] Encrypt ACCESS_TOKEN when requesting the unregister endpoint
guard let tokenJWT = try? JWT(from: token.accessToken),
```



### [A_21574](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21574)


#### `../Sources/eRpApp/Screens/CardWall/Login/CardWallLoginOptionView.swift:98`:  Actual view

```
// [REQ:gemSpec_IDP_Frontend:A_21574] Actual view
private struct PrivacyWarningView: View {
```



#### `../Sources/eRpApp/Screens/CardWall/Login/CardWallLoginOptionDomain.swift:42`:  Present user information

```
// [REQ:gemSpec_IDP_Frontend:A_21574] Present user information
return Effect(value: .presentSecurityWarning)
```



### [A_21576](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21576)


#### `../Sources/IDP/DefaultIDPSession.swift:289`:  deletion call

```
// [REQ:gemSpec_IDP_Frontend:A_21576] deletion call
public func unregisterDevice(_ keyIdentifier: String) -> AnyPublisher<Bool, IDPError> {
```



### [A_21578](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21578)


#### `../Sources/IDP/PrivateKeyContainer.swift:127`:  Enforced via access attribute

```
// [REQ:gemSpec_IDP_Frontend:A_21578,A_21579,A_21580,A_21583] Enforced via access attribute
kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
```



### [A_21579](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21579)


#### `../Sources/IDP/PrivateKeyContainer.swift:127`:  Enforced via access attribute

```
// [REQ:gemSpec_IDP_Frontend:A_21578,A_21579,A_21580,A_21583] Enforced via access attribute
kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
```



### [A_21580](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21580)


#### `../Sources/IDP/PrivateKeyContainer.swift:127`:  Enforced via access attribute

```
// [REQ:gemSpec_IDP_Frontend:A_21578,A_21579,A_21580,A_21583] Enforced via access attribute
kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
```



### [A_21581](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21581)


#### `../Sources/IDP/PrivateKeyContainer.swift:123`:  Algorithm selection

```
// [REQ:gemSpec_IDP_Frontend:A_21581,A_21589] Algorithm selection
kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
```



### [A_21582](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21582)


#### `../Sources/IDP/PrivateKeyContainer.swift:112`:  method selection

```
// [REQ:gemSpec_IDP_Frontend:A_21582] method selection
// [REQ:gemSpec_IDP_Frontend:A_21587] via `.privateKeyUsage`
[.privateKeyUsage,
```



### [A_21583](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21583)


#### `../Sources/IDP/PrivateKeyContainer.swift:127`:  Enforced via access attribute

```
// [REQ:gemSpec_IDP_Frontend:A_21578,A_21579,A_21580,A_21583] Enforced via access attribute
kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
```



### [A_21584](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21584)


#### `../Sources/IDP/PrivateKeyContainer.swift:218`:  private key usage triggers biometric unlock

```
// [REQ:gemSpec_IDP_Frontend:A_21584] private key usage triggers biometric unlock
guard let signature = SecKeyCreateSignature(privateKey,
```



### [A_21586](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21586)


#### `../Sources/IDP/PrivateKeyContainer.swift:109`:  prevents migration to other devices

```
// [REQ:gemSpec_IDP_Frontend:A_21586] prevents migration to other devices
kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
```



#### `../Sources/IDP/PrivateKeyContainer.swift:114`:  invalidates biometry after changes

```
// [REQ:gemSpec_IDP_Frontend:A_21586] invalidates biometry after changes
.biometryCurrentSet], &error) else {
```



### [A_21587](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21587)


#### `../Sources/IDP/PrivateKeyContainer.swift:113`:  via `.privateKeyUsage`

```
// [REQ:gemSpec_IDP_Frontend:A_21582] method selection
// [REQ:gemSpec_IDP_Frontend:A_21587] via `.privateKeyUsage`
[.privateKeyUsage,
```



### [A_21588](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21588)


#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:13`:  key identfier generator, number of bytes 32

```
// [REQ:gemSpec_IDP_Frontend:A_21588] key identfier generator, number of bytes 32
keyIdentifierGenerator: @escaping (() throws -> Data) = { try generateSecureRandom(length: 32) },
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:36`:  Key generation

```
// [REQ:gemSpec_IDP_Frontend:A_21588] Key generation
let keyIdentifier = try keyIdentifierGenerator()
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:101`:  usage as base64 encoded string

```
// [REQ:gemSpec_IDP_Frontend:A_21588] usage as base64 encoded string
guard let someIdentifier = identifier,
```



### [A_21589](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21589)


#### `../Sources/IDP/PrivateKeyContainer.swift:123`:  Algorithm selection

```
// [REQ:gemSpec_IDP_Frontend:A_21581,A_21589] Algorithm selection
kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
```



#### `../Sources/IDP/PrivateKeyContainer.swift:125`:  Key length

```
// [REQ:gemSpec_IDP_Frontend:A_21589] Key length
kSecAttrKeySizeInBits as String: 256,
```



### [A_21591](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21591)


#### `../Sources/IDP/UIDevice+Extension.swift:10`: 

```
/// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
func deviceInformation() -> RegistrationData.DeviceInformation {
```



#### `../Sources/IDP/UIDevice+Extension.swift:43`: 

```
/// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
func deviceInformation() -> RegistrationData.DeviceInformation {
```



#### `../Sources/IDP/Models/RegistrationData.swift:57`: 

```
/// [REQ:gemF_Biometrie:A_21415:Device_Type]
/// [REQ:gemSpec_IDP_Frontend:A_21591]
public struct DeviceType: Codable {
```



### [A_21595](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21595)


#### `../Sources/IDP/IDPStorage.swift:12`:  Storage Protocol

```
/// Interface to access an eGK Certificate that should be kept private
/// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Protocol
public protocol SecureEGKCertificateStorage {
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:51`:  Store pairing data

```
// [REQ:gemSpec_IDP_Frontend:A_21598,A_21595,A_21595] Store pairing data
certificateStorage.set(certificate: certificate)
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:51`:  Store pairing data

```
// [REQ:gemSpec_IDP_Frontend:A_21598,A_21595,A_21595] Store pairing data
certificateStorage.set(certificate: certificate)
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:72`:  case deletion

```
// [REQ:gemSpec_IDP_Frontend:A_21595] case deletion
certificateStorage.set(certificate: nil)
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:170`:  Failure will delete paring data

```
// [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
_ = try? self.signatureProvider.abort(pairingSession: pairingSession)
```



#### `../Sources/eRpApp/Session/KeychainStorage.swift:20`:  Storage Implementation

```
// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
```



#### `../Sources/eRpApp/Session/KeychainStorage.swift:172`:  Store within keychain

```
// [REQ:gemSpec_IDP_Frontend:A_21595] Store within keychain
_ = try? keychainHelper.setGenericPassword(derBytes, for: egkAuthCertIdentifier)
```



#### `../Sources/eRpApp/Session/KeychainStorage.swift:197`:  Store within keychain

```
// [REQ:gemSpec_IDP_Frontend:A_21595] Store within keychain
_ = try? keychainHelper.setGenericPassword(keyIdentifier, for: idpBiometricKeyIdentifier)
```



### [A_21598](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21598)


#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:51`:  Store pairing data

```
// [REQ:gemSpec_IDP_Frontend:A_21598,A_21595,A_21595] Store pairing data
certificateStorage.set(certificate: certificate)
```



#### `../Sources/IDP/DefaultSecureEnclaveSignatureProvider.swift:69`:  Delete all stored keys/identifiers/certificate in case of an unsuccessful

```
// [REQ:gemSpec_IDP_Frontend:A_21598] Delete all stored keys/identifiers/certificate in case of an unsuccessful
// registration
public func abort(pairingSession: PairingSession) throws {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:170`:  Failure will delete paring data

```
// [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
_ = try? self.signatureProvider.abort(pairingSession: pairingSession)
```



### [A_21600](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21600)


#### `../Sources/IDP/UIDevice+Extension.swift:10`: 

```
/// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
func deviceInformation() -> RegistrationData.DeviceInformation {
```



#### `../Sources/IDP/UIDevice+Extension.swift:43`: 

```
/// [REQ:gemSpec_IDP_Frontend:A_21591,A_21600]
func deviceInformation() -> RegistrationData.DeviceInformation {
```



### [A_21603](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21603)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:65`:  Certificate

```
// [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
changeableUserSessionContainer.userSession.secureUserStore.set(certificate: nil)
```



#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:72`:  key identifier

```
// [REQ:gemSpec_IDP_Frontend:A_21603] key identifier
changeableUserSessionContainer.userSession.secureUserStore.set(keyIdentifier: nil)
```



#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:76`:  PrK_SE_AUT/PuK_SE_AUT

```
// If deletion fails we cannot do anything
// [REQ:gemSpec_IDP_Frontend:A_21603] PrK_SE_AUT/PuK_SE_AUT
_ = try? PrivateKeyContainer.deleteExistingKey(for: identifier)
```



## gemF_Tokenverschlüsselung

### [A_20526-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20526-01)


#### `../Sources/IDP/DefaultIDPSession.swift:140`:  Encryption with JWE

```
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Encryption with JWE
guard let jwe = try? signedChallenge.encrypt(with: document.encryptionPublicKey,
```



#### `../Sources/IDP/internal/RealIDPClient.swift:152`:  Building and sending the request

```
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Building and sending the request
var request = URLRequest(url: document.authentication.url, cachePolicy: .reloadIgnoringCacheData)
```



#### `../Sources/IDP/Models/IDPChallengeSession.swift:48`:  Embed certificate

```
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Embed certificate
let header = JWT.Header(alg: alg, x5c: certificates, typ: "JWT", cty: "NJWT")
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:110`:  Smartcard signature

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.sign(challengeSession: challengeSession)
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:268`:  Smartcard signature

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.readAutCertificate()
```



### [A_20700-06](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20700-06)


#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:111`:  sign

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.sign(challengeSession: challengeSession)
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:165`:  sign

```
// [REQ:gemSpec_IDP_Frontend:A_20526-01] sign
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
func sign(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession)
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:269`:  sign

```
// [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
// [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
// [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
.readAutCertificate()
```



### [A_21322](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21322)


#### `../Sources/eRpApp/Session/KeychainStorage.swift:19`:  Storage implementation uses iOS Keychain

```
// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
```



## gemSpec_Krypt

### [A_17207](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_17207)


#### `../Sources/IDP/DefaultIDPSession.swift:238`:  Only implemented for brainpoolP256r1

```
// Validate JWT/DiscoveryDocument signature
// [REQ:gemSpec_Krypt:A_17207] Only implemented for brainpoolP256r1
guard (try? fetchedDocument.backing.verify(with: fetchedDocument.discKey)) ?? false else {
```



#### `../Sources/IDP/DefaultIDPSession.swift:396`:  Only implemented for brainpoolP256r1

```
// [REQ:gemSpec_Krypt:A_17207] Only implemented for brainpoolP256r1
// [REQ:gemSpec_IDP_Frontend:A_19908-01] Signature check
guard let verified = try? challenge.challenge.verify(with: document.authentication.cert),
```



#### `../Sources/IDP/internal/JWT/JWTSignatureVerifier.swift:22`: 

```
// [REQ:gemSpec_Krypt:A_17207]
public func verify(signature raw: Data, message: Data) throws -> Bool {
```



#### `../Sources/IDP/internal/JWT/JWTSignatureVerifier.swift:31`: 

```
// [REQ:gemSpec_Krypt:A_17207]
guard let key = brainpoolP256r1VerifyPublicKey() else {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:17`:  Assure only brainpoolP256r1 is used

```
// [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
guard let alg = certificate.info.algorithm.alg else {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.Environment+Biometrics.swift:40`:  Assure only brainpoolP256r1 is used

```
// [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
guard certificate.info.algorithm.alg == .bp256r1 else {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:270`:  Assure only brainpoolP256r1 is used

```
// [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
guard let alg = certificate.info.algorithm.alg else {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/NFCSignatureProvider.swift:319`:  Assure only brainpoolP256r1 is used

```
// [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
var alg: JWT.Algorithm? {
```



### [A_18464](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_18464)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:35`: 

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [A_18467](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_18467)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:35`: 

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [A_20161-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20161-01)


#### `../Sources/VAU/VAUInterceptor.swift:46`: 

```
// Prepare outer request (encrypt original request and embed it into a new one)
// [REQ:gemSpec_Krypt:A_20161-01]
.processToVauRequest(urlRequest: request, vauCryptoProvider: vauCryptoProvider)
```



#### `../Sources/VAU/VAUInterceptor.swift:61`: 

```
// Prepare outer request (encrypt original request and embed it into a new one)
// [REQ:gemSpec_Krypt:A_20161-01]
func processToVauRequest(
```



#### `../Sources/VAU/internal/VAUCrypto.swift:26`: 

```
/// Perform encryption of the data that the implementing instance has been initialized with
/// in order to send it to a VAU service endpoint. See: gemSpec_Krypt A_20161-01
///
/// [REQ:gemSpec_Krypt:A_20161-01]
///
/// - Returns: Encrypted HTTPRequest as specified to be sent to a VAU endpoint
/// - Throws: `VAUError` in case of encryption failure
func encrypt() throws -> Data
```



#### 5 `../Sources/VAU/internal/VAUCrypto.swift:87`: 

```
// [REQ:gemSpec_Krypt:A_20161-01:5]
guard let payload = "1 \(bearerToken) \(requestId) \(symKeyHex) \(message)".data(using: .utf8) else {
```



#### 6a-g `../Sources/VAU/internal/VAUCrypto.swift:130`: 

```
/// Perform Elliptic Curve Integrated Encryption Scheme [SEC1-2009] on some payload
/// [REQ:gemSpec_Krypt:A_20161-01:6a-g]
static func encrypt(
```



### [A_20163](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20163)


#### `../Sources/VAU/internal/VAUCrypto.swift:34`: 

```
/// Perform decryption and validation of given data with the secret key material the implementing instance holds.
///
/// [REQ:gemSpec_Krypt:A_20163]
///
/// - Parameter data: Data to be decrypted
/// - Returns: Decrypted UTF8 string representation of the given data
/// - Throws: `VAUError` in case of decryption failure or when the decrypted data could not be validated
func decrypt(data: Data) throws -> String
```



### [A_20174](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20174)


#### `../Sources/VAU/VAUInterceptor.swift:51`: 

```
// Process VAU server response (validate and extract+decrypt inner FHIR service response)
// [REQ:gemSpec_Krypt:A_20174]
.handleUserPseudonym(vauEndpointHandler: self.vauEndpointHandler)
```



#### `../Sources/VAU/VAUInterceptor.swift:128`: 

```
// Process VAU server response (validate and extract+decrypt inner FHIR service response)
// [REQ:gemSpec_Krypt:A_20174]
static func processVauResponse(httpResponse: HTTPResponse, vauCrypto: VAUCrypto, originalUrl: URL) throws
```



#### 2 `../Sources/VAU/internal/VAUEndpointHandler.swift:13`: 

```
// [REQ:gemSpec_Krypt:A_20174:2]
func didReceiveUserPseudonym(in httpResponse: HTTPResponse)
```



#### 2 `../Sources/VAU/internal/VAUEndpointHandler.swift:34`: 

```
// [REQ:gemSpec_Krypt:A_20174:2]
if let pseudonym = httpResponse.response.value(forHTTPHeaderField: "userpseudonym") {
```



#### 3 `../Sources/VAU/internal/VAUCrypto.swift:107`:  Decrypt using AES symmetric key

```
// Steps according to gemSpec_Krypt A_20174
// [REQ:gemSpec_Krypt:A_20174:3] Decrypt using AES symmetric key
guard let sealed = try? AES.GCM.SealedBox(combined: data),
```



#### 4,5 `../Sources/VAU/internal/VAUCrypto.swift:114`:  Verify decrypted message. Expect: "1 <request id> <response header and body>"

```
// [REQ:gemSpec_Krypt:A_20174:4,5] Verify decrypted message. Expect: "1 <request id> <response header and body>"
let separated = utf8.split(separator: " ", maxSplits: 2).map { String($0) }
```



### [A_20175](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20175)


#### `../Sources/VAU/VAUStorage.swift:15`: 

```
/// Retrieve a previously saved UserPseudonym
///
/// [REQ:gemSpec_Krypt:A_20175]
var userPseudonym: AnyPublisher<String?, Never> { get }
```



#### `../Sources/VAU/VAUStorage.swift:22`: 

```
/// Set and save a user pseudonym
///
/// [REQ:gemSpec_Krypt:A_20175]
///
/// - Parameter userPseudonym: value to save. Pass in nil to unset
func set(userPseudonym: String?)
```



### [A_21216](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21216)


#### `../Sources/TrustStore/internal/CertList.swift:11`: 

```
/// Data structure according to */CertList* endpoint
/// [REQ:gemSpec_Krypt:A_21216]
public struct CertList: Codable, Equatable {
```



#### `../Sources/VAU/internal/VAUCertList.swift:11`: 

```
/// Data structure according to */CertList* endpoint
/// [REQ:gemSpec_Krypt:A_21216]
public struct VAUCertList: Codable, Equatable {
```



### [A_21217](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21217)


#### `../Sources/TrustStore/internal/OCSPList.swift:10`: 

```
/// [REQ:gemSpec_Krypt:A_21217]
/// Data structure according to */OCSPList* endpoint
public struct OCSPList: Codable, Equatable {
```



### [A_21218](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21218)


#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:68`: 

```
// [REQ:gemSpec_Krypt:A_21218,A_21222]
extension DefaultTrustStoreSession: TrustStoreSession {
```



#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:165`: 

```
// [REQ:gemSpec_Krypt:A_21218]
func loadOCSPResponses() -> AnyPublisher<[OCSPResponse], TrustStoreError> {
```



#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:176`:  If only OCSP responses >12h available, we must request new ones

```
// [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
ocspResponses
```



#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:191`:  If only OCSP responses >12h available, ...

```
// [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, ...
ocspResponses
```



#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:215`:  If only OCSP responses >12h available, we must request new ones

```
// [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
func allSatisfyNotProducedBefore(date: Date) -> Bool {
```



#### `../Sources/TrustStore/TrustStoreSession.swift:13`: 

```
/// TrustStoreSession acts as an interactor/mediator for the TrustStoreClient and TrustStoreStorage
///
/// [REQ:gemSpec_Krypt:A_21218,A_21222]
public protocol TrustStoreSession {
```



#### `../Sources/TrustStore/X509TrustStore.swift:13`: 

```
// [REQ:gemSpec_Krypt:A_21218]
// [REQ:gemSpec_eRp_FdV:A_20032-01]
// Category A: Cross root certificates
private let rootCa: X509
```



#### `../Sources/TrustStore/X509TrustStore.swift:83`: 

```
/// Match a collection of `OCSPResponse`s with the end entity certificates of this `X509TrustStore`.
/// Checks response status, revocation status for each certificate and validates the signer certificates of
///   the responses itself.
///
/// [REQ:gemSpec_Krypt:A_21218]
/// [REQ:gemSpec_eRp_Fdv:A_20032-01]
///
/// - Note: This function assumes that up-to-dateness of the responses itself has already been checked.
///
/// - Returns: true on successful matching/validation, false if not successful or error
func checkEeCertificatesStatus(with ocspResponses: [OCSPResponse]) throws -> Bool {
```



#### `../Sources/TrustStore/X509TrustStore.swift:81`:  OCSP responder certificates must be verifiable by the trust store

```
// [REQ:gemSpec_Krypt:A_21218] OCSP responder certificates must be verifiable by the trust store
let verifiedOCSPResponses = basicVerifyFilter(ocspResponses: ocspResponses)
```



#### `../Sources/TrustStore/X509TrustStore.swift:89`:  For every EE certificate there must be a matching OCSP response

```
// [REQ:gemSpec_Krypt:A_21218] For every EE certificate there must be a matching OCSP response
let matchedResponses = try eeCertAndSignerTuple.map { eeCertificate, signer in
```



#### `../Sources/TrustStore/X509TrustStore.swift:97`:  For every OCSP response there must be a matching EE certificate

```
// [REQ:gemSpec_Krypt:A_21218] For every OCSP response there must be a matching EE certificate
let matchedEeCerts = try ocspResponses.map { response in
```



#### `../Sources/TrustStore/X509TrustStore.swift:108`:  OCSP responder certificates must be verifiable by the trust store

```
// [REQ:gemSpec_Krypt:A_21218] OCSP responder certificates must be verifiable by the trust store
private func basicVerifyFilter(ocspResponses: [OCSPResponse]) -> [OCSPResponse] {
```



#### (3) `../Sources/TrustStore/X509TrustStore.swift:129`:  Check ca_certs against category A certificates

```
// [REQ:gemSpec_Krypt:A_21218:(3)] Check ca_certs against category A certificates
private static let caCertRegex =
```



#### (4) `../Sources/TrustStore/X509TrustStore.swift:146`:  Check ee_certs against category A+B certificates

```
// [REQ:gemSpec_Krypt:A_21218:(4)] Check ee_certs against category A+B certificates
typealias VauAndIpdCerts = (vauCerts: [X509], idpCerts: [X509])
```



#### `../Sources/eRpApp/AppConfiguration.swift:88`:  Gematik Root CA 3 as a trust anchor has to be set in the program code

```
// [REQ:gemSpec_Krypt:A_21218] Gematik Root CA 3 as a trust anchor has to be set in the program code
// swiftlint:disable:next force_try
let TRUSTANCHOR_GemRootCa3 = try! TrustAnchor(withPEM: """
```



### [A_21222](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21222)


#### `../Sources/TrustStore/DefaultTrustStoreSession.swift:68`: 

```
// [REQ:gemSpec_Krypt:A_21218,A_21222]
extension DefaultTrustStoreSession: TrustStoreSession {
```



#### `../Sources/TrustStore/TrustStoreSession.swift:13`: 

```
/// TrustStoreSession acts as an interactor/mediator for the TrustStoreClient and TrustStoreStorage
///
/// [REQ:gemSpec_Krypt:A_21218,A_21222]
public protocol TrustStoreSession {
```



### [GS-A_4357](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=GS-A_4357)


#### `../Sources/IDP/internal/JWT/JWE+KDF.swift:30`:  Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters

```
// [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
case bpp256r1(BrainpoolP256r1.KeyExchange.PublicKey,
```



#### `../Sources/IDP/internal/IDPCrypto.swift:15`:  Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters

```
/// Key-pair generator type based on BrainpoolP256r1
///
/// [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
public typealias BrainpoolKeyGenerator = () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
```



#### `../Sources/VAU/internal/VAUCrypto.swift:92`:  Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters

```
// [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
let keyPairGenerator = { try BrainpoolP256r1.KeyExchange.generateKey(compactRepresentable: false) }
```



### [GS-A_4367](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=GS-A_4367)


#### `../Sources/IDP/internal/SecKeyRandom.swift:19`: 

```
/// Generate random Data with given length
///
/// [REQ:gemSpec_Krypt:GS-A_4367]
///
/// - Parameters:
///   - length: the number of bytes to generate
///   - randomizer: the randomizer to be used. Default: kSecRandomDefault
/// - Returns: the random initialized Data
/// - Throws: `IDPError`
public func generateSecureRandom(length: Int, randomizer: SecRandomRef? = kSecRandomDefault) throws -> Data {
```



#### `../Sources/VAU/internal/VAURandom.swift:20`: 

```
/// Generate random Data with given length
///
/// [REQ:gemSpec_Krypt:GS-A_4367]
///
/// - Parameters:
///   - length: the number of bytes to generate
///   - randomizer: the randomizer to be used. Default: kSecRandomDefault
/// - Returns: the random initialized Data
/// - Throws: `VAUError`
static func generateSecureRandom(length: Int, randomizer: SecRandomRef? = kSecRandomDefault) throws -> Data {
```



### [GS-A_4385](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=GS-A_4385)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:35`: 

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [GS-A_4387](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=GS-A_4387)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:35`: 

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [GS-A_5322](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=GS-A_5322)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:36`:  TODO: Check if limiting SSL Sessions is possible, check for renegotiation

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



## gemF_Biometrie

### [A21450](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A21450)


#### Pairing_Entry `../Sources/IDP/Models/PairingEntry.swift:12`: 

```
/// Represents stored data within the idp.
/// [REQ:gemF_Biometrie:A21450:Pairing_Entry]
public struct PairingEntry: Equatable, Codable {
```



### [A_21415](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_21415)


#### Registration_Data `../Sources/IDP/Models/RegistrationData.swift:13`: 

```
/// Bundles data needed for creating and verifiying a pairing.
/// [REQ:gemF_Biometrie:A_21415:Registration_Data]
/// [REQ:gemSpec_IDP_Frontend:A_21416] Data Structure
public struct RegistrationData: Claims, Codable {
```



#### Device_Information `../Sources/IDP/Models/RegistrationData.swift:39`: 

```
/// [REQ:gemF_Biometrie:A_21415:Device_Information]
public struct DeviceInformation: Codable {
```



#### Device_Type `../Sources/IDP/Models/RegistrationData.swift:56`: 

```
/// [REQ:gemF_Biometrie:A_21415:Device_Type]
/// [REQ:gemSpec_IDP_Frontend:A_21591]
public struct DeviceType: Codable {
```



#### Encrypted_Registration_Data `../Sources/IDP/Models/RegistrationData.swift:104`:  Returns JWE encrypted Registration_Data

```
/// [REQ:gemF_Biometrie:A_21415:Encrypted_Registration_Data] Returns JWE encrypted Registration_Data
/// [REQ:gemSpec_IDP_Frontend:A_21416] Encryption
func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
```



#### Signed_Pairing_Data `../Sources/IDP/Models/SignedPairingData.swift:12`: 

```
/// Signed (with eGK) version of `PairingData`.
/// [REQ:gemF_Biometrie:A_21415:Signed_Pairing_Data]
public struct SignedPairingData {
```



#### Pairing_Data `../Sources/IDP/Models/PairingData.swift:12`: 

```
/// Structure for registering a biometric key. See `SignedPairingData` for sigend representation.
/// [REQ:gemF_Biometrie:A_21415:Pairing_Data]
public struct PairingData: Claims, Codable {
```



## gemSpec_eRp_FdV

### [ A_19092](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query= A_19092)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:116`:  OptIn for user tracking

```
// Tracking
// [REQ:gemSpec_eRp_FdV:A_19089, A_19092, A_19097] OptIn for user tracking
case let .toggleTrackingTapped(optIn):
```



### [ A_19097](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query= A_19097)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:116`:  OptIn for user tracking

```
// Tracking
// [REQ:gemSpec_eRp_FdV:A_19089, A_19092, A_19097] OptIn for user tracking
case let .toggleTrackingTapped(optIn):
```



### [A_19089](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19089)


#### `../Sources/eRpApp/Screens/Settings/SettingsView.swift:119`:  User info for usage tracking

```
// [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
HeadernoteView(
```



#### `../Sources/eRpApp/Screens/Settings/SettingsView.swift:140`:  User info for usage tracking

```
// [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
FootnoteView(
```



#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:116`:  OptIn for user tracking

```
// Tracking
// [REQ:gemSpec_eRp_FdV:A_19089, A_19092, A_19097] OptIn for user tracking
case let .toggleTrackingTapped(optIn):
```



### [A_19090](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19090)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:124`: 

```
// [REQ:gemSpec_eRp_FdV:A_19090]
case .confirmedOptInTracking:
```



### [A_19095](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19095)


#### `../Sources/eRpApp/Tracking/PiwikProTracker.swift:23`:  user session is randomly created by piwik - See visitorID.

```
// [REQ:gemSpec_eRp_FdV:A_19095] user session is randomly created by piwik - See visitorID.
// [REQ:gemSpec_eRp_FdV:A_19096] new visitorID is generated when app is reinstalled.
tracker = PiwikTracker.sharedInstance(siteID: siteId, baseURL: baseURL)
```



### [A_19096](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19096)


#### `../Sources/eRpApp/Tracking/PiwikProTracker.swift:24`:  new visitorID is generated when app is reinstalled.

```
// [REQ:gemSpec_eRp_FdV:A_19095] user session is randomly created by piwik - See visitorID.
// [REQ:gemSpec_eRp_FdV:A_19096] new visitorID is generated when app is reinstalled.
tracker = PiwikTracker.sharedInstance(siteID: siteId, baseURL: baseURL)
```



### [A_19186](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19186)


#### `../Sources/eRpApp/Session/KeychainStorage.swift:16`: 

```
// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
```



### [A_19187](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19187)


#### `../Sources/VAU/VAUInterceptor.swift:37`:  VAU Bearer must be set to trigger a request

```
// [REQ:gemSpec_eRp_FdV:A_19187] VAU Bearer must be set to trigger a request
return vauAccessTokenProvider.vauBearerToken
```



### [A_19188](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19188)


#### `../Sources/eRpApp/Session/KeychainStorage.swift:17`:  Deletion of data saved here is managed by the OS.

```
// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
```



### [A_19229](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19229)


#### `../Sources/eRpApp/Screens/Main/PrescriptionDetail/PrescriptionDetailDomain.swift:123`: 

```
// Delete
// [REQ:gemSpec_eRp_FdV:A_19229]
case .delete:
```



#### `../Sources/eRpApp/Screens/Main/PrescriptionDetail/PrescriptionDetailDomain.swift:129`: 

```
// [REQ:gemSpec_eRp_FdV:A_19229]
case .confirmedDelete:
```



### [A_19739](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19739)


#### `../Sources/TrustStore/TrustStoreSession.swift:19`: 

```
/// Request and validate the VAU certificate
///
/// [REQ:gemSpec_eRp_FdV:A_19739]
///
/// - Returns: A publisher that emits a validated VAU certificate or an error
func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError>
```



#### `../Sources/TrustStore/TrustStoreSession.swift:29`: 

```
/// Try to validate a given certificate against the underlying truststore.
/// An OCSP response will also be requested and checked against
///
/// [REQ:gemSpec_eRp_FdV:A_19739]
///
/// - Parameter certificate: the certificate to be validated
/// - Returns: A publisher that emits a Boolean stating whether or not the certificate could be validated.
func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError>
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:96`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:129`:  rejection

```
/// [REQ:gemSpec_eRp_FdV:A_19739] rejection
completionHandler(.cancelAuthenticationChallenge, nil)
```



### [A_19984](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19984)


#### `../Sources/Pharmacy/FHIRClient+PharmacyOperation.swift:22`:  validate pharmacy data format conforming to FHIR

```
/// Convenience function for searching for pharmacies
///
/// [REQ:gemSpec_eRp_FdV:A_19984] validate pharmacy data format conforming to FHIR
///
/// - Parameters:
///   - searchTerm: Search term
///   - position: Pharmacy position (latitude and longitude)
/// - Returns: `AnyPublisher` that emits a list of pharmacies or nil when not found
public func searchPharmacies(by searchTerm: String,
```



#### `../Sources/eRpKit/ScannedErxTask.swift:48`:  parse task id and access code

```
// [REQ:gemSpec_eRp_FdV:A_19984] parse task id and access code
guard let taskId = taskString.match(pattern: Self.taskIdRegex) else {
```



### [A_20032-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20032-01)


#### `../Sources/TrustStore/X509TrustStore.swift:14`: 

```
// [REQ:gemSpec_Krypt:A_21218]
// [REQ:gemSpec_eRp_FdV:A_20032-01]
// Category A: Cross root certificates
private let rootCa: X509
```



### [A_20033](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20033)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:96`: 

```
// [REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]
// [REQ:gemSpec_eRp_FdV:A_20033,A_19739]
func urlSession(
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:208`:  pinned certificates

```
// [REQ:gemSpec_IDP_Frontend:A_20608] pinned certificates
// [REQ:gemSpec_eRp_FdV:A_20033] pinned certificates
"idp.app.ti-dienste.de": [
```



#### `../Sources/HTTPClient/DefaultHTTPClient.swift:244`:  pinned certificates

```
// [REQ:gemSpec_IDP_Frontend:A_20608] pinned certificates
// [REQ:gemSpec_eRp_FdV:A_20033] pinned certificates
"erp.app.ti-dienste.de": [
```



### [A_20167](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20167)


#### `../Sources/IDP/IDPInterceptor.swift:61`:  no token available, bailout

```
// [REQ:gemSpec_eRp_FdV:A_20167] no token available, bailout
.authentication(error)
```



#### `../Sources/IDP/IDPInterceptor.swift:71`:  invalidate/delete unauthorized token

```
// [REQ:gemSpec_eRp_FdV:A_20167] invalidate/delete unauthorized token
self.session.invalidateAccessToken()
```



#### `../Sources/eRpApp/Screens/Main/GroupedPrescriptionListDomain.swift:305`:  no token/not authorized, show authenticator module

```
// [REQ:gemSpec_eRp_FdV:A_20167,A_20172] no token/not authorized, show authenticator module
if Result.success(false) == isAuthenticated {
```



### [A_20172](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20172)


#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.swift:110`: 

```
// [REQ:gemSpec_eRp_FdV:A_20172]
var idpChallengePublisher: Effect<CardWallReadCardDomain.Action, Never> {
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.swift:129`: 

```
// [REQ:gemSpec_eRp_FdV:A_20172]
// [REQ:gemSpec_IDP_Frontend:A_20526-01] sign and verify with idp
func signChallengeWithNFCCard(can: CAN, pin: Format2Pin,
```



#### `../Sources/eRpApp/Screens/CardWall/ReadCard/CardWallReadCardDomain.swift:155`: 

```
// [REQ:gemSpec_eRp_FdV:A_20172]
// [REQ:gemSpec_IDP_Frontend:A_20526-01] verify with idp
private func verifyResultWithIDP(_ signedChallenge: SignedChallenge,
```



#### `../Sources/eRpApp/Screens/Main/GroupedPrescriptionListDomain.swift:305`:  no token/not authorized, show authenticator module

```
// [REQ:gemSpec_eRp_FdV:A_20167,A_20172] no token/not authorized, show authenticator module
if Result.success(false) == isAuthenticated {
```



### [A_20183](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20183)


#### `../Sources/Pharmacy/PharmacyFHIRDataSource.swift:28`: 

```
/// API for requesting pharmacies with the passed search term
///
/// [REQ:gemSpec_eRp_FdV:A_20183]
///
/// - Parameter searchTerm: String that send to the server for filtering the pharmacies response
/// - Parameter position: Position (latitude and longitude) of pharmacy
/// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
public func searchPharmacies(by searchTerm: String,
```



#### `../Sources/eRpApp/Screens/Pharmacy/Search/PharmacySearchDomain.swift:145`:  search results mirrored verbatim, no sorting, no highlighting

```
// [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
state.searchState = .searchRunning
```



### [A_20184](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20184)


#### `../Sources/eRpApp/Session/StandardSessionContainer.swift:71`:  Keychain storage encrypts session/ssl tokens

```
storage: secureUserStore, // [REQ:gemSpec_eRp_FdV:A_20184] Keychain storage encrypts session/ssl tokens
schedulers: schedulers,
```



#### `../Sources/eRpApp/Session/StandardSessionContainer.swift:93`:  No persistent storage for idp biometrics session

```
storage: MemoryStorage(), // [REQ:gemSpec_eRp_FdV:A_20184] No persistent storage for idp biometrics session
schedulers: schedulers,
```



#### `../Sources/eRpApp/Session/KeychainStorage.swift:88`: 

```
// [REQ:gemSpec_eRp_FdV:A_20184]
let success: Bool
```



### [A_20186](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20186)


#### `../Sources/eRpApp/Screens/Settings/SettingsDomain.swift:59`:  Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN

```
// [REQ:gemSpec_IDP_Frontend:A_20499] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
// [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
changeableUserSessionContainer.userSession.secureUserStore.set(token: nil)
```



### [A_20206](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20206)


#### `../Sources/HTTPClient/DefaultHTTPClient.swift:40`: 

```
// [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
// [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
// swiftlint:disable:previous todo
// [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
// HTTP communication
// [REQ:gemSpec_eRp_FdV:A_20206]

```



### [A_20208](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20208)


#### `../Sources/Pharmacy/PharmacyFHIROperation.swift:14`: 

```
/// Search for pharmacies by name
/// [REQ:gemSpec_eRp_FdV:A_20208]
case searchPharmacies(searchTerm: String, position: Position?, handler: Handler)
```



## gemSpec_eRp_Fdv

### [A_20032-01](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_20032-01)


#### `../Sources/TrustStore/X509TrustStore.swift:84`: 

```
/// Match a collection of `OCSPResponse`s with the end entity certificates of this `X509TrustStore`.
/// Checks response status, revocation status for each certificate and validates the signer certificates of
///   the responses itself.
///
/// [REQ:gemSpec_Krypt:A_21218]
/// [REQ:gemSpec_eRp_Fdv:A_20032-01]
///
/// - Note: This function assumes that up-to-dateness of the responses itself has already been checked.
///
/// - Returns: true on successful matching/validation, false if not successful or error
func checkEeCertificatesStatus(with ocspResponses: [OCSPResponse]) throws -> Bool {
```



## gemspec_eRp_FdV

### [A_19984](https://gsbepo03.int.gematik.de/polarion/#/project/Mainline_OPB1/search?query=A_19984)


#### `../Sources/eRpKit/ScannedErxTask.swift:97`:  validate data matrix code structure

```
// [REQ:gemspec_eRp_FdV:A_19984] validate data matrix code structure
erxToken = try jsonDecoder.decode(ErxToken.self, from: jsonData)
```

