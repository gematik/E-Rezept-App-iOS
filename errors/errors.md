# Swift Error Documentation

Generated on: 2026-08-11 13:55:58

## Summary

- **Total Files**: 81
- **Total Error Enums**: 93
- **Total Error Cases**: 378

## Table of Contents

- [AVSError](#avserror)
- [InternalError](#internalerror)
- [BfArMError](#bfarmerror)
- [ConsentServiceError](#consentserviceerror)
- [FHIRClientError](#fhirclienterror)
- [FHIRVZDError](#fhirvzderror)
- [HealthcareServiceBundleParsingError](#healthcareservicebundleparsingerror)
- [CardWallExtAuthSelectionDomainError](#cardwallextauthselectiondomainerror)
- [CardWallIntroductionDomainError](#cardwallintroductiondomainerror)
- [StateError](#stateerror)
- [InputError](#inputerror)
- [LoginHandlerError](#loginhandlererror)
- [NFCSignatureProviderError](#nfcsignatureprovidererror)
- [SigningError](#signingerror)
- [VerifyPINError](#verifypinerror)
- [OrdersRepositoryError](#ordersrepositoryerror)
- [InternalCommunicationError](#internalcommunicationerror)
- [EuCodeGenerationError](#eucodegenerationerror)
- [EuRedeemServiceError](#euredeemserviceerror)
- [HTTPClientError](#httpclienterror)
- [IDPError](#idperror)
- [InternalError](#internalerror)
- [PrivateKeyContainerError](#privatekeycontainererror)
- [SecureEnclaveSignatureProviderError](#secureenclavesignatureprovidererror)
- [JWEError](#jweerror)
- [JWTError](#jwterror)
- [TokenPayloadError](#tokenpayloaderror)
- [BiometricsSHA256SignerError](#biometricssha256signererror)
- [ConversionError](#conversionerror)
- [KeyVerifierError](#keyverifiererror)
- [PharmacyRepositoryError](#pharmacyrepositoryerror)
- [IDTokenValidatorError](#idtokenvalidatorerror)
- [KeychainAccessHelperError](#keychainaccesshelpererror)
- [PushNotificationCryptoError](#pushnotificationcryptoerror)
- [TrustAnchorError](#trustanchorerror)
- [TrustStoreError](#truststoreerror)
- [InternalError](#internalerror)
- [VAUError](#vauerror)
- [APNSRegistrationError](#apnsregistrationerror)
- [ZXingMatrixCodeGeneratorError](#zxingmatrixcodegeneratorerror)
- [PrescriptionRepositoryError](#prescriptionrepositoryerror)
- [AuthenticationChallengeProviderError](#authenticationchallengeprovidererror)
- [AVScannerViewControllerError](#avscannerviewcontrollererror)
- [ScannerDomainError](#scannerdomainerror)
- [ExtAuthPendingDomainError](#extauthpendingdomainerror)
- [MainDomainError](#maindomainerror)
- [LoadingImageError](#loadingimageerror)
- [LoadingImageError](#loadingimageerror)
- [MedicationReminderListDomainError](#medicationreminderlistdomainerror)
- [MedicationReminderSetupDomainError](#medicationremindersetupdomainerror)
- [InternalCommunicationError](#internalcommunicationerror)
- [DefaultOrdersRepositoryError](#defaultordersrepositoryerror)
- [RedeemOrderServiceError](#redeemorderserviceerror)
- [RedeemServiceError](#redeemserviceerror)
- [InternalError](#internalerror)
- [NFCHealthCardPasswordControllerError](#nfchealthcardpasswordcontrollererror)
- [OrganDonorJumpServiceError](#organdonorjumpserviceerror)
- [ChargeItemDomainServiceFetchResultError](#chargeitemdomainservicefetchresulterror)
- [ChargeItemDomainServiceAuthenticateResultError](#chargeitemdomainserviceauthenticateresulterror)
- [ChargeItemListDomainServiceGrantResultError](#chargeitemlistdomainservicegrantresulterror)
- [ChargeItemListDomainServiceRevokeResultError](#chargeitemlistdomainservicerevokeresulterror)
- [ChargeItemDomainServiceDeleteResultError](#chargeitemdomainservicedeleteresulterror)
- [ChargeItemPDFServiceError](#chargeitempdfserviceerror)
- [PushNotificationRegistrationError](#pushnotificationregistrationerror)
- [AuditEventsServiceError](#auditeventsserviceerror)
- [RegisteredDevicesDomainError](#registereddevicesdomainerror)
- [RegisteredDevicesServiceError](#registereddevicesserviceerror)
- [SettingsDomainError](#settingsdomainerror)
- [DemoError](#demoerror)
- [AppSecurityManagerError](#appsecuritymanagererror)
- [UserProfileServiceError](#userprofileserviceerror)
- [UserSessionError](#usersessionerror)
- [UserSessionProviderError](#usersessionprovidererror)
- [ShareSheetDomainError](#sharesheetdomainerror)
- [DefaultDataMatrixStringEncoderError](#defaultdatamatrixstringencodererror)
- [ErxConsentError](#erxconsenterror)
- [StatusError](#statuserror)
- [ErxTaskError](#erxtaskerror)
- [ErxTaskOrderError](#erxtaskordererror)
- [ErxRepositoryError](#erxrepositoryerror)
- [EuAccessCodeError](#euaccesscodeerror)
- [LocalStoreError](#localstoreerror)
- [RemoteStoreError](#remotestoreerror)
- [ScannedErxTaskError](#scannederxtaskerror)
- [SharedTaskError](#sharedtaskerror)
- [AVSTransactionCoreDataStoreError](#avstransactioncoredatastoreerror)
- [CoreDataControllerError](#coredatacontrollererror)
- [ExcludeFileError](#excludefileerror)
- [MigrationError](#migrationerror)
- [PharmacyCoreDataStoreError](#pharmacycoredatastoreerror)
- [ProfileCoreDataStoreError](#profilecoredatastoreerror)
- [ShipmentInfoCoreDataStoreError](#shipmentinfocoredatastoreerror)
- [RemoteStorageBundleParsingError](#remotestoragebundleparsingerror)

---

## AVSError

**Error Code**: `540`
**Qualified Name**: `AVSError`
**File**: `./Sources/AVS/AVSError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `54001` | `network` | In case of HTTP/Connection error |
| `54002` | `invalidAVSMessageInput` | When failed to create an AVSMessage |
| `54003` | `invalidX509Input` | When an X509 certificate was of unexpected format |
| `54004` | `unspecified` | Conversion error when trying to cast to `AVSError` but error type was different |
| `54005` | ``internal`` | Internal error |

### Related Errors

- Case `network` → [HTTPClientError](#httpclienterror)
- Case ``internal`` → [InternalError](#internalerror)

---

## InternalError

**Error Code**: `541`
**Qualified Name**: `AVSError.InternalError`
**File**: `./Sources/AVS/AVSError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `54101` | `cmsContentCreation` | No description |

---

## BfArMError

**Error Code**: `301`
**Qualified Name**: `BfArMError`
**File**: `./Sources/BfArM/BfArMError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `30101` | `network` | In case of HTTP/Connection error |
| `30102` | `decoding` | Message failed to decode/parse |
| `30103` | `invalidAssetLink` | When the asset link from bfarm endpoint is invalid |
| `30104` | `unspecified` | Other error cases |

### Related Errors

- Case `network` → [HTTPClientError](#httpclienterror)

---

## ConsentServiceError

**Error Code**: `041`
**Qualified Name**: `ConsentService.Error`
**File**: `./Sources/ConsentService/ConsentService+Error.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04101` | `localStore` | No description |
| `04102` | `loginHandler` | No description |
| `04103` | `erxRepository` | No description |
| `04104` | `unexpectedGrantConsentResponse` | No description |
| `04105` | `unexpected` | No description |
| `04106` | `unexpectedRevokeConsentResponse` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)

---

## FHIRClientError

**Error Code**: `520`
**Qualified Name**: `FHIRClient.Error`
**File**: `./Sources/FHIRClient/FHIRClient.swift`

**Description**:
Error cases when using the `FHIRClient`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `52001` | `internalError` | No description |
| `52004` | `inconsistentResponse` | When the server returned a successful response with inconsistent response data. E.g. no task(s) found in a Fetch response where we normally would have expected a HTTP 404 instead. |
| `52005` | `decoding` | No description |
| `52006` | `unknown` | No description |
| `52007` | `http` | No description |

---

## FHIRVZDError

**Error Code**: `300`
**Qualified Name**: `FHIRVZDError`
**File**: `./Sources/FHIRVZD/Models/FHIRVZDError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `30001` | `network` | In case of HTTP/Connection error |
| `30002` | `tokenUnavailable` | When a token is being requested, but none can be found |
| `30003` | `decoding` | Message failed to decode/parse |
| `30004` | `unspecified` | Other error cases |

### Related Errors

- Case `network` → [HTTPClientError](#httpclienterror)

---

## HealthcareServiceBundleParsingError

**Error Code**: `610`
**Qualified Name**: `HealthcareServiceBundleParsingError`
**File**: `./Sources/FHIRVZD/ModelsR4.Bundle+HealthcareService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `61001` | `parseError` | No description |

---

## CardWallExtAuthSelectionDomainError

**Error Code**: `012`
**Qualified Name**: `CardWallExtAuthSelectionDomain.Error`
**File**: `./Sources/FeatureCardWall/ExtAuth/CardWallExtAuthSelectionDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01201` | `idpError` | No description |
| `01202` | `universalLinkFailed` | No description |

### Related Errors

- Case `idpError` → [IDPError](#idperror)

---

## CardWallIntroductionDomainError

**Error Code**: `029`
**Qualified Name**: `CardWallIntroductionDomain.Error`
**File**: `./Sources/FeatureCardWall/Introduction/CardWallIntroductionDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02901` | `idpError` | No description |
| `02902` | `universalLinkFailed` | No description |
| `02903` | `kkNotFound` | No description |

### Related Errors

- Case `idpError` → [IDPError](#idperror)

---

## StateError

**Error Code**: `010`
**Qualified Name**: `CardWallReadCardDomain.State.Error`
**File**: `./Sources/FeatureCardWall/ReadCard/CardWallReadCardDomain.State+Helper.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01001` | `idpError` | `IDPError` thrown within the `CardWallReadCardDomain` |
| `01002` | `inputError` | Possible user input errors thrown within the `CardWallReadCardDomain` |
| `01003` | `signChallengeError` | NFC signature errors thrown within the `CardWallReadCardDomain` |
| `01004` | `biometrieError` | Error that can occur during authentication with biometry |
| `01005` | `profileValidation` | Error when `Profile` validation with the given authentication fails. Error is produces within the `IDPError.unspecified` error before saving the IDPToken |

### Related Errors

- Case `idpError` → [IDPError](#idperror)
- Case `inputError` → [InputError](#inputerror)
- Case `signChallengeError` → [NFCSignatureProviderError](#nfcsignatureprovidererror)
- Case `profileValidation` → [IDTokenValidatorError](#idtokenvalidatorerror)

---

## InputError

**Error Code**: `011`
**Qualified Name**: `Error.InputError`
**File**: `./Sources/FeatureCardWall/ReadCard/CardWallReadCardDomain.State+Helper.swift`

**Description**:
User input error

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01101` | `missingPIN` | User input for PIN is incorrect |
| `01102` | `missingCAN` | User input for CAN is incorrect |

---

## LoginHandlerError

**Error Code**: `013`
**Qualified Name**: `LoginHandlerError`
**File**: `./Sources/FeatureCardWall/ReadCard/LoginHandler.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01301` | `biometrieFailed` | No description |
| `01302` | `biometrieFatal` | No description |
| `01303` | `ssoFailed` | No description |
| `01304` | `ssoExpired` | No description |
| `01305` | `idpError` | No description |
| `01306` | `network` | No description |

### Related Errors

- Case `idpError` → [IDPError](#idperror)

---

## NFCSignatureProviderError

**Error Code**: `004`
**Qualified Name**: `NFCSignatureProviderError`
**File**: `./Sources/FeatureCardWall/ReadCard/NFCSignatureProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00401` | `cardError` | Error while establishing a connection to the card |
| `00403` | `wrongCAN` | Error while verifying the CAN |
| `00404` | `cardConnectionError` | Error while establishing Secure channel or card connection |
| `00405` | `verifyCardError` | Any error related to PIN verification |
| `00406` | `signingFailure` | ESIGN Failed |
| `00407` | `wrongPin` | Wrong pin while opening secure channel |
| `00408` | `genericError` | Generic error while trying to sign the challenge |
| `00409` | `cardReadingError` | Generic error while reading something from the card |
| `00410` | `secureEnclaveError` | Generic error while reading something from the card |
| `00411` | `nfcHealthCardSession` | Any error regarding the communication with the NFC health card itself or sending/receiving data (operation execution) |

### Related Errors

- Case `verifyCardError` → [VerifyPINError](#verifypinerror)
- Case `signingFailure` → [SigningError](#signingerror)
- Case `secureEnclaveError` → [SecureEnclaveSignatureProviderError](#secureenclavesignatureprovidererror)

---

## SigningError

**Error Code**: `005`
**Qualified Name**: `NFCSignatureProviderError.SigningError`
**File**: `./Sources/FeatureCardWall/ReadCard/NFCSignatureProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00501` | `unsupportedAlgorithm` | No description |
| `00502` | `responseStatus` | No description |
| `00503` | `certificate` | No description |
| `00504` | `missingCertificate` | No description |

---

## VerifyPINError

**Error Code**: `006`
**Qualified Name**: `NFCSignatureProviderError.VerifyPINError`
**File**: `./Sources/FeatureCardWall/ReadCard/NFCSignatureProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00601` | `wrongSecretWarning` | Pin verification failed, retry count is the number of retries left for the given `EgkFileSystem.Pin` type |
| `00602` | `securityStatusNotSatisfied` | Access rule evaluation failure |
| `00603` | `memoryFailure` | Write action unsuccessful |
| `00604` | `passwordBlocked` | Exhausted retry counter |
| `00605` | `passwordNotUsable` | Password is transport protected |
| `00606` | `passwordNotFound` | Referenced password could not be found |
| `00607` | `unknownFailure` | Any (unexpected) error not specified in gemSpec_COS 14.6.6.2 |

---

## OrdersRepositoryError

**Error Code**: `037`
**Qualified Name**: `OrdersRepositoryError`
**File**: `./Sources/FeatureCommunication/MessagesList/CommunicationsRepository.swift`

**Description**:
MARK: - Error

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03701` | `erxRepository` | No description |
| `03702` | `pharmacyRepository` | No description |
| `03703` | `unspecified` | No description |

### Related Errors

- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `pharmacyRepository` → [PharmacyRepositoryError](#pharmacyrepositoryerror)

---

## InternalCommunicationError

**Error Code**: `038`
**Qualified Name**: `InternalCommunicationError`
**File**: `./Sources/FeatureCommunication/MessagesList/InternalCommunicationClient.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03801` | `decodingError` | No description |
| `03802` | `invalidURL` | No description |
| `03803` | `emptyOnboardingDate` | No description |
| `03804` | `unknownError` | No description |

### Related Errors

- Case `decodingError` → [ConsentServiceError](#consentserviceerror)

---

## EuCodeGenerationError

**Error Code**: `046`
**Qualified Name**: `EuCodeGenerationError`
**File**: `./Sources/FeatureEURedeem/EuAccessCodeGenerator.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04601` | `euCGImageConversion` | No description |

---

## EuRedeemServiceError

**Error Code**: `047`
**Qualified Name**: `EuRedeemServiceError`
**File**: `./Sources/FeatureEURedeem/EuRedeemServiceError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04701` | `eRxRepository` | When redeeming a task via Fachdienst |
| `04702` | `localStoreError` | When persisting/extracting information from the store went wrong |
| `04703` | `euCodeGeneration` | When the eu accessCode generation fails |
| `04704` | `unspecified` | When error conversion into `EuRedeemServiceError` fails |
| `04705` | `noTokenAvailable` | When the user has no valid token available while trying to redeem via Fachdienst |
| `04706` | `loginHandler` | When receiving an error while doing a login |

### Related Errors

- Case `eRxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `localStoreError` → [LocalStoreError](#localstoreerror)
- Case `euCodeGeneration` → [EuCodeGenerationError](#eucodegenerationerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)

---

## HTTPClientError

**Error Code**: `530`
**Qualified Name**: `HTTPClientError`
**File**: `./Sources/HTTPClient/HTTPClient.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `53001` | `internalError` | Internal error in the request/chain handling |
| `53002` | `httpError` | The server responded with an error |
| `53003` | `networkError` | The connection to the server has gone bad |
| `53004` | `authentication` | Authentication error |
| `53005` | `vauError` | Error emitted by the VAU client |
| `53006` | `unknown` | Unclassified error |

---

## IDPError

**Error Code**: `100`
**Qualified Name**: `IDPError`
**File**: `./Sources/IDP/Models/IDPError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10001` | `network` | In case of HTTP/Connection error |
| `10002` | `validation` | In case a response (or request) could not be (cryptographically) verified |
| `10003` | `tokenUnavailable` | When a token is being requested, but none can be found |
| `10004` | `unspecified` | Other error cases |
| `10005` | `decoding` | Message failed to decode/parse |
| `10006` | `noCertificateFound` | When failed to extract a X.509 certificate from the DiscoveryDocument |
| `10007` | `invalidDiscoveryDocument` | When the discovery document has expired or the trust anchors could not be verified |
| `10008` | `invalidStateParameter` | When the state parameter received from the server is not equal to the one sent |
| `10009` | `invalidNonce` | When the nonce received from the server is not equal to the one sent |
| `10010` | `unsupported` | When a method/algorithm is unsupported |
| `10011` | `encryption` | When encryption fails |
| `10012` | `decryption` | When decryption fails |
| `10013` | ``internal`` | Internal error |
| `10014` | `trustStore` | Issues related to Building or Verifying the trust store |
| `10015` | `pairing` | No description |
| `10016` | `invalidSignature` | No description |
| `10017` | `serverError` | Server responded with an error |
| `10018` | `biometrics` | Any biometrics related error |
| `10019` | `extAuthOriginalRequestMissing` | External authentication failed due to missing or invalid original request |
| `10020` | `notAvailableInDemoMode` | Not implemented as the conforming instance is meant for demo purpose only |

### Related Errors

- Case ``internal`` → [InternalError](#internalerror)
- Case `biometrics` → [SecureEnclaveSignatureProviderError](#secureenclavesignatureprovidererror)

---

## InternalError

**Error Code**: `101`
**Qualified Name**: `IDPError.InternalError`
**File**: `./Sources/IDP/Models/IDPError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10101` | `loadDiscoveryDocumentUnexpectedNil` | No description |
| `10102` | `requestChallengeUnexpectedNil` | No description |
| `10103` | `constructingChallengeRequestUrl` | No description |
| `10104` | `getAndValidateUnexpectedNil` | No description |
| `10105` | `constructingRefreshWithSSOTokenRequest` | No description |
| `10106` | `refreshResponseMissingHeaderValue` | No description |
| `10107` | `challengeExpired` | No description |
| `10108` | `verifyUnexpectedNil` | No description |
| `10109` | `verifyResponseMissingHeaderValue` | No description |
| `10110` | `verifierCodeCreation` | No description |
| `10111` | `stateNonceCreation` | No description |
| `10112` | `signedChallengeEncoded` | No description |
| `10113` | `signedChallengeEncryption` | No description |
| `10114` | `altVerifyResponseMissingHeaderValue` | No description |
| `10115` | `encryptedSignedChallengeEncoding` | No description |
| `10116` | `exchangeUnexpectedNil` | No description |
| `10117` | `exchangeTokenUnexpectedNil` | No description |
| `10118` | `ssoLoginAndExchangeUnexpectedNil` | No description |
| `10119` | `registrationDataEncryption` | No description |
| `10120` | `keyVerifierEncoding` | No description |
| `10121` | `encryptedKeyVerifierEncoding` | No description |
| `10122` | `keyVerifierJweHeaderEncryption` | No description |
| `10123` | `keyVerifierJwePayloadEncryption` | No description |
| `10124` | `nestJwtInJwePayloadEncryption` | No description |
| `10125` | `invalidByteBuffer` | No description |
| `10126` | `generatingSecureRandom` | No description |
| `10127` | `registeredDeviceEncoding` | No description |
| `10128` | `signedAuthenticationDataEncryption` | No description |
| `10129` | `constructingExtAuthRequestUrl` | No description |
| `10130` | `refreshTokenUnexpectedNil` | No description |
| `10131` | `loadDirectoryKKAppsUnexpectedNil` | No description |
| `10132` | `extAuthVerifyResponseMissingHeaderValue` | No description |
| `10133` | `extAuthVerifierCodeCreation` | No description |
| `10134` | `extAuthStateNonceCreation` | No description |
| `10135` | `extAuthVerifyAndExchangeUnexpectedNil` | No description |
| `10136` | `extAuthVerifyAndExchangeMissingQueryItem` | No description |
| `10137` | `extAuthConstructingRedirectUri` | No description |
| `10138` | `startExtAuthUnexpectedNil` | No description |
| `10139` | `extAuthVerifyUnexpectedNil` | No description |
| `10140` | `pairDeviceUnexpectedNil` | No description |
| `10141` | `unregisterDeviceUnexpectedNil` | No description |
| `10142` | `listDevicesUnexpectedNil` | No description |
| `10143` | `altVerifyUnexpectedNil` | No description |
| `10144` | `notImplemented` | No description |

---

## PrivateKeyContainerError

**Error Code**: `108`
**Qualified Name**: `PrivateKeyContainer.Error`
**File**: `./Sources/IDP/PrivateKeyContainer.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10801` | `keyNotFound` | No description |
| `10802` | `unknownError` | No description |
| `10803` | `retrievingPublicKeyFailed` | No description |
| `10804` | `creationFromBiometrie` | No description |
| `10805` | `creationWithoutBiometrie` | No description |
| `10806` | `convertingKey` | No description |
| `10807` | `signing` | No description |
| `10808` | `canceledByUser` | No description |

---

## SecureEnclaveSignatureProviderError

**Error Code**: `109`
**Qualified Name**: `SecureEnclaveSignatureProviderError`
**File**: `./Sources/IDP/SecureEnclaveSignatureProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10901` | `fetchingPrivateKey` | No description |
| `10902` | `signing` | No description |
| `10903` | `packagingAuthCertificate` | No description |
| `10904` | `packagingSeCertificate` | No description |
| `10905` | `gatheringPairingData` | No description |
| `10906` | ``internal`` | No description |

---

## JWEError

**Error Code**: `103`
**Qualified Name**: `JWE.Error`
**File**: `./Sources/IDP/internal/JWT/JWE.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10301` | `invalidJWE` | No description |
| `10302` | `encodingError` | No description |

---

## JWTError

**Error Code**: `104`
**Qualified Name**: `JWT.Error`
**File**: `./Sources/IDP/internal/JWT/JWT.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10401` | `malformedJWT` | No description |
| `10402` | `noSignature` | No description |
| `10403` | `encodingError` | No description |
| `10404` | `invalidSignature` | No description |
| `10405` | `invalidExpirationDate` | No description |

---

## TokenPayloadError

**Error Code**: `106`
**Qualified Name**: `TokenPayload.Error`
**File**: `./Sources/IDP/internal/TokenPayload.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10601` | `dataEncoding` | No description |
| `10602` | `stringConversion` | No description |
| `10603` | `decryption` | No description |

---

## BiometricsSHA256SignerError

**Error Code**: `102`
**Qualified Name**: `BiometricsSHA256Signer.Error`
**File**: `./Sources/IDPLive/BiometricsSHA256Signer.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10201` | `sessionClosed` | No description |
| `10202` | `signatureFailed` | No description |

---

## ConversionError

**Error Code**: `107`
**Qualified Name**: `ConversionError`
**File**: `./Sources/IDPLive/BiometricsSHA256Signer.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10701` | `generic` | No description |

---

## KeyVerifierError

**Error Code**: `105`
**Qualified Name**: `KeyVerifier.Error`
**File**: `./Sources/IDPLive/KeyVerifier.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `10501` | `stringConversion` | No description |

---

## PharmacyRepositoryError

**Error Code**: `571`
**Qualified Name**: `PharmacyRepositoryError`
**File**: `./Sources/Pharmacy/PharmacyRepositoryError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `57101` | `local` | No description |
| `57102` | `remote` | No description |

### Related Errors

- Case `local` → [LocalStoreError](#localstoreerror)

---

## IDTokenValidatorError

**Error Code**: `021`
**Qualified Name**: `IDTokenValidatorError`
**File**: `./Sources/Profiles/IDTokenValidator.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02101` | `profileNotFound` | No description |
| `02102` | `profileNotMatchingInsuranceId` | No description |
| `02103` | `profileWithInsuranceIdExists` | No description |
| `02104` | `other` | No description |

---

## KeychainAccessHelperError

**Error Code**: `020`
**Qualified Name**: `KeychainAccessHelperError`
**File**: `./Sources/Profiles/SystemKeychainAccessHelper.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02001` | `illegalArgument` | No description |
| `02002` | `keyChainError` | No description |
| `02003` | `decodingError` | No description |

---

## PushNotificationCryptoError

**Error Code**: `700`
**Qualified Name**: `PushNotificationCryptoError`
**File**: `./Sources/PushNotificationCrypto/PushNotificationCrypto.swift`

**Description**:
MARK: - Errors

### Error Cases

| ID | Case | Description |
|---|---|---|
| `70001` | `noKeyAvailable` | No description |
| `70002` | `keyNotFoundForMonth` | No description |
| `70003` | `invalidPayloadTooShort` | No description |
| `70004` | `invalidPNM1Prefix` | No description |
| `70005` | `invalidPayloadLength` | No description |
| `70006` | `storageError` | A keychain operation failed with the given OSStatus code and message. |

---

## TrustAnchorError

**Error Code**: `562`
**Qualified Name**: `TrustAnchor.Error`
**File**: `./Sources/TrustStore/TrustAnchor.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `56201` | `invalidPEM` | No description |

---

## TrustStoreError

**Error Code**: `560`
**Qualified Name**: `TrustStoreError`
**File**: `./Sources/TrustStore/TrustStoreError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `56001` | `network` | In case of HTTP/Connection error |
| `56002` | `noCertificateFound` | When failed to extract a certificate from the CertList |
| `56003` | `invalidOCSPResponse` | When one (or more) OCSP response(s) can not be parsed or do not meet expiry conditions |
| `56004` | `eeCertificateOCSPStatusVerification` | When one (or more) end entity certificate cannot be status verified by given OCSP responses |
| `56005` | `unspecified` | Other error cases |
| `56006` | ``internal`` | Internal error |
| `56007` | `noValidVauCertificateAvailable` | When no valid VAU certificate can be provided by the system at the moment |
| `56008` | `malformedCertificate` | When a certificate is of unexpected (e.g. not parsable) format |

### Related Errors

- Case `network` → [HTTPClientError](#httpclienterror)
- Case ``internal`` → [InternalError](#internalerror)

---

## InternalError

**Error Code**: `561`
**Qualified Name**: `TrustStoreError.InternalError`
**File**: `./Sources/TrustStore/TrustStoreError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `56101` | `loadOCSPCheckedTrustStoreUnexpectedNil` | No description |
| `56102` | `loadCertListFromServerUnexpectedNil` | No description |
| `56103` | `loadOCSPListFromServerUnexpectedNil` | No description |
| `56104` | `trustStoreCertListUnexpectedNil` | No description |
| `56105` | `loadOCSPResponsesUnexpectedNil` | No description |
| `56106` | `missingSignerForEECertificate` | No description |
| `56107` | `notImplemented` | No description |
| `56108` | `trustAnchorUnexpectedFormat` | No description |
| `56109` | `vauCertificateUnexpectedFormat` | No description |
| `56110` | `trustStoreCreationFailed` | No description |

---

## VAUError

**Error Code**: `550`
**Qualified Name**: `VAUError`
**File**: `./Sources/VAUClient/VAUError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `55001` | `network` | In case of HTTP/Connection error |
| `55002` | `certificateDecoding` | When failed to extract a X.509 VAU certificate information |
| `55003` | `internalCryptoError` | When internal cryptographic operations fail |
| `55004` | `responseValidation` | In case a response (or request) could not be (cryptographically) verified |
| `55005` | `unspecified` | Other error cases |
| `55006` | `internalError` | Internal error |

### Related Errors

- Case `network` → [HTTPClientError](#httpclienterror)

---

## APNSRegistrationError

**Error Code**: `701`
**Qualified Name**: `APNSRegistrationError`
**File**: `./Sources/eRpApp/Common/APNSRegistrationService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `70101` | `permissionDenied` | No description |
| `70102` | `registrationFailed` | No description |
| `70103` | `missingToken` | No description |

---

## ZXingMatrixCodeGeneratorError

**Error Code**: `009`
**Qualified Name**: `ZXingMatrixCodeGenerator.Error`
**File**: `./Sources/eRpApp/Common/DataMatrixCodeGenerator/ZXingMatrixCodeGenerator.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00901` | `cgImageConversion` | No description |

---

## PrescriptionRepositoryError

**Error Code**: `027`
**Qualified Name**: `PrescriptionRepositoryError`
**File**: `./Sources/eRpApp/Data/PrescriptionRepository.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02701` | `loginHandler` | No description |
| `02702` | `erxRepository` | No description |

### Related Errors

- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)

---

## AuthenticationChallengeProviderError

**Error Code**: `003`
**Qualified Name**: `AuthenticationChallengeProviderError`
**File**: `./Sources/eRpApp/Screens/AppAuthentication/AppAuthenticationBiometry/BiometricsAuthenticationChallengeProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00301` | `cannotEvaluatePolicy` | No description |
| `00302` | `failedEvaluatingPolicy` | No description |

---

## AVScannerViewControllerError

**Error Code**: `002`
**Qualified Name**: `AVScannerViewController.Error`
**File**: `./Sources/eRpApp/Screens/CameraView/AVScannerView.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00201` | `initalizationError` | No description |
| `00202` | `other` | No description |

---

## ScannerDomainError

**Error Code**: `001`
**Qualified Name**: `ScannerDomain.Error`
**File**: `./Sources/eRpApp/Screens/CameraView/ScannerDomain+Helper.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00101` | `duplicate` | No description |
| `00102` | `empty` | No description |
| `00103` | `invalid` | No description |
| `00104` | `storeDuplicate` | No description |
| `00105` | `scannedErxTask` | No description |
| `00106` | `unknown` | No description |

### Related Errors

- Case `scannedErxTask` → [ScannedErxTaskError](#scannederxtaskerror)

---

## ExtAuthPendingDomainError

**Error Code**: `014`
**Qualified Name**: `ExtAuthPendingDomain.Error`
**File**: `./Sources/eRpApp/Screens/Main/ExtAuth/ExtAuthPendingDomain.swift`

**Description**:
`ExtAuthPendingDomain` error types

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01401` | `idpError` | Underlying `IDPError` for the external authentication agains `URL` |
| `01402` | `profileValidation` | Error when `Profile` validation with the given authentication fails. Error is produces within the `IDPError.unspecified` error before saving the IDPToken |

### Related Errors

- Case `idpError` → [IDPError](#idperror)
- Case `profileValidation` → [IDTokenValidatorError](#idtokenvalidatorerror)

---

## MainDomainError

**Error Code**: `015`
**Qualified Name**: `MainDomain.Error`
**File**: `./Sources/eRpApp/Screens/Main/MainDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01501` | `localStoreError` | No description |
| `01502` | `userSessionError` | No description |
| `01503` | `importDuplicate` | Import of shared Task failed due to being a duplicate already existing within the app |
| `01504` | `repositoryError` | Saving or retrieving data failed |

### Related Errors

- Case `localStoreError` → [LocalStoreError](#localstoreerror)
- Case `userSessionError` → [UserSessionError](#usersessionerror)
- Case `repositoryError` → [ErxRepositoryError](#erxrepositoryerror)

---

## LoadingImageError

**Error Code**: `016`
**Qualified Name**: `PrescriptionDetailDomain.LoadingImageError`
**File**: `./Sources/eRpApp/Screens/Main/PrescriptionDetail/PrescriptionDetailDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01601` | `matrixCodeGenerationFailed` | No description |

---

## LoadingImageError

**Error Code**: `023`
**Qualified Name**: `MatrixCodeDomain.LoadingImageError`
**File**: `./Sources/eRpApp/Screens/MatrixCode/MatrixCodeDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02301` | `matrixCodeGenerationFailed` | No description |

---

## MedicationReminderListDomainError

**Error Code**: `042`
**Qualified Name**: `MedicationReminderListDomain.Error`
**File**: `./Sources/eRpApp/Screens/MedicationReminder/MedicationReminderListDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04201` | `generic` | No description |

---

## MedicationReminderSetupDomainError

**Error Code**: `036`
**Qualified Name**: `MedicationReminderSetupDomain.Error`
**File**: `./Sources/eRpApp/Screens/MedicationReminder/MedicationReminderSetupDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03601` | `generic` | No description |

---

## InternalCommunicationError

**Error Code**: `038`
**Qualified Name**: `InternalCommunicationError`
**File**: `./Sources/eRpApp/Screens/Orders/InternalCommunicationProtocol.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03801` | `decodingError` | No description |
| `03802` | `invalidURL` | No description |
| `03803` | `emptyOnboardingDate` | No description |
| `03804` | `unknownError` | No description |

### Related Errors

- Case `decodingError` → [ConsentServiceError](#consentserviceerror)

---

## DefaultOrdersRepositoryError

**Error Code**: `037`
**Qualified Name**: `DefaultOrdersRepository.Error`
**File**: `./Sources/eRpApp/Screens/Orders/OrdersRepository.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03701` | `erxRepository` | No description |
| `03702` | `pharmacyRepository` | No description |
| `03703` | `unspecified` | No description |

### Related Errors

- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `pharmacyRepository` → [PharmacyRepositoryError](#pharmacyrepositoryerror)

---

## RedeemOrderServiceError

**Error Code**: `045`
**Qualified Name**: `RedeemOrderServiceError`
**File**: `./Sources/eRpApp/Screens/Pharmacy/RedeemService/RedeemOrderService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04501` | `localStore` | No description |
| `04502` | `pharmacy` | No description |
| `04503` | `redeem` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `pharmacy` → [PharmacyRepositoryError](#pharmacyrepositoryerror)
- Case `redeem` → [RedeemServiceError](#redeemserviceerror)

---

## RedeemServiceError

**Error Code**: `024`
**Qualified Name**: `RedeemServiceError`
**File**: `./Sources/eRpApp/Screens/Pharmacy/RedeemService/RedeemServiceError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02401` | `eRxRepository` | When redeeming a task via Fachdienst |
| `02403` | `internalError` | When an internal error occurs which most likely is a programming error |
| `02404` | `unspecified` | When error conversion into `RedeemServiceError` fails |
| `02405` | `noTokenAvailable` | When the user has no valid token available while trying to redeem via Fachdienst |
| `02406` | `loginHandler` | When receiving an error while doing a login |
| `02407` | `prescriptionAlreadyRedeemed` | When the prescription has already been redeemed |

### Related Errors

- Case `eRxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `internalError` → [InternalError](#internalerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)

---

## InternalError

**Error Code**: `025`
**Qualified Name**: `RedeemServiceError.InternalError`
**File**: `./Sources/eRpApp/Screens/Pharmacy/RedeemService/RedeemServiceError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02501` | `missingAVSEndpoint` | When the AVS endpoint for the selected redeem option is missing |
| `02502` | `missingAVSCertificate` | When the required AVS certificates for redeeming via AVS are missing |
| `02503` | `missingTelematikId` | When the Telematik-ID of the pharmacy to redeem in is missing |
| `02504` | `conversionVersionNumber` | When converting AVS Version number |
| `02505` | `idMissmatch` | When no order can be found to the received response |
| `02506` | `noService` | When no service can be found for the selected pharmacy |
| `02507` | `unexpectedHTTPStatusCode` | When the status code is not in [200..<300] but the service did not return an error beforehand |
| `02508` | `localStoreError` | When persisting/extracting information from the store went wrong |

### Related Errors

- Case `localStoreError` → [LocalStoreError](#localstoreerror)

---

## NFCHealthCardPasswordControllerError

**Error Code**: `026`
**Qualified Name**: `NFCHealthCardPasswordControllerError`
**File**: `./Sources/eRpApp/Screens/Settings/HealthCard/Password/ReadCard/NFCHealthCardPasswordController.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02601` | `cardError` | No description |
| `02602` | `openSecureSession` | No description |
| `02603` | `resetRetryCounter` | No description |
| `02604` | `wrongCan` | No description |
| `02605` | `changeReferenceData` | No description |
| `02606` | `couldNotInitializeSession` | No description |
| `02607` | `nfcHealthCardSession` | Any error regarding the communication with the NFC health card itself or sending/receiving data (operation execution) |

---

## OrganDonorJumpServiceError

**Error Code**: `040`
**Qualified Name**: `OrganDonorJumpServiceError`
**File**: `./Sources/eRpApp/Screens/Settings/OrganDonorJumpService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04001` | `fetchingProfile` | No description |
| `04002` | `generatingGenericUrl` | No description |
| `04003` | `openingSpecificUrl` | No description |

---

## ChargeItemDomainServiceFetchResultError

**Error Code**: `030`
**Qualified Name**: `ChargeItemDomainServiceFetchResult.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/ChargeItemListDomainService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03001` | `localStore` | No description |
| `03002` | `loginHandler` | No description |
| `03003` | `erxRepository` | No description |
| `03004` | `unexpected` | No description |
| `03005` | `consentService` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `consentService` → [ConsentServiceError](#consentserviceerror)

---

## ChargeItemDomainServiceAuthenticateResultError

**Error Code**: `031`
**Qualified Name**: `ChargeItemDomainServiceAuthenticateResult.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/ChargeItemListDomainService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03101` | `loginHandler` | No description |
| `03102` | `unexpected` | No description |

### Related Errors

- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)

---

## ChargeItemListDomainServiceGrantResultError

**Error Code**: `032`
**Qualified Name**: `ChargeItemListDomainServiceGrantResult.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/ChargeItemListDomainService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03201` | `localStore` | No description |
| `03202` | `loginHandler` | No description |
| `03203` | `erxRepository` | No description |
| `03204` | `unexpectedGrantConsentResponse` | No description |
| `03205` | `unexpected` | No description |
| `03206` | `consentService` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `consentService` → [ConsentServiceError](#consentserviceerror)

---

## ChargeItemListDomainServiceRevokeResultError

**Error Code**: `033`
**Qualified Name**: `ChargeItemListDomainServiceRevokeResult.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/ChargeItemListDomainService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03301` | `localStore` | No description |
| `03302` | `loginHandler` | No description |
| `03303` | `erxRepository` | No description |
| `03304` | `unexpected` | No description |
| `03305` | `consentService` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)
- Case `consentService` → [ConsentServiceError](#consentserviceerror)

---

## ChargeItemDomainServiceDeleteResultError

**Error Code**: `034`
**Qualified Name**: `ChargeItemDomainServiceDeleteResult.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/ChargeItemListDomainService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03401` | `localStore` | No description |
| `03402` | `loginHandler` | No description |
| `03403` | `erxRepository` | No description |
| `03404` | `unexpected` | No description |

### Related Errors

- Case `localStore` → [LocalStoreError](#localstoreerror)
- Case `loginHandler` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepository` → [ErxRepositoryError](#erxrepositoryerror)

---

## ChargeItemPDFServiceError

**Error Code**: `035`
**Qualified Name**: `ChargeItemPDFServiceError`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/ChargeItemList/Helper/ChargeItemPDFService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03501` | `couldNotCreateDestinationURL` | No description |
| `03502` | `couldNotCreatePDFStringForParsing` | No description |
| `03503` | `parsingError` | No description |
| `03504` | `failedToCreateAttachment` | No description |
| `03505` | `dataMissingPatient` | No description |
| `03506` | `dataMissingDoctor` | No description |
| `03507` | `dataMissingPharmacy` | No description |
| `03508` | `dataMissingInvoice` | No description |

### Related Errors

- Case `parsingError` → [ConsentServiceError](#consentserviceerror)
- Case `failedToCreateAttachment` → [ConsentServiceError](#consentserviceerror)

---

## PushNotificationRegistrationError

**Error Code**: `702`
**Qualified Name**: `PushNotificationRegistrationError`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/Notifications/PushNotificationRegistrationService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `70201` | `missingPushGatewayURL` | No description |
| `70202` | `missingAppId` | No description |
| `70203` | `notRegistered` | No description |

---

## AuditEventsServiceError

**Error Code**: `028`
**Qualified Name**: `AuditEventsServiceError`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/Protocol/AuditEventsService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02801` | `missingAuthentication` | No description |
| `02802` | `loginHandlerError` | No description |
| `02803` | `erxRepositoryError` | No description |

### Related Errors

- Case `loginHandlerError` → [LoginHandlerError](#loginhandlererror)
- Case `erxRepositoryError` → [ErxRepositoryError](#erxrepositoryerror)

---

## RegisteredDevicesDomainError

**Error Code**: `017`
**Qualified Name**: `RegisteredDevicesDomain.Error`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/RegisteredDevices/RegisteredDevicesDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01701` | `generic` | No description |

---

## RegisteredDevicesServiceError

**Error Code**: `018`
**Qualified Name**: `RegisteredDevicesServiceError`
**File**: `./Sources/eRpApp/Screens/Settings/Profiles/RegisteredDevices/RegisteredDevicesService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01801` | `missingAuthentication` | No description |
| `01802` | `missingToken` | No description |
| `01803` | `loginHandlerError` | No description |
| `01804` | `idpError` | No description |

### Related Errors

- Case `loginHandlerError` → [LoginHandlerError](#loginhandlererror)
- Case `idpError` → [IDPError](#idperror)

---

## SettingsDomainError

**Error Code**: `039`
**Qualified Name**: `SettingsDomainError`
**File**: `./Sources/eRpApp/Screens/Settings/SettingsDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `03901` | `organDonorJumpError` | No description |
| `03902` | `organDonorUnknownError` | No description |

### Related Errors

- Case `organDonorJumpError` → [OrganDonorJumpServiceError](#organdonorjumpserviceerror)

---

## DemoError

**Error Code**: `019`
**Qualified Name**: `DemoError`
**File**: `./Sources/eRpApp/Session/Demo/DemoError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `01901` | `demo` | No description |

---

## AppSecurityManagerError

**Error Code**: `044`
**Qualified Name**: `AppSecurityManagerError`
**File**: `./Sources/eRpApp/Session/Helper/AppSecurityManager.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04401` | `savePasswordFailed` | No description |
| `04402` | `retrievePasswordFailed` | No description |
| `04403` | `localAuthenticationContext` | No description |
| `04404` | `migrationFailed` | No description |
| `04405` | `passwordDelayInfoIOFailed` | No description |

---

## UserProfileServiceError

**Error Code**: `022`
**Qualified Name**: `UserProfileServiceError`
**File**: `./Sources/eRpApp/Session/UserProfileService.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `02201` | `localStoreError` | No description |

### Related Errors

- Case `localStoreError` → [LocalStoreError](#localstoreerror)

---

## UserSessionError

**Error Code**: `008`
**Qualified Name**: `UserSessionError`
**File**: `./Sources/eRpApp/Session/UserSession.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00801` | `idpError` | No description |

### Related Errors

- Case `idpError` → [IDPError](#idperror)

---

## UserSessionProviderError

**Error Code**: `007`
**Qualified Name**: `UserSessionProviderError`
**File**: `./Sources/eRpApp/Session/UserSessionProvider.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `00701` | `unavailable` | No description |

---

## ShareSheetDomainError

**Error Code**: `043`
**Qualified Name**: `ShareSheetDomain.Error`
**File**: `./Sources/eRpApp/State/ShareSheetDomain.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `04301` | `shareFailure` | No description |

---

## DefaultDataMatrixStringEncoderError

**Error Code**: `202`
**Qualified Name**: `DefaultDataMatrixStringEncoderError`
**File**: `./Sources/eRpKit/ErxMatrixCode/DataMatrixStringEncoder.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20201` | `stringEncoding` | Generic error while encoding the string. |
| `20202` | `missingAccessCode` | Access code is missing |

---

## ErxConsentError

**Error Code**: `206`
**Qualified Name**: `ErxConsent.Error`
**File**: `./Sources/eRpKit/ErxModels/ErxConsent.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20601` | `unableToConstructConsentRequest` | Unable to construct consent request |
| `20602` | `invalidErxConsentInput` | Invalid ErxConsent input |

---

## StatusError

**Error Code**: `201`
**Qualified Name**: `ErxTask.Status.Error`
**File**: `./Sources/eRpKit/ErxModels/ErxTask+Status.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20101` | `decoding` | No description |
| `20102` | `unknown` | No description |
| `20103` | `missingStatus` | No description |
| `20104` | `missingPatientReceiptReference` | No description |
| `20105` | `missingPatientReceiptIdentifier` | No description |
| `20106` | `missingPatientReceiptBundle` | No description |

---

## ErxTaskError

**Error Code**: `209`
**Qualified Name**: `ErxTask.Error`
**File**: `./Sources/eRpKit/ErxModels/ErxTask.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20901` | `unableToConstructInputPatch` | Unable to construct task input patch request |

---

## ErxTaskOrderError

**Error Code**: `208`
**Qualified Name**: `ErxTaskOrder.Error`
**File**: `./Sources/eRpKit/ErxModels/ErxTaskOrder.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20801` | `unableToConstructCommunicationRequest` | Unable to construct communication request |
| `20802` | `invalidErxTaskOrderInput` | Invalid ErxTaskOrder though previous validation checks have been passed |

---

## ErxRepositoryError

**Error Code**: `200`
**Qualified Name**: `ErxRepositoryError`
**File**: `./Sources/eRpKit/ErxRepositoryError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20001` | `local` | No description |
| `20002` | `remote` | No description |

### Related Errors

- Case `local` → [LocalStoreError](#localstoreerror)
- Case `remote` → [RemoteStoreError](#remotestoreerror)

---

## EuAccessCodeError

**Error Code**: `209`
**Qualified Name**: `EuAccessCode.Error`
**File**: `./Sources/eRpKit/EuAccessCode.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20901` | `unableToConstructEuAccessCodeRequest` | Unable to construct euAccessCode request |

---

## LocalStoreError

**Error Code**: `203`
**Qualified Name**: `LocalStoreError`
**File**: `./Sources/eRpKit/LocalStoreError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20301` | `notImplemented` | No description |
| `20302` | `initialization` | No description |
| `20303` | `write` | No description |
| `20304` | `delete` | No description |
| `20305` | `read` | No description |

---

## RemoteStoreError

**Error Code**: `204`
**Qualified Name**: `RemoteStoreError`
**File**: `./Sources/eRpKit/RemoteStoreError.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20401` | `fhirClient` | No description |
| `20402` | `notImplemented` | No description |

### Related Errors

- Case `fhirClient` → [FHIRClientError](#fhirclienterror)

---

## ScannedErxTaskError

**Error Code**: `205`
**Qualified Name**: `ScannedErxTask.Error`
**File**: `./Sources/eRpKit/ScannedErxTask.swift`

**Description**:
Error cases for the ScannedErxTask

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20501` | `format` | No description |
| `20502` | `invalidID` | No description |
| `20503` | `invalidAccessCode` | No description |
| `20504` | `invalidJSON` | No description |

---

## SharedTaskError

**Error Code**: `207`
**Qualified Name**: `SharedTask.Error`
**File**: `./Sources/eRpKit/SharedTask.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `20701` | `missingSeparator` | No description |
| `20702` | `failedDecodingEmptyString` | No description |
| `20703` | `tooManyComponents` | No description |

---

## AVSTransactionCoreDataStoreError

**Error Code**: `581`
**Qualified Name**: `AVSTransactionCoreDataStore.Error`
**File**: `./Sources/eRpLocalStorage/AVSTransaction/AVSTransactionCoreDataStore.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `58101` | `noMatchingEntity` | No description |
| `58102` | `internalError` | No description |

---

## CoreDataControllerError

**Error Code**: `500`
**Qualified Name**: `CoreDataController.Error`
**File**: `./Sources/eRpLocalStorage/CoreDataController.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50001` | `initialization` | No description |

---

## ExcludeFileError

**Error Code**: `503`
**Qualified Name**: `FileManager.ExcludeFileError`
**File**: `./Sources/eRpLocalStorage/FileManager+Backup.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50301` | `fileDoesNotExist` | No description |
| `50302` | `error` | No description |

---

## MigrationError

**Error Code**: `501`
**Qualified Name**: `MigrationError`
**File**: `./Sources/eRpLocalStorage/MigrationManager.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50101` | `isLatestVersion` | No description |
| `50102` | `missingProfile` | No description |
| `50103` | `write` | No description |
| `50104` | `read` | No description |
| `50105` | `delete` | No description |
| `50106` | `unspecified` | No description |
| `50107` | `initialization` | No description |

---

## PharmacyCoreDataStoreError

**Error Code**: `505`
**Qualified Name**: `PharmacyCoreDataStore.Error`
**File**: `./Sources/eRpLocalStorage/Pharmacy/PharmacyCoreDataStore.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50501` | `noMatchingEntity` | No description |

---

## ProfileCoreDataStoreError

**Error Code**: `502`
**Qualified Name**: `ProfileCoreDataStore.Error`
**File**: `./Sources/eRpLocalStorage/Profiles/ProfileCoreDataStore.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50201` | `noMatchingEntity` | No description |
| `50202` | `initialization` | No description |

---

## ShipmentInfoCoreDataStoreError

**Error Code**: `504`
**Qualified Name**: `ShipmentInfoCoreDataStore.Error`
**File**: `./Sources/eRpLocalStorage/ShipmentInfo/ShipmentInfoCoreDataStore.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `50401` | `noMatchingEntity` | No description |
| `50402` | `internalError` | No description |

---

## RemoteStorageBundleParsingError

**Error Code**: `580`
**Qualified Name**: `RemoteStorageBundleParsingError`
**File**: `./Sources/eRpRemoteStorage/ModelsR4.Bundle+ErxTask.swift`

### Error Cases

| ID | Case | Description |
|---|---|---|
| `58001` | `parseError` | No description |

---

## Error Relationships

This section shows how errors are related to each other through associated types:

- `AVSError.network` → `HTTPClientError`
- `AVSError.`internal`` → `InternalError`
- `BfArMError.network` → `HTTPClientError`
- `ConsentServiceError.localStore` → `LocalStoreError`
- `ConsentServiceError.loginHandler` → `LoginHandlerError`
- `ConsentServiceError.erxRepository` → `ErxRepositoryError`
- `FHIRVZDError.network` → `HTTPClientError`
- `CardWallExtAuthSelectionDomainError.idpError` → `IDPError`
- `CardWallIntroductionDomainError.idpError` → `IDPError`
- `StateError.idpError` → `IDPError`
- `StateError.inputError` → `InputError`
- `StateError.signChallengeError` → `NFCSignatureProviderError`
- `StateError.profileValidation` → `IDTokenValidatorError`
- `LoginHandlerError.idpError` → `IDPError`
- `NFCSignatureProviderError.verifyCardError` → `VerifyPINError`
- `NFCSignatureProviderError.signingFailure` → `SigningError`
- `NFCSignatureProviderError.secureEnclaveError` → `SecureEnclaveSignatureProviderError`
- `OrdersRepositoryError.erxRepository` → `ErxRepositoryError`
- `OrdersRepositoryError.pharmacyRepository` → `PharmacyRepositoryError`
- `InternalCommunicationError.decodingError` → `ConsentServiceError`
- `EuRedeemServiceError.eRxRepository` → `ErxRepositoryError`
- `EuRedeemServiceError.localStoreError` → `LocalStoreError`
- `EuRedeemServiceError.euCodeGeneration` → `EuCodeGenerationError`
- `EuRedeemServiceError.loginHandler` → `LoginHandlerError`
- `IDPError.`internal`` → `InternalError`
- `IDPError.biometrics` → `SecureEnclaveSignatureProviderError`
- `PharmacyRepositoryError.local` → `LocalStoreError`
- `TrustStoreError.network` → `HTTPClientError`
- `TrustStoreError.`internal`` → `InternalError`
- `VAUError.network` → `HTTPClientError`
- `PrescriptionRepositoryError.loginHandler` → `LoginHandlerError`
- `PrescriptionRepositoryError.erxRepository` → `ErxRepositoryError`
- `ScannerDomainError.scannedErxTask` → `ScannedErxTaskError`
- `ExtAuthPendingDomainError.idpError` → `IDPError`
- `ExtAuthPendingDomainError.profileValidation` → `IDTokenValidatorError`
- `MainDomainError.localStoreError` → `LocalStoreError`
- `MainDomainError.userSessionError` → `UserSessionError`
- `MainDomainError.repositoryError` → `ErxRepositoryError`
- `InternalCommunicationError.decodingError` → `ConsentServiceError`
- `DefaultOrdersRepositoryError.erxRepository` → `ErxRepositoryError`
- `DefaultOrdersRepositoryError.pharmacyRepository` → `PharmacyRepositoryError`
- `RedeemOrderServiceError.localStore` → `LocalStoreError`
- `RedeemOrderServiceError.pharmacy` → `PharmacyRepositoryError`
- `RedeemOrderServiceError.redeem` → `RedeemServiceError`
- `RedeemServiceError.eRxRepository` → `ErxRepositoryError`
- `RedeemServiceError.internalError` → `InternalError`
- `RedeemServiceError.loginHandler` → `LoginHandlerError`
- `InternalError.localStoreError` → `LocalStoreError`
- `ChargeItemDomainServiceFetchResultError.localStore` → `LocalStoreError`
- `ChargeItemDomainServiceFetchResultError.loginHandler` → `LoginHandlerError`
- `ChargeItemDomainServiceFetchResultError.erxRepository` → `ErxRepositoryError`
- `ChargeItemDomainServiceFetchResultError.consentService` → `ConsentServiceError`
- `ChargeItemDomainServiceAuthenticateResultError.loginHandler` → `LoginHandlerError`
- `ChargeItemListDomainServiceGrantResultError.localStore` → `LocalStoreError`
- `ChargeItemListDomainServiceGrantResultError.loginHandler` → `LoginHandlerError`
- `ChargeItemListDomainServiceGrantResultError.erxRepository` → `ErxRepositoryError`
- `ChargeItemListDomainServiceGrantResultError.consentService` → `ConsentServiceError`
- `ChargeItemListDomainServiceRevokeResultError.localStore` → `LocalStoreError`
- `ChargeItemListDomainServiceRevokeResultError.loginHandler` → `LoginHandlerError`
- `ChargeItemListDomainServiceRevokeResultError.erxRepository` → `ErxRepositoryError`
- `ChargeItemListDomainServiceRevokeResultError.consentService` → `ConsentServiceError`
- `ChargeItemDomainServiceDeleteResultError.localStore` → `LocalStoreError`
- `ChargeItemDomainServiceDeleteResultError.loginHandler` → `LoginHandlerError`
- `ChargeItemDomainServiceDeleteResultError.erxRepository` → `ErxRepositoryError`
- `ChargeItemPDFServiceError.parsingError` → `ConsentServiceError`
- `ChargeItemPDFServiceError.failedToCreateAttachment` → `ConsentServiceError`
- `AuditEventsServiceError.loginHandlerError` → `LoginHandlerError`
- `AuditEventsServiceError.erxRepositoryError` → `ErxRepositoryError`
- `RegisteredDevicesServiceError.loginHandlerError` → `LoginHandlerError`
- `RegisteredDevicesServiceError.idpError` → `IDPError`
- `SettingsDomainError.organDonorJumpError` → `OrganDonorJumpServiceError`
- `UserProfileServiceError.localStoreError` → `LocalStoreError`
- `UserSessionError.idpError` → `IDPError`
- `ErxRepositoryError.local` → `LocalStoreError`
- `ErxRepositoryError.remote` → `RemoteStoreError`
- `RemoteStoreError.fhirClient` → `FHIRClientError`
