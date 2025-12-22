// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
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
import ZXingCpp
import FeatureHelpers
import FeatureCardWall
import Profiles
import eRpResources

@testable import eRpFeatures

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockAVSSession -

final class MockAVSSession: AVSSession {
    
   // MARK: - redeem

    var redeemMessageEndpointRecipientsThrowableError: Error?
    var redeemMessageEndpointRecipientsCallsCount = 0
    var redeemMessageEndpointRecipientsCalled: Bool {
        redeemMessageEndpointRecipientsCallsCount > 0
    }
    var redeemMessageEndpointRecipientsReceivedArguments: (message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])?
    var redeemMessageEndpointRecipientsReceivedInvocations: [(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])] = []
    var redeemMessageEndpointRecipientsReturnValue: AVSSessionResponse!
    var redeemMessageEndpointRecipientsClosure: ((AVSMessage, AVSEndpoint, [X509]) throws -> AVSSessionResponse)?

    func redeem(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509]) throws -> AVSSessionResponse {
        if let error = redeemMessageEndpointRecipientsThrowableError {
            throw error
        }
        redeemMessageEndpointRecipientsCallsCount += 1
        redeemMessageEndpointRecipientsReceivedArguments = (message: message, endpoint: endpoint, recipients: recipients)
        redeemMessageEndpointRecipientsReceivedInvocations.append((message: message, endpoint: endpoint, recipients: recipients))
        return try redeemMessageEndpointRecipientsClosure.map({ try $0(message, endpoint, recipients) }) ?? redeemMessageEndpointRecipientsReturnValue
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


// MARK: - MockAppSecurityManager -

final class MockAppSecurityManager: AppSecurityManager {
    
   // MARK: - availableSecurityOptions

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        get { underlyingAvailableSecurityOptions }
        set(value) { underlyingAvailableSecurityOptions = value }
    }
    var underlyingAvailableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?)!
    
   // MARK: - save

    var savePasswordThrowableError: Error?
    var savePasswordCallsCount = 0
    var savePasswordCalled: Bool {
        savePasswordCallsCount > 0
    }
    var savePasswordReceivedPassword: String?
    var savePasswordReceivedInvocations: [String] = []
    var savePasswordReturnValue: Bool!
    var savePasswordClosure: ((String) throws -> Bool)?

    func save(password: String) throws -> Bool {
        if let error = savePasswordThrowableError {
            throw error
        }
        savePasswordCallsCount += 1
        savePasswordReceivedPassword = password
        savePasswordReceivedInvocations.append(password)
        return try savePasswordClosure.map({ try $0(password) }) ?? savePasswordReturnValue
    }
    
   // MARK: - matches

    var matchesPasswordThrowableError: Error?
    var matchesPasswordCallsCount = 0
    var matchesPasswordCalled: Bool {
        matchesPasswordCallsCount > 0
    }
    var matchesPasswordReceivedPassword: String?
    var matchesPasswordReceivedInvocations: [String] = []
    var matchesPasswordReturnValue: Bool!
    var matchesPasswordClosure: ((String) throws -> Bool)?

    func matches(password: String) throws -> Bool {
        if let error = matchesPasswordThrowableError {
            throw error
        }
        matchesPasswordCallsCount += 1
        matchesPasswordReceivedPassword = password
        matchesPasswordReceivedInvocations.append(password)
        return try matchesPasswordClosure.map({ try $0(password) }) ?? matchesPasswordReturnValue
    }
    
   // MARK: - registerFailedPasswordAttempt

    var registerFailedPasswordAttemptThrowableError: Error?
    var registerFailedPasswordAttemptCallsCount = 0
    var registerFailedPasswordAttemptCalled: Bool {
        registerFailedPasswordAttemptCallsCount > 0
    }
    var registerFailedPasswordAttemptClosure: (() throws -> Void)?

    func registerFailedPasswordAttempt() throws {
        if let error = registerFailedPasswordAttemptThrowableError {
            throw error
        }
        registerFailedPasswordAttemptCallsCount += 1
        try registerFailedPasswordAttemptClosure?()
    }
    
   // MARK: - resetPasswordDelay

    var resetPasswordDelayThrowableError: Error?
    var resetPasswordDelayCallsCount = 0
    var resetPasswordDelayCalled: Bool {
        resetPasswordDelayCallsCount > 0
    }
    var resetPasswordDelayClosure: (() throws -> Void)?

    func resetPasswordDelay() throws {
        if let error = resetPasswordDelayThrowableError {
            throw error
        }
        resetPasswordDelayCallsCount += 1
        try resetPasswordDelayClosure?()
    }
    
   // MARK: - currentPasswordDelay

    var currentPasswordDelayThrowableError: Error?
    var currentPasswordDelayCallsCount = 0
    var currentPasswordDelayCalled: Bool {
        currentPasswordDelayCallsCount > 0
    }
    var currentPasswordDelayReturnValue: TimeInterval!
    var currentPasswordDelayClosure: (() throws -> TimeInterval)?

    func currentPasswordDelay() throws -> TimeInterval {
        if let error = currentPasswordDelayThrowableError {
            throw error
        }
        currentPasswordDelayCallsCount += 1
        return try currentPasswordDelayClosure.map({ try $0() }) ?? currentPasswordDelayReturnValue
    }
    
   // MARK: - migrate

    var migrateThrowableError: Error?
    var migrateCallsCount = 0
    var migrateCalled: Bool {
        migrateCallsCount > 0
    }
    var migrateClosure: (() throws -> Void)?

    func migrate() throws {
        if let error = migrateThrowableError {
            throw error
        }
        migrateCallsCount += 1
        try migrateClosure?()
    }
}


// MARK: - MockAuditEventsService -

final class MockAuditEventsService: AuditEventsService {
    
   // MARK: - loadAuditEvents

    var loadAuditEventsForLocaleCallsCount = 0
    var loadAuditEventsForLocaleCalled: Bool {
        loadAuditEventsForLocaleCallsCount > 0
    }
    var loadAuditEventsForLocaleReceivedArguments: (profileId: UUID, locale: String?)?
    var loadAuditEventsForLocaleReceivedInvocations: [(profileId: UUID, locale: String?)] = []
    var loadAuditEventsForLocaleReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>!
    var loadAuditEventsForLocaleClosure: ((UUID, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)?

    func loadAuditEvents(for profileId: UUID, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        loadAuditEventsForLocaleCallsCount += 1
        loadAuditEventsForLocaleReceivedArguments = (profileId: profileId, locale: locale)
        loadAuditEventsForLocaleReceivedInvocations.append((profileId: profileId, locale: locale))
        return loadAuditEventsForLocaleClosure.map({ $0(profileId, locale) }) ?? loadAuditEventsForLocaleReturnValue
    }
    
   // MARK: - loadNextAuditEvents

    var loadNextAuditEventsForUrlLocaleCallsCount = 0
    var loadNextAuditEventsForUrlLocaleCalled: Bool {
        loadNextAuditEventsForUrlLocaleCallsCount > 0
    }
    var loadNextAuditEventsForUrlLocaleReceivedArguments: (profileId: UUID, url: URL, locale: String?)?
    var loadNextAuditEventsForUrlLocaleReceivedInvocations: [(profileId: UUID, url: URL, locale: String?)] = []
    var loadNextAuditEventsForUrlLocaleReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>!
    var loadNextAuditEventsForUrlLocaleClosure: ((UUID, URL, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)?

    func loadNextAuditEvents(for profileId: UUID, url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        loadNextAuditEventsForUrlLocaleCallsCount += 1
        loadNextAuditEventsForUrlLocaleReceivedArguments = (profileId: profileId, url: url, locale: locale)
        loadNextAuditEventsForUrlLocaleReceivedInvocations.append((profileId: profileId, url: url, locale: locale))
        return loadNextAuditEventsForUrlLocaleClosure.map({ $0(profileId, url, locale) }) ?? loadNextAuditEventsForUrlLocaleReturnValue
    }
}


// MARK: - MockAuthenticationChallengeProvider -

final class MockAuthenticationChallengeProvider: AuthenticationChallengeProvider {
    
   // MARK: - startAuthenticationChallenge

    var startAuthenticationChallengeCallsCount = 0
    var startAuthenticationChallengeCalled: Bool {
        startAuthenticationChallengeCallsCount > 0
    }
    var startAuthenticationChallengeReturnValue: AnyPublisher<AuthenticationChallengeProviderResult, Never>!
    var startAuthenticationChallengeClosure: (() -> AnyPublisher<AuthenticationChallengeProviderResult, Never>)?

    func startAuthenticationChallenge() -> AnyPublisher<AuthenticationChallengeProviderResult, Never> {
        startAuthenticationChallengeCallsCount += 1
        return startAuthenticationChallengeClosure.map({ $0() }) ?? startAuthenticationChallengeReturnValue
    }
}


// MARK: - MockChargeItemListDomainService -

final class MockChargeItemListDomainService: ChargeItemListDomainService {
    
   // MARK: - fetchLocalChargeItems

    var fetchLocalChargeItemsForCallsCount = 0
    var fetchLocalChargeItemsForCalled: Bool {
        fetchLocalChargeItemsForCallsCount > 0
    }
    var fetchLocalChargeItemsForReceivedProfileId: UUID?
    var fetchLocalChargeItemsForReceivedInvocations: [UUID] = []
    var fetchLocalChargeItemsForReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchLocalChargeItemsForClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchLocalChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchLocalChargeItemsForCallsCount += 1
        fetchLocalChargeItemsForReceivedProfileId = profileId
        fetchLocalChargeItemsForReceivedInvocations.append(profileId)
        return fetchLocalChargeItemsForClosure.map({ $0(profileId) }) ?? fetchLocalChargeItemsForReturnValue
    }
    
   // MARK: - fetchRemoteChargeItemsAndSave

    var fetchRemoteChargeItemsAndSaveForCallsCount = 0
    var fetchRemoteChargeItemsAndSaveForCalled: Bool {
        fetchRemoteChargeItemsAndSaveForCallsCount > 0
    }
    var fetchRemoteChargeItemsAndSaveForReceivedProfileId: UUID?
    var fetchRemoteChargeItemsAndSaveForReceivedInvocations: [UUID] = []
    var fetchRemoteChargeItemsAndSaveForReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchRemoteChargeItemsAndSaveForClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchRemoteChargeItemsAndSaveForCallsCount += 1
        fetchRemoteChargeItemsAndSaveForReceivedProfileId = profileId
        fetchRemoteChargeItemsAndSaveForReceivedInvocations.append(profileId)
        return fetchRemoteChargeItemsAndSaveForClosure.map({ $0(profileId) }) ?? fetchRemoteChargeItemsAndSaveForReturnValue
    }
    
   // MARK: - delete

    var deleteChargeItemForCallsCount = 0
    var deleteChargeItemForCalled: Bool {
        deleteChargeItemForCallsCount > 0
    }
    var deleteChargeItemForReceivedArguments: (chargeItem: ErxChargeItem, profileId: UUID)?
    var deleteChargeItemForReceivedInvocations: [(chargeItem: ErxChargeItem, profileId: UUID)] = []
    var deleteChargeItemForReturnValue: AnyPublisher<ChargeItemDomainServiceDeleteResult, Never>!
    var deleteChargeItemForClosure: ((ErxChargeItem, UUID) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never>)?

    func delete(chargeItem: ErxChargeItem, for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        deleteChargeItemForCallsCount += 1
        deleteChargeItemForReceivedArguments = (chargeItem: chargeItem, profileId: profileId)
        deleteChargeItemForReceivedInvocations.append((chargeItem: chargeItem, profileId: profileId))
        return deleteChargeItemForClosure.map({ $0(chargeItem, profileId) }) ?? deleteChargeItemForReturnValue
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
    var grantChargeItemsConsentForReturnValue: AnyPublisher<ChargeItemListDomainServiceGrantResult, Never>!
    var grantChargeItemsConsentForClosure: ((UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never>)?

    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> {
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
    var revokeChargeItemsConsentForReturnValue: AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never>!
    var revokeChargeItemsConsentForClosure: ((UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never>)?

    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> {
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


// MARK: - MockErxLocalDataStore -

final class MockErxLocalDataStore: ErxLocalDataStore {
    
   // MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        fetchTaskByAccessCodeCallsCount > 0
    }
    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, LocalStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, LocalStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        return fetchTaskByAccessCodeClosure.map({ $0(id, accessCode) }) ?? fetchTaskByAccessCodeReturnValue
    }
    
   // MARK: - listAllTasks

    var listAllTasksOfCallsCount = 0
    var listAllTasksOfCalled: Bool {
        listAllTasksOfCallsCount > 0
    }
    var listAllTasksOfReceivedProfileId: UUID?
    var listAllTasksOfReceivedInvocations: [UUID?] = []
    var listAllTasksOfReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksOfClosure: ((UUID?) -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasks(of profileId: UUID?) -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksOfCallsCount += 1
        listAllTasksOfReceivedProfileId = profileId
        listAllTasksOfReceivedInvocations.append(profileId)
        return listAllTasksOfClosure.map({ $0(profileId) }) ?? listAllTasksOfReturnValue
    }
    
   // MARK: - fetchLatestLastModifiedForErxTasks

    var fetchLatestLastModifiedForErxTasksOfCallsCount = 0
    var fetchLatestLastModifiedForErxTasksOfCalled: Bool {
        fetchLatestLastModifiedForErxTasksOfCallsCount > 0
    }
    var fetchLatestLastModifiedForErxTasksOfReceivedProfileId: UUID?
    var fetchLatestLastModifiedForErxTasksOfReceivedInvocations: [UUID?] = []
    var fetchLatestLastModifiedForErxTasksOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestLastModifiedForErxTasksOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestLastModifiedForErxTasks(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksOfCallsCount += 1
        fetchLatestLastModifiedForErxTasksOfReceivedProfileId = profileId
        fetchLatestLastModifiedForErxTasksOfReceivedInvocations.append(profileId)
        return fetchLatestLastModifiedForErxTasksOfClosure.map({ $0(profileId) }) ?? fetchLatestLastModifiedForErxTasksOfReturnValue
    }
    
   // MARK: - save

    var saveTasksInUpdateProfileLastAuthenticatedCallsCount = 0
    var saveTasksInUpdateProfileLastAuthenticatedCalled: Bool {
        saveTasksInUpdateProfileLastAuthenticatedCallsCount > 0
    }
    var saveTasksInUpdateProfileLastAuthenticatedReceivedArguments: (tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)?
    var saveTasksInUpdateProfileLastAuthenticatedReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)] = []
    var saveTasksInUpdateProfileLastAuthenticatedReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveTasksInUpdateProfileLastAuthenticatedClosure: (([ErxTask], UUID?, Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(tasks: [ErxTask], in profileId: UUID?, updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksInUpdateProfileLastAuthenticatedCallsCount += 1
        saveTasksInUpdateProfileLastAuthenticatedReceivedArguments = (tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksInUpdateProfileLastAuthenticatedReceivedInvocations.append((tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        return saveTasksInUpdateProfileLastAuthenticatedClosure.map({ $0(tasks, profileId, updateProfileLastAuthenticated) }) ?? saveTasksInUpdateProfileLastAuthenticatedReturnValue
    }
    
   // MARK: - delete

    var deleteTasksInCallsCount = 0
    var deleteTasksInCalled: Bool {
        deleteTasksInCallsCount > 0
    }
    var deleteTasksInReceivedArguments: (tasks: [ErxTask], profileId: UUID?)?
    var deleteTasksInReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?)] = []
    var deleteTasksInReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteTasksInClosure: (([ErxTask], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(tasks: [ErxTask], in profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksInCallsCount += 1
        deleteTasksInReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksInReceivedInvocations.append((tasks: tasks, profileId: profileId))
        return deleteTasksInClosure.map({ $0(tasks, profileId) }) ?? deleteTasksInReturnValue
    }
    
   // MARK: - listAllTasksWithoutProfile

    var listAllTasksWithoutProfileCallsCount = 0
    var listAllTasksWithoutProfileCalled: Bool {
        listAllTasksWithoutProfileCallsCount > 0
    }
    var listAllTasksWithoutProfileReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksWithoutProfileClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksWithoutProfileCallsCount += 1
        return listAllTasksWithoutProfileClosure.map({ $0() }) ?? listAllTasksWithoutProfileReturnValue
    }
    
   // MARK: - listAllCommunications

    var listAllCommunicationsForCallsCount = 0
    var listAllCommunicationsForCalled: Bool {
        listAllCommunicationsForCallsCount > 0
    }
    var listAllCommunicationsForReceivedProfile: ErxTask.Communication.Profile?
    var listAllCommunicationsForReceivedInvocations: [ErxTask.Communication.Profile] = []
    var listAllCommunicationsForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var listAllCommunicationsForClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        listAllCommunicationsForCallsCount += 1
        listAllCommunicationsForReceivedProfile = profile
        listAllCommunicationsForReceivedInvocations.append(profile)
        return listAllCommunicationsForClosure.map({ $0(profile) }) ?? listAllCommunicationsForReturnValue
    }
    
   // MARK: - fetchLatestTimestampForCommunications

    var fetchLatestTimestampForCommunicationsOfCallsCount = 0
    var fetchLatestTimestampForCommunicationsOfCalled: Bool {
        fetchLatestTimestampForCommunicationsOfCallsCount > 0
    }
    var fetchLatestTimestampForCommunicationsOfReceivedProfileId: UUID?
    var fetchLatestTimestampForCommunicationsOfReceivedInvocations: [UUID?] = []
    var fetchLatestTimestampForCommunicationsOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForCommunicationsOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForCommunications(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsOfCallsCount += 1
        fetchLatestTimestampForCommunicationsOfReceivedProfileId = profileId
        fetchLatestTimestampForCommunicationsOfReceivedInvocations.append(profileId)
        return fetchLatestTimestampForCommunicationsOfClosure.map({ $0(profileId) }) ?? fetchLatestTimestampForCommunicationsOfReturnValue
    }
    
   // MARK: - save

    var saveCommunicationsOfCallsCount = 0
    var saveCommunicationsOfCalled: Bool {
        saveCommunicationsOfCallsCount > 0
    }
    var saveCommunicationsOfReceivedArguments: (communications: [ErxTask.Communication], profileId: UUID?)?
    var saveCommunicationsOfReceivedInvocations: [(communications: [ErxTask.Communication], profileId: UUID?)] = []
    var saveCommunicationsOfReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveCommunicationsOfClosure: (([ErxTask.Communication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(communications: [ErxTask.Communication], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsOfCallsCount += 1
        saveCommunicationsOfReceivedArguments = (communications: communications, profileId: profileId)
        saveCommunicationsOfReceivedInvocations.append((communications: communications, profileId: profileId))
        return saveCommunicationsOfClosure.map({ $0(communications, profileId) }) ?? saveCommunicationsOfReturnValue
    }
    
   // MARK: - allUnreadCommunications

    var allUnreadCommunicationsOfForCallsCount = 0
    var allUnreadCommunicationsOfForCalled: Bool {
        allUnreadCommunicationsOfForCallsCount > 0
    }
    var allUnreadCommunicationsOfForReceivedArguments: (profileId: UUID?, profile: ErxTask.Communication.Profile)?
    var allUnreadCommunicationsOfForReceivedInvocations: [(profileId: UUID?, profile: ErxTask.Communication.Profile)] = []
    var allUnreadCommunicationsOfForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var allUnreadCommunicationsOfForClosure: ((UUID?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func allUnreadCommunications(of profileId: UUID?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsOfForCallsCount += 1
        allUnreadCommunicationsOfForReceivedArguments = (profileId: profileId, profile: profile)
        allUnreadCommunicationsOfForReceivedInvocations.append((profileId: profileId, profile: profile))
        return allUnreadCommunicationsOfForClosure.map({ $0(profileId, profile) }) ?? allUnreadCommunicationsOfForReturnValue
    }
    
   // MARK: - listAllMedicationDispenses

    var listAllMedicationDispensesOfCallsCount = 0
    var listAllMedicationDispensesOfCalled: Bool {
        listAllMedicationDispensesOfCallsCount > 0
    }
    var listAllMedicationDispensesOfReceivedProfileId: UUID?
    var listAllMedicationDispensesOfReceivedInvocations: [UUID?] = []
    var listAllMedicationDispensesOfReturnValue: AnyPublisher<[ErxMedicationDispense], LocalStoreError>!
    var listAllMedicationDispensesOfClosure: ((UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>)?

    func listAllMedicationDispenses(of profileId: UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        listAllMedicationDispensesOfCallsCount += 1
        listAllMedicationDispensesOfReceivedProfileId = profileId
        listAllMedicationDispensesOfReceivedInvocations.append(profileId)
        return listAllMedicationDispensesOfClosure.map({ $0(profileId) }) ?? listAllMedicationDispensesOfReturnValue
    }
    
   // MARK: - save

    var saveMedicationDispensesCallsCount = 0
    var saveMedicationDispensesCalled: Bool {
        saveMedicationDispensesCallsCount > 0
    }
    var saveMedicationDispensesReceivedMedicationDispenses: [ErxMedicationDispense]?
    var saveMedicationDispensesReceivedInvocations: [[ErxMedicationDispense]] = []
    var saveMedicationDispensesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveMedicationDispensesClosure: (([ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        saveMedicationDispensesCallsCount += 1
        saveMedicationDispensesReceivedMedicationDispenses = medicationDispenses
        saveMedicationDispensesReceivedInvocations.append(medicationDispenses)
        return saveMedicationDispensesClosure.map({ $0(medicationDispenses) }) ?? saveMedicationDispensesReturnValue
    }
    
   // MARK: - fetchChargeItem

    var fetchChargeItemOfByCallsCount = 0
    var fetchChargeItemOfByCalled: Bool {
        fetchChargeItemOfByCallsCount > 0
    }
    var fetchChargeItemOfByReceivedArguments: (profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)?
    var fetchChargeItemOfByReceivedInvocations: [(profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)] = []
    var fetchChargeItemOfByReturnValue: AnyPublisher<ErxSparseChargeItem?, LocalStoreError>!
    var fetchChargeItemOfByClosure: ((UUID?, ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>)?

    func fetchChargeItem(of profileId: UUID?, by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        fetchChargeItemOfByCallsCount += 1
        fetchChargeItemOfByReceivedArguments = (profileId: profileId, chargeItemID: chargeItemID)
        fetchChargeItemOfByReceivedInvocations.append((profileId: profileId, chargeItemID: chargeItemID))
        return fetchChargeItemOfByClosure.map({ $0(profileId, chargeItemID) }) ?? fetchChargeItemOfByReturnValue
    }
    
   // MARK: - fetchLatestTimestampForChargeItems

    var fetchLatestTimestampForChargeItemsOfCallsCount = 0
    var fetchLatestTimestampForChargeItemsOfCalled: Bool {
        fetchLatestTimestampForChargeItemsOfCallsCount > 0
    }
    var fetchLatestTimestampForChargeItemsOfReceivedProfileId: UUID?
    var fetchLatestTimestampForChargeItemsOfReceivedInvocations: [UUID?] = []
    var fetchLatestTimestampForChargeItemsOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForChargeItemsOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForChargeItemsOfCallsCount += 1
        fetchLatestTimestampForChargeItemsOfReceivedProfileId = profileId
        fetchLatestTimestampForChargeItemsOfReceivedInvocations.append(profileId)
        return fetchLatestTimestampForChargeItemsOfClosure.map({ $0(profileId) }) ?? fetchLatestTimestampForChargeItemsOfReturnValue
    }
    
   // MARK: - listAllChargeItems

    var listAllChargeItemsOfCallsCount = 0
    var listAllChargeItemsOfCalled: Bool {
        listAllChargeItemsOfCallsCount > 0
    }
    var listAllChargeItemsOfReceivedProfileId: UUID?
    var listAllChargeItemsOfReceivedInvocations: [UUID?] = []
    var listAllChargeItemsOfReturnValue: AnyPublisher<[ErxSparseChargeItem], LocalStoreError>!
    var listAllChargeItemsOfClosure: ((UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>)?

    func listAllChargeItems(of profileId: UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        listAllChargeItemsOfCallsCount += 1
        listAllChargeItemsOfReceivedProfileId = profileId
        listAllChargeItemsOfReceivedInvocations.append(profileId)
        return listAllChargeItemsOfClosure.map({ $0(profileId) }) ?? listAllChargeItemsOfReturnValue
    }
    
   // MARK: - save

    var saveChargeItemsOfCallsCount = 0
    var saveChargeItemsOfCalled: Bool {
        saveChargeItemsOfCallsCount > 0
    }
    var saveChargeItemsOfReceivedArguments: (chargeItems: [ErxSparseChargeItem], profileId: UUID?)?
    var saveChargeItemsOfReceivedInvocations: [(chargeItems: [ErxSparseChargeItem], profileId: UUID?)] = []
    var saveChargeItemsOfReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveChargeItemsOfClosure: (([ErxSparseChargeItem], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsOfCallsCount += 1
        saveChargeItemsOfReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        saveChargeItemsOfReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        return saveChargeItemsOfClosure.map({ $0(chargeItems, profileId) }) ?? saveChargeItemsOfReturnValue
    }
    
   // MARK: - delete

    var deleteOfChargeItemsCallsCount = 0
    var deleteOfChargeItemsCalled: Bool {
        deleteOfChargeItemsCallsCount > 0
    }
    var deleteOfChargeItemsReceivedArguments: (profileId: UUID?, chargeItems: [ErxSparseChargeItem])?
    var deleteOfChargeItemsReceivedInvocations: [(profileId: UUID?, chargeItems: [ErxSparseChargeItem])] = []
    var deleteOfChargeItemsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteOfChargeItemsClosure: ((UUID?, [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(of profileId: UUID?, chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteOfChargeItemsCallsCount += 1
        deleteOfChargeItemsReceivedArguments = (profileId: profileId, chargeItems: chargeItems)
        deleteOfChargeItemsReceivedInvocations.append((profileId: profileId, chargeItems: chargeItems))
        return deleteOfChargeItemsClosure.map({ $0(profileId, chargeItems) }) ?? deleteOfChargeItemsReturnValue
    }
    
   // MARK: - update

    var updateDiGaInfoCallsCount = 0
    var updateDiGaInfoCalled: Bool {
        updateDiGaInfoCallsCount > 0
    }
    var updateDiGaInfoReceivedDiGaInfo: DiGaInfo?
    var updateDiGaInfoReceivedInvocations: [DiGaInfo] = []
    var updateDiGaInfoReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateDiGaInfoClosure: ((DiGaInfo) -> AnyPublisher<Bool, LocalStoreError>)?

    func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        updateDiGaInfoCallsCount += 1
        updateDiGaInfoReceivedDiGaInfo = diGaInfo
        updateDiGaInfoReceivedInvocations.append(diGaInfo)
        return updateDiGaInfoClosure.map({ $0(diGaInfo) }) ?? updateDiGaInfoReturnValue
    }
}


// MARK: - MockErxRemoteDataStore -

final class MockErxRemoteDataStore: ErxRemoteDataStore {
    
   // MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        fetchTaskByAccessCodeCallsCount > 0
    }
    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        return fetchTaskByAccessCodeClosure.map({ $0(id, accessCode) }) ?? fetchTaskByAccessCodeReturnValue
    }
    
   // MARK: - listAllTasks

    var listAllTasksAfterCallsCount = 0
    var listAllTasksAfterCalled: Bool {
        listAllTasksAfterCallsCount > 0
    }
    var listAllTasksAfterReceivedReferenceDate: String?
    var listAllTasksAfterReceivedInvocations: [String?] = []
    var listAllTasksAfterReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listAllTasksAfterClosure: ((String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listAllTasks(after referenceDate: String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listAllTasksAfterCallsCount += 1
        listAllTasksAfterReceivedReferenceDate = referenceDate
        listAllTasksAfterReceivedInvocations.append(referenceDate)
        return listAllTasksAfterClosure.map({ $0(referenceDate) }) ?? listAllTasksAfterReturnValue
    }
    
   // MARK: - listTasksNextPage

    var listTasksNextPageOfCallsCount = 0
    var listTasksNextPageOfCalled: Bool {
        listTasksNextPageOfCallsCount > 0
    }
    var listTasksNextPageOfReceivedPreviousPage: PagedContent<[ErxTask]>?
    var listTasksNextPageOfReceivedInvocations: [PagedContent<[ErxTask]>] = []
    var listTasksNextPageOfReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listTasksNextPageOfClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listTasksNextPageOfCallsCount += 1
        listTasksNextPageOfReceivedPreviousPage = previousPage
        listTasksNextPageOfReceivedInvocations.append(previousPage)
        return listTasksNextPageOfClosure.map({ $0(previousPage) }) ?? listTasksNextPageOfReturnValue
    }
    
   // MARK: - listDetailedTasks

    var listDetailedTasksForCallsCount = 0
    var listDetailedTasksForCalled: Bool {
        listDetailedTasksForCallsCount > 0
    }
    var listDetailedTasksForReceivedTasks: PagedContent<[ErxTask]>?
    var listDetailedTasksForReceivedInvocations: [PagedContent<[ErxTask]>] = []
    var listDetailedTasksForReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listDetailedTasksForClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listDetailedTasks(for tasks: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listDetailedTasksForCallsCount += 1
        listDetailedTasksForReceivedTasks = tasks
        listDetailedTasksForReceivedInvocations.append(tasks)
        return listDetailedTasksForClosure.map({ $0(tasks) }) ?? listDetailedTasksForReturnValue
    }
    
   // MARK: - delete

    var deleteTasksCallsCount = 0
    var deleteTasksCalled: Bool {
        deleteTasksCallsCount > 0
    }
    var deleteTasksReceivedTasks: [ErxTask]?
    var deleteTasksReceivedInvocations: [[ErxTask]] = []
    var deleteTasksReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var deleteTasksClosure: (([ErxTask]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksCallsCount += 1
        deleteTasksReceivedTasks = tasks
        deleteTasksReceivedInvocations.append(tasks)
        return deleteTasksClosure.map({ $0(tasks) }) ?? deleteTasksReturnValue
    }
    
   // MARK: - redeem

    var redeemOrderCallsCount = 0
    var redeemOrderCalled: Bool {
        redeemOrderCallsCount > 0
    }
    var redeemOrderReceivedOrder: ErxTaskOrder?
    var redeemOrderReceivedInvocations: [ErxTaskOrder] = []
    var redeemOrderReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    var redeemOrderClosure: ((ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderCallsCount += 1
        redeemOrderReceivedOrder = order
        redeemOrderReceivedInvocations.append(order)
        return redeemOrderClosure.map({ $0(order) }) ?? redeemOrderReturnValue
    }
    
   // MARK: - listAllCommunications

    var listAllCommunicationsAfterForCallsCount = 0
    var listAllCommunicationsAfterForCalled: Bool {
        listAllCommunicationsAfterForCallsCount > 0
    }
    var listAllCommunicationsAfterForReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile)?
    var listAllCommunicationsAfterForReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile)] = []
    var listAllCommunicationsAfterForReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    var listAllCommunicationsAfterForClosure: ((String?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterForCallsCount += 1
        listAllCommunicationsAfterForReceivedArguments = (referenceDate: referenceDate, profile: profile)
        listAllCommunicationsAfterForReceivedInvocations.append((referenceDate: referenceDate, profile: profile))
        return listAllCommunicationsAfterForClosure.map({ $0(referenceDate, profile) }) ?? listAllCommunicationsAfterForReturnValue
    }
    
   // MARK: - fetchAuditEvent

    var fetchAuditEventByCallsCount = 0
    var fetchAuditEventByCalled: Bool {
        fetchAuditEventByCallsCount > 0
    }
    var fetchAuditEventByReceivedId: ErxAuditEvent.ID?
    var fetchAuditEventByReceivedInvocations: [ErxAuditEvent.ID] = []
    var fetchAuditEventByReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    var fetchAuditEventByClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByCallsCount += 1
        fetchAuditEventByReceivedId = id
        fetchAuditEventByReceivedInvocations.append(id)
        return fetchAuditEventByClosure.map({ $0(id) }) ?? fetchAuditEventByReturnValue
    }
    
   // MARK: - listAllAuditEvents

    var listAllAuditEventsAfterForCallsCount = 0
    var listAllAuditEventsAfterForCalled: Bool {
        listAllAuditEventsAfterForCallsCount > 0
    }
    var listAllAuditEventsAfterForReceivedArguments: (referenceDate: String?, locale: String?)?
    var listAllAuditEventsAfterForReceivedInvocations: [(referenceDate: String?, locale: String?)] = []
    var listAllAuditEventsAfterForReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAllAuditEventsAfterForClosure: ((String?, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAllAuditEvents(after referenceDate: String?, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterForCallsCount += 1
        listAllAuditEventsAfterForReceivedArguments = (referenceDate: referenceDate, locale: locale)
        listAllAuditEventsAfterForReceivedInvocations.append((referenceDate: referenceDate, locale: locale))
        return listAllAuditEventsAfterForClosure.map({ $0(referenceDate, locale) }) ?? listAllAuditEventsAfterForReturnValue
    }
    
   // MARK: - listAuditEventsNextPage

    var listAuditEventsNextPageFromLocaleCallsCount = 0
    var listAuditEventsNextPageFromLocaleCalled: Bool {
        listAuditEventsNextPageFromLocaleCallsCount > 0
    }
    var listAuditEventsNextPageFromLocaleReceivedArguments: (url: URL, locale: String?)?
    var listAuditEventsNextPageFromLocaleReceivedInvocations: [(url: URL, locale: String?)] = []
    var listAuditEventsNextPageFromLocaleReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAuditEventsNextPageFromLocaleClosure: ((URL, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAuditEventsNextPage(from url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageFromLocaleCallsCount += 1
        listAuditEventsNextPageFromLocaleReceivedArguments = (url: url, locale: locale)
        listAuditEventsNextPageFromLocaleReceivedInvocations.append((url: url, locale: locale))
        return listAuditEventsNextPageFromLocaleClosure.map({ $0(url, locale) }) ?? listAuditEventsNextPageFromLocaleReturnValue
    }
    
   // MARK: - listMedicationDispenses

    var listMedicationDispensesForCallsCount = 0
    var listMedicationDispensesForCalled: Bool {
        listMedicationDispensesForCallsCount > 0
    }
    var listMedicationDispensesForReceivedId: ErxTask.ID?
    var listMedicationDispensesForReceivedInvocations: [ErxTask.ID] = []
    var listMedicationDispensesForReturnValue: AnyPublisher<[ErxMedicationDispense], RemoteStoreError>!
    var listMedicationDispensesForClosure: ((ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>)?

    func listMedicationDispenses(for id: ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        listMedicationDispensesForCallsCount += 1
        listMedicationDispensesForReceivedId = id
        listMedicationDispensesForReceivedInvocations.append(id)
        return listMedicationDispensesForClosure.map({ $0(id) }) ?? listMedicationDispensesForReturnValue
    }
    
   // MARK: - fetchChargeItem

    var fetchChargeItemByCallsCount = 0
    var fetchChargeItemByCalled: Bool {
        fetchChargeItemByCallsCount > 0
    }
    var fetchChargeItemByReceivedId: ErxChargeItem.ID?
    var fetchChargeItemByReceivedInvocations: [ErxChargeItem.ID] = []
    var fetchChargeItemByReturnValue: AnyPublisher<ErxChargeItem?, RemoteStoreError>!
    var fetchChargeItemByClosure: ((ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>)?

    func fetchChargeItem(by id: ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fetchChargeItemByCallsCount += 1
        fetchChargeItemByReceivedId = id
        fetchChargeItemByReceivedInvocations.append(id)
        return fetchChargeItemByClosure.map({ $0(id) }) ?? fetchChargeItemByReturnValue
    }
    
   // MARK: - listAllChargeItems

    var listAllChargeItemsAfterCallsCount = 0
    var listAllChargeItemsAfterCalled: Bool {
        listAllChargeItemsAfterCallsCount > 0
    }
    var listAllChargeItemsAfterReceivedReferenceDate: String?
    var listAllChargeItemsAfterReceivedInvocations: [String?] = []
    var listAllChargeItemsAfterReturnValue: AnyPublisher<[ErxChargeItem], RemoteStoreError>!
    var listAllChargeItemsAfterClosure: ((String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>)?

    func listAllChargeItems(after referenceDate: String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        listAllChargeItemsAfterCallsCount += 1
        listAllChargeItemsAfterReceivedReferenceDate = referenceDate
        listAllChargeItemsAfterReceivedInvocations.append(referenceDate)
        return listAllChargeItemsAfterClosure.map({ $0(referenceDate) }) ?? listAllChargeItemsAfterReturnValue
    }
    
   // MARK: - delete

    var deleteChargeItemsCallsCount = 0
    var deleteChargeItemsCalled: Bool {
        deleteChargeItemsCallsCount > 0
    }
    var deleteChargeItemsReceivedChargeItems: [ErxChargeItem]?
    var deleteChargeItemsReceivedInvocations: [[ErxChargeItem]] = []
    var deleteChargeItemsReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var deleteChargeItemsClosure: (([ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteChargeItemsCallsCount += 1
        deleteChargeItemsReceivedChargeItems = chargeItems
        deleteChargeItemsReceivedInvocations.append(chargeItems)
        return deleteChargeItemsClosure.map({ $0(chargeItems) }) ?? deleteChargeItemsReturnValue
    }
    
   // MARK: - fetchConsents

    var fetchConsentsCallsCount = 0
    var fetchConsentsCalled: Bool {
        fetchConsentsCallsCount > 0
    }
    var fetchConsentsReturnValue: AnyPublisher<[ErxConsent], RemoteStoreError>!
    var fetchConsentsClosure: (() -> AnyPublisher<[ErxConsent], RemoteStoreError>)?

    func fetchConsents() -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fetchConsentsCallsCount += 1
        return fetchConsentsClosure.map({ $0() }) ?? fetchConsentsReturnValue
    }
    
   // MARK: - grantConsent

    var grantConsentCallsCount = 0
    var grantConsentCalled: Bool {
        grantConsentCallsCount > 0
    }
    var grantConsentReceivedConsent: ErxConsent?
    var grantConsentReceivedInvocations: [ErxConsent] = []
    var grantConsentReturnValue: AnyPublisher<ErxConsent?, RemoteStoreError>!
    var grantConsentClosure: ((ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError>)?

    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        grantConsentCallsCount += 1
        grantConsentReceivedConsent = consent
        grantConsentReceivedInvocations.append(consent)
        return grantConsentClosure.map({ $0(consent) }) ?? grantConsentReturnValue
    }
    
   // MARK: - revokeConsent

    var revokeConsentCallsCount = 0
    var revokeConsentCalled: Bool {
        revokeConsentCallsCount > 0
    }
    var revokeConsentReceivedCategory: ErxConsent.Category?
    var revokeConsentReceivedInvocations: [ErxConsent.Category] = []
    var revokeConsentReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var revokeConsentClosure: ((ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError>)?

    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError> {
        revokeConsentCallsCount += 1
        revokeConsentReceivedCategory = category
        revokeConsentReceivedInvocations.append(category)
        return revokeConsentClosure.map({ $0(category) }) ?? revokeConsentReturnValue
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


// MARK: - MockInternalCommunicationProtocol -

final class MockInternalCommunicationProtocol: InternalCommunicationProtocol {
    
   // MARK: - load

    var loadThrowableError: Error?
    var loadCallsCount = 0
    var loadCalled: Bool {
        loadCallsCount > 0
    }
    var loadReturnValue: IdentifiedArray<String, InternalCommunication>!
    var loadClosure: (() throws -> IdentifiedArray<String, InternalCommunication>)?

    func load() throws -> IdentifiedArray<String, InternalCommunication> {
        if let error = loadThrowableError {
            throw error
        }
        loadCallsCount += 1
        return try loadClosure.map({ try $0() }) ?? loadReturnValue
    }
    
   // MARK: - loadUnreadInternalCommunicationsCount

    var loadUnreadInternalCommunicationsCountCallsCount = 0
    var loadUnreadInternalCommunicationsCountCalled: Bool {
        loadUnreadInternalCommunicationsCountCallsCount > 0
    }
    var loadUnreadInternalCommunicationsCountReturnValue: AsyncThrowingStream<Int, Swift.Error>!
    var loadUnreadInternalCommunicationsCountClosure: (() -> AsyncThrowingStream<Int, Swift.Error>)?

    func loadUnreadInternalCommunicationsCount() -> AsyncThrowingStream<Int, Swift.Error> {
        loadUnreadInternalCommunicationsCountCallsCount += 1
        return loadUnreadInternalCommunicationsCountClosure.map({ $0() }) ?? loadUnreadInternalCommunicationsCountReturnValue
    }
}


// MARK: - MockKeychainAccessHelper -

final class MockKeychainAccessHelper: KeychainAccessHelper {
    
   // MARK: - genericPassword

    var genericPasswordForOfServiceThrowableError: Error?
    var genericPasswordForOfServiceCallsCount = 0
    var genericPasswordForOfServiceCalled: Bool {
        genericPasswordForOfServiceCallsCount > 0
    }
    var genericPasswordForOfServiceReceivedArguments: (account: Data, service: Data)?
    var genericPasswordForOfServiceReceivedInvocations: [(account: Data, service: Data)] = []
    var genericPasswordForOfServiceReturnValue: Data?
    var genericPasswordForOfServiceClosure: ((Data, Data) throws -> Data?)?

    func genericPassword(for account: Data, ofService service: Data) throws -> Data? {
        if let error = genericPasswordForOfServiceThrowableError {
            throw error
        }
        genericPasswordForOfServiceCallsCount += 1
        genericPasswordForOfServiceReceivedArguments = (account: account, service: service)
        genericPasswordForOfServiceReceivedInvocations.append((account: account, service: service))
        return try genericPasswordForOfServiceClosure.map({ try $0(account, service) }) ?? genericPasswordForOfServiceReturnValue
    }
    
   // MARK: - unsetGenericPassword

    var unsetGenericPasswordForOfServiceCallsCount = 0
    var unsetGenericPasswordForOfServiceCalled: Bool {
        unsetGenericPasswordForOfServiceCallsCount > 0
    }
    var unsetGenericPasswordForOfServiceReceivedArguments: (account: Data, service: Data)?
    var unsetGenericPasswordForOfServiceReceivedInvocations: [(account: Data, service: Data)] = []
    var unsetGenericPasswordForOfServiceReturnValue: Bool!
    var unsetGenericPasswordForOfServiceClosure: ((Data, Data) -> Bool)?

    func unsetGenericPassword(for account: Data, ofService service: Data) -> Bool {
        unsetGenericPasswordForOfServiceCallsCount += 1
        unsetGenericPasswordForOfServiceReceivedArguments = (account: account, service: service)
        unsetGenericPasswordForOfServiceReceivedInvocations.append((account: account, service: service))
        return unsetGenericPasswordForOfServiceClosure.map({ $0(account, service) }) ?? unsetGenericPasswordForOfServiceReturnValue
    }
    
   // MARK: - setGenericPassword

    var setGenericPasswordForServiceThrowableError: Error?
    var setGenericPasswordForServiceCallsCount = 0
    var setGenericPasswordForServiceCalled: Bool {
        setGenericPasswordForServiceCallsCount > 0
    }
    var setGenericPasswordForServiceReceivedArguments: (password: Data, account: Data, service: Data)?
    var setGenericPasswordForServiceReceivedInvocations: [(password: Data, account: Data, service: Data)] = []
    var setGenericPasswordForServiceReturnValue: Bool!
    var setGenericPasswordForServiceClosure: ((Data, Data, Data) throws -> Bool)?

    func setGenericPassword(_ password: Data, for account: Data, service: Data) throws -> Bool {
        if let error = setGenericPasswordForServiceThrowableError {
            throw error
        }
        setGenericPasswordForServiceCallsCount += 1
        setGenericPasswordForServiceReceivedArguments = (password: password, account: account, service: service)
        setGenericPasswordForServiceReceivedInvocations.append((password: password, account: account, service: service))
        return try setGenericPasswordForServiceClosure.map({ try $0(password, account, service) }) ?? setGenericPasswordForServiceReturnValue
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


// MARK: - MockMedicationScheduleStore -

final class MockMedicationScheduleStore: MedicationScheduleStore {
    
   // MARK: - fetch

    var fetchByThrowableError: Error?
    var fetchByCallsCount = 0
    var fetchByCalled: Bool {
        fetchByCallsCount > 0
    }
    var fetchByReceivedTaskID: ErxTask.ID?
    var fetchByReceivedInvocations: [ErxTask.ID] = []
    var fetchByReturnValue: MedicationSchedule?
    var fetchByClosure: ((ErxTask.ID) throws -> MedicationSchedule?)?

    func fetch(by taskID: ErxTask.ID) throws -> MedicationSchedule? {
        if let error = fetchByThrowableError {
            throw error
        }
        fetchByCallsCount += 1
        fetchByReceivedTaskID = taskID
        fetchByReceivedInvocations.append(taskID)
        return try fetchByClosure.map({ try $0(taskID) }) ?? fetchByReturnValue
    }
    
   // MARK: - fetch

    var fetchByEntryIdDateProviderThrowableError: Error?
    var fetchByEntryIdDateProviderCallsCount = 0
    var fetchByEntryIdDateProviderCalled: Bool {
        fetchByEntryIdDateProviderCallsCount > 0
    }
    var fetchByEntryIdDateProviderReceivedArguments: (entryId: UUID, dateProvider: () -> Date)?
    var fetchByEntryIdDateProviderReceivedInvocations: [(entryId: UUID, dateProvider: () -> Date)] = []
    var fetchByEntryIdDateProviderReturnValue: MedicationScheduleFetchByEntryIdResponse!
    var fetchByEntryIdDateProviderClosure: ((UUID, @escaping () -> Date) throws -> MedicationScheduleFetchByEntryIdResponse)?

    func fetch(byEntryId entryId: UUID, dateProvider: @escaping () -> Date) throws -> MedicationScheduleFetchByEntryIdResponse {
        if let error = fetchByEntryIdDateProviderThrowableError {
            throw error
        }
        fetchByEntryIdDateProviderCallsCount += 1
        fetchByEntryIdDateProviderReceivedArguments = (entryId: entryId, dateProvider: dateProvider)
        fetchByEntryIdDateProviderReceivedInvocations.append((entryId: entryId, dateProvider: dateProvider))
        return try fetchByEntryIdDateProviderClosure.map({ try $0(entryId, dateProvider) }) ?? fetchByEntryIdDateProviderReturnValue
    }
    
   // MARK: - fetchAll

    var fetchAllThrowableError: Error?
    var fetchAllCallsCount = 0
    var fetchAllCalled: Bool {
        fetchAllCallsCount > 0
    }
    var fetchAllReturnValue: [MedicationSchedule]!
    var fetchAllClosure: (() throws -> [MedicationSchedule])?

    func fetchAll() throws -> [MedicationSchedule] {
        if let error = fetchAllThrowableError {
            throw error
        }
        fetchAllCallsCount += 1
        return try fetchAllClosure.map({ try $0() }) ?? fetchAllReturnValue
    }
    
   // MARK: - save

    var saveMedicationSchedulesThrowableError: Error?
    var saveMedicationSchedulesCallsCount = 0
    var saveMedicationSchedulesCalled: Bool {
        saveMedicationSchedulesCallsCount > 0
    }
    var saveMedicationSchedulesReceivedMedicationSchedules: [MedicationSchedule]?
    var saveMedicationSchedulesReceivedInvocations: [[MedicationSchedule]] = []
    var saveMedicationSchedulesReturnValue: [MedicationSchedule]!
    var saveMedicationSchedulesClosure: (([MedicationSchedule]) throws -> [MedicationSchedule])?

    func save(medicationSchedules: [MedicationSchedule]) throws -> [MedicationSchedule] {
        if let error = saveMedicationSchedulesThrowableError {
            throw error
        }
        saveMedicationSchedulesCallsCount += 1
        saveMedicationSchedulesReceivedMedicationSchedules = medicationSchedules
        saveMedicationSchedulesReceivedInvocations.append(medicationSchedules)
        return try saveMedicationSchedulesClosure.map({ try $0(medicationSchedules) }) ?? saveMedicationSchedulesReturnValue
    }
    
   // MARK: - delete

    var deleteMedicationSchedulesThrowableError: Error?
    var deleteMedicationSchedulesCallsCount = 0
    var deleteMedicationSchedulesCalled: Bool {
        deleteMedicationSchedulesCallsCount > 0
    }
    var deleteMedicationSchedulesReceivedMedicationSchedules: [MedicationSchedule]?
    var deleteMedicationSchedulesReceivedInvocations: [[MedicationSchedule]] = []
    var deleteMedicationSchedulesClosure: (([MedicationSchedule]) throws -> Void)?

    func delete(medicationSchedules: [MedicationSchedule]) throws {
        if let error = deleteMedicationSchedulesThrowableError {
            throw error
        }
        deleteMedicationSchedulesCallsCount += 1
        deleteMedicationSchedulesReceivedMedicationSchedules = medicationSchedules
        deleteMedicationSchedulesReceivedInvocations.append(medicationSchedules)
        try deleteMedicationSchedulesClosure?(medicationSchedules)
    }
}


// MARK: - MockModelMigrating -

final class MockModelMigrating: ModelMigrating {
    
   // MARK: - startModelMigration

    var startModelMigrationFromDefaultProfileNameCallsCount = 0
    var startModelMigrationFromDefaultProfileNameCalled: Bool {
        startModelMigrationFromDefaultProfileNameCallsCount > 0
    }
    var startModelMigrationFromDefaultProfileNameReceivedArguments: (currentVersion: ModelVersion, defaultProfileName: String)?
    var startModelMigrationFromDefaultProfileNameReceivedInvocations: [(currentVersion: ModelVersion, defaultProfileName: String)] = []
    var startModelMigrationFromDefaultProfileNameReturnValue: AnyPublisher<ModelVersion, MigrationError>!
    var startModelMigrationFromDefaultProfileNameClosure: ((ModelVersion, String) -> AnyPublisher<ModelVersion, MigrationError>)?

    func startModelMigration(from currentVersion: ModelVersion, defaultProfileName: String) -> AnyPublisher<ModelVersion, MigrationError> {
        startModelMigrationFromDefaultProfileNameCallsCount += 1
        startModelMigrationFromDefaultProfileNameReceivedArguments = (currentVersion: currentVersion, defaultProfileName: defaultProfileName)
        startModelMigrationFromDefaultProfileNameReceivedInvocations.append((currentVersion: currentVersion, defaultProfileName: defaultProfileName))
        return startModelMigrationFromDefaultProfileNameClosure.map({ $0(currentVersion, defaultProfileName) }) ?? startModelMigrationFromDefaultProfileNameReturnValue
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
    var resetEgkMrPinRetryCounterCanPukModeReturnValue: Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var resetEgkMrPinRetryCounterCanPukModeClosure: ((String, String, NFCResetRetryCounterMode) -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode) -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
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
    var changeReferenceDataCanOldNewModeReturnValue: Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var changeReferenceDataCanOldNewModeClosure: ((String, String, String, NFCChangeReferenceDataMode) -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode) -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        changeReferenceDataCanOldNewModeCallsCount += 1
        changeReferenceDataCanOldNewModeReceivedArguments = (can: can, old: old, new: new, mode: mode)
        changeReferenceDataCanOldNewModeReceivedInvocations.append((can: can, old: old, new: new, mode: mode))
        return changeReferenceDataCanOldNewModeClosure.map({ $0(can, old, new, mode) }) ?? changeReferenceDataCanOldNewModeReturnValue
    }
}


// MARK: - MockOrdersRepository -

final class MockOrdersRepository: OrdersRepository {
    
   // MARK: - loadAllOrders

    var loadAllOrdersCallsCount = 0
    var loadAllOrdersCalled: Bool {
        loadAllOrdersCallsCount > 0
    }
    var loadAllOrdersReturnValue: AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>!
    var loadAllOrdersClosure: (() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>)?

    func loadAllOrders() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error> {
        loadAllOrdersCallsCount += 1
        return loadAllOrdersClosure.map({ $0() }) ?? loadAllOrdersReturnValue
    }
}


// MARK: - MockPagedAuditEventsController -

final class MockPagedAuditEventsController: PagedAuditEventsController {
    
   // MARK: - getPageContainer

    var getPageContainerCallsCount = 0
    var getPageContainerCalled: Bool {
        getPageContainerCallsCount > 0
    }
    var getPageContainerReturnValue: PageContainer?
    var getPageContainerClosure: (() -> PageContainer?)?

    func getPageContainer() -> PageContainer? {
        getPageContainerCallsCount += 1
        return getPageContainerClosure.map({ $0() }) ?? getPageContainerReturnValue
    }
    
   // MARK: - getPage

    var getPageCallsCount = 0
    var getPageCalled: Bool {
        getPageCallsCount > 0
    }
    var getPageReceivedPage: Page?
    var getPageReceivedInvocations: [Page] = []
    var getPageReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    var getPageClosure: ((Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    func getPage(_ page: Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        getPageCallsCount += 1
        getPageReceivedPage = page
        getPageReceivedInvocations.append(page)
        return getPageClosure.map({ $0(page) }) ?? getPageReturnValue
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

    var loadLocalForCallsCount = 0
    var loadLocalForCalled: Bool {
        loadLocalForCallsCount > 0
    }
    var loadLocalForReceivedProfileId: UUID?
    var loadLocalForReceivedInvocations: [UUID] = []
    var loadLocalForReturnValue: AnyPublisher<[Prescription], PrescriptionRepositoryError>!
    var loadLocalForClosure: ((UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError>)?

    func loadLocal(for profileId: UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        loadLocalForCallsCount += 1
        loadLocalForReceivedProfileId = profileId
        loadLocalForReceivedInvocations.append(profileId)
        return loadLocalForClosure.map({ $0(profileId) }) ?? loadLocalForReturnValue
    }
    
   // MARK: - forcedLoadRemote

    var forcedLoadRemoteForForCallsCount = 0
    var forcedLoadRemoteForForCalled: Bool {
        forcedLoadRemoteForForCallsCount > 0
    }
    var forcedLoadRemoteForForReceivedArguments: (locale: String?, profileId: UUID)?
    var forcedLoadRemoteForForReceivedInvocations: [(locale: String?, profileId: UUID)] = []
    var forcedLoadRemoteForForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var forcedLoadRemoteForForClosure: ((String?, UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func forcedLoadRemote(for locale: String?, for profileId: UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        forcedLoadRemoteForForCallsCount += 1
        forcedLoadRemoteForForReceivedArguments = (locale: locale, profileId: profileId)
        forcedLoadRemoteForForReceivedInvocations.append((locale: locale, profileId: profileId))
        return forcedLoadRemoteForForClosure.map({ $0(locale, profileId) }) ?? forcedLoadRemoteForForReturnValue
    }
    
   // MARK: - silentLoadRemote

    var silentLoadRemoteForForCallsCount = 0
    var silentLoadRemoteForForCalled: Bool {
        silentLoadRemoteForForCallsCount > 0
    }
    var silentLoadRemoteForForReceivedArguments: (locale: String?, profileId: UUID)?
    var silentLoadRemoteForForReceivedInvocations: [(locale: String?, profileId: UUID)] = []
    var silentLoadRemoteForForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var silentLoadRemoteForForClosure: ((String?, UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func silentLoadRemote(for locale: String?, for profileId: UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        silentLoadRemoteForForCallsCount += 1
        silentLoadRemoteForForReceivedArguments = (locale: locale, profileId: profileId)
        silentLoadRemoteForForReceivedInvocations.append((locale: locale, profileId: profileId))
        return silentLoadRemoteForForClosure.map({ $0(locale, profileId) }) ?? silentLoadRemoteForForReturnValue
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

    var redeemProfileIdCallsCount = 0
    var redeemProfileIdCalled: Bool {
        redeemProfileIdCallsCount > 0
    }
    var redeemProfileIdReceivedArguments: (orders: [OrderRequest], profileId: UUID)?
    var redeemProfileIdReceivedInvocations: [(orders: [OrderRequest], profileId: UUID)] = []
    var redeemProfileIdReturnValue: AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>!
    var redeemProfileIdClosure: (([OrderRequest], UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)?

    func redeem(_ orders: [OrderRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        redeemProfileIdCallsCount += 1
        redeemProfileIdReceivedArguments = (orders: orders, profileId: profileId)
        redeemProfileIdReceivedInvocations.append((orders: orders, profileId: profileId))
        return redeemProfileIdClosure.map({ $0(orders, profileId) }) ?? redeemProfileIdReturnValue
    }
    
   // MARK: - redeemDiGa

    var redeemDiGaProfileIdCallsCount = 0
    var redeemDiGaProfileIdCalled: Bool {
        redeemDiGaProfileIdCallsCount > 0
    }
    var redeemDiGaProfileIdReceivedArguments: (orders: [OrderDiGaRequest], profileId: UUID)?
    var redeemDiGaProfileIdReceivedInvocations: [(orders: [OrderDiGaRequest], profileId: UUID)] = []
    var redeemDiGaProfileIdReturnValue: AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>!
    var redeemDiGaProfileIdClosure: (([OrderDiGaRequest], UUID) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>)?

    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> {
        redeemDiGaProfileIdCallsCount += 1
        redeemDiGaProfileIdReceivedArguments = (orders: orders, profileId: profileId)
        redeemDiGaProfileIdReceivedInvocations.append((orders: orders, profileId: profileId))
        return redeemDiGaProfileIdClosure.map({ $0(orders, profileId) }) ?? redeemDiGaProfileIdReturnValue
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
    var cardWallForReturnValue: AnyPublisher<CardWallCANDomain.State, Never>!
    var cardWallForClosure: ((UUID) -> AnyPublisher<CardWallCANDomain.State, Never>)?

    func cardWall(for profileId: UUID) -> AnyPublisher<CardWallCANDomain.State, Never> {
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
    
   // MARK: - onboardingDate

    var onboardingDate: AnyPublisher<Date?, Never> {
        get { underlyingOnboardingDate }
        set(value) { underlyingOnboardingDate = value }
    }
    var underlyingOnboardingDate: AnyPublisher<Date?, Never>!
    
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
    
   // MARK: - readInternalCommunications

    var readInternalCommunications: AnyPublisher<[String], Never> {
        get { underlyingReadInternalCommunications }
        set(value) { underlyingReadInternalCommunications = value }
    }
    var underlyingReadInternalCommunications: AnyPublisher<[String], Never>!
    
   // MARK: - hideWelcomeMessage

    var hideWelcomeMessage: AnyPublisher<Bool, Never> {
        get { underlyingHideWelcomeMessage }
        set(value) { underlyingHideWelcomeMessage = value }
    }
    var underlyingHideWelcomeMessage: AnyPublisher<Bool, Never>!
    
   // MARK: - hideEURedeemInstructions

    var hideEURedeemInstructions: AnyPublisher<Bool, Never> {
        get { underlyingHideEURedeemInstructions }
        set(value) { underlyingHideEURedeemInstructions = value }
    }
    var underlyingHideEURedeemInstructions: AnyPublisher<Bool, Never>!
    
   // MARK: - set

    var setOnboardingDateCallsCount = 0
    var setOnboardingDateCalled: Bool {
        setOnboardingDateCallsCount > 0
    }
    var setOnboardingDateReceivedOnboardingDate: Date?
    var setOnboardingDateReceivedInvocations: [Date?] = []
    var setOnboardingDateClosure: ((Date?) -> Void)?

    func set(onboardingDate: Date?) {
        setOnboardingDateCallsCount += 1
        setOnboardingDateReceivedOnboardingDate = onboardingDate
        setOnboardingDateReceivedInvocations.append(onboardingDate)
        setOnboardingDateClosure?(onboardingDate)
    }
    
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
    
   // MARK: - markInternalCommunicationAsRead

    var markInternalCommunicationAsReadMessageIdCallsCount = 0
    var markInternalCommunicationAsReadMessageIdCalled: Bool {
        markInternalCommunicationAsReadMessageIdCallsCount > 0
    }
    var markInternalCommunicationAsReadMessageIdReceivedMessageId: String?
    var markInternalCommunicationAsReadMessageIdReceivedInvocations: [String] = []
    var markInternalCommunicationAsReadMessageIdClosure: ((String) -> Void)?

    func markInternalCommunicationAsRead(messageId: String) {
        markInternalCommunicationAsReadMessageIdCallsCount += 1
        markInternalCommunicationAsReadMessageIdReceivedMessageId = messageId
        markInternalCommunicationAsReadMessageIdReceivedInvocations.append(messageId)
        markInternalCommunicationAsReadMessageIdClosure?(messageId)
    }
    
   // MARK: - set

    var setHideWelcomeMessageCallsCount = 0
    var setHideWelcomeMessageCalled: Bool {
        setHideWelcomeMessageCallsCount > 0
    }
    var setHideWelcomeMessageReceivedHideWelcomeMessage: Bool?
    var setHideWelcomeMessageReceivedInvocations: [Bool] = []
    var setHideWelcomeMessageClosure: ((Bool) -> Void)?

    func set(hideWelcomeMessage: Bool) {
        setHideWelcomeMessageCallsCount += 1
        setHideWelcomeMessageReceivedHideWelcomeMessage = hideWelcomeMessage
        setHideWelcomeMessageReceivedInvocations.append(hideWelcomeMessage)
        setHideWelcomeMessageClosure?(hideWelcomeMessage)
    }
    
   // MARK: - set

    var setHideEURedeemInstructionsCallsCount = 0
    var setHideEURedeemInstructionsCalled: Bool {
        setHideEURedeemInstructionsCallsCount > 0
    }
    var setHideEURedeemInstructionsReceivedHideEURedeemInstructions: Bool?
    var setHideEURedeemInstructionsReceivedInvocations: [Bool] = []
    var setHideEURedeemInstructionsClosure: ((Bool) -> Void)?

    func set(hideEURedeemInstructions: Bool) {
        setHideEURedeemInstructionsCallsCount += 1
        setHideEURedeemInstructionsReceivedHideEURedeemInstructions = hideEURedeemInstructions
        setHideEURedeemInstructionsReceivedInvocations.append(hideEURedeemInstructions)
        setHideEURedeemInstructionsClosure?(hideEURedeemInstructions)
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
