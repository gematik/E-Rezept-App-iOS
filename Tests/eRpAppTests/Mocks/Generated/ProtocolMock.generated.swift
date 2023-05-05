// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import AVS
import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy
import TestUtils
import TrustStore
import VAUClient
import ZXingObjC

@testable import eRpApp

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockAVSSession -

final class MockAVSSession: AVSSession {
    
   // MARK: - redeem

    var redeemMessageEndpointRecipientsCallsCount = 0
    var redeemMessageEndpointRecipientsCalled: Bool {
        redeemMessageEndpointRecipientsCallsCount > 0
    }
    var redeemMessageEndpointRecipientsReceivedArguments: (message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])?
    var redeemMessageEndpointRecipientsReceivedInvocations: [(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])] = []
    var redeemMessageEndpointRecipientsReturnValue: AnyPublisher<AVSSessionResponse, AVSError>!
    var redeemMessageEndpointRecipientsClosure: ((AVSMessage, AVSEndpoint, [X509]) -> AnyPublisher<AVSSessionResponse, AVSError>)?

    func redeem(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509]) -> AnyPublisher<AVSSessionResponse, AVSError> {
        redeemMessageEndpointRecipientsCallsCount += 1
        redeemMessageEndpointRecipientsReceivedArguments = (message: message, endpoint: endpoint, recipients: recipients)
        redeemMessageEndpointRecipientsReceivedInvocations.append((message: message, endpoint: endpoint, recipients: recipients))
        return redeemMessageEndpointRecipientsClosure.map({ $0(message, endpoint, recipients) }) ?? redeemMessageEndpointRecipientsReturnValue
    }
}


// MARK: - MockAVSTransactionDataStore -

final class MockAVSTransactionDataStore: AVSTransactionDataStore {
    
   // MARK: - fetchAVSTransaction

    var fetchAVSTransactionByCallsCount = 0
    var fetchAVSTransactionByCalled: Bool {
        fetchAVSTransactionByCallsCount > 0
    }
    var fetchAVSTransactionByReceivedIdentifier: UUID?
    var fetchAVSTransactionByReceivedInvocations: [UUID] = []
    var fetchAVSTransactionByReturnValue: AnyPublisher<AVSTransaction?, LocalStoreError>!
    var fetchAVSTransactionByClosure: ((UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>)?

    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        fetchAVSTransactionByCallsCount += 1
        fetchAVSTransactionByReceivedIdentifier = identifier
        fetchAVSTransactionByReceivedInvocations.append(identifier)
        return fetchAVSTransactionByClosure.map({ $0(identifier) }) ?? fetchAVSTransactionByReturnValue
    }
    
   // MARK: - listAllAVSTransactions

    var listAllAVSTransactionsCallsCount = 0
    var listAllAVSTransactionsCalled: Bool {
        listAllAVSTransactionsCallsCount > 0
    }
    var listAllAVSTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var listAllAVSTransactionsClosure: (() -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        listAllAVSTransactionsCallsCount += 1
        return listAllAVSTransactionsClosure.map({ $0() }) ?? listAllAVSTransactionsReturnValue
    }
    
   // MARK: - save

    var saveAvsTransactionsCallsCount = 0
    var saveAvsTransactionsCalled: Bool {
        saveAvsTransactionsCallsCount > 0
    }
    var saveAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var saveAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var saveAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var saveAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        saveAvsTransactionsCallsCount += 1
        saveAvsTransactionsReceivedAvsTransactions = avsTransactions
        saveAvsTransactionsReceivedInvocations.append(avsTransactions)
        return saveAvsTransactionsClosure.map({ $0(avsTransactions) }) ?? saveAvsTransactionsReturnValue
    }
    
   // MARK: - delete

    var deleteAvsTransactionsCallsCount = 0
    var deleteAvsTransactionsCalled: Bool {
        deleteAvsTransactionsCallsCount > 0
    }
    var deleteAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var deleteAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var deleteAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var deleteAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        deleteAvsTransactionsCallsCount += 1
        deleteAvsTransactionsReceivedAvsTransactions = avsTransactions
        deleteAvsTransactionsReceivedInvocations.append(avsTransactions)
        return deleteAvsTransactionsClosure.map({ $0(avsTransactions) }) ?? deleteAvsTransactionsReturnValue
    }
}


// MARK: - MockActivityIndicating -

final class MockActivityIndicating: ActivityIndicating {
    
   // MARK: - isActive

    var isActive: AnyPublisher<Bool, Never> {
        get { underlyingIsActive }
        set(value) { underlyingIsActive = value }
    }
    var underlyingIsActive: AnyPublisher<Bool, Never>!
}


// MARK: - MockAuthenticationChallengeProvider -

final class MockAuthenticationChallengeProvider: AuthenticationChallengeProvider {
    
   // MARK: - startAuthenticationChallenge

    var startAuthenticationChallengeCallsCount = 0
    var startAuthenticationChallengeCalled: Bool {
        startAuthenticationChallengeCallsCount > 0
    }
    var startAuthenticationChallengeReturnValue: AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never>!
    var startAuthenticationChallengeClosure: (() -> AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never>)?

    func startAuthenticationChallenge() -> AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never> {
        startAuthenticationChallengeCallsCount += 1
        return startAuthenticationChallengeClosure.map({ $0() }) ?? startAuthenticationChallengeReturnValue
    }
}


// MARK: - MockChargeItemsDomainService -

final class MockChargeItemsDomainService: ChargeItemsDomainService {
    
   // MARK: - fetchChargeItems

    var fetchChargeItemsForCallsCount = 0
    var fetchChargeItemsForCalled: Bool {
        fetchChargeItemsForCallsCount > 0
    }
    var fetchChargeItemsForReceivedProfileId: UUID?
    var fetchChargeItemsForReceivedInvocations: [UUID] = []
    var fetchChargeItemsForReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchChargeItemsForClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchChargeItemsForCallsCount += 1
        fetchChargeItemsForReceivedProfileId = profileId
        fetchChargeItemsForReceivedInvocations.append(profileId)
        return fetchChargeItemsForClosure.map({ $0(profileId) }) ?? fetchChargeItemsForReturnValue
    }
    
   // MARK: - authenticate

    var authenticateForCallsCount = 0
    var authenticateForCalled: Bool {
        authenticateForCallsCount > 0
    }
    var authenticateForReceivedProfileId: UUID?
    var authenticateForReceivedInvocations: [UUID] = []
    var authenticateForReturnValue: AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>!
    var authenticateForClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>)?

    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never> {
        authenticateForCallsCount += 1
        authenticateForReceivedProfileId = profileId
        authenticateForReceivedInvocations.append(profileId)
        return authenticateForClosure.map({ $0(profileId) }) ?? authenticateForReturnValue
    }
    
   // MARK: - grantChargeItemsConsent

    var grantChargeItemsConsentForCallsCount = 0
    var grantChargeItemsConsentForCalled: Bool {
        grantChargeItemsConsentForCallsCount > 0
    }
    var grantChargeItemsConsentForReceivedProfileId: UUID?
    var grantChargeItemsConsentForReceivedInvocations: [UUID] = []
    var grantChargeItemsConsentForReturnValue: AnyPublisher<ChargeItemsDomainServiceGrantResult, Never>!
    var grantChargeItemsConsentForClosure: ((UUID) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never>)?

    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceGrantResult, Never> {
        grantChargeItemsConsentForCallsCount += 1
        grantChargeItemsConsentForReceivedProfileId = profileId
        grantChargeItemsConsentForReceivedInvocations.append(profileId)
        return grantChargeItemsConsentForClosure.map({ $0(profileId) }) ?? grantChargeItemsConsentForReturnValue
    }
    
   // MARK: - fetchChargeItemsAssumingConsentGranted

    var fetchChargeItemsAssumingConsentGrantedForCallsCount = 0
    var fetchChargeItemsAssumingConsentGrantedForCalled: Bool {
        fetchChargeItemsAssumingConsentGrantedForCallsCount > 0
    }
    var fetchChargeItemsAssumingConsentGrantedForReceivedProfileId: UUID?
    var fetchChargeItemsAssumingConsentGrantedForReceivedInvocations: [UUID] = []
    var fetchChargeItemsAssumingConsentGrantedForReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchChargeItemsAssumingConsentGrantedForClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchChargeItemsAssumingConsentGrantedForCallsCount += 1
        fetchChargeItemsAssumingConsentGrantedForReceivedProfileId = profileId
        fetchChargeItemsAssumingConsentGrantedForReceivedInvocations.append(profileId)
        return fetchChargeItemsAssumingConsentGrantedForClosure.map({ $0(profileId) }) ?? fetchChargeItemsAssumingConsentGrantedForReturnValue
    }
    
   // MARK: - revokeChargeItemsConsent

    var revokeChargeItemsConsentForCallsCount = 0
    var revokeChargeItemsConsentForCalled: Bool {
        revokeChargeItemsConsentForCallsCount > 0
    }
    var revokeChargeItemsConsentForReceivedProfileId: UUID?
    var revokeChargeItemsConsentForReceivedInvocations: [UUID] = []
    var revokeChargeItemsConsentForReturnValue: AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never>!
    var revokeChargeItemsConsentForClosure: ((UUID) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never>)?

    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemsDomainServiceRevokeResult, Never> {
        revokeChargeItemsConsentForCallsCount += 1
        revokeChargeItemsConsentForReceivedProfileId = profileId
        revokeChargeItemsConsentForReceivedInvocations.append(profileId)
        return revokeChargeItemsConsentForClosure.map({ $0(profileId) }) ?? revokeChargeItemsConsentForReturnValue
    }
}


// MARK: - MockDeviceSecurityManagerSessionStorage -

final class MockDeviceSecurityManagerSessionStorage: DeviceSecurityManagerSessionStorage {
    
   // MARK: - ignoreDeviceNotSecuredWarningForSession

    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> {
        get { underlyingIgnoreDeviceNotSecuredWarningForSession }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningForSession = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never>!
    
   // MARK: - ignoreDeviceRootedWarningForSession

    var ignoreDeviceRootedWarningForSession: Bool {
        get { underlyingIgnoreDeviceRootedWarningForSession }
        set(value) { underlyingIgnoreDeviceRootedWarningForSession = value }
    }
    var underlyingIgnoreDeviceRootedWarningForSession: Bool!
    
   // MARK: - set

    var setIgnoreDeviceNotSecuredWarningForSessionCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningForSessionCalled: Bool {
        setIgnoreDeviceNotSecuredWarningForSessionCallsCount > 0
    }
    var setIgnoreDeviceNotSecuredWarningForSessionReceivedIgnoreDeviceNotSecuredWarningForSession: Bool?
    var setIgnoreDeviceNotSecuredWarningForSessionReceivedInvocations: [Bool?] = []
    var setIgnoreDeviceNotSecuredWarningForSessionClosure: ((Bool?) -> Void)?

    func set(ignoreDeviceNotSecuredWarningForSession: Bool?) {
        setIgnoreDeviceNotSecuredWarningForSessionCallsCount += 1
        setIgnoreDeviceNotSecuredWarningForSessionReceivedIgnoreDeviceNotSecuredWarningForSession = ignoreDeviceNotSecuredWarningForSession
        setIgnoreDeviceNotSecuredWarningForSessionReceivedInvocations.append(ignoreDeviceNotSecuredWarningForSession)
        setIgnoreDeviceNotSecuredWarningForSessionClosure?(ignoreDeviceNotSecuredWarningForSession)
    }
}


// MARK: - MockERPDateFormatter -

final class MockERPDateFormatter: ERPDateFormatter {
    
   // MARK: - string

    var stringFromCallsCount = 0
    var stringFromCalled: Bool {
        stringFromCallsCount > 0
    }
    var stringFromReceivedFrom: Date?
    var stringFromReceivedInvocations: [Date] = []
    var stringFromReturnValue: String!
    var stringFromClosure: ((Date) -> String)?

    func string(from: Date) -> String {
        stringFromCallsCount += 1
        stringFromReceivedFrom = from
        stringFromReceivedInvocations.append(from)
        return stringFromClosure.map({ $0(from) }) ?? stringFromReturnValue
    }
}


// MARK: - MockFeedbackReceiver -

final class MockFeedbackReceiver: FeedbackReceiver {
    
   // MARK: - hapticFeedbackSuccess

    var hapticFeedbackSuccessCallsCount = 0
    var hapticFeedbackSuccessCalled: Bool {
        hapticFeedbackSuccessCallsCount > 0
    }
    var hapticFeedbackSuccessClosure: (() -> Void)?

    func hapticFeedbackSuccess() {
        hapticFeedbackSuccessCallsCount += 1
        hapticFeedbackSuccessClosure?()
    }
}


// MARK: - MockIDPSession -

final class MockIDPSession: IDPSession {
    
   // MARK: - isLoggedIn

    var isLoggedIn: AnyPublisher<Bool, IDPError> {
        get { underlyingIsLoggedIn }
        set(value) { underlyingIsLoggedIn = value }
    }
    var underlyingIsLoggedIn: AnyPublisher<Bool, IDPError>!
    
   // MARK: - autoRefreshedToken

    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        get { underlyingAutoRefreshedToken }
        set(value) { underlyingAutoRefreshedToken = value }
    }
    var underlyingAutoRefreshedToken: AnyPublisher<IDPToken?, IDPError>!
    
   // MARK: - invalidateAccessToken

    var invalidateAccessTokenCallsCount = 0
    var invalidateAccessTokenCalled: Bool {
        invalidateAccessTokenCallsCount > 0
    }
    var invalidateAccessTokenClosure: (() -> Void)?

    func invalidateAccessToken() {
        invalidateAccessTokenCallsCount += 1
        invalidateAccessTokenClosure?()
    }
    
   // MARK: - requestChallenge

    var requestChallengeCallsCount = 0
    var requestChallengeCalled: Bool {
        requestChallengeCallsCount > 0
    }
    var requestChallengeReturnValue: AnyPublisher<IDPChallengeSession, IDPError>!
    var requestChallengeClosure: (() -> AnyPublisher<IDPChallengeSession, IDPError>)?

    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        requestChallengeCallsCount += 1
        return requestChallengeClosure.map({ $0() }) ?? requestChallengeReturnValue
    }
    
   // MARK: - verify

    var verifyCallsCount = 0
    var verifyCalled: Bool {
        verifyCallsCount > 0
    }
    var verifyReceivedSignedChallenge: SignedChallenge?
    var verifyReceivedInvocations: [SignedChallenge] = []
    var verifyReturnValue: AnyPublisher<IDPExchangeToken, IDPError>!
    var verifyClosure: ((SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError>)?

    func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        verifyCallsCount += 1
        verifyReceivedSignedChallenge = signedChallenge
        verifyReceivedInvocations.append(signedChallenge)
        return verifyClosure.map({ $0(signedChallenge) }) ?? verifyReturnValue
    }
    
   // MARK: - exchange

    var exchangeTokenChallengeSessionIdTokenValidatorCallsCount = 0
    var exchangeTokenChallengeSessionIdTokenValidatorCalled: Bool {
        exchangeTokenChallengeSessionIdTokenValidatorCallsCount > 0
    }
    var exchangeTokenChallengeSessionIdTokenValidatorReceivedArguments: (token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)?
    var exchangeTokenChallengeSessionIdTokenValidatorReceivedInvocations: [(token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)] = []
    var exchangeTokenChallengeSessionIdTokenValidatorReturnValue: AnyPublisher<IDPToken, IDPError>!
    var exchangeTokenChallengeSessionIdTokenValidatorClosure: ((IDPExchangeToken, ChallengeSession, @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError>)?

    func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        exchangeTokenChallengeSessionIdTokenValidatorCallsCount += 1
        exchangeTokenChallengeSessionIdTokenValidatorReceivedArguments = (token: token, challengeSession: challengeSession, idTokenValidator: idTokenValidator)
        exchangeTokenChallengeSessionIdTokenValidatorReceivedInvocations.append((token: token, challengeSession: challengeSession, idTokenValidator: idTokenValidator))
        return exchangeTokenChallengeSessionIdTokenValidatorClosure.map({ $0(token, challengeSession, idTokenValidator) }) ?? exchangeTokenChallengeSessionIdTokenValidatorReturnValue
    }
    
   // MARK: - refresh

    var refreshTokenCallsCount = 0
    var refreshTokenCalled: Bool {
        refreshTokenCallsCount > 0
    }
    var refreshTokenReceivedToken: IDPToken?
    var refreshTokenReceivedInvocations: [IDPToken] = []
    var refreshTokenReturnValue: AnyPublisher<IDPToken, IDPError>!
    var refreshTokenClosure: ((IDPToken) -> AnyPublisher<IDPToken, IDPError>)?

    func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        refreshTokenCallsCount += 1
        refreshTokenReceivedToken = token
        refreshTokenReceivedInvocations.append(token)
        return refreshTokenClosure.map({ $0(token) }) ?? refreshTokenReturnValue
    }
    
   // MARK: - pairDevice

    var pairDeviceWithTokenCallsCount = 0
    var pairDeviceWithTokenCalled: Bool {
        pairDeviceWithTokenCallsCount > 0
    }
    var pairDeviceWithTokenReceivedArguments: (registrationData: RegistrationData, token: IDPToken)?
    var pairDeviceWithTokenReceivedInvocations: [(registrationData: RegistrationData, token: IDPToken)] = []
    var pairDeviceWithTokenReturnValue: AnyPublisher<PairingEntry, IDPError>!
    var pairDeviceWithTokenClosure: ((RegistrationData, IDPToken) -> AnyPublisher<PairingEntry, IDPError>)?

    func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        pairDeviceWithTokenCallsCount += 1
        pairDeviceWithTokenReceivedArguments = (registrationData: registrationData, token: token)
        pairDeviceWithTokenReceivedInvocations.append((registrationData: registrationData, token: token))
        return pairDeviceWithTokenClosure.map({ $0(registrationData, token) }) ?? pairDeviceWithTokenReturnValue
    }
    
   // MARK: - unregisterDevice

    var unregisterDeviceTokenCallsCount = 0
    var unregisterDeviceTokenCalled: Bool {
        unregisterDeviceTokenCallsCount > 0
    }
    var unregisterDeviceTokenReceivedArguments: (keyIdentifier: String, token: IDPToken)?
    var unregisterDeviceTokenReceivedInvocations: [(keyIdentifier: String, token: IDPToken)] = []
    var unregisterDeviceTokenReturnValue: AnyPublisher<Bool, IDPError>!
    var unregisterDeviceTokenClosure: ((String, IDPToken) -> AnyPublisher<Bool, IDPError>)?

    func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        unregisterDeviceTokenCallsCount += 1
        unregisterDeviceTokenReceivedArguments = (keyIdentifier: keyIdentifier, token: token)
        unregisterDeviceTokenReceivedInvocations.append((keyIdentifier: keyIdentifier, token: token))
        return unregisterDeviceTokenClosure.map({ $0(keyIdentifier, token) }) ?? unregisterDeviceTokenReturnValue
    }
    
   // MARK: - listDevices

    var listDevicesTokenCallsCount = 0
    var listDevicesTokenCalled: Bool {
        listDevicesTokenCallsCount > 0
    }
    var listDevicesTokenReceivedToken: IDPToken?
    var listDevicesTokenReceivedInvocations: [IDPToken] = []
    var listDevicesTokenReturnValue: AnyPublisher<PairingEntries, IDPError>!
    var listDevicesTokenClosure: ((IDPToken) -> AnyPublisher<PairingEntries, IDPError>)?

    func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        listDevicesTokenCallsCount += 1
        listDevicesTokenReceivedToken = token
        listDevicesTokenReceivedInvocations.append(token)
        return listDevicesTokenClosure.map({ $0(token) }) ?? listDevicesTokenReturnValue
    }
    
   // MARK: - altVerify

    var altVerifyCallsCount = 0
    var altVerifyCalled: Bool {
        altVerifyCallsCount > 0
    }
    var altVerifyReceivedSignedChallenge: SignedAuthenticationData?
    var altVerifyReceivedInvocations: [SignedAuthenticationData] = []
    var altVerifyReturnValue: AnyPublisher<IDPExchangeToken, IDPError>!
    var altVerifyClosure: ((SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError>)?

    func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        altVerifyCallsCount += 1
        altVerifyReceivedSignedChallenge = signedChallenge
        altVerifyReceivedInvocations.append(signedChallenge)
        return altVerifyClosure.map({ $0(signedChallenge) }) ?? altVerifyReturnValue
    }
    
   // MARK: - loadDirectoryKKApps

    var loadDirectoryKKAppsCallsCount = 0
    var loadDirectoryKKAppsCalled: Bool {
        loadDirectoryKKAppsCallsCount > 0
    }
    var loadDirectoryKKAppsReturnValue: AnyPublisher<KKAppDirectory, IDPError>!
    var loadDirectoryKKAppsClosure: (() -> AnyPublisher<KKAppDirectory, IDPError>)?

    func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        loadDirectoryKKAppsCallsCount += 1
        return loadDirectoryKKAppsClosure.map({ $0() }) ?? loadDirectoryKKAppsReturnValue
    }
    
   // MARK: - startExtAuth

    var startExtAuthEntryCallsCount = 0
    var startExtAuthEntryCalled: Bool {
        startExtAuthEntryCallsCount > 0
    }
    var startExtAuthEntryReceivedEntry: KKAppDirectory.Entry?
    var startExtAuthEntryReceivedInvocations: [KKAppDirectory.Entry] = []
    var startExtAuthEntryReturnValue: AnyPublisher<URL, IDPError>!
    var startExtAuthEntryClosure: ((KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError>)?

    func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        startExtAuthEntryCallsCount += 1
        startExtAuthEntryReceivedEntry = entry
        startExtAuthEntryReceivedInvocations.append(entry)
        return startExtAuthEntryClosure.map({ $0(entry) }) ?? startExtAuthEntryReturnValue
    }
    
   // MARK: - extAuthVerifyAndExchange

    var extAuthVerifyAndExchangeIdTokenValidatorCallsCount = 0
    var extAuthVerifyAndExchangeIdTokenValidatorCalled: Bool {
        extAuthVerifyAndExchangeIdTokenValidatorCallsCount > 0
    }
    var extAuthVerifyAndExchangeIdTokenValidatorReceivedArguments: (url: URL, idTokenValidator: (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)?
    var extAuthVerifyAndExchangeIdTokenValidatorReceivedInvocations: [(url: URL, idTokenValidator: (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)] = []
    var extAuthVerifyAndExchangeIdTokenValidatorReturnValue: AnyPublisher<IDPToken, IDPError>!
    var extAuthVerifyAndExchangeIdTokenValidatorClosure: ((URL, @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError>)?

    func extAuthVerifyAndExchange(_ url: URL, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        extAuthVerifyAndExchangeIdTokenValidatorCallsCount += 1
        extAuthVerifyAndExchangeIdTokenValidatorReceivedArguments = (url: url, idTokenValidator: idTokenValidator)
        extAuthVerifyAndExchangeIdTokenValidatorReceivedInvocations.append((url: url, idTokenValidator: idTokenValidator))
        return extAuthVerifyAndExchangeIdTokenValidatorClosure.map({ $0(url, idTokenValidator) }) ?? extAuthVerifyAndExchangeIdTokenValidatorReturnValue
    }
}


// MARK: - MockLoginHandler -

final class MockLoginHandler: LoginHandler {
    
   // MARK: - isAuthenticated

    var isAuthenticatedCallsCount = 0
    var isAuthenticatedCalled: Bool {
        isAuthenticatedCallsCount > 0
    }
    var isAuthenticatedReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedCallsCount += 1
        return isAuthenticatedClosure.map({ $0() }) ?? isAuthenticatedReturnValue
    }
    
   // MARK: - isAuthenticatedOrAuthenticate

    var isAuthenticatedOrAuthenticateCallsCount = 0
    var isAuthenticatedOrAuthenticateCalled: Bool {
        isAuthenticatedOrAuthenticateCallsCount > 0
    }
    var isAuthenticatedOrAuthenticateReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedOrAuthenticateClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedOrAuthenticateCallsCount += 1
        return isAuthenticatedOrAuthenticateClosure.map({ $0() }) ?? isAuthenticatedOrAuthenticateReturnValue
    }
}


// MARK: - MockMatrixCodeGenerator -

final class MockMatrixCodeGenerator: MatrixCodeGenerator {
    
   // MARK: - generateImage

    var generateImageForWidthHeightThrowableError: Error?
    var generateImageForWidthHeightCallsCount = 0
    var generateImageForWidthHeightCalled: Bool {
        generateImageForWidthHeightCallsCount > 0
    }
    var generateImageForWidthHeightReceivedArguments: (contents: String, width: Int, height: Int)?
    var generateImageForWidthHeightReceivedInvocations: [(contents: String, width: Int, height: Int)] = []
    var generateImageForWidthHeightReturnValue: CGImage!
    var generateImageForWidthHeightClosure: ((String, Int, Int) throws -> CGImage)?

    func generateImage(for contents: String, width: Int, height: Int) throws -> CGImage {
        if let error = generateImageForWidthHeightThrowableError {
            throw error
        }
        generateImageForWidthHeightCallsCount += 1
        generateImageForWidthHeightReceivedArguments = (contents: contents, width: width, height: height)
        generateImageForWidthHeightReceivedInvocations.append((contents: contents, width: width, height: height))
        return try generateImageForWidthHeightClosure.map({ try $0(contents, width, height) }) ?? generateImageForWidthHeightReturnValue
    }
}


// MARK: - MockModelMigrating -

final class MockModelMigrating: ModelMigrating {
    
   // MARK: - startModelMigration

    var startModelMigrationFromCallsCount = 0
    var startModelMigrationFromCalled: Bool {
        startModelMigrationFromCallsCount > 0
    }
    var startModelMigrationFromReceivedCurrentVersion: ModelVersion?
    var startModelMigrationFromReceivedInvocations: [ModelVersion] = []
    var startModelMigrationFromReturnValue: AnyPublisher<ModelVersion, MigrationError>!
    var startModelMigrationFromClosure: ((ModelVersion) -> AnyPublisher<ModelVersion, MigrationError>)?

    func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError> {
        startModelMigrationFromCallsCount += 1
        startModelMigrationFromReceivedCurrentVersion = currentVersion
        startModelMigrationFromReceivedInvocations.append(currentVersion)
        return startModelMigrationFromClosure.map({ $0(currentVersion) }) ?? startModelMigrationFromReturnValue
    }
}


// MARK: - MockNFCHealthCardPasswordController -

final class MockNFCHealthCardPasswordController: NFCHealthCardPasswordController {
    
   // MARK: - resetEgkMrPinRetryCounter

    var resetEgkMrPinRetryCounterCanPukModeCallsCount = 0
    var resetEgkMrPinRetryCounterCanPukModeCalled: Bool {
        resetEgkMrPinRetryCounterCanPukModeCallsCount > 0
    }
    var resetEgkMrPinRetryCounterCanPukModeReceivedArguments: (can: String, puk: String, mode: NFCResetRetryCounterMode)?
    var resetEgkMrPinRetryCounterCanPukModeReceivedInvocations: [(can: String, puk: String, mode: NFCResetRetryCounterMode)] = []
    var resetEgkMrPinRetryCounterCanPukModeReturnValue: AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var resetEgkMrPinRetryCounterCanPukModeClosure: ((String, String, NFCResetRetryCounterMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        resetEgkMrPinRetryCounterCanPukModeCallsCount += 1
        resetEgkMrPinRetryCounterCanPukModeReceivedArguments = (can: can, puk: puk, mode: mode)
        resetEgkMrPinRetryCounterCanPukModeReceivedInvocations.append((can: can, puk: puk, mode: mode))
        return resetEgkMrPinRetryCounterCanPukModeClosure.map({ $0(can, puk, mode) }) ?? resetEgkMrPinRetryCounterCanPukModeReturnValue
    }
    
   // MARK: - changeReferenceData

    var changeReferenceDataCanOldNewModeCallsCount = 0
    var changeReferenceDataCanOldNewModeCalled: Bool {
        changeReferenceDataCanOldNewModeCallsCount > 0
    }
    var changeReferenceDataCanOldNewModeReceivedArguments: (can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)?
    var changeReferenceDataCanOldNewModeReceivedInvocations: [(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)] = []
    var changeReferenceDataCanOldNewModeReturnValue: AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var changeReferenceDataCanOldNewModeClosure: ((String, String, String, NFCChangeReferenceDataMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        changeReferenceDataCanOldNewModeCallsCount += 1
        changeReferenceDataCanOldNewModeReceivedArguments = (can: can, old: old, new: new, mode: mode)
        changeReferenceDataCanOldNewModeReceivedInvocations.append((can: can, old: old, new: new, mode: mode))
        return changeReferenceDataCanOldNewModeClosure.map({ $0(can, old, new, mode) }) ?? changeReferenceDataCanOldNewModeReturnValue
    }
}


// MARK: - MockNFCSignatureProvider -

final class MockNFCSignatureProvider: NFCSignatureProvider {
    
   // MARK: - openSecureSession

    var openSecureSessionCanPinCallsCount = 0
    var openSecureSessionCanPinCalled: Bool {
        openSecureSessionCanPinCallsCount > 0
    }
    var openSecureSessionCanPinReceivedArguments: (can: String, pin: String)?
    var openSecureSessionCanPinReceivedInvocations: [(can: String, pin: String)] = []
    var openSecureSessionCanPinReturnValue: AnyPublisher<SignatureSession, NFCSignatureProviderError>!
    var openSecureSessionCanPinClosure: ((String, String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError>)?

    func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        openSecureSessionCanPinCallsCount += 1
        openSecureSessionCanPinReceivedArguments = (can: can, pin: pin)
        openSecureSessionCanPinReceivedInvocations.append((can: can, pin: pin))
        return openSecureSessionCanPinClosure.map({ $0(can, pin) }) ?? openSecureSessionCanPinReturnValue
    }
    
   // MARK: - sign

    var signCanPinChallengeCallsCount = 0
    var signCanPinChallengeCalled: Bool {
        signCanPinChallengeCallsCount > 0
    }
    var signCanPinChallengeReceivedArguments: (can: String, pin: String, challenge: IDPChallengeSession)?
    var signCanPinChallengeReceivedInvocations: [(can: String, pin: String, challenge: IDPChallengeSession)] = []
    var signCanPinChallengeReturnValue: AnyPublisher<SignedChallenge, NFCSignatureProviderError>!
    var signCanPinChallengeClosure: ((String, String, IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError>)?

    func sign(can: String, pin: String, challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        signCanPinChallengeCallsCount += 1
        signCanPinChallengeReceivedArguments = (can: can, pin: pin, challenge: challenge)
        signCanPinChallengeReceivedInvocations.append((can: can, pin: pin, challenge: challenge))
        return signCanPinChallengeClosure.map({ $0(can, pin, challenge) }) ?? signCanPinChallengeReturnValue
    }
}


// MARK: - MockPasswordStrengthTester -

final class MockPasswordStrengthTester: PasswordStrengthTester {
    
   // MARK: - passwordStrength

    var passwordStrengthForCallsCount = 0
    var passwordStrengthForCalled: Bool {
        passwordStrengthForCallsCount > 0
    }
    var passwordStrengthForReceivedPassword: String?
    var passwordStrengthForReceivedInvocations: [String] = []
    var passwordStrengthForReturnValue: PasswordStrength!
    var passwordStrengthForClosure: ((String) -> PasswordStrength)?

    func passwordStrength(for password: String) -> PasswordStrength {
        passwordStrengthForCallsCount += 1
        passwordStrengthForReceivedPassword = password
        passwordStrengthForReceivedInvocations.append(password)
        return passwordStrengthForClosure.map({ $0(password) }) ?? passwordStrengthForReturnValue
    }
}


// MARK: - MockPrescriptionRepository -

final class MockPrescriptionRepository: PrescriptionRepository {
    
   // MARK: - loadLocal

    var loadLocalCallsCount = 0
    var loadLocalCalled: Bool {
        loadLocalCallsCount > 0
    }
    var loadLocalReturnValue: AnyPublisher<[Prescription], PrescriptionRepositoryError>!
    var loadLocalClosure: (() -> AnyPublisher<[Prescription], PrescriptionRepositoryError>)?

    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        loadLocalCallsCount += 1
        return loadLocalClosure.map({ $0() }) ?? loadLocalReturnValue
    }
    
   // MARK: - forcedLoadRemote

    var forcedLoadRemoteForCallsCount = 0
    var forcedLoadRemoteForCalled: Bool {
        forcedLoadRemoteForCallsCount > 0
    }
    var forcedLoadRemoteForReceivedLocale: String?
    var forcedLoadRemoteForReceivedInvocations: [String?] = []
    var forcedLoadRemoteForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var forcedLoadRemoteForClosure: ((String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func forcedLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        forcedLoadRemoteForCallsCount += 1
        forcedLoadRemoteForReceivedLocale = locale
        forcedLoadRemoteForReceivedInvocations.append(locale)
        return forcedLoadRemoteForClosure.map({ $0(locale) }) ?? forcedLoadRemoteForReturnValue
    }
    
   // MARK: - silentLoadRemote

    var silentLoadRemoteForCallsCount = 0
    var silentLoadRemoteForCalled: Bool {
        silentLoadRemoteForCallsCount > 0
    }
    var silentLoadRemoteForReceivedLocale: String?
    var silentLoadRemoteForReceivedInvocations: [String?] = []
    var silentLoadRemoteForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var silentLoadRemoteForClosure: ((String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func silentLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        silentLoadRemoteForCallsCount += 1
        silentLoadRemoteForReceivedLocale = locale
        silentLoadRemoteForReceivedInvocations.append(locale)
        return silentLoadRemoteForClosure.map({ $0(locale) }) ?? silentLoadRemoteForReturnValue
    }
}


// MARK: - MockProfileBasedSessionProvider -

final class MockProfileBasedSessionProvider: ProfileBasedSessionProvider {
    
   // MARK: - idpSession

    var idpSessionForCallsCount = 0
    var idpSessionForCalled: Bool {
        idpSessionForCallsCount > 0
    }
    var idpSessionForReceivedProfileId: UUID?
    var idpSessionForReceivedInvocations: [UUID] = []
    var idpSessionForReturnValue: IDPSession!
    var idpSessionForClosure: ((UUID) -> IDPSession)?

    func idpSession(for profileId: UUID) -> IDPSession {
        idpSessionForCallsCount += 1
        idpSessionForReceivedProfileId = profileId
        idpSessionForReceivedInvocations.append(profileId)
        return idpSessionForClosure.map({ $0(profileId) }) ?? idpSessionForReturnValue
    }
    
   // MARK: - biometrieIdpSession

    var biometrieIdpSessionForCallsCount = 0
    var biometrieIdpSessionForCalled: Bool {
        biometrieIdpSessionForCallsCount > 0
    }
    var biometrieIdpSessionForReceivedProfileId: UUID?
    var biometrieIdpSessionForReceivedInvocations: [UUID] = []
    var biometrieIdpSessionForReturnValue: IDPSession!
    var biometrieIdpSessionForClosure: ((UUID) -> IDPSession)?

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        biometrieIdpSessionForCallsCount += 1
        biometrieIdpSessionForReceivedProfileId = profileId
        biometrieIdpSessionForReceivedInvocations.append(profileId)
        return biometrieIdpSessionForClosure.map({ $0(profileId) }) ?? biometrieIdpSessionForReturnValue
    }
    
   // MARK: - userDataStore

    var userDataStoreForCallsCount = 0
    var userDataStoreForCalled: Bool {
        userDataStoreForCallsCount > 0
    }
    var userDataStoreForReceivedProfileId: UUID?
    var userDataStoreForReceivedInvocations: [UUID] = []
    var userDataStoreForReturnValue: SecureUserDataStore!
    var userDataStoreForClosure: ((UUID) -> SecureUserDataStore)?

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userDataStoreForCallsCount += 1
        userDataStoreForReceivedProfileId = profileId
        userDataStoreForReceivedInvocations.append(profileId)
        return userDataStoreForClosure.map({ $0(profileId) }) ?? userDataStoreForReturnValue
    }
    
   // MARK: - idTokenValidator

    var idTokenValidatorForCallsCount = 0
    var idTokenValidatorForCalled: Bool {
        idTokenValidatorForCallsCount > 0
    }
    var idTokenValidatorForReceivedProfileId: UUID?
    var idTokenValidatorForReceivedInvocations: [UUID] = []
    var idTokenValidatorForReturnValue: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var idTokenValidatorForClosure: ((UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>)?

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        idTokenValidatorForCallsCount += 1
        idTokenValidatorForReceivedProfileId = profileId
        idTokenValidatorForReceivedInvocations.append(profileId)
        return idTokenValidatorForClosure.map({ $0(profileId) }) ?? idTokenValidatorForReturnValue
    }
}


// MARK: - MockProfileDataStore -

final class MockProfileDataStore: ProfileDataStore {
    
   // MARK: - fetchProfile

    var fetchProfileByCallsCount = 0
    var fetchProfileByCalled: Bool {
        fetchProfileByCallsCount > 0
    }
    var fetchProfileByReceivedIdentifier: Profile.ID?
    var fetchProfileByReceivedInvocations: [Profile.ID] = []
    var fetchProfileByReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    var fetchProfileByClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByCallsCount += 1
        fetchProfileByReceivedIdentifier = identifier
        fetchProfileByReceivedInvocations.append(identifier)
        return fetchProfileByClosure.map({ $0(identifier) }) ?? fetchProfileByReturnValue
    }
    
   // MARK: - listAllProfiles

    var listAllProfilesCallsCount = 0
    var listAllProfilesCalled: Bool {
        listAllProfilesCallsCount > 0
    }
    var listAllProfilesReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    var listAllProfilesClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesCallsCount += 1
        return listAllProfilesClosure.map({ $0() }) ?? listAllProfilesReturnValue
    }
    
   // MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        saveProfilesCallsCount > 0
    }
    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        return saveProfilesClosure.map({ $0(profiles) }) ?? saveProfilesReturnValue
    }
    
   // MARK: - delete

    var deleteProfilesCallsCount = 0
    var deleteProfilesCalled: Bool {
        deleteProfilesCallsCount > 0
    }
    var deleteProfilesReceivedProfiles: [Profile]?
    var deleteProfilesReceivedInvocations: [[Profile]] = []
    var deleteProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesCallsCount += 1
        deleteProfilesReceivedProfiles = profiles
        deleteProfilesReceivedInvocations.append(profiles)
        return deleteProfilesClosure.map({ $0(profiles) }) ?? deleteProfilesReturnValue
    }
    
   // MARK: - update

    var updateProfileIdMutatingCallsCount = 0
    var updateProfileIdMutatingCalled: Bool {
        updateProfileIdMutatingCallsCount > 0
    }
    var updateProfileIdMutatingReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdMutatingReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdMutatingReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateProfileIdMutatingClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdMutatingCallsCount += 1
        updateProfileIdMutatingReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdMutatingReceivedInvocations.append((profileId: profileId, mutating: mutating))
        return updateProfileIdMutatingClosure.map({ $0(profileId, mutating) }) ?? updateProfileIdMutatingReturnValue
    }
    
   // MARK: - pagedAuditEventsController

    var pagedAuditEventsControllerForWithThrowableError: Error?
    var pagedAuditEventsControllerForWithCallsCount = 0
    var pagedAuditEventsControllerForWithCalled: Bool {
        pagedAuditEventsControllerForWithCallsCount > 0
    }
    var pagedAuditEventsControllerForWithReceivedArguments: (profileId: UUID, locale: String?)?
    var pagedAuditEventsControllerForWithReceivedInvocations: [(profileId: UUID, locale: String?)] = []
    var pagedAuditEventsControllerForWithReturnValue: PagedAuditEventsController!
    var pagedAuditEventsControllerForWithClosure: ((UUID, String?) throws -> PagedAuditEventsController)?

    func pagedAuditEventsController(for profileId: UUID, with locale: String?) throws -> PagedAuditEventsController {
        if let error = pagedAuditEventsControllerForWithThrowableError {
            throw error
        }
        pagedAuditEventsControllerForWithCallsCount += 1
        pagedAuditEventsControllerForWithReceivedArguments = (profileId: profileId, locale: locale)
        pagedAuditEventsControllerForWithReceivedInvocations.append((profileId: profileId, locale: locale))
        return try pagedAuditEventsControllerForWithClosure.map({ try $0(profileId, locale) }) ?? pagedAuditEventsControllerForWithReturnValue
    }
}


// MARK: - MockProfileOnlineChecker -

final class MockProfileOnlineChecker: ProfileOnlineChecker {
    
   // MARK: - token

    var tokenForCallsCount = 0
    var tokenForCalled: Bool {
        tokenForCallsCount > 0
    }
    var tokenForReceivedProfile: Profile?
    var tokenForReceivedInvocations: [Profile] = []
    var tokenForReturnValue: AnyPublisher<IDPToken?, Never>!
    var tokenForClosure: ((Profile) -> AnyPublisher<IDPToken?, Never>)?

    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        tokenForCallsCount += 1
        tokenForReceivedProfile = profile
        tokenForReceivedInvocations.append(profile)
        return tokenForClosure.map({ $0(profile) }) ?? tokenForReturnValue
    }
}


// MARK: - MockProfileSecureDataWiper -

final class MockProfileSecureDataWiper: ProfileSecureDataWiper {
    
   // MARK: - wipeSecureData

    var wipeSecureDataOfCallsCount = 0
    var wipeSecureDataOfCalled: Bool {
        wipeSecureDataOfCallsCount > 0
    }
    var wipeSecureDataOfReceivedProfileId: UUID?
    var wipeSecureDataOfReceivedInvocations: [UUID] = []
    var wipeSecureDataOfReturnValue: AnyPublisher<Void, Never>!
    var wipeSecureDataOfClosure: ((UUID) -> AnyPublisher<Void, Never>)?

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        wipeSecureDataOfCallsCount += 1
        wipeSecureDataOfReceivedProfileId = profileId
        wipeSecureDataOfReceivedInvocations.append(profileId)
        return wipeSecureDataOfClosure.map({ $0(profileId) }) ?? wipeSecureDataOfReturnValue
    }
    
   // MARK: - logout

    var logoutProfileCallsCount = 0
    var logoutProfileCalled: Bool {
        logoutProfileCallsCount > 0
    }
    var logoutProfileReceivedProfile: Profile?
    var logoutProfileReceivedInvocations: [Profile] = []
    var logoutProfileReturnValue: AnyPublisher<Void, Never>!
    var logoutProfileClosure: ((Profile) -> AnyPublisher<Void, Never>)?

    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        logoutProfileCallsCount += 1
        logoutProfileReceivedProfile = profile
        logoutProfileReceivedInvocations.append(profile)
        return logoutProfileClosure.map({ $0(profile) }) ?? logoutProfileReturnValue
    }
    
   // MARK: - secureStorage

    var secureStorageOfCallsCount = 0
    var secureStorageOfCalled: Bool {
        secureStorageOfCallsCount > 0
    }
    var secureStorageOfReceivedProfileId: UUID?
    var secureStorageOfReceivedInvocations: [UUID] = []
    var secureStorageOfReturnValue: SecureUserDataStore!
    var secureStorageOfClosure: ((UUID) -> SecureUserDataStore)?

    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        secureStorageOfCallsCount += 1
        secureStorageOfReceivedProfileId = profileId
        secureStorageOfReceivedInvocations.append(profileId)
        return secureStorageOfClosure.map({ $0(profileId) }) ?? secureStorageOfReturnValue
    }
}


// MARK: - MockRedeemService -

final class MockRedeemService: RedeemService {
    
   // MARK: - redeem

    var redeemCallsCount = 0
    var redeemCalled: Bool {
        redeemCallsCount > 0
    }
    var redeemReceivedOrders: [Order]?
    var redeemReceivedInvocations: [[Order]] = []
    var redeemReturnValue: AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>!
    var redeemClosure: (([Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)?

    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        redeemCallsCount += 1
        redeemReceivedOrders = orders
        redeemReceivedInvocations.append(orders)
        return redeemClosure.map({ $0(orders) }) ?? redeemReturnValue
    }
}


// MARK: - MockRegisteredDevicesService -

final class MockRegisteredDevicesService: RegisteredDevicesService {
    
   // MARK: - registeredDevices

    var registeredDevicesForCallsCount = 0
    var registeredDevicesForCalled: Bool {
        registeredDevicesForCallsCount > 0
    }
    var registeredDevicesForReceivedProfileId: UUID?
    var registeredDevicesForReceivedInvocations: [UUID] = []
    var registeredDevicesForReturnValue: AnyPublisher<PairingEntries, RegisteredDevicesServiceError>!
    var registeredDevicesForClosure: ((UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError>)?

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        registeredDevicesForCallsCount += 1
        registeredDevicesForReceivedProfileId = profileId
        registeredDevicesForReceivedInvocations.append(profileId)
        return registeredDevicesForClosure.map({ $0(profileId) }) ?? registeredDevicesForReturnValue
    }
    
   // MARK: - deviceId

    var deviceIdForCallsCount = 0
    var deviceIdForCalled: Bool {
        deviceIdForCallsCount > 0
    }
    var deviceIdForReceivedProfileId: UUID?
    var deviceIdForReceivedInvocations: [UUID] = []
    var deviceIdForReturnValue: AnyPublisher<String?, Never>!
    var deviceIdForClosure: ((UUID) -> AnyPublisher<String?, Never>)?

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        deviceIdForCallsCount += 1
        deviceIdForReceivedProfileId = profileId
        deviceIdForReceivedInvocations.append(profileId)
        return deviceIdForClosure.map({ $0(profileId) }) ?? deviceIdForReturnValue
    }
    
   // MARK: - deleteDevice

    var deleteDeviceOfCallsCount = 0
    var deleteDeviceOfCalled: Bool {
        deleteDeviceOfCallsCount > 0
    }
    var deleteDeviceOfReceivedArguments: (device: String, profileId: UUID)?
    var deleteDeviceOfReceivedInvocations: [(device: String, profileId: UUID)] = []
    var deleteDeviceOfReturnValue: AnyPublisher<Bool, RegisteredDevicesServiceError>!
    var deleteDeviceOfClosure: ((String, UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError>)?

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        deleteDeviceOfCallsCount += 1
        deleteDeviceOfReceivedArguments = (device: device, profileId: profileId)
        deleteDeviceOfReceivedInvocations.append((device: device, profileId: profileId))
        return deleteDeviceOfClosure.map({ $0(device, profileId) }) ?? deleteDeviceOfReturnValue
    }
    
   // MARK: - cardWall

    var cardWallForCallsCount = 0
    var cardWallForCalled: Bool {
        cardWallForCallsCount > 0
    }
    var cardWallForReceivedProfileId: UUID?
    var cardWallForReceivedInvocations: [UUID] = []
    var cardWallForReturnValue: AnyPublisher<IDPCardWallDomain.State, Never>!
    var cardWallForClosure: ((UUID) -> AnyPublisher<IDPCardWallDomain.State, Never>)?

    func cardWall(for profileId: UUID) -> AnyPublisher<IDPCardWallDomain.State, Never> {
        cardWallForCallsCount += 1
        cardWallForReceivedProfileId = profileId
        cardWallForReceivedInvocations.append(profileId)
        return cardWallForClosure.map({ $0(profileId) }) ?? cardWallForReturnValue
    }
}


// MARK: - MockRouting -

final class MockRouting: Routing {
    
   // MARK: - routeTo

    var routeToCallsCount = 0
    var routeToCalled: Bool {
        routeToCallsCount > 0
    }
    var routeToReceivedEndpoint: Endpoint?
    var routeToReceivedInvocations: [Endpoint] = []
    var routeToClosure: ((Endpoint) -> Void)?

    func routeTo(_ endpoint: Endpoint) {
        routeToCallsCount += 1
        routeToReceivedEndpoint = endpoint
        routeToReceivedInvocations.append(endpoint)
        routeToClosure?(endpoint)
    }
}


// MARK: - MockSearchHistory -

final class MockSearchHistory: SearchHistory {
    
   // MARK: - addHistoryItem

    var addHistoryItemCallsCount = 0
    var addHistoryItemCalled: Bool {
        addHistoryItemCallsCount > 0
    }
    var addHistoryItemReceivedItem: String?
    var addHistoryItemReceivedInvocations: [String] = []
    var addHistoryItemClosure: ((String) -> Void)?

    func addHistoryItem(_ item: String) {
        addHistoryItemCallsCount += 1
        addHistoryItemReceivedItem = item
        addHistoryItemReceivedInvocations.append(item)
        addHistoryItemClosure?(item)
    }
    
   // MARK: - historyItems

    var historyItemsCallsCount = 0
    var historyItemsCalled: Bool {
        historyItemsCallsCount > 0
    }
    var historyItemsReturnValue: [String]!
    var historyItemsClosure: (() -> [String])?

    func historyItems() -> [String] {
        historyItemsCallsCount += 1
        return historyItemsClosure.map({ $0() }) ?? historyItemsReturnValue
    }
}


// MARK: - MockSecureEnclaveSignatureProvider -

final class MockSecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
    
   // MARK: - isBiometrieRegistered

    var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        get { underlyingIsBiometrieRegistered }
        set(value) { underlyingIsBiometrieRegistered = value }
    }
    var underlyingIsBiometrieRegistered: AnyPublisher<Bool, Never>!
    
   // MARK: - createPairingSession

    var createPairingSessionThrowableError: Error?
    var createPairingSessionCallsCount = 0
    var createPairingSessionCalled: Bool {
        createPairingSessionCallsCount > 0
    }
    var createPairingSessionReturnValue: PairingSession!
    var createPairingSessionClosure: (() throws -> PairingSession)?

    func createPairingSession() throws -> PairingSession {
        if let error = createPairingSessionThrowableError {
            throw error
        }
        createPairingSessionCallsCount += 1
        return try createPairingSessionClosure.map({ try $0() }) ?? createPairingSessionReturnValue
    }
    
   // MARK: - signPairingSession

    var signPairingSessionWithCertificateCallsCount = 0
    var signPairingSessionWithCertificateCalled: Bool {
        signPairingSessionWithCertificateCallsCount > 0
    }
    var signPairingSessionWithCertificateReceivedArguments: (pairingSession: PairingSession, signer: JWTSigner, certificate: X509)?
    var signPairingSessionWithCertificateReceivedInvocations: [(pairingSession: PairingSession, signer: JWTSigner, certificate: X509)] = []
    var signPairingSessionWithCertificateReturnValue: AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>!
    var signPairingSessionWithCertificateClosure: ((PairingSession, JWTSigner, X509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>)?

    func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: X509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        signPairingSessionWithCertificateCallsCount += 1
        signPairingSessionWithCertificateReceivedArguments = (pairingSession: pairingSession, signer: signer, certificate: certificate)
        signPairingSessionWithCertificateReceivedInvocations.append((pairingSession: pairingSession, signer: signer, certificate: certificate))
        return signPairingSessionWithCertificateClosure.map({ $0(pairingSession, signer, certificate) }) ?? signPairingSessionWithCertificateReturnValue
    }
    
   // MARK: - abort

    var abortPairingSessionThrowableError: Error?
    var abortPairingSessionCallsCount = 0
    var abortPairingSessionCalled: Bool {
        abortPairingSessionCallsCount > 0
    }
    var abortPairingSessionReceivedPairingSession: PairingSession?
    var abortPairingSessionReceivedInvocations: [PairingSession] = []
    var abortPairingSessionClosure: ((PairingSession) throws -> Void)?

    func abort(pairingSession: PairingSession) throws {
        if let error = abortPairingSessionThrowableError {
            throw error
        }
        abortPairingSessionCallsCount += 1
        abortPairingSessionReceivedPairingSession = pairingSession
        abortPairingSessionReceivedInvocations.append(pairingSession)
        try abortPairingSessionClosure?(pairingSession)
    }
    
   // MARK: - authenticationData

    var authenticationDataForCallsCount = 0
    var authenticationDataForCalled: Bool {
        authenticationDataForCallsCount > 0
    }
    var authenticationDataForReceivedChallenge: IDPChallengeSession?
    var authenticationDataForReceivedInvocations: [IDPChallengeSession] = []
    var authenticationDataForReturnValue: AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>!
    var authenticationDataForClosure: ((IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>)?

    func authenticationData(for challenge: IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        authenticationDataForCallsCount += 1
        authenticationDataForReceivedChallenge = challenge
        authenticationDataForReceivedInvocations.append(challenge)
        return authenticationDataForClosure.map({ $0(challenge) }) ?? authenticationDataForReturnValue
    }
}


// MARK: - MockSecureUserDataStore -

final class MockSecureUserDataStore: SecureUserDataStore {
    
   // MARK: - can

    var can: AnyPublisher<String?, Never> {
        get { underlyingCan }
        set(value) { underlyingCan = value }
    }
    var underlyingCan: AnyPublisher<String?, Never>!
    
   // MARK: - token

    var token: AnyPublisher<IDPToken?, Never> {
        get { underlyingToken }
        set(value) { underlyingToken = value }
    }
    var underlyingToken: AnyPublisher<IDPToken?, Never>!
    
   // MARK: - discoveryDocument

    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        get { underlyingDiscoveryDocument }
        set(value) { underlyingDiscoveryDocument = value }
    }
    var underlyingDiscoveryDocument: AnyPublisher<DiscoveryDocument?, Never>!
    
   // MARK: - certificate

    var certificate: AnyPublisher<X509?, Never> {
        get { underlyingCertificate }
        set(value) { underlyingCertificate = value }
    }
    var underlyingCertificate: AnyPublisher<X509?, Never>!
    
   // MARK: - keyIdentifier

    var keyIdentifier: AnyPublisher<Data?, Never> {
        get { underlyingKeyIdentifier }
        set(value) { underlyingKeyIdentifier = value }
    }
    var underlyingKeyIdentifier: AnyPublisher<Data?, Never>!
    
   // MARK: - set

    var setCanCallsCount = 0
    var setCanCalled: Bool {
        setCanCallsCount > 0
    }
    var setCanReceivedCan: String?
    var setCanReceivedInvocations: [String?] = []
    var setCanClosure: ((String?) -> Void)?

    func set(can: String?) {
        setCanCallsCount += 1
        setCanReceivedCan = can
        setCanReceivedInvocations.append(can)
        setCanClosure?(can)
    }
    
   // MARK: - wipe

    var wipeCallsCount = 0
    var wipeCalled: Bool {
        wipeCallsCount > 0
    }
    var wipeClosure: (() -> Void)?

    func wipe() {
        wipeCallsCount += 1
        wipeClosure?()
    }
    
   // MARK: - set

    var setTokenCallsCount = 0
    var setTokenCalled: Bool {
        setTokenCallsCount > 0
    }
    var setTokenReceivedToken: IDPToken?
    var setTokenReceivedInvocations: [IDPToken?] = []
    var setTokenClosure: ((IDPToken?) -> Void)?

    func set(token: IDPToken?) {
        setTokenCallsCount += 1
        setTokenReceivedToken = token
        setTokenReceivedInvocations.append(token)
        setTokenClosure?(token)
    }
    
   // MARK: - set

    var setDiscoveryCallsCount = 0
    var setDiscoveryCalled: Bool {
        setDiscoveryCallsCount > 0
    }
    var setDiscoveryReceivedDocument: DiscoveryDocument?
    var setDiscoveryReceivedInvocations: [DiscoveryDocument?] = []
    var setDiscoveryClosure: ((DiscoveryDocument?) -> Void)?

    func set(discovery document: DiscoveryDocument?) {
        setDiscoveryCallsCount += 1
        setDiscoveryReceivedDocument = document
        setDiscoveryReceivedInvocations.append(document)
        setDiscoveryClosure?(document)
    }
    
   // MARK: - set

    var setCertificateCallsCount = 0
    var setCertificateCalled: Bool {
        setCertificateCallsCount > 0
    }
    var setCertificateReceivedCertificate: X509?
    var setCertificateReceivedInvocations: [X509?] = []
    var setCertificateClosure: ((X509?) -> Void)?

    func set(certificate: X509?) {
        setCertificateCallsCount += 1
        setCertificateReceivedCertificate = certificate
        setCertificateReceivedInvocations.append(certificate)
        setCertificateClosure?(certificate)
    }
    
   // MARK: - set

    var setKeyIdentifierCallsCount = 0
    var setKeyIdentifierCalled: Bool {
        setKeyIdentifierCallsCount > 0
    }
    var setKeyIdentifierReceivedKeyIdentifier: Data?
    var setKeyIdentifierReceivedInvocations: [Data?] = []
    var setKeyIdentifierClosure: ((Data?) -> Void)?

    func set(keyIdentifier: Data?) {
        setKeyIdentifierCallsCount += 1
        setKeyIdentifierReceivedKeyIdentifier = keyIdentifier
        setKeyIdentifierReceivedInvocations.append(keyIdentifier)
        setKeyIdentifierClosure?(keyIdentifier)
    }
}


// MARK: - MockShipmentInfoDataStore -

final class MockShipmentInfoDataStore: ShipmentInfoDataStore {
    
   // MARK: - selectedShipmentInfo

    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        get { underlyingSelectedShipmentInfo }
        set(value) { underlyingSelectedShipmentInfo = value }
    }
    var underlyingSelectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError>!
    
   // MARK: - set

    var setSelectedShipmentInfoIdCallsCount = 0
    var setSelectedShipmentInfoIdCalled: Bool {
        setSelectedShipmentInfoIdCallsCount > 0
    }
    var setSelectedShipmentInfoIdReceivedSelectedShipmentInfoId: UUID?
    var setSelectedShipmentInfoIdReceivedInvocations: [UUID] = []
    var setSelectedShipmentInfoIdClosure: ((UUID) -> Void)?

    func set(selectedShipmentInfoId: UUID) {
        setSelectedShipmentInfoIdCallsCount += 1
        setSelectedShipmentInfoIdReceivedSelectedShipmentInfoId = selectedShipmentInfoId
        setSelectedShipmentInfoIdReceivedInvocations.append(selectedShipmentInfoId)
        setSelectedShipmentInfoIdClosure?(selectedShipmentInfoId)
    }
    
   // MARK: - fetchShipmentInfo

    var fetchShipmentInfoByCallsCount = 0
    var fetchShipmentInfoByCalled: Bool {
        fetchShipmentInfoByCallsCount > 0
    }
    var fetchShipmentInfoByReceivedIdentifier: UUID?
    var fetchShipmentInfoByReceivedInvocations: [UUID] = []
    var fetchShipmentInfoByReturnValue: AnyPublisher<ShipmentInfo?, LocalStoreError>!
    var fetchShipmentInfoByClosure: ((UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError>)?

    func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fetchShipmentInfoByCallsCount += 1
        fetchShipmentInfoByReceivedIdentifier = identifier
        fetchShipmentInfoByReceivedInvocations.append(identifier)
        return fetchShipmentInfoByClosure.map({ $0(identifier) }) ?? fetchShipmentInfoByReturnValue
    }
    
   // MARK: - listAllShipmentInfos

    var listAllShipmentInfosCallsCount = 0
    var listAllShipmentInfosCalled: Bool {
        listAllShipmentInfosCallsCount > 0
    }
    var listAllShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var listAllShipmentInfosClosure: (() -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        listAllShipmentInfosCallsCount += 1
        return listAllShipmentInfosClosure.map({ $0() }) ?? listAllShipmentInfosReturnValue
    }
    
   // MARK: - save

    var saveShipmentInfosCallsCount = 0
    var saveShipmentInfosCalled: Bool {
        saveShipmentInfosCallsCount > 0
    }
    var saveShipmentInfosReceivedShipmentInfos: [ShipmentInfo]?
    var saveShipmentInfosReceivedInvocations: [[ShipmentInfo]] = []
    var saveShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var saveShipmentInfosClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        saveShipmentInfosCallsCount += 1
        saveShipmentInfosReceivedShipmentInfos = shipmentInfos
        saveShipmentInfosReceivedInvocations.append(shipmentInfos)
        return saveShipmentInfosClosure.map({ $0(shipmentInfos) }) ?? saveShipmentInfosReturnValue
    }
    
   // MARK: - delete

    var deleteShipmentInfosCallsCount = 0
    var deleteShipmentInfosCalled: Bool {
        deleteShipmentInfosCallsCount > 0
    }
    var deleteShipmentInfosReceivedShipmentInfos: [ShipmentInfo]?
    var deleteShipmentInfosReceivedInvocations: [[ShipmentInfo]] = []
    var deleteShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var deleteShipmentInfosClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        deleteShipmentInfosCallsCount += 1
        deleteShipmentInfosReceivedShipmentInfos = shipmentInfos
        deleteShipmentInfosReceivedInvocations.append(shipmentInfos)
        return deleteShipmentInfosClosure.map({ $0(shipmentInfos) }) ?? deleteShipmentInfosReturnValue
    }
    
   // MARK: - update

    var updateIdentifierMutatingCallsCount = 0
    var updateIdentifierMutatingCalled: Bool {
        updateIdentifierMutatingCallsCount > 0
    }
    var updateIdentifierMutatingReceivedArguments: (identifier: UUID, mutating: (inout ShipmentInfo) -> Void)?
    var updateIdentifierMutatingReceivedInvocations: [(identifier: UUID, mutating: (inout ShipmentInfo) -> Void)] = []
    var updateIdentifierMutatingReturnValue: AnyPublisher<ShipmentInfo, LocalStoreError>!
    var updateIdentifierMutatingClosure: ((UUID, @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError>)?

    func update(identifier: UUID, mutating: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        updateIdentifierMutatingCallsCount += 1
        updateIdentifierMutatingReceivedArguments = (identifier: identifier, mutating: mutating)
        updateIdentifierMutatingReceivedInvocations.append((identifier: identifier, mutating: mutating))
        return updateIdentifierMutatingClosure.map({ $0(identifier, mutating) }) ?? updateIdentifierMutatingReturnValue
    }
}


// MARK: - MockTracker -

final class MockTracker: Tracker {
    
   // MARK: - optIn

    var optIn: Bool {
        get { underlyingOptIn }
        set(value) { underlyingOptIn = value }
    }
    var underlyingOptIn: Bool!
    
   // MARK: - optInPublisher

    var optInPublisher: AnyPublisher<Bool, Never> {
        get { underlyingOptInPublisher }
        set(value) { underlyingOptInPublisher = value }
    }
    var underlyingOptInPublisher: AnyPublisher<Bool, Never>!
    
   // MARK: - track

    var trackEventsCallsCount = 0
    var trackEventsCalled: Bool {
        trackEventsCallsCount > 0
    }
    var trackEventsReceivedEvents: [AnalyticsEvent]?
    var trackEventsReceivedInvocations: [[AnalyticsEvent]] = []
    var trackEventsClosure: (([AnalyticsEvent]) -> Void)?

    func track(events: [AnalyticsEvent]) {
        trackEventsCallsCount += 1
        trackEventsReceivedEvents = events
        trackEventsReceivedInvocations.append(events)
        trackEventsClosure?(events)
    }
    
   // MARK: - track

    var trackScreensCallsCount = 0
    var trackScreensCalled: Bool {
        trackScreensCallsCount > 0
    }
    var trackScreensReceivedScreens: [AnalyticsScreen]?
    var trackScreensReceivedInvocations: [[AnalyticsScreen]] = []
    var trackScreensClosure: (([AnalyticsScreen]) -> Void)?

    func track(screens: [AnalyticsScreen]) {
        trackScreensCallsCount += 1
        trackScreensReceivedScreens = screens
        trackScreensReceivedInvocations.append(screens)
        trackScreensClosure?(screens)
    }
    
   // MARK: - track

    var trackEventCallsCount = 0
    var trackEventCalled: Bool {
        trackEventCallsCount > 0
    }
    var trackEventReceivedEvent: String?
    var trackEventReceivedInvocations: [String] = []
    var trackEventClosure: ((String) -> Void)?

    func track(event: String) {
        trackEventCallsCount += 1
        trackEventReceivedEvent = event
        trackEventReceivedInvocations.append(event)
        trackEventClosure?(event)
    }
    
   // MARK: - track

    var trackScreenCallsCount = 0
    var trackScreenCalled: Bool {
        trackScreenCallsCount > 0
    }
    var trackScreenReceivedScreen: String?
    var trackScreenReceivedInvocations: [String] = []
    var trackScreenClosure: ((String) -> Void)?

    func track(screen: String) {
        trackScreenCallsCount += 1
        trackScreenReceivedScreen = screen
        trackScreenReceivedInvocations.append(screen)
        trackScreenClosure?(screen)
    }
    
   // MARK: - stopTracking

    var stopTrackingCallsCount = 0
    var stopTrackingCalled: Bool {
        stopTrackingCallsCount > 0
    }
    var stopTrackingClosure: (() -> Void)?

    func stopTracking() {
        stopTrackingCallsCount += 1
        stopTrackingClosure?()
    }
}


// MARK: - MockUserDataStore -

final class MockUserDataStore: UserDataStore {
    
   // MARK: - hideOnboarding

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    var underlyingHideOnboarding: AnyPublisher<Bool, Never>!
    
   // MARK: - isOnboardingHidden

    var isOnboardingHidden: Bool {
        get { underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    var underlyingIsOnboardingHidden: Bool!
    
   // MARK: - onboardingVersion

    var onboardingVersion: AnyPublisher<String?, Never> {
        get { underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    var underlyingOnboardingVersion: AnyPublisher<String?, Never>!
    
   // MARK: - hideCardWallIntro

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    var underlyingHideCardWallIntro: AnyPublisher<Bool, Never>!
    
   // MARK: - serverEnvironmentConfiguration

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    var underlyingServerEnvironmentConfiguration: AnyPublisher<String?, Never>!
    var serverEnvironmentName: String?
    
   // MARK: - appSecurityOption

    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    var underlyingAppSecurityOption: AnyPublisher<AppSecurityOption, Never>!
    
   // MARK: - failedAppAuthentications

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    var underlyingFailedAppAuthentications: AnyPublisher<Int, Never>!
    
   // MARK: - ignoreDeviceNotSecuredWarningPermanently

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never>!
    
   // MARK: - selectedProfileId

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!
    
   // MARK: - latestCompatibleModelVersion

    var latestCompatibleModelVersion: ModelVersion {
        get { underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    var underlyingLatestCompatibleModelVersion: ModelVersion!
    
   // MARK: - appStartCounter

    var appStartCounter: Int {
        get { underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    var underlyingAppStartCounter: Int!
    
   // MARK: - hideWelcomeDrawer

    var hideWelcomeDrawer: Bool {
        get { underlyingHideWelcomeDrawer }
        set(value) { underlyingHideWelcomeDrawer = value }
    }
    var underlyingHideWelcomeDrawer: Bool!
    
   // MARK: - set

    var setHideOnboardingCallsCount = 0
    var setHideOnboardingCalled: Bool {
        setHideOnboardingCallsCount > 0
    }
    var setHideOnboardingReceivedHideOnboarding: Bool?
    var setHideOnboardingReceivedInvocations: [Bool] = []
    var setHideOnboardingClosure: ((Bool) -> Void)?

    func set(hideOnboarding: Bool) {
        setHideOnboardingCallsCount += 1
        setHideOnboardingReceivedHideOnboarding = hideOnboarding
        setHideOnboardingReceivedInvocations.append(hideOnboarding)
        setHideOnboardingClosure?(hideOnboarding)
    }
    
   // MARK: - set

    var setOnboardingVersionCallsCount = 0
    var setOnboardingVersionCalled: Bool {
        setOnboardingVersionCallsCount > 0
    }
    var setOnboardingVersionReceivedOnboardingVersion: String?
    var setOnboardingVersionReceivedInvocations: [String?] = []
    var setOnboardingVersionClosure: ((String?) -> Void)?

    func set(onboardingVersion: String?) {
        setOnboardingVersionCallsCount += 1
        setOnboardingVersionReceivedOnboardingVersion = onboardingVersion
        setOnboardingVersionReceivedInvocations.append(onboardingVersion)
        setOnboardingVersionClosure?(onboardingVersion)
    }
    
   // MARK: - set

    var setHideCardWallIntroCallsCount = 0
    var setHideCardWallIntroCalled: Bool {
        setHideCardWallIntroCallsCount > 0
    }
    var setHideCardWallIntroReceivedHideCardWallIntro: Bool?
    var setHideCardWallIntroReceivedInvocations: [Bool] = []
    var setHideCardWallIntroClosure: ((Bool) -> Void)?

    func set(hideCardWallIntro: Bool) {
        setHideCardWallIntroCallsCount += 1
        setHideCardWallIntroReceivedHideCardWallIntro = hideCardWallIntro
        setHideCardWallIntroReceivedInvocations.append(hideCardWallIntro)
        setHideCardWallIntroClosure?(hideCardWallIntro)
    }
    
   // MARK: - set

    var setServerEnvironmentConfigurationCallsCount = 0
    var setServerEnvironmentConfigurationCalled: Bool {
        setServerEnvironmentConfigurationCallsCount > 0
    }
    var setServerEnvironmentConfigurationReceivedServerEnvironmentConfiguration: String?
    var setServerEnvironmentConfigurationReceivedInvocations: [String?] = []
    var setServerEnvironmentConfigurationClosure: ((String?) -> Void)?

    func set(serverEnvironmentConfiguration: String?) {
        setServerEnvironmentConfigurationCallsCount += 1
        setServerEnvironmentConfigurationReceivedServerEnvironmentConfiguration = serverEnvironmentConfiguration
        setServerEnvironmentConfigurationReceivedInvocations.append(serverEnvironmentConfiguration)
        setServerEnvironmentConfigurationClosure?(serverEnvironmentConfiguration)
    }
    
   // MARK: - set

    var setAppSecurityOptionCallsCount = 0
    var setAppSecurityOptionCalled: Bool {
        setAppSecurityOptionCallsCount > 0
    }
    var setAppSecurityOptionReceivedAppSecurityOption: AppSecurityOption?
    var setAppSecurityOptionReceivedInvocations: [AppSecurityOption] = []
    var setAppSecurityOptionClosure: ((AppSecurityOption) -> Void)?

    func set(appSecurityOption: AppSecurityOption) {
        setAppSecurityOptionCallsCount += 1
        setAppSecurityOptionReceivedAppSecurityOption = appSecurityOption
        setAppSecurityOptionReceivedInvocations.append(appSecurityOption)
        setAppSecurityOptionClosure?(appSecurityOption)
    }
    
   // MARK: - set

    var setFailedAppAuthenticationsCallsCount = 0
    var setFailedAppAuthenticationsCalled: Bool {
        setFailedAppAuthenticationsCallsCount > 0
    }
    var setFailedAppAuthenticationsReceivedFailedAppAuthentications: Int?
    var setFailedAppAuthenticationsReceivedInvocations: [Int] = []
    var setFailedAppAuthenticationsClosure: ((Int) -> Void)?

    func set(failedAppAuthentications: Int) {
        setFailedAppAuthenticationsCallsCount += 1
        setFailedAppAuthenticationsReceivedFailedAppAuthentications = failedAppAuthentications
        setFailedAppAuthenticationsReceivedInvocations.append(failedAppAuthentications)
        setFailedAppAuthenticationsClosure?(failedAppAuthentications)
    }
    
   // MARK: - set

    var setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningPermanentlyCalled: Bool {
        setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount > 0
    }
    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently: Bool?
    var setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations: [Bool] = []
    var setIgnoreDeviceNotSecuredWarningPermanentlyClosure: ((Bool) -> Void)?

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount += 1
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedIgnoreDeviceNotSecuredWarningPermanently = ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }
    
   // MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        setSelectedProfileIdCallsCount > 0
    }
    var setSelectedProfileIdReceivedSelectedProfileId: UUID?
    var setSelectedProfileIdReceivedInvocations: [UUID] = []
    var setSelectedProfileIdClosure: ((UUID) -> Void)?

    func set(selectedProfileId: UUID) {
        setSelectedProfileIdCallsCount += 1
        setSelectedProfileIdReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdClosure?(selectedProfileId)
    }
    
   // MARK: - wipeAll

    var wipeAllCallsCount = 0
    var wipeAllCalled: Bool {
        wipeAllCallsCount > 0
    }
    var wipeAllClosure: (() -> Void)?

    func wipeAll() {
        wipeAllCallsCount += 1
        wipeAllClosure?()
    }
}


// MARK: - MockUserProfileService -

final class MockUserProfileService: UserProfileService {
    
   // MARK: - selectedProfileId

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!
    
   // MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        setSelectedProfileIdCallsCount > 0
    }
    var setSelectedProfileIdReceivedSelectedProfileId: UUID?
    var setSelectedProfileIdReceivedInvocations: [UUID] = []
    var setSelectedProfileIdClosure: ((UUID) -> Void)?

    func set(selectedProfileId: UUID) {
        setSelectedProfileIdCallsCount += 1
        setSelectedProfileIdReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdClosure?(selectedProfileId)
    }
    
   // MARK: - userProfilesPublisher

    var userProfilesPublisherCallsCount = 0
    var userProfilesPublisherCalled: Bool {
        userProfilesPublisherCallsCount > 0
    }
    var userProfilesPublisherReturnValue: AnyPublisher<[UserProfile], UserProfileServiceError>!
    var userProfilesPublisherClosure: (() -> AnyPublisher<[UserProfile], UserProfileServiceError>)?

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        userProfilesPublisherCallsCount += 1
        return userProfilesPublisherClosure.map({ $0() }) ?? userProfilesPublisherReturnValue
    }
    
   // MARK: - activeUserProfilePublisher

    var activeUserProfilePublisherCallsCount = 0
    var activeUserProfilePublisherCalled: Bool {
        activeUserProfilePublisherCallsCount > 0
    }
    var activeUserProfilePublisherReturnValue: AnyPublisher<UserProfile, UserProfileServiceError>!
    var activeUserProfilePublisherClosure: (() -> AnyPublisher<UserProfile, UserProfileServiceError>)?

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        activeUserProfilePublisherCallsCount += 1
        return activeUserProfilePublisherClosure.map({ $0() }) ?? activeUserProfilePublisherReturnValue
    }
    
   // MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        saveProfilesCallsCount > 0
    }
    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, UserProfileServiceError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, UserProfileServiceError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        return saveProfilesClosure.map({ $0(profiles) }) ?? saveProfilesReturnValue
    }
    
   // MARK: - update

    var updateProfileIdMutatingCallsCount = 0
    var updateProfileIdMutatingCalled: Bool {
        updateProfileIdMutatingCallsCount > 0
    }
    var updateProfileIdMutatingReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdMutatingReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdMutatingReturnValue: AnyPublisher<Bool, UserProfileServiceError>!
    var updateProfileIdMutatingClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError> {
        updateProfileIdMutatingCallsCount += 1
        updateProfileIdMutatingReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdMutatingReceivedInvocations.append((profileId: profileId, mutating: mutating))
        return updateProfileIdMutatingClosure.map({ $0(profileId, mutating) }) ?? updateProfileIdMutatingReturnValue
    }
}


// MARK: - MockUserSessionProvider -

final class MockUserSessionProvider: UserSessionProvider {
    
   // MARK: - userSession

    var userSessionForCallsCount = 0
    var userSessionForCalled: Bool {
        userSessionForCallsCount > 0
    }
    var userSessionForReceivedUuid: UUID?
    var userSessionForReceivedInvocations: [UUID] = []
    var userSessionForReturnValue: UserSession!
    var userSessionForClosure: ((UUID) -> UserSession)?

    func userSession(for uuid: UUID) -> UserSession {
        userSessionForCallsCount += 1
        userSessionForReceivedUuid = uuid
        userSessionForReceivedInvocations.append(uuid)
        return userSessionForClosure.map({ $0(uuid) }) ?? userSessionForReturnValue
    }
}


// MARK: - MockUsersSessionContainer -

final class MockUsersSessionContainer: UsersSessionContainer {
    
   // MARK: - userSession

    var userSession: UserSession {
        get { underlyingUserSession }
        set(value) { underlyingUserSession = value }
    }
    var underlyingUserSession: UserSession!
    
   // MARK: - isDemoMode

    var isDemoMode: AnyPublisher<Bool, Never> {
        get { underlyingIsDemoMode }
        set(value) { underlyingIsDemoMode = value }
    }
    var underlyingIsDemoMode: AnyPublisher<Bool, Never>!
    
   // MARK: - switchToDemoMode

    var switchToDemoModeCallsCount = 0
    var switchToDemoModeCalled: Bool {
        switchToDemoModeCallsCount > 0
    }
    var switchToDemoModeClosure: (() -> Void)?

    func switchToDemoMode() {
        switchToDemoModeCallsCount += 1
        switchToDemoModeClosure?()
    }
    
   // MARK: - switchToStandardMode

    var switchToStandardModeCallsCount = 0
    var switchToStandardModeCalled: Bool {
        switchToStandardModeCallsCount > 0
    }
    var switchToStandardModeClosure: (() -> Void)?

    func switchToStandardMode() {
        switchToStandardModeCallsCount += 1
        switchToStandardModeClosure?()
    }
}
