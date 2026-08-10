// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import BfArM
import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy
import Profiles
import TestUtils
import TrustStore
import VAUClient
import ZXingCpp
import FeatureCardWall
import FeatureHelpers
import eRpResources

@testable import eRpFeatures
























public class AVSTransactionDataStoreMock: AVSTransactionDataStore {

    public init() {}



    //MARK: - fetchAVSTransaction

    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorCallsCount = 0
    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorCalled: Bool {
        return fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorCallsCount > 0
    }
    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReceivedIdentifier: (UUID)?
    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations: [(UUID)] = []
    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReturnValue: AnyPublisher<AVSTransaction?, LocalStoreError>!
    public var fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorClosure: ((UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>)?

    public func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorCallsCount += 1
        fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReceivedIdentifier = identifier
        fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations.append(identifier)
        if let fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorClosure = fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorClosure {
            return fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorClosure(identifier)
        } else {
            return fetchAVSTransactionByIdentifierUUIDAnyPublisherAVSTransactionLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllAVSTransactions

    public var listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorCallsCount = 0
    public var listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorCalled: Bool {
        return listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorCallsCount > 0
    }
    public var listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    public var listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorClosure: (() -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    public func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorCallsCount += 1
        if let listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorClosure = listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorClosure {
            return listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorClosure()
        } else {
            return listAllAVSTransactionsAnyPublisherAVSTransactionLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount = 0
    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCalled: Bool {
        return saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount > 0
    }
    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedAvsTransactions: ([AVSTransaction])?
    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations: [([AVSTransaction])] = []
    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    public var saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    public func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount += 1
        saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedAvsTransactions = avsTransactions
        saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations.append(avsTransactions)
        if let saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure = saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure {
            return saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure(avsTransactions)
        } else {
            return saveAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount = 0
    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCalled: Bool {
        return deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount > 0
    }
    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedAvsTransactions: ([AVSTransaction])?
    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations: [([AVSTransaction])] = []
    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    public var deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    public func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorCallsCount += 1
        deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedAvsTransactions = avsTransactions
        deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReceivedInvocations.append(avsTransactions)
        if let deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure = deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure {
            return deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorClosure(avsTransactions)
        } else {
            return deleteAvsTransactionsAVSTransactionAnyPublisherAVSTransactionLocalStoreErrorReturnValue
        }
    }


}
class ActivityIndicatingMock: ActivityIndicating {


    var isActive: AnyPublisher<Bool, Never> {
        get { return underlyingIsActive }
        set(value) { underlyingIsActive = value }
    }
    var underlyingIsActive: (AnyPublisher<Bool, Never>)!



}
class AppSecurityManagerMock: AppSecurityManager {


    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        get { return underlyingAvailableSecurityOptions }
        set(value) { underlyingAvailableSecurityOptions = value }
    }
    var underlyingAvailableSecurityOptions: ((options: [AppSecurityOption], error: AppSecurityManagerError?))!


    //MARK: - save

    var savePasswordStringBoolThrowableError: (any Error)?
    var savePasswordStringBoolCallsCount = 0
    var savePasswordStringBoolCalled: Bool {
        return savePasswordStringBoolCallsCount > 0
    }
    var savePasswordStringBoolReceivedPassword: (String)?
    var savePasswordStringBoolReceivedInvocations: [(String)] = []
    var savePasswordStringBoolReturnValue: Bool!
    var savePasswordStringBoolClosure: ((String) throws -> Bool)?

    func save(password: String) throws -> Bool {
        savePasswordStringBoolCallsCount += 1
        savePasswordStringBoolReceivedPassword = password
        savePasswordStringBoolReceivedInvocations.append(password)
        if let error = savePasswordStringBoolThrowableError {
            throw error
        }
        if let savePasswordStringBoolClosure = savePasswordStringBoolClosure {
            return try savePasswordStringBoolClosure(password)
        } else {
            return savePasswordStringBoolReturnValue
        }
    }

    //MARK: - matches

    var matchesPasswordStringBoolThrowableError: (any Error)?
    var matchesPasswordStringBoolCallsCount = 0
    var matchesPasswordStringBoolCalled: Bool {
        return matchesPasswordStringBoolCallsCount > 0
    }
    var matchesPasswordStringBoolReceivedPassword: (String)?
    var matchesPasswordStringBoolReceivedInvocations: [(String)] = []
    var matchesPasswordStringBoolReturnValue: Bool!
    var matchesPasswordStringBoolClosure: ((String) throws -> Bool)?

    func matches(password: String) throws -> Bool {
        matchesPasswordStringBoolCallsCount += 1
        matchesPasswordStringBoolReceivedPassword = password
        matchesPasswordStringBoolReceivedInvocations.append(password)
        if let error = matchesPasswordStringBoolThrowableError {
            throw error
        }
        if let matchesPasswordStringBoolClosure = matchesPasswordStringBoolClosure {
            return try matchesPasswordStringBoolClosure(password)
        } else {
            return matchesPasswordStringBoolReturnValue
        }
    }

    //MARK: - registerFailedPasswordAttempt

    var registerFailedPasswordAttemptVoidThrowableError: (any Error)?
    var registerFailedPasswordAttemptVoidCallsCount = 0
    var registerFailedPasswordAttemptVoidCalled: Bool {
        return registerFailedPasswordAttemptVoidCallsCount > 0
    }
    var registerFailedPasswordAttemptVoidClosure: (() throws -> Void)?

    func registerFailedPasswordAttempt() throws {
        registerFailedPasswordAttemptVoidCallsCount += 1
        if let error = registerFailedPasswordAttemptVoidThrowableError {
            throw error
        }
        try registerFailedPasswordAttemptVoidClosure?()
    }

    //MARK: - resetPasswordDelay

    var resetPasswordDelayVoidThrowableError: (any Error)?
    var resetPasswordDelayVoidCallsCount = 0
    var resetPasswordDelayVoidCalled: Bool {
        return resetPasswordDelayVoidCallsCount > 0
    }
    var resetPasswordDelayVoidClosure: (() throws -> Void)?

    func resetPasswordDelay() throws {
        resetPasswordDelayVoidCallsCount += 1
        if let error = resetPasswordDelayVoidThrowableError {
            throw error
        }
        try resetPasswordDelayVoidClosure?()
    }

    //MARK: - currentPasswordDelay

    var currentPasswordDelayTimeIntervalThrowableError: (any Error)?
    var currentPasswordDelayTimeIntervalCallsCount = 0
    var currentPasswordDelayTimeIntervalCalled: Bool {
        return currentPasswordDelayTimeIntervalCallsCount > 0
    }
    var currentPasswordDelayTimeIntervalReturnValue: TimeInterval!
    var currentPasswordDelayTimeIntervalClosure: (() throws -> TimeInterval)?

    func currentPasswordDelay() throws -> TimeInterval {
        currentPasswordDelayTimeIntervalCallsCount += 1
        if let error = currentPasswordDelayTimeIntervalThrowableError {
            throw error
        }
        if let currentPasswordDelayTimeIntervalClosure = currentPasswordDelayTimeIntervalClosure {
            return try currentPasswordDelayTimeIntervalClosure()
        } else {
            return currentPasswordDelayTimeIntervalReturnValue
        }
    }

    //MARK: - migrate

    var migrateVoidThrowableError: (any Error)?
    var migrateVoidCallsCount = 0
    var migrateVoidCalled: Bool {
        return migrateVoidCallsCount > 0
    }
    var migrateVoidClosure: (() throws -> Void)?

    func migrate() throws {
        migrateVoidCallsCount += 1
        if let error = migrateVoidThrowableError {
            throw error
        }
        try migrateVoidClosure?()
    }


}
class AuditEventsServiceMock: AuditEventsService {




    //MARK: - loadAuditEvents

    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount = 0
    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCalled: Bool {
        return loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount > 0
    }
    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedArguments: (profileId: UUID, locale: String?)?
    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedInvocations: [(profileId: UUID, locale: String?)] = []
    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>!
    var loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure: ((UUID, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)?

    func loadAuditEvents(for profileId: UUID, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount += 1
        loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedArguments = (profileId: profileId, locale: locale)
        loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedInvocations.append((profileId: profileId, locale: locale))
        if let loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure = loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure {
            return loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure(profileId, locale)
        } else {
            return loadAuditEventsForProfileIdUUIDLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReturnValue
        }
    }

    //MARK: - loadNextAuditEvents

    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount = 0
    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCalled: Bool {
        return loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount > 0
    }
    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedArguments: (profileId: UUID, url: URL, locale: String?)?
    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedInvocations: [(profileId: UUID, url: URL, locale: String?)] = []
    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>!
    var loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure: ((UUID, URL, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)?

    func loadNextAuditEvents(for profileId: UUID, url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError> {
        loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorCallsCount += 1
        loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedArguments = (profileId: profileId, url: url, locale: locale)
        loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReceivedInvocations.append((profileId: profileId, url: url, locale: locale))
        if let loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure = loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure {
            return loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorClosure(profileId, url, locale)
        } else {
            return loadNextAuditEventsForProfileIdUUIDUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventAuditEventsServiceErrorReturnValue
        }
    }


}
class AuthenticationChallengeProviderMock: AuthenticationChallengeProvider {




    //MARK: - startAuthenticationChallenge

    var startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverCallsCount = 0
    var startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverCalled: Bool {
        return startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverCallsCount > 0
    }
    var startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverReturnValue: AnyPublisher<AuthenticationChallengeProviderResult, Never>!
    var startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverClosure: (() -> AnyPublisher<AuthenticationChallengeProviderResult, Never>)?

    func startAuthenticationChallenge() -> AnyPublisher<AuthenticationChallengeProviderResult, Never> {
        startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverCallsCount += 1
        if let startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverClosure = startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverClosure {
            return startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverClosure()
        } else {
            return startAuthenticationChallengeAnyPublisherResultBoolAuthenticationChallengeProviderErrorNeverReturnValue
        }
    }


}
class ChargeItemListDomainServiceMock: ChargeItemListDomainService {




    //MARK: - fetchLocalChargeItems

    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount = 0
    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCalled: Bool {
        return fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount > 0
    }
    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId: (UUID)?
    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations: [(UUID)] = []
    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchLocalChargeItems(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount += 1
        fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId = profileId
        fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations.append(profileId)
        if let fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure = fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure {
            return fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure(profileId)
        } else {
            return fetchLocalChargeItemsForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue
        }
    }

    //MARK: - fetchRemoteChargeItemsAndSave

    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount = 0
    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCalled: Bool {
        return fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount > 0
    }
    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId: (UUID)?
    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations: [(UUID)] = []
    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchRemoteChargeItemsAndSave(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount += 1
        fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId = profileId
        fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations.append(profileId)
        if let fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure = fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure {
            return fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure(profileId)
        } else {
            return fetchRemoteChargeItemsAndSaveForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue
        }
    }

    //MARK: - delete

    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverCallsCount = 0
    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverCalled: Bool {
        return deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverCallsCount > 0
    }
    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReceivedArguments: (chargeItem: ErxChargeItem, profileId: UUID)?
    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReceivedInvocations: [(chargeItem: ErxChargeItem, profileId: UUID)] = []
    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReturnValue: AnyPublisher<ChargeItemDomainServiceDeleteResult, Never>!
    var deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverClosure: ((ErxChargeItem, UUID) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never>)?

    func delete(chargeItem: ErxChargeItem, for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceDeleteResult, Never> {
        deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverCallsCount += 1
        deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReceivedArguments = (chargeItem: chargeItem, profileId: profileId)
        deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReceivedInvocations.append((chargeItem: chargeItem, profileId: profileId))
        if let deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverClosure = deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverClosure {
            return deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverClosure(chargeItem, profileId)
        } else {
            return deleteChargeItemErxChargeItemForProfileIdUUIDAnyPublisherChargeItemDomainServiceDeleteResultNeverReturnValue
        }
    }

    //MARK: - authenticate

    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverCallsCount = 0
    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverCalled: Bool {
        return authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverCallsCount > 0
    }
    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReceivedProfileId: (UUID)?
    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReceivedInvocations: [(UUID)] = []
    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReturnValue: AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>!
    var authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never>)?

    func authenticate(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceAuthenticateResult, Never> {
        authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverCallsCount += 1
        authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReceivedProfileId = profileId
        authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReceivedInvocations.append(profileId)
        if let authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverClosure = authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverClosure {
            return authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverClosure(profileId)
        } else {
            return authenticateForProfileIdUUIDAnyPublisherChargeItemDomainServiceAuthenticateResultNeverReturnValue
        }
    }

    //MARK: - grantChargeItemsConsent

    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverCallsCount = 0
    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverCalled: Bool {
        return grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverCallsCount > 0
    }
    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReceivedProfileId: (UUID)?
    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReceivedInvocations: [(UUID)] = []
    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReturnValue: AnyPublisher<ChargeItemListDomainServiceGrantResult, Never>!
    var grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never>)?

    func grantChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceGrantResult, Never> {
        grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverCallsCount += 1
        grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReceivedProfileId = profileId
        grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReceivedInvocations.append(profileId)
        if let grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverClosure = grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverClosure {
            return grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverClosure(profileId)
        } else {
            return grantChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceGrantResultNeverReturnValue
        }
    }

    //MARK: - fetchChargeItemsAssumingConsentGranted

    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount = 0
    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCalled: Bool {
        return fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount > 0
    }
    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId: (UUID)?
    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations: [(UUID)] = []
    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue: AnyPublisher<ChargeItemDomainServiceFetchResult, Never>!
    var fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never>)?

    func fetchChargeItemsAssumingConsentGranted(for profileId: UUID) -> AnyPublisher<ChargeItemDomainServiceFetchResult, Never> {
        fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverCallsCount += 1
        fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedProfileId = profileId
        fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReceivedInvocations.append(profileId)
        if let fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure = fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure {
            return fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverClosure(profileId)
        } else {
            return fetchChargeItemsAssumingConsentGrantedForProfileIdUUIDAnyPublisherChargeItemDomainServiceFetchResultNeverReturnValue
        }
    }

    //MARK: - revokeChargeItemsConsent

    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverCallsCount = 0
    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverCalled: Bool {
        return revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverCallsCount > 0
    }
    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReceivedProfileId: (UUID)?
    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReceivedInvocations: [(UUID)] = []
    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReturnValue: AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never>!
    var revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverClosure: ((UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never>)?

    func revokeChargeItemsConsent(for profileId: UUID) -> AnyPublisher<ChargeItemListDomainServiceRevokeResult, Never> {
        revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverCallsCount += 1
        revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReceivedProfileId = profileId
        revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReceivedInvocations.append(profileId)
        if let revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverClosure = revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverClosure {
            return revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverClosure(profileId)
        } else {
            return revokeChargeItemsConsentForProfileIdUUIDAnyPublisherChargeItemListDomainServiceRevokeResultNeverReturnValue
        }
    }


}
class DeviceSecurityManagerSessionStorageMock: DeviceSecurityManagerSessionStorage {


    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningForSession }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningForSession = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningForSession: (AnyPublisher<Bool?, Never>)!
    var ignoreDeviceRootedWarningForSession: Bool {
        get { return underlyingIgnoreDeviceRootedWarningForSession }
        set(value) { underlyingIgnoreDeviceRootedWarningForSession = value }
    }
    var underlyingIgnoreDeviceRootedWarningForSession: (Bool)!


    //MARK: - set

    var setIgnoreDeviceNotSecuredWarningForSessionBoolVoidCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningForSessionBoolVoidCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningForSessionBoolVoidCallsCount > 0
    }
    var setIgnoreDeviceNotSecuredWarningForSessionBoolVoidReceivedIgnoreDeviceNotSecuredWarningForSession: (Bool)?
    var setIgnoreDeviceNotSecuredWarningForSessionBoolVoidReceivedInvocations: [(Bool)?] = []
    var setIgnoreDeviceNotSecuredWarningForSessionBoolVoidClosure: ((Bool?) -> Void)?

    func set(ignoreDeviceNotSecuredWarningForSession: Bool?) {
        setIgnoreDeviceNotSecuredWarningForSessionBoolVoidCallsCount += 1
        setIgnoreDeviceNotSecuredWarningForSessionBoolVoidReceivedIgnoreDeviceNotSecuredWarningForSession = ignoreDeviceNotSecuredWarningForSession
        setIgnoreDeviceNotSecuredWarningForSessionBoolVoidReceivedInvocations.append(ignoreDeviceNotSecuredWarningForSession)
        setIgnoreDeviceNotSecuredWarningForSessionBoolVoidClosure?(ignoreDeviceNotSecuredWarningForSession)
    }


}
class ERPDateFormatterMock: ERPDateFormatter {




    //MARK: - string

    var stringFromDateStringCallsCount = 0
    var stringFromDateStringCalled: Bool {
        return stringFromDateStringCallsCount > 0
    }
    var stringFromDateStringReceivedFrom: (Date)?
    var stringFromDateStringReceivedInvocations: [(Date)] = []
    var stringFromDateStringReturnValue: String!
    var stringFromDateStringClosure: ((Date) -> String)?

    func string(from: Date) -> String {
        stringFromDateStringCallsCount += 1
        stringFromDateStringReceivedFrom = from
        stringFromDateStringReceivedInvocations.append(from)
        if let stringFromDateStringClosure = stringFromDateStringClosure {
            return stringFromDateStringClosure(from)
        } else {
            return stringFromDateStringReturnValue
        }
    }


}
public class ErxLocalDataStoreMock: ErxLocalDataStore {

    public init() {}



    //MARK: - fetchTask

    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<ErxTask?, LocalStoreError>!
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, LocalStoreError>)?

    public func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedInvocations.append((id: id, accessCode: accessCode))
        if let fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure = fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure(id, accessCode)
        } else {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasks

    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxTask], LocalStoreError>)?

    public func listAllTasks(of profileId: UUID?) -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedProfileId = profileId
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure = listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure {
            return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure(profileId)
        } else {
            return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestLastModifiedForErxTasks

    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestLastModifiedForErxTasks(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)?
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)] = []
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask], UUID?, Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(tasks: [ErxTask], in profileId: UUID?, updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        if let saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure = saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure {
            return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure(tasks, profileId, updateProfileLastAuthenticated)
        } else {
            return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID?)?
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?)] = []
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(tasks: [ErxTask], in profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(tasks, profileId)
        } else {
            return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasksWithoutProfile

    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    public func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        if let listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure = listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure {
            return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure()
        } else {
            return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllCommunications

    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount = 0
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCalled: Bool {
        return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount > 0
    }
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedProfile: (ErxTask.Communication.Profile)?
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations: [(ErxTask.Communication.Profile)] = []
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    public func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount += 1
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedProfile = profile
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations.append(profile)
        if let listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure = listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure {
            return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure(profile)
        } else {
            return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForCommunications

    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestTimestampForCommunications(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (communications: [ErxTask.Communication], profileId: UUID?)?
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(communications: [ErxTask.Communication], profileId: UUID?)] = []
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask.Communication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(communications: [ErxTask.Communication], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (communications: communications, profileId: profileId)
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((communications: communications, profileId: profileId))
        if let saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(communications, profileId)
        } else {
            return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - allUnreadCommunications

    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount = 0
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCalled: Bool {
        return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount > 0
    }
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedArguments: (profileId: UUID?, profile: ErxTask.Communication.Profile)?
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations: [(profileId: UUID?, profile: ErxTask.Communication.Profile)] = []
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure: ((UUID?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    public func allUnreadCommunications(of profileId: UUID?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount += 1
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedArguments = (profileId: profileId, profile: profile)
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations.append((profileId: profileId, profile: profile))
        if let allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure = allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure {
            return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure(profileId, profile)
        } else {
            return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllMedicationDispenses

    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount = 0
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCalled: Bool {
        return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount > 0
    }
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReturnValue: AnyPublisher<[ErxMedicationDispense], LocalStoreError>!
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>)?

    public func listAllMedicationDispenses(of profileId: UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount += 1
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedProfileId = profileId
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure = listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure {
            return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure(profileId)
        } else {
            return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedMedicationDispenses: ([ErxMedicationDispense])?
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([ErxMedicationDispense])] = []
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure: (([ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedMedicationDispenses = medicationDispenses
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(medicationDispenses)
        if let saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure = saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure {
            return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure(medicationDispenses)
        } else {
            return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchChargeItem

    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount = 0
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCalled: Bool {
        return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount > 0
    }
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedArguments: (profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)?
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations: [(profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)] = []
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue: AnyPublisher<ErxSparseChargeItem?, LocalStoreError>!
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure: ((UUID?, ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>)?

    public func fetchChargeItem(of profileId: UUID?, by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount += 1
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedArguments = (profileId: profileId, chargeItemID: chargeItemID)
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations.append((profileId: profileId, chargeItemID: chargeItemID))
        if let fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure = fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure {
            return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure(profileId, chargeItemID)
        } else {
            return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForChargeItems

    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllChargeItems

    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount = 0
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCalled: Bool {
        return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount > 0
    }
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue: AnyPublisher<[ErxSparseChargeItem], LocalStoreError>!
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>)?

    public func listAllChargeItems(of profileId: UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount += 1
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedProfileId = profileId
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure = listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure {
            return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure(profileId)
        } else {
            return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (chargeItems: [ErxSparseChargeItem], profileId: UUID?)?
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(chargeItems: [ErxSparseChargeItem], profileId: UUID?)] = []
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxSparseChargeItem], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        if let saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(chargeItems, profileId)
        } else {
            return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedArguments: (profileId: UUID?, chargeItems: [ErxSparseChargeItem])?
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(profileId: UUID?, chargeItems: [ErxSparseChargeItem])] = []
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure: ((UUID?, [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(of profileId: UUID?, chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedArguments = (profileId: profileId, chargeItems: chargeItems)
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((profileId: profileId, chargeItems: chargeItems))
        if let deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure = deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure {
            return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure(profileId, chargeItems)
        } else {
            return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedDiGaInfo: (DiGaInfo)?
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(DiGaInfo)] = []
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure: ((DiGaInfo) -> AnyPublisher<Bool, LocalStoreError>)?

    public func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount += 1
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedDiGaInfo = diGaInfo
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(diGaInfo)
        if let updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure = updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure {
            return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure(diGaInfo)
        } else {
            return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (euCommunications: [EuCommunication], profileId: UUID?)?
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(euCommunications: [EuCommunication], profileId: UUID?)] = []
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([EuCommunication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (euCommunications: euCommunications, profileId: profileId)
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((euCommunications: euCommunications, profileId: profileId))
        if let saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(euCommunications, profileId)
        } else {
            return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllEuCommunication

    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount = 0
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCalled: Bool {
        return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount > 0
    }
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedArguments: (countryCode: String?, profileId: UUID?)?
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations: [(countryCode: String?, profileId: UUID?)] = []
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue: AnyPublisher<[EuCommunication], LocalStoreError>!
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure: ((String?, UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError>)?

    public func listAllEuCommunication(countryCode: String?, profileId: UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError> {
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount += 1
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedArguments = (countryCode: countryCode, profileId: profileId)
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations.append((countryCode: countryCode, profileId: profileId))
        if let listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure = listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure {
            return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure(countryCode, profileId)
        } else {
            return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (euCommunications: [EuCommunication], profileId: UUID?)?
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(euCommunications: [EuCommunication], profileId: UUID?)] = []
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([EuCommunication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (euCommunications: euCommunications, profileId: profileId)
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((euCommunications: euCommunications, profileId: profileId))
        if let deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(euCommunications, profileId)
        } else {
            return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - loadLatestActiveEuCommunication

    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount = 0
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCalled: Bool {
        return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount > 0
    }
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedProfileId: (UUID)?
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue: AnyPublisher<EuCommunication?, LocalStoreError>!
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<EuCommunication?, LocalStoreError>)?

    public func loadLatestActiveEuCommunication(profileId: UUID?) -> AnyPublisher<EuCommunication?, LocalStoreError> {
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount += 1
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedProfileId = profileId
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations.append(profileId)
        if let loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure = loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure {
            return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure(profileId)
        } else {
            return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue
        }
    }


}
public class ErxRemoteDataStoreMock: ErxRemoteDataStore {

    public init() {}



    //MARK: - fetchTask

    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, accessCode: String?, profileId: UUID)?
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, accessCode: String?, profileId: UUID)] = []
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, String?, UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func fetchTask(by id: ErxTask.ID, accessCode: String?, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, accessCode: accessCode, profileId: profileId)
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, accessCode: accessCode, profileId: profileId))
        if let fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure = fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure {
            return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure(id, accessCode, profileId)
        } else {
            return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasks

    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (referenceDate: String?, profileId: UUID)?
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profileId: UUID)] = []
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((String?, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listAllTasks(after referenceDate: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profileId: profileId)
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profileId: profileId))
        if let listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(referenceDate, profileId)
        } else {
            return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listTasksNextPage

    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (previousPage: PagedContent<[ErxTask]>, profileId: UUID)?
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(previousPage: PagedContent<[ErxTask]>, profileId: UUID)] = []
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (previousPage: previousPage, profileId: profileId)
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((previousPage: previousPage, profileId: profileId))
        if let listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(previousPage, profileId)
        } else {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listDetailedTasks

    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (tasks: PagedContent<[ErxTask]>, profileId: UUID)?
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(tasks: PagedContent<[ErxTask]>, profileId: UUID)] = []
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listDetailedTasks(for tasks: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(tasks, profileId)
        } else {
            return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID)?
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID)] = []
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: (([ErxTask], UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(tasks: [ErxTask], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(tasks, profileId)
        } else {
            return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - markEURedeemable

    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID)?
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID)] = []
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, Bool, UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func markEURedeemable(for id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, byPatientAuthorization: byPatientAuthorization, profileId: profileId)
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, byPatientAuthorization: byPatientAuthorization, profileId: profileId))
        if let markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure = markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure(id, byPatientAuthorization, profileId)
        } else {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - redeem

    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount = 0
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCalled: Bool {
        return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount > 0
    }
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedArguments: (order: ErxTaskOrder, profileId: UUID)?
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations: [(order: ErxTaskOrder, profileId: UUID)] = []
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure: ((ErxTaskOrder, UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    public func redeem(order: ErxTaskOrder, profileId: UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount += 1
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedArguments = (order: order, profileId: profileId)
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations.append((order: order, profileId: profileId))
        if let redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure = redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure {
            return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure(order, profileId)
        } else {
            return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllCommunications

    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount = 0
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCalled: Bool {
        return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount > 0
    }
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile, profileId: UUID)?
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile, profileId: UUID)] = []
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure: ((String?, ErxTask.Communication.Profile, UUID) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    public func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile, profileId: UUID) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount += 1
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profile: profile, profileId: profileId)
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profile: profile, profileId: profileId))
        if let listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure = listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure(referenceDate, profile, profileId)
        } else {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchAuditEvent

    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount = 0
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCalled: Bool {
        return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedArguments: (id: ErxAuditEvent.ID, profileId: UUID)?
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations: [(id: ErxAuditEvent.ID, profileId: UUID)] = []
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure: ((ErxAuditEvent.ID, UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    public func fetchAuditEvent(by id: ErxAuditEvent.ID, profileId: UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount += 1
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure = fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure {
            return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure(id, profileId)
        } else {
            return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (referenceDate: String?, locale: String?, profileId: UUID)?
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, locale: String?, profileId: UUID)] = []
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((String?, String?, UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAllAuditEvents(after referenceDate: String?, for locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, locale: locale, profileId: profileId)
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, locale: locale, profileId: profileId))
        if let listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(referenceDate, locale, profileId)
        } else {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAuditEventsNextPage

    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (url: URL, locale: String?, profileId: UUID)?
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(url: URL, locale: String?, profileId: UUID)] = []
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((URL, String?, UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAuditEventsNextPage(from url: URL, locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (url: url, locale: locale, profileId: profileId)
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((url: url, locale: locale, profileId: profileId))
        if let listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(url, locale, profileId)
        } else {
            return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listMedicationDispenses

    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount = 0
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCalled: Bool {
        return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount > 0
    }
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, profileId: UUID)?
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, profileId: UUID)] = []
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue: AnyPublisher<[ErxMedicationDispense], RemoteStoreError>!
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure: ((ErxTask.ID, UUID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>)?

    public func listMedicationDispenses(for id: ErxTask.ID, profileId: UUID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount += 1
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure = listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure {
            return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure(id, profileId)
        } else {
            return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchChargeItem

    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments: (id: ErxChargeItem.ID, profileId: UUID)?
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(id: ErxChargeItem.ID, profileId: UUID)] = []
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<ErxChargeItem?, RemoteStoreError>!
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((ErxChargeItem.ID, UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>)?

    public func fetchChargeItem(by id: ErxChargeItem.ID, profileId: UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure = fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure(id, profileId)
        } else {
            return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllChargeItems

    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments: (referenceDate: String?, profileId: UUID)?
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profileId: UUID)] = []
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<[ErxChargeItem], RemoteStoreError>!
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((String?, UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>)?

    public func listAllChargeItems(after referenceDate: String?, profileId: UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profileId: profileId)
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profileId: profileId))
        if let listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure = listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure(referenceDate, profileId)
        } else {
            return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (chargeItems: [ErxChargeItem], profileId: UUID)?
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(chargeItems: [ErxChargeItem], profileId: UUID)] = []
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: (([ErxChargeItem], UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(chargeItems: [ErxChargeItem], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        if let deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(chargeItems, profileId)
        } else {
            return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchConsents

    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedProfileId: (UUID)?
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<[ErxConsent], RemoteStoreError>!
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError>)?

    public func fetchConsents(profileId: UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedProfileId = profileId
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations.append(profileId)
        if let fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure = fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure {
            return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure(profileId)
        } else {
            return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantConsent

    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedArguments: (consent: ErxConsent, profileId: UUID)?
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations: [(consent: ErxConsent, profileId: UUID)] = []
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<ErxConsent?, RemoteStoreError>!
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure: ((ErxConsent, UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError>)?

    public func grantConsent(_ consent: ErxConsent, profileId: UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedArguments = (consent: consent, profileId: profileId)
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations.append((consent: consent, profileId: profileId))
        if let grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure = grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure {
            return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure(consent, profileId)
        } else {
            return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - revokeConsent

    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (category: ErxConsent.Category, profileId: UUID)?
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(category: ErxConsent.Category, profileId: UUID)] = []
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: ((ErxConsent.Category, UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func revokeConsent(_ category: ErxConsent.Category, profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (category: category, profileId: profileId)
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((category: category, profileId: profileId))
        if let revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(category, profileId)
        } else {
            return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - loadRemoteEuAccessCode

    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedProfileId: (UUID)?
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func loadRemoteEuAccessCode(profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedProfileId = profileId
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations.append(profileId)
        if let loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure = loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure(profileId)
        } else {
            return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantEuAccessPermission

    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedArguments: (accessCode: EuAccessCode, profileId: UUID)?
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations: [(accessCode: EuAccessCode, profileId: UUID)] = []
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure: ((EuAccessCode, UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func grantEuAccessPermission(accessCode: EuAccessCode, profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedArguments = (accessCode: accessCode, profileId: profileId)
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations.append((accessCode: accessCode, profileId: profileId))
        if let grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure = grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure(accessCode, profileId)
        } else {
            return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - deleteEuAccessCode

    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedProfileId: (UUID)?
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func deleteEuAccessCode(profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedProfileId = profileId
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append(profileId)
        if let deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(profileId)
        } else {
            return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }


}
class InternalCommunicationProtocolMock: InternalCommunicationProtocol {




    //MARK: - load

    var loadIdentifiedArrayStringInternalCommunicationThrowableError: (any Error)?
    var loadIdentifiedArrayStringInternalCommunicationCallsCount = 0
    var loadIdentifiedArrayStringInternalCommunicationCalled: Bool {
        return loadIdentifiedArrayStringInternalCommunicationCallsCount > 0
    }
    var loadIdentifiedArrayStringInternalCommunicationReturnValue: IdentifiedArray<String, InternalCommunication>!
    var loadIdentifiedArrayStringInternalCommunicationClosure: (() async throws -> IdentifiedArray<String, InternalCommunication>)?

    func load() async throws -> IdentifiedArray<String, InternalCommunication> {
        loadIdentifiedArrayStringInternalCommunicationCallsCount += 1
        if let error = loadIdentifiedArrayStringInternalCommunicationThrowableError {
            throw error
        }
        if let loadIdentifiedArrayStringInternalCommunicationClosure = loadIdentifiedArrayStringInternalCommunicationClosure {
            return try await loadIdentifiedArrayStringInternalCommunicationClosure()
        } else {
            return loadIdentifiedArrayStringInternalCommunicationReturnValue
        }
    }

    //MARK: - loadUnreadInternalCommunicationsCount

    var loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorCallsCount = 0
    var loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorCalled: Bool {
        return loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorCallsCount > 0
    }
    var loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorReturnValue: AsyncThrowingStream<Int, Swift.Error>!
    var loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorClosure: (() -> AsyncThrowingStream<Int, Swift.Error>)?

    func loadUnreadInternalCommunicationsCount() -> AsyncThrowingStream<Int, Swift.Error> {
        loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorCallsCount += 1
        if let loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorClosure = loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorClosure {
            return loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorClosure()
        } else {
            return loadUnreadInternalCommunicationsCountAsyncThrowingStreamIntSwiftErrorReturnValue
        }
    }


}
public class KeychainAccessHelperMock: KeychainAccessHelper {

    public init() {}



    //MARK: - genericPassword

    public var genericPasswordForAccountDataOfServiceServiceDataDataThrowableError: (any Error)?
    public var genericPasswordForAccountDataOfServiceServiceDataDataCallsCount = 0
    public var genericPasswordForAccountDataOfServiceServiceDataDataCalled: Bool {
        return genericPasswordForAccountDataOfServiceServiceDataDataCallsCount > 0
    }
    public var genericPasswordForAccountDataOfServiceServiceDataDataReceivedArguments: (account: Data, service: Data)?
    public var genericPasswordForAccountDataOfServiceServiceDataDataReceivedInvocations: [(account: Data, service: Data)] = []
    public var genericPasswordForAccountDataOfServiceServiceDataDataReturnValue: Data?
    public var genericPasswordForAccountDataOfServiceServiceDataDataClosure: ((Data, Data) throws -> Data?)?

    public func genericPassword(for account: Data, ofService service: Data) throws -> Data? {
        genericPasswordForAccountDataOfServiceServiceDataDataCallsCount += 1
        genericPasswordForAccountDataOfServiceServiceDataDataReceivedArguments = (account: account, service: service)
        genericPasswordForAccountDataOfServiceServiceDataDataReceivedInvocations.append((account: account, service: service))
        if let error = genericPasswordForAccountDataOfServiceServiceDataDataThrowableError {
            throw error
        }
        if let genericPasswordForAccountDataOfServiceServiceDataDataClosure = genericPasswordForAccountDataOfServiceServiceDataDataClosure {
            return try genericPasswordForAccountDataOfServiceServiceDataDataClosure(account, service)
        } else {
            return genericPasswordForAccountDataOfServiceServiceDataDataReturnValue
        }
    }

    //MARK: - unsetGenericPassword

    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolCallsCount = 0
    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolCalled: Bool {
        return unsetGenericPasswordForAccountDataOfServiceServiceDataBoolCallsCount > 0
    }
    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReceivedArguments: (account: Data, service: Data)?
    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReceivedInvocations: [(account: Data, service: Data)] = []
    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReturnValue: Bool!
    public var unsetGenericPasswordForAccountDataOfServiceServiceDataBoolClosure: ((Data, Data) -> Bool)?

    public func unsetGenericPassword(for account: Data, ofService service: Data) -> Bool {
        unsetGenericPasswordForAccountDataOfServiceServiceDataBoolCallsCount += 1
        unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReceivedArguments = (account: account, service: service)
        unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReceivedInvocations.append((account: account, service: service))
        if let unsetGenericPasswordForAccountDataOfServiceServiceDataBoolClosure = unsetGenericPasswordForAccountDataOfServiceServiceDataBoolClosure {
            return unsetGenericPasswordForAccountDataOfServiceServiceDataBoolClosure(account, service)
        } else {
            return unsetGenericPasswordForAccountDataOfServiceServiceDataBoolReturnValue
        }
    }

    //MARK: - setGenericPassword

    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolThrowableError: (any Error)?
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolCallsCount = 0
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolCalled: Bool {
        return setGenericPasswordPasswordDataForAccountDataServiceDataBoolCallsCount > 0
    }
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolReceivedArguments: (password: Data, account: Data, service: Data)?
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolReceivedInvocations: [(password: Data, account: Data, service: Data)] = []
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolReturnValue: Bool!
    public var setGenericPasswordPasswordDataForAccountDataServiceDataBoolClosure: ((Data, Data, Data) throws -> Bool)?

    public func setGenericPassword(_ password: Data, for account: Data, service: Data) throws -> Bool {
        setGenericPasswordPasswordDataForAccountDataServiceDataBoolCallsCount += 1
        setGenericPasswordPasswordDataForAccountDataServiceDataBoolReceivedArguments = (password: password, account: account, service: service)
        setGenericPasswordPasswordDataForAccountDataServiceDataBoolReceivedInvocations.append((password: password, account: account, service: service))
        if let error = setGenericPasswordPasswordDataForAccountDataServiceDataBoolThrowableError {
            throw error
        }
        if let setGenericPasswordPasswordDataForAccountDataServiceDataBoolClosure = setGenericPasswordPasswordDataForAccountDataServiceDataBoolClosure {
            return try setGenericPasswordPasswordDataForAccountDataServiceDataBoolClosure(password, account, service)
        } else {
            return setGenericPasswordPasswordDataForAccountDataServiceDataBoolReturnValue
        }
    }


}
public class LoginHandlerMock: LoginHandler {

    public init() {}



    //MARK: - isAuthenticated

    public var isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount = 0
    public var isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCalled: Bool {
        return isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount > 0
    }
    public var isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue: AnyPublisher<LoginResult, Never>!
    public var isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverClosure: (() -> AnyPublisher<LoginResult, Never>)?

    public func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount += 1
        if let isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverClosure = isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverClosure {
            return isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverClosure()
        } else {
            return isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue
        }
    }

    //MARK: - isAuthenticatedOrAuthenticate

    public var isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount = 0
    public var isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverCalled: Bool {
        return isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount > 0
    }
    public var isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue: AnyPublisher<LoginResult, Never>!
    public var isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverClosure: (() -> AnyPublisher<LoginResult, Never>)?

    public func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount += 1
        if let isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverClosure = isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverClosure {
            return isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverClosure()
        } else {
            return isAuthenticatedOrAuthenticateAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue
        }
    }


}
public class MatrixCodeGeneratorMock: MatrixCodeGenerator {

    public init() {}



    //MARK: - generateImage

    public var generateImageForContentsStringWidthIntHeightIntCGImageThrowableError: (any Error)?
    public var generateImageForContentsStringWidthIntHeightIntCGImageCallsCount = 0
    public var generateImageForContentsStringWidthIntHeightIntCGImageCalled: Bool {
        return generateImageForContentsStringWidthIntHeightIntCGImageCallsCount > 0
    }
    public var generateImageForContentsStringWidthIntHeightIntCGImageReceivedArguments: (contents: String, width: Int, height: Int)?
    public var generateImageForContentsStringWidthIntHeightIntCGImageReceivedInvocations: [(contents: String, width: Int, height: Int)] = []
    public var generateImageForContentsStringWidthIntHeightIntCGImageReturnValue: CGImage!
    public var generateImageForContentsStringWidthIntHeightIntCGImageClosure: ((String, Int, Int) throws -> CGImage)?

    public func generateImage(for contents: String, width: Int, height: Int) throws -> CGImage {
        generateImageForContentsStringWidthIntHeightIntCGImageCallsCount += 1
        generateImageForContentsStringWidthIntHeightIntCGImageReceivedArguments = (contents: contents, width: width, height: height)
        generateImageForContentsStringWidthIntHeightIntCGImageReceivedInvocations.append((contents: contents, width: width, height: height))
        if let error = generateImageForContentsStringWidthIntHeightIntCGImageThrowableError {
            throw error
        }
        if let generateImageForContentsStringWidthIntHeightIntCGImageClosure = generateImageForContentsStringWidthIntHeightIntCGImageClosure {
            return try generateImageForContentsStringWidthIntHeightIntCGImageClosure(contents, width, height)
        } else {
            return generateImageForContentsStringWidthIntHeightIntCGImageReturnValue
        }
    }


}
public class MedicationScheduleStoreMock: MedicationScheduleStore {

    public init() {}



    //MARK: - fetch

    public var fetchByTaskIDErxTaskIDMedicationScheduleThrowableError: (any Error)?
    public var fetchByTaskIDErxTaskIDMedicationScheduleCallsCount = 0
    public var fetchByTaskIDErxTaskIDMedicationScheduleCalled: Bool {
        return fetchByTaskIDErxTaskIDMedicationScheduleCallsCount > 0
    }
    public var fetchByTaskIDErxTaskIDMedicationScheduleReceivedTaskID: (ErxTask.ID)?
    public var fetchByTaskIDErxTaskIDMedicationScheduleReceivedInvocations: [(ErxTask.ID)] = []
    public var fetchByTaskIDErxTaskIDMedicationScheduleReturnValue: MedicationSchedule?
    public var fetchByTaskIDErxTaskIDMedicationScheduleClosure: ((ErxTask.ID) throws -> MedicationSchedule?)?

    public func fetch(by taskID: ErxTask.ID) throws -> MedicationSchedule? {
        fetchByTaskIDErxTaskIDMedicationScheduleCallsCount += 1
        fetchByTaskIDErxTaskIDMedicationScheduleReceivedTaskID = taskID
        fetchByTaskIDErxTaskIDMedicationScheduleReceivedInvocations.append(taskID)
        if let error = fetchByTaskIDErxTaskIDMedicationScheduleThrowableError {
            throw error
        }
        if let fetchByTaskIDErxTaskIDMedicationScheduleClosure = fetchByTaskIDErxTaskIDMedicationScheduleClosure {
            return try fetchByTaskIDErxTaskIDMedicationScheduleClosure(taskID)
        } else {
            return fetchByTaskIDErxTaskIDMedicationScheduleReturnValue
        }
    }

    //MARK: - fetch

    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseThrowableError: (any Error)?
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseCallsCount = 0
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseCalled: Bool {
        return fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseCallsCount > 0
    }
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReceivedArguments: (entryId: UUID, dateProvider: () -> Date)?
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReceivedInvocations: [(entryId: UUID, dateProvider: () -> Date)] = []
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReturnValue: MedicationScheduleFetchByEntryIdResponse!
    public var fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseClosure: ((UUID, @escaping () -> Date) throws -> MedicationScheduleFetchByEntryIdResponse)?

    public func fetch(byEntryId entryId: UUID, dateProvider: @escaping () -> Date) throws -> MedicationScheduleFetchByEntryIdResponse {
        fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseCallsCount += 1
        fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReceivedArguments = (entryId: entryId, dateProvider: dateProvider)
        fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReceivedInvocations.append((entryId: entryId, dateProvider: dateProvider))
        if let error = fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseThrowableError {
            throw error
        }
        if let fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseClosure = fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseClosure {
            return try fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseClosure(entryId, dateProvider)
        } else {
            return fetchByEntryIdEntryIdUUIDDateProviderEscapingDateMedicationScheduleFetchByEntryIdResponseReturnValue
        }
    }

    //MARK: - fetchAll

    public var fetchAllMedicationScheduleThrowableError: (any Error)?
    public var fetchAllMedicationScheduleCallsCount = 0
    public var fetchAllMedicationScheduleCalled: Bool {
        return fetchAllMedicationScheduleCallsCount > 0
    }
    public var fetchAllMedicationScheduleReturnValue: [MedicationSchedule]!
    public var fetchAllMedicationScheduleClosure: (() throws -> [MedicationSchedule])?

    public func fetchAll() throws -> [MedicationSchedule] {
        fetchAllMedicationScheduleCallsCount += 1
        if let error = fetchAllMedicationScheduleThrowableError {
            throw error
        }
        if let fetchAllMedicationScheduleClosure = fetchAllMedicationScheduleClosure {
            return try fetchAllMedicationScheduleClosure()
        } else {
            return fetchAllMedicationScheduleReturnValue
        }
    }

    //MARK: - save

    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleThrowableError: (any Error)?
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleCallsCount = 0
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleCalled: Bool {
        return saveMedicationSchedulesMedicationScheduleMedicationScheduleCallsCount > 0
    }
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleReceivedMedicationSchedules: ([MedicationSchedule])?
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleReceivedInvocations: [([MedicationSchedule])] = []
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleReturnValue: [MedicationSchedule]!
    public var saveMedicationSchedulesMedicationScheduleMedicationScheduleClosure: (([MedicationSchedule]) throws -> [MedicationSchedule])?

    public func save(medicationSchedules: [MedicationSchedule]) throws -> [MedicationSchedule] {
        saveMedicationSchedulesMedicationScheduleMedicationScheduleCallsCount += 1
        saveMedicationSchedulesMedicationScheduleMedicationScheduleReceivedMedicationSchedules = medicationSchedules
        saveMedicationSchedulesMedicationScheduleMedicationScheduleReceivedInvocations.append(medicationSchedules)
        if let error = saveMedicationSchedulesMedicationScheduleMedicationScheduleThrowableError {
            throw error
        }
        if let saveMedicationSchedulesMedicationScheduleMedicationScheduleClosure = saveMedicationSchedulesMedicationScheduleMedicationScheduleClosure {
            return try saveMedicationSchedulesMedicationScheduleMedicationScheduleClosure(medicationSchedules)
        } else {
            return saveMedicationSchedulesMedicationScheduleMedicationScheduleReturnValue
        }
    }

    //MARK: - delete

    public var deleteMedicationSchedulesMedicationScheduleVoidThrowableError: (any Error)?
    public var deleteMedicationSchedulesMedicationScheduleVoidCallsCount = 0
    public var deleteMedicationSchedulesMedicationScheduleVoidCalled: Bool {
        return deleteMedicationSchedulesMedicationScheduleVoidCallsCount > 0
    }
    public var deleteMedicationSchedulesMedicationScheduleVoidReceivedMedicationSchedules: ([MedicationSchedule])?
    public var deleteMedicationSchedulesMedicationScheduleVoidReceivedInvocations: [([MedicationSchedule])] = []
    public var deleteMedicationSchedulesMedicationScheduleVoidClosure: (([MedicationSchedule]) throws -> Void)?

    public func delete(medicationSchedules: [MedicationSchedule]) throws {
        deleteMedicationSchedulesMedicationScheduleVoidCallsCount += 1
        deleteMedicationSchedulesMedicationScheduleVoidReceivedMedicationSchedules = medicationSchedules
        deleteMedicationSchedulesMedicationScheduleVoidReceivedInvocations.append(medicationSchedules)
        if let error = deleteMedicationSchedulesMedicationScheduleVoidThrowableError {
            throw error
        }
        try deleteMedicationSchedulesMedicationScheduleVoidClosure?(medicationSchedules)
    }


}
public class ModelMigratingMock: ModelMigrating {

    public init() {}



    //MARK: - startModelMigration

    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorCallsCount = 0
    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorCalled: Bool {
        return startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorCallsCount > 0
    }
    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReceivedArguments: (currentVersion: ModelVersion, defaultProfileName: String)?
    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReceivedInvocations: [(currentVersion: ModelVersion, defaultProfileName: String)] = []
    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReturnValue: AnyPublisher<ModelVersion, MigrationError>!
    public var startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorClosure: ((ModelVersion, String) -> AnyPublisher<ModelVersion, MigrationError>)?

    public func startModelMigration(from currentVersion: ModelVersion, defaultProfileName: String) -> AnyPublisher<ModelVersion, MigrationError> {
        startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorCallsCount += 1
        startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReceivedArguments = (currentVersion: currentVersion, defaultProfileName: defaultProfileName)
        startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReceivedInvocations.append((currentVersion: currentVersion, defaultProfileName: defaultProfileName))
        if let startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorClosure = startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorClosure {
            return startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorClosure(currentVersion, defaultProfileName)
        } else {
            return startModelMigrationFromCurrentVersionModelVersionDefaultProfileNameStringAnyPublisherModelVersionMigrationErrorReturnValue
        }
    }


}
class NFCHealthCardPasswordControllerMock: NFCHealthCardPasswordController {




    //MARK: - resetEgkMrPinRetryCounter

    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount = 0
    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCalled: Bool {
        return resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount > 0
    }
    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedArguments: (can: String, puk: String, mode: NFCResetRetryCounterMode)?
    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedInvocations: [(can: String, puk: String, mode: NFCResetRetryCounterMode)] = []
    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReturnValue: Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure: ((String, String, NFCResetRetryCounterMode) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount += 1
        resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedArguments = (can: can, puk: puk, mode: mode)
        resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedInvocations.append((can: can, puk: puk, mode: mode))
        if let resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure = resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure {
            return await resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure(can, puk, mode)
        } else {
            return resetEgkMrPinRetryCounterCanStringPukStringModeNFCResetRetryCounterModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReturnValue
        }
    }

    //MARK: - changeReferenceData

    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount = 0
    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCalled: Bool {
        return changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount > 0
    }
    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedArguments: (can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)?
    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedInvocations: [(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)] = []
    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReturnValue: Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure: ((String, String, String, NFCChangeReferenceDataMode) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorCallsCount += 1
        changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedArguments = (can: can, old: old, new: new, mode: mode)
        changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReceivedInvocations.append((can: can, old: old, new: new, mode: mode))
        if let changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure = changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure {
            return await changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorClosure(can, old, new, mode)
        } else {
            return changeReferenceDataCanStringOldStringNewStringModeNFCChangeReferenceDataModeResultNFCHealthCardPasswordControllerResponseNFCHealthCardPasswordControllerErrorReturnValue
        }
    }


}
class OrdersRepositoryMock: OrdersRepository {




    //MARK: - loadAllOrders

    var loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCallsCount = 0
    var loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCalled: Bool {
        return loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCallsCount > 0
    }
    var loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue: AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>!
    var loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorClosure: (() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error>)?

    func loadAllOrders() -> AsyncThrowingStream<IdentifiedArray<String, Order>, Swift.Error> {
        loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCallsCount += 1
        if let loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorClosure = loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorClosure {
            return loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorClosure()
        } else {
            return loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue
        }
    }

    //MARK: - loadEuOrders

    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorCallsCount = 0
    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorCalled: Bool {
        return loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorCallsCount > 0
    }
    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReceivedProfileId: (UUID)?
    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReceivedInvocations: [(UUID)] = []
    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue: AsyncThrowingStream<IdentifiedArray<String, EuOrder>, Swift.Error>!
    var loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorClosure: ((UUID) -> AsyncThrowingStream<IdentifiedArray<String, EuOrder>, Swift.Error>)?

    func loadEuOrders(profileId: UUID) -> AsyncThrowingStream<IdentifiedArray<String, EuOrder>, Swift.Error> {
        loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorCallsCount += 1
        loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReceivedProfileId = profileId
        loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReceivedInvocations.append(profileId)
        if let loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorClosure = loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorClosure {
            return loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorClosure(profileId)
        } else {
            return loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue
        }
    }


}
public class PagedAuditEventsControllerMock: PagedAuditEventsController {

    public init() {}



    //MARK: - getPageContainer

    public var getPageContainerPageContainerCallsCount = 0
    public var getPageContainerPageContainerCalled: Bool {
        return getPageContainerPageContainerCallsCount > 0
    }
    public var getPageContainerPageContainerReturnValue: PageContainer?
    public var getPageContainerPageContainerClosure: (() -> PageContainer?)?

    public func getPageContainer() -> PageContainer? {
        getPageContainerPageContainerCallsCount += 1
        if let getPageContainerPageContainerClosure = getPageContainerPageContainerClosure {
            return getPageContainerPageContainerClosure()
        } else {
            return getPageContainerPageContainerReturnValue
        }
    }

    //MARK: - getPage

    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorCallsCount = 0
    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorCalled: Bool {
        return getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorCallsCount > 0
    }
    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReceivedPage: (Page)?
    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReceivedInvocations: [(Page)] = []
    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    public var getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorClosure: ((Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    public func getPage(_ page: Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorCallsCount += 1
        getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReceivedPage = page
        getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReceivedInvocations.append(page)
        if let getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorClosure = getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorClosure {
            return getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorClosure(page)
        } else {
            return getPagePagePageAnyPublisherErxAuditEventLocalStoreErrorReturnValue
        }
    }


}
class PasswordStrengthTesterMock: PasswordStrengthTester {




    //MARK: - passwordStrength

    var passwordStrengthForPasswordStringPasswordStrengthCallsCount = 0
    var passwordStrengthForPasswordStringPasswordStrengthCalled: Bool {
        return passwordStrengthForPasswordStringPasswordStrengthCallsCount > 0
    }
    var passwordStrengthForPasswordStringPasswordStrengthReceivedPassword: (String)?
    var passwordStrengthForPasswordStringPasswordStrengthReceivedInvocations: [(String)] = []
    var passwordStrengthForPasswordStringPasswordStrengthReturnValue: PasswordStrength!
    var passwordStrengthForPasswordStringPasswordStrengthClosure: ((String) -> PasswordStrength)?

    func passwordStrength(for password: String) -> PasswordStrength {
        passwordStrengthForPasswordStringPasswordStrengthCallsCount += 1
        passwordStrengthForPasswordStringPasswordStrengthReceivedPassword = password
        passwordStrengthForPasswordStringPasswordStrengthReceivedInvocations.append(password)
        if let passwordStrengthForPasswordStringPasswordStrengthClosure = passwordStrengthForPasswordStringPasswordStrengthClosure {
            return passwordStrengthForPasswordStringPasswordStrengthClosure(password)
        } else {
            return passwordStrengthForPasswordStringPasswordStrengthReturnValue
        }
    }


}
class PrescriptionRepositoryMock: PrescriptionRepository {




    //MARK: - loadLocal

    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorCallsCount = 0
    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorCalled: Bool {
        return loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorCallsCount > 0
    }
    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReceivedProfileId: (UUID)?
    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReceivedInvocations: [(UUID)] = []
    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue: AnyPublisher<[Prescription], PrescriptionRepositoryError>!
    var loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorClosure: ((UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError>)?

    func loadLocal(for profileId: UUID) -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorCallsCount += 1
        loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReceivedProfileId = profileId
        loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReceivedInvocations.append(profileId)
        if let loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorClosure = loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorClosure {
            return loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorClosure(profileId)
        } else {
            return loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue
        }
    }

    //MARK: - forcedLoadRemote

    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount = 0
    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCalled: Bool {
        return forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount > 0
    }
    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedArguments: (locale: String?, profileId: UUID)?
    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedInvocations: [(locale: String?, profileId: UUID)] = []
    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure: ((String?, UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func forcedLoadRemote(for locale: String?, for profileId: UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount += 1
        forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedArguments = (locale: locale, profileId: profileId)
        forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedInvocations.append((locale: locale, profileId: profileId))
        if let forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure = forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure {
            return forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure(locale, profileId)
        } else {
            return forcedLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReturnValue
        }
    }

    //MARK: - silentLoadRemote

    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount = 0
    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCalled: Bool {
        return silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount > 0
    }
    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedArguments: (locale: String?, profileId: UUID)?
    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedInvocations: [(locale: String?, profileId: UUID)] = []
    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure: ((String?, UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func silentLoadRemote(for locale: String?, for profileId: UUID) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorCallsCount += 1
        silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedArguments = (locale: locale, profileId: profileId)
        silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReceivedInvocations.append((locale: locale, profileId: profileId))
        if let silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure = silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure {
            return silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorClosure(locale, profileId)
        } else {
            return silentLoadRemoteForLocaleStringForProfileIdUUIDAnyPublisherPrescriptionRepositoryLoadRemoteResultPrescriptionRepositoryErrorReturnValue
        }
    }


}
public class ProfileDataStoreMock: ProfileDataStore {

    public init() {}



    //MARK: - fetchProfile

    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount = 0
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCalled: Bool {
        return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount > 0
    }
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedIdentifier: (Profile.ID)?
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedInvocations: [(Profile.ID)] = []
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    public func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount += 1
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedIdentifier = identifier
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedInvocations.append(identifier)
        if let fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure = fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure {
            return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure(identifier)
        } else {
            return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllProfiles

    public var listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount = 0
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorCalled: Bool {
        return listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount > 0
    }
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    public func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount += 1
        if let listAllProfilesAnyPublisherProfileLocalStoreErrorClosure = listAllProfilesAnyPublisherProfileLocalStoreErrorClosure {
            return listAllProfilesAnyPublisherProfileLocalStoreErrorClosure()
        } else {
            return listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles: ([Profile])?
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([Profile])] = []
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles = profiles
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(profiles)
        if let saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure = saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure {
            return saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure(profiles)
        } else {
            return saveProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles: ([Profile])?
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([Profile])] = []
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles = profiles
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(profiles)
        if let deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure = deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure {
            return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure(profiles)
        } else {
            return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError>)?

    public func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount += 1
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((profileId: profileId, mutating: mutating))
        if let updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure = updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure(profileId, mutating)
        } else {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }


}
class ProfileOnlineCheckerMock: ProfileOnlineChecker {




    //MARK: - token

    var tokenForProfileProfileAnyPublisherIDPTokenNeverCallsCount = 0
    var tokenForProfileProfileAnyPublisherIDPTokenNeverCalled: Bool {
        return tokenForProfileProfileAnyPublisherIDPTokenNeverCallsCount > 0
    }
    var tokenForProfileProfileAnyPublisherIDPTokenNeverReceivedProfile: (Profile)?
    var tokenForProfileProfileAnyPublisherIDPTokenNeverReceivedInvocations: [(Profile)] = []
    var tokenForProfileProfileAnyPublisherIDPTokenNeverReturnValue: AnyPublisher<IDPToken?, Never>!
    var tokenForProfileProfileAnyPublisherIDPTokenNeverClosure: ((Profile) -> AnyPublisher<IDPToken?, Never>)?

    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        tokenForProfileProfileAnyPublisherIDPTokenNeverCallsCount += 1
        tokenForProfileProfileAnyPublisherIDPTokenNeverReceivedProfile = profile
        tokenForProfileProfileAnyPublisherIDPTokenNeverReceivedInvocations.append(profile)
        if let tokenForProfileProfileAnyPublisherIDPTokenNeverClosure = tokenForProfileProfileAnyPublisherIDPTokenNeverClosure {
            return tokenForProfileProfileAnyPublisherIDPTokenNeverClosure(profile)
        } else {
            return tokenForProfileProfileAnyPublisherIDPTokenNeverReturnValue
        }
    }


}
class ProfileSecureDataWiperMock: ProfileSecureDataWiper {




    //MARK: - wipeSecureData

    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount = 0
    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCalled: Bool {
        return wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount > 0
    }
    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReceivedProfileId: (UUID)?
    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReceivedInvocations: [(UUID)] = []
    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue: AnyPublisher<Void, Never>!
    var wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverClosure: ((UUID) -> AnyPublisher<Void, Never>)?

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverCallsCount += 1
        wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReceivedProfileId = profileId
        wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReceivedInvocations.append(profileId)
        if let wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverClosure = wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverClosure {
            return wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverClosure(profileId)
        } else {
            return wipeSecureDataOfProfileIdUUIDAnyPublisherVoidNeverReturnValue
        }
    }

    //MARK: - logout

    var logoutProfileProfileAnyPublisherVoidNeverCallsCount = 0
    var logoutProfileProfileAnyPublisherVoidNeverCalled: Bool {
        return logoutProfileProfileAnyPublisherVoidNeverCallsCount > 0
    }
    var logoutProfileProfileAnyPublisherVoidNeverReceivedProfile: (Profile)?
    var logoutProfileProfileAnyPublisherVoidNeverReceivedInvocations: [(Profile)] = []
    var logoutProfileProfileAnyPublisherVoidNeverReturnValue: AnyPublisher<Void, Never>!
    var logoutProfileProfileAnyPublisherVoidNeverClosure: ((Profile) -> AnyPublisher<Void, Never>)?

    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        logoutProfileProfileAnyPublisherVoidNeverCallsCount += 1
        logoutProfileProfileAnyPublisherVoidNeverReceivedProfile = profile
        logoutProfileProfileAnyPublisherVoidNeverReceivedInvocations.append(profile)
        if let logoutProfileProfileAnyPublisherVoidNeverClosure = logoutProfileProfileAnyPublisherVoidNeverClosure {
            return logoutProfileProfileAnyPublisherVoidNeverClosure(profile)
        } else {
            return logoutProfileProfileAnyPublisherVoidNeverReturnValue
        }
    }

    //MARK: - secureStorage

    var secureStorageOfProfileIdUUIDSecureUserDataStoreCallsCount = 0
    var secureStorageOfProfileIdUUIDSecureUserDataStoreCalled: Bool {
        return secureStorageOfProfileIdUUIDSecureUserDataStoreCallsCount > 0
    }
    var secureStorageOfProfileIdUUIDSecureUserDataStoreReceivedProfileId: (UUID)?
    var secureStorageOfProfileIdUUIDSecureUserDataStoreReceivedInvocations: [(UUID)] = []
    var secureStorageOfProfileIdUUIDSecureUserDataStoreReturnValue: SecureUserDataStore!
    var secureStorageOfProfileIdUUIDSecureUserDataStoreClosure: ((UUID) -> SecureUserDataStore)?

    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        secureStorageOfProfileIdUUIDSecureUserDataStoreCallsCount += 1
        secureStorageOfProfileIdUUIDSecureUserDataStoreReceivedProfileId = profileId
        secureStorageOfProfileIdUUIDSecureUserDataStoreReceivedInvocations.append(profileId)
        if let secureStorageOfProfileIdUUIDSecureUserDataStoreClosure = secureStorageOfProfileIdUUIDSecureUserDataStoreClosure {
            return secureStorageOfProfileIdUUIDSecureUserDataStoreClosure(profileId)
        } else {
            return secureStorageOfProfileIdUUIDSecureUserDataStoreReturnValue
        }
    }


}
class RedeemServiceMock: RedeemService {




    //MARK: - redeem

    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorCallsCount = 0
    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorCalled: Bool {
        return redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorCallsCount > 0
    }
    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReceivedArguments: (orders: [OrderRequest], profileId: UUID)?
    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReceivedInvocations: [(orders: [OrderRequest], profileId: UUID)] = []
    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReturnValue: AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>!
    var redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorClosure: (([OrderRequest], UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)?

    func redeem(_ orders: [OrderRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorCallsCount += 1
        redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReceivedArguments = (orders: orders, profileId: profileId)
        redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReceivedInvocations.append((orders: orders, profileId: profileId))
        if let redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorClosure = redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorClosure {
            return redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorClosure(orders, profileId)
        } else {
            return redeemOrdersOrderRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderResponseRedeemServiceErrorReturnValue
        }
    }

    //MARK: - redeemDiGa

    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorCallsCount = 0
    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorCalled: Bool {
        return redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorCallsCount > 0
    }
    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReceivedArguments: (orders: [OrderDiGaRequest], profileId: UUID)?
    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReceivedInvocations: [(orders: [OrderDiGaRequest], profileId: UUID)] = []
    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReturnValue: AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>!
    var redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorClosure: (([OrderDiGaRequest], UUID) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>)?

    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> {
        redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorCallsCount += 1
        redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReceivedArguments = (orders: orders, profileId: profileId)
        redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReceivedInvocations.append((orders: orders, profileId: profileId))
        if let redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorClosure = redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorClosure {
            return redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorClosure(orders, profileId)
        } else {
            return redeemDiGaOrdersOrderDiGaRequestProfileIdUUIDAnyPublisherIdentifiedArrayOfOrderDiGaResponseRedeemServiceErrorReturnValue
        }
    }


}
class RegisteredDevicesServiceMock: RegisteredDevicesService {




    //MARK: - registeredDevices

    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorCallsCount = 0
    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorCalled: Bool {
        return registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorCallsCount > 0
    }
    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReceivedProfileId: (UUID)?
    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReceivedInvocations: [(UUID)] = []
    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReturnValue: AnyPublisher<PairingEntries, RegisteredDevicesServiceError>!
    var registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorClosure: ((UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError>)?

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorCallsCount += 1
        registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReceivedProfileId = profileId
        registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReceivedInvocations.append(profileId)
        if let registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorClosure = registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorClosure {
            return registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorClosure(profileId)
        } else {
            return registeredDevicesForProfileIdUUIDAnyPublisherPairingEntriesRegisteredDevicesServiceErrorReturnValue
        }
    }

    //MARK: - deviceId

    var deviceIdForProfileIdUUIDAnyPublisherStringNeverCallsCount = 0
    var deviceIdForProfileIdUUIDAnyPublisherStringNeverCalled: Bool {
        return deviceIdForProfileIdUUIDAnyPublisherStringNeverCallsCount > 0
    }
    var deviceIdForProfileIdUUIDAnyPublisherStringNeverReceivedProfileId: (UUID)?
    var deviceIdForProfileIdUUIDAnyPublisherStringNeverReceivedInvocations: [(UUID)] = []
    var deviceIdForProfileIdUUIDAnyPublisherStringNeverReturnValue: AnyPublisher<String?, Never>!
    var deviceIdForProfileIdUUIDAnyPublisherStringNeverClosure: ((UUID) -> AnyPublisher<String?, Never>)?

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        deviceIdForProfileIdUUIDAnyPublisherStringNeverCallsCount += 1
        deviceIdForProfileIdUUIDAnyPublisherStringNeverReceivedProfileId = profileId
        deviceIdForProfileIdUUIDAnyPublisherStringNeverReceivedInvocations.append(profileId)
        if let deviceIdForProfileIdUUIDAnyPublisherStringNeverClosure = deviceIdForProfileIdUUIDAnyPublisherStringNeverClosure {
            return deviceIdForProfileIdUUIDAnyPublisherStringNeverClosure(profileId)
        } else {
            return deviceIdForProfileIdUUIDAnyPublisherStringNeverReturnValue
        }
    }

    //MARK: - deleteDevice

    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorCallsCount = 0
    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorCalled: Bool {
        return deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorCallsCount > 0
    }
    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReceivedArguments: (device: String, profileId: UUID)?
    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReceivedInvocations: [(device: String, profileId: UUID)] = []
    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReturnValue: AnyPublisher<Bool, RegisteredDevicesServiceError>!
    var deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorClosure: ((String, UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError>)?

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorCallsCount += 1
        deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReceivedArguments = (device: device, profileId: profileId)
        deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReceivedInvocations.append((device: device, profileId: profileId))
        if let deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorClosure = deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorClosure {
            return deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorClosure(device, profileId)
        } else {
            return deleteDeviceDeviceStringOfProfileIdUUIDAnyPublisherBoolRegisteredDevicesServiceErrorReturnValue
        }
    }

    //MARK: - cardWall

    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverCallsCount = 0
    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverCalled: Bool {
        return cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverCallsCount > 0
    }
    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReceivedProfileId: (UUID)?
    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReceivedInvocations: [(UUID)] = []
    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReturnValue: AnyPublisher<CardWallCANDomain.State, Never>!
    var cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverClosure: ((UUID) -> AnyPublisher<CardWallCANDomain.State, Never>)?

    func cardWall(for profileId: UUID) -> AnyPublisher<CardWallCANDomain.State, Never> {
        cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverCallsCount += 1
        cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReceivedProfileId = profileId
        cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReceivedInvocations.append(profileId)
        if let cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverClosure = cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverClosure {
            return cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverClosure(profileId)
        } else {
            return cardWallForProfileIdUUIDAnyPublisherCardWallCANDomainStateNeverReturnValue
        }
    }


}
public class RoutingMock: Routing {

    public init() {}



    //MARK: - routeTo

    public var routeToEndpointEndpointVoidCallsCount = 0
    public var routeToEndpointEndpointVoidCalled: Bool {
        return routeToEndpointEndpointVoidCallsCount > 0
    }
    public var routeToEndpointEndpointVoidReceivedEndpoint: (Endpoint)?
    public var routeToEndpointEndpointVoidReceivedInvocations: [(Endpoint)] = []
    public var routeToEndpointEndpointVoidClosure: ((Endpoint) async -> Void)?

    public func routeTo(_ endpoint: Endpoint) async {
        routeToEndpointEndpointVoidCallsCount += 1
        routeToEndpointEndpointVoidReceivedEndpoint = endpoint
        routeToEndpointEndpointVoidReceivedInvocations.append(endpoint)
        await routeToEndpointEndpointVoidClosure?(endpoint)
    }


}
class SearchHistoryMock: SearchHistory {




    //MARK: - addHistoryItem

    var addHistoryItemItemStringVoidCallsCount = 0
    var addHistoryItemItemStringVoidCalled: Bool {
        return addHistoryItemItemStringVoidCallsCount > 0
    }
    var addHistoryItemItemStringVoidReceivedItem: (String)?
    var addHistoryItemItemStringVoidReceivedInvocations: [(String)] = []
    var addHistoryItemItemStringVoidClosure: ((String) -> Void)?

    func addHistoryItem(_ item: String) {
        addHistoryItemItemStringVoidCallsCount += 1
        addHistoryItemItemStringVoidReceivedItem = item
        addHistoryItemItemStringVoidReceivedInvocations.append(item)
        addHistoryItemItemStringVoidClosure?(item)
    }

    //MARK: - historyItems

    var historyItemsStringCallsCount = 0
    var historyItemsStringCalled: Bool {
        return historyItemsStringCallsCount > 0
    }
    var historyItemsStringReturnValue: [String]!
    var historyItemsStringClosure: (() -> [String])?

    func historyItems() -> [String] {
        historyItemsStringCallsCount += 1
        if let historyItemsStringClosure = historyItemsStringClosure {
            return historyItemsStringClosure()
        } else {
            return historyItemsStringReturnValue
        }
    }


}
public class SecureEnclaveSignatureProviderMock: SecureEnclaveSignatureProvider {

    public init() {}

    public var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        get { return underlyingIsBiometrieRegistered }
        set(value) { underlyingIsBiometrieRegistered = value }
    }
    public var underlyingIsBiometrieRegistered: (AnyPublisher<Bool, Never>)!


    //MARK: - createPairingSession

    public var createPairingSessionPairingSessionThrowableError: (any Error)?
    public var createPairingSessionPairingSessionCallsCount = 0
    public var createPairingSessionPairingSessionCalled: Bool {
        return createPairingSessionPairingSessionCallsCount > 0
    }
    public var createPairingSessionPairingSessionReturnValue: PairingSession!
    public var createPairingSessionPairingSessionClosure: (() throws -> PairingSession)?

    public func createPairingSession() throws -> PairingSession {
        createPairingSessionPairingSessionCallsCount += 1
        if let error = createPairingSessionPairingSessionThrowableError {
            throw error
        }
        if let createPairingSessionPairingSessionClosure = createPairingSessionPairingSessionClosure {
            return try createPairingSessionPairingSessionClosure()
        } else {
            return createPairingSessionPairingSessionReturnValue
        }
    }

    //MARK: - signPairingSession

    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorCallsCount = 0
    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorCalled: Bool {
        return signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorCallsCount > 0
    }
    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReceivedArguments: (pairingSession: PairingSession, signer: JWTSigner, certificate: IDPX509)?
    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReceivedInvocations: [(pairingSession: PairingSession, signer: JWTSigner, certificate: IDPX509)] = []
    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReturnValue: AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>!
    public var signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorClosure: ((PairingSession, JWTSigner, IDPX509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>)?

    public func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: IDPX509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorCallsCount += 1
        signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReceivedArguments = (pairingSession: pairingSession, signer: signer, certificate: certificate)
        signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReceivedInvocations.append((pairingSession: pairingSession, signer: signer, certificate: certificate))
        if let signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorClosure = signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorClosure {
            return signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorClosure(pairingSession, signer, certificate)
        } else {
            return signPairingSessionPairingSessionPairingSessionWithSignerJWTSignerCertificateIDPX509AnyPublisherRegistrationDataSecureEnclaveSignatureProviderErrorReturnValue
        }
    }

    //MARK: - abort

    public var abortPairingSessionPairingSessionVoidThrowableError: (any Error)?
    public var abortPairingSessionPairingSessionVoidCallsCount = 0
    public var abortPairingSessionPairingSessionVoidCalled: Bool {
        return abortPairingSessionPairingSessionVoidCallsCount > 0
    }
    public var abortPairingSessionPairingSessionVoidReceivedPairingSession: (PairingSession)?
    public var abortPairingSessionPairingSessionVoidReceivedInvocations: [(PairingSession)] = []
    public var abortPairingSessionPairingSessionVoidClosure: ((PairingSession) throws -> Void)?

    public func abort(pairingSession: PairingSession) throws {
        abortPairingSessionPairingSessionVoidCallsCount += 1
        abortPairingSessionPairingSessionVoidReceivedPairingSession = pairingSession
        abortPairingSessionPairingSessionVoidReceivedInvocations.append(pairingSession)
        if let error = abortPairingSessionPairingSessionVoidThrowableError {
            throw error
        }
        try abortPairingSessionPairingSessionVoidClosure?(pairingSession)
    }

    //MARK: - authenticationData

    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorCallsCount = 0
    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorCalled: Bool {
        return authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorCallsCount > 0
    }
    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReceivedChallenge: (IDPChallengeSession)?
    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReceivedInvocations: [(IDPChallengeSession)] = []
    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReturnValue: AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>!
    public var authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorClosure: ((IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>)?

    public func authenticationData(for challenge: IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorCallsCount += 1
        authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReceivedChallenge = challenge
        authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReceivedInvocations.append(challenge)
        if let authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorClosure = authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorClosure {
            return authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorClosure(challenge)
        } else {
            return authenticationDataForChallengeIDPChallengeSessionAnyPublisherSignedAuthenticationDataSecureEnclaveSignatureProviderErrorReturnValue
        }
    }


}
public class SecureUserDataStoreMock: SecureUserDataStore {

    public init() {}

    public var can: AnyPublisher<String?, Never> {
        get { return underlyingCan }
        set(value) { underlyingCan = value }
    }
    public var underlyingCan: (AnyPublisher<String?, Never>)!
    public var token: AnyPublisher<IDPToken?, Never> {
        get { return underlyingToken }
        set(value) { underlyingToken = value }
    }
    public var underlyingToken: (AnyPublisher<IDPToken?, Never>)!
    public var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        get { return underlyingDiscoveryDocument }
        set(value) { underlyingDiscoveryDocument = value }
    }
    public var underlyingDiscoveryDocument: (AnyPublisher<DiscoveryDocument?, Never>)!
    public var certificate: AnyPublisher<IDPX509?, Never> {
        get { return underlyingCertificate }
        set(value) { underlyingCertificate = value }
    }
    public var underlyingCertificate: (AnyPublisher<IDPX509?, Never>)!
    public var keyIdentifier: AnyPublisher<Data?, Never> {
        get { return underlyingKeyIdentifier }
        set(value) { underlyingKeyIdentifier = value }
    }
    public var underlyingKeyIdentifier: (AnyPublisher<Data?, Never>)!


    //MARK: - set

    public var setCanStringVoidCallsCount = 0
    public var setCanStringVoidCalled: Bool {
        return setCanStringVoidCallsCount > 0
    }
    public var setCanStringVoidReceivedCan: (String)?
    public var setCanStringVoidReceivedInvocations: [(String)?] = []
    public var setCanStringVoidClosure: ((String?) -> Void)?

    public func set(can: String?) {
        setCanStringVoidCallsCount += 1
        setCanStringVoidReceivedCan = can
        setCanStringVoidReceivedInvocations.append(can)
        setCanStringVoidClosure?(can)
    }

    //MARK: - wipe

    public var wipeVoidCallsCount = 0
    public var wipeVoidCalled: Bool {
        return wipeVoidCallsCount > 0
    }
    public var wipeVoidClosure: (() -> Void)?

    public func wipe() {
        wipeVoidCallsCount += 1
        wipeVoidClosure?()
    }

    //MARK: - set

    public var setTokenIDPTokenVoidCallsCount = 0
    public var setTokenIDPTokenVoidCalled: Bool {
        return setTokenIDPTokenVoidCallsCount > 0
    }
    public var setTokenIDPTokenVoidReceivedToken: (IDPToken)?
    public var setTokenIDPTokenVoidReceivedInvocations: [(IDPToken)?] = []
    public var setTokenIDPTokenVoidClosure: ((IDPToken?) -> Void)?

    public func set(token: IDPToken?) {
        setTokenIDPTokenVoidCallsCount += 1
        setTokenIDPTokenVoidReceivedToken = token
        setTokenIDPTokenVoidReceivedInvocations.append(token)
        setTokenIDPTokenVoidClosure?(token)
    }

    //MARK: - set

    public var setDiscoveryDocumentDiscoveryDocumentVoidCallsCount = 0
    public var setDiscoveryDocumentDiscoveryDocumentVoidCalled: Bool {
        return setDiscoveryDocumentDiscoveryDocumentVoidCallsCount > 0
    }
    public var setDiscoveryDocumentDiscoveryDocumentVoidReceivedDocument: (DiscoveryDocument)?
    public var setDiscoveryDocumentDiscoveryDocumentVoidReceivedInvocations: [(DiscoveryDocument)?] = []
    public var setDiscoveryDocumentDiscoveryDocumentVoidClosure: ((DiscoveryDocument?) -> Void)?

    public func set(discovery document: DiscoveryDocument?) {
        setDiscoveryDocumentDiscoveryDocumentVoidCallsCount += 1
        setDiscoveryDocumentDiscoveryDocumentVoidReceivedDocument = document
        setDiscoveryDocumentDiscoveryDocumentVoidReceivedInvocations.append(document)
        setDiscoveryDocumentDiscoveryDocumentVoidClosure?(document)
    }

    //MARK: - set

    public var setCertificateIDPX509VoidCallsCount = 0
    public var setCertificateIDPX509VoidCalled: Bool {
        return setCertificateIDPX509VoidCallsCount > 0
    }
    public var setCertificateIDPX509VoidReceivedCertificate: (IDPX509)?
    public var setCertificateIDPX509VoidReceivedInvocations: [(IDPX509)?] = []
    public var setCertificateIDPX509VoidClosure: ((IDPX509?) -> Void)?

    public func set(certificate: IDPX509?) {
        setCertificateIDPX509VoidCallsCount += 1
        setCertificateIDPX509VoidReceivedCertificate = certificate
        setCertificateIDPX509VoidReceivedInvocations.append(certificate)
        setCertificateIDPX509VoidClosure?(certificate)
    }

    //MARK: - set

    public var setKeyIdentifierDataVoidCallsCount = 0
    public var setKeyIdentifierDataVoidCalled: Bool {
        return setKeyIdentifierDataVoidCallsCount > 0
    }
    public var setKeyIdentifierDataVoidReceivedKeyIdentifier: (Data)?
    public var setKeyIdentifierDataVoidReceivedInvocations: [(Data)?] = []
    public var setKeyIdentifierDataVoidClosure: ((Data?) -> Void)?

    public func set(keyIdentifier: Data?) {
        setKeyIdentifierDataVoidCallsCount += 1
        setKeyIdentifierDataVoidReceivedKeyIdentifier = keyIdentifier
        setKeyIdentifierDataVoidReceivedInvocations.append(keyIdentifier)
        setKeyIdentifierDataVoidClosure?(keyIdentifier)
    }


}
public class ShipmentInfoDataStoreMock: ShipmentInfoDataStore {

    public init() {}

    public var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        get { return underlyingSelectedShipmentInfo }
        set(value) { underlyingSelectedShipmentInfo = value }
    }
    public var underlyingSelectedShipmentInfo: (AnyPublisher<ShipmentInfo?, LocalStoreError>)!


    //MARK: - set

    public var setSelectedShipmentInfoIdUUIDVoidCallsCount = 0
    public var setSelectedShipmentInfoIdUUIDVoidCalled: Bool {
        return setSelectedShipmentInfoIdUUIDVoidCallsCount > 0
    }
    public var setSelectedShipmentInfoIdUUIDVoidReceivedSelectedShipmentInfoId: (UUID)?
    public var setSelectedShipmentInfoIdUUIDVoidReceivedInvocations: [(UUID)] = []
    public var setSelectedShipmentInfoIdUUIDVoidClosure: ((UUID) -> Void)?

    public func set(selectedShipmentInfoId: UUID) {
        setSelectedShipmentInfoIdUUIDVoidCallsCount += 1
        setSelectedShipmentInfoIdUUIDVoidReceivedSelectedShipmentInfoId = selectedShipmentInfoId
        setSelectedShipmentInfoIdUUIDVoidReceivedInvocations.append(selectedShipmentInfoId)
        setSelectedShipmentInfoIdUUIDVoidClosure?(selectedShipmentInfoId)
    }

    //MARK: - fetchShipmentInfo

    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorCallsCount = 0
    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorCalled: Bool {
        return fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorCallsCount > 0
    }
    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReceivedIdentifier: (UUID)?
    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations: [(UUID)] = []
    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReturnValue: AnyPublisher<ShipmentInfo?, LocalStoreError>!
    public var fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorClosure: ((UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError>)?

    public func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorCallsCount += 1
        fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReceivedIdentifier = identifier
        fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations.append(identifier)
        if let fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorClosure = fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorClosure {
            return fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorClosure(identifier)
        } else {
            return fetchShipmentInfoByIdentifierUUIDAnyPublisherShipmentInfoLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllShipmentInfos

    public var listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorCallsCount = 0
    public var listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorCalled: Bool {
        return listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorCallsCount > 0
    }
    public var listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    public var listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorClosure: (() -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    public func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorCallsCount += 1
        if let listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorClosure = listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorClosure {
            return listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorClosure()
        } else {
            return listAllShipmentInfosAnyPublisherShipmentInfoLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount = 0
    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCalled: Bool {
        return saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount > 0
    }
    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedShipmentInfos: ([ShipmentInfo])?
    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations: [([ShipmentInfo])] = []
    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    public var saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    public func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount += 1
        saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedShipmentInfos = shipmentInfos
        saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations.append(shipmentInfos)
        if let saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure = saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure {
            return saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure(shipmentInfos)
        } else {
            return saveShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount = 0
    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCalled: Bool {
        return deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount > 0
    }
    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedShipmentInfos: ([ShipmentInfo])?
    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations: [([ShipmentInfo])] = []
    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    public var deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    public func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorCallsCount += 1
        deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedShipmentInfos = shipmentInfos
        deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations.append(shipmentInfos)
        if let deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure = deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure {
            return deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorClosure(shipmentInfos)
        } else {
            return deleteShipmentInfosShipmentInfoAnyPublisherShipmentInfoLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorCallsCount = 0
    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorCalled: Bool {
        return updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorCallsCount > 0
    }
    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReceivedArguments: (identifier: UUID, mutating: (inout ShipmentInfo) -> Void)?
    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations: [(identifier: UUID, mutating: (inout ShipmentInfo) -> Void)] = []
    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReturnValue: AnyPublisher<ShipmentInfo, LocalStoreError>!
    public var updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorClosure: ((UUID, @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError>)?

    public func update(identifier: UUID, mutating: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorCallsCount += 1
        updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReceivedArguments = (identifier: identifier, mutating: mutating)
        updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReceivedInvocations.append((identifier: identifier, mutating: mutating))
        if let updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorClosure = updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorClosure {
            return updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorClosure(identifier, mutating)
        } else {
            return updateIdentifierUUIDMutatingEscapingInoutShipmentInfoVoidAnyPublisherShipmentInfoLocalStoreErrorReturnValue
        }
    }


}
public class UserDataStoreMock: UserDataStore {

    public init() {}

    public var hideOnboarding: AnyPublisher<Bool, Never> {
        get { return underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    public var underlyingHideOnboarding: (AnyPublisher<Bool, Never>)!
    public var isOnboardingHidden: Bool {
        get { return underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    public var underlyingIsOnboardingHidden: (Bool)!
    public var onboardingDate: AnyPublisher<Date?, Never> {
        get { return underlyingOnboardingDate }
        set(value) { underlyingOnboardingDate = value }
    }
    public var underlyingOnboardingDate: (AnyPublisher<Date?, Never>)!
    public var onboardingVersion: AnyPublisher<String?, Never> {
        get { return underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    public var underlyingOnboardingVersion: (AnyPublisher<String?, Never>)!
    public var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { return underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    public var underlyingHideCardWallIntro: (AnyPublisher<Bool, Never>)!
    public var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { return underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    public var underlyingServerEnvironmentConfiguration: (AnyPublisher<String?, Never>)!
    public var serverEnvironmentName: String?
    public var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { return underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    public var underlyingAppSecurityOption: (AnyPublisher<AppSecurityOption, Never>)!
    public var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { return underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    public var underlyingFailedAppAuthentications: (AnyPublisher<Int, Never>)!
    public var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    public var underlyingIgnoreDeviceNotSecuredWarningPermanently: (AnyPublisher<Bool, Never>)!
    public var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    public var underlyingSelectedProfileId: (AnyPublisher<UUID?, Never>)!
    public var latestCompatibleModelVersion: ModelVersion {
        get { return underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    public var underlyingLatestCompatibleModelVersion: (ModelVersion)!
    public var appStartCounter: Int {
        get { return underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    public var underlyingAppStartCounter: (Int)!
    public var readInternalCommunications: AnyPublisher<[String], Never> {
        get { return underlyingReadInternalCommunications }
        set(value) { underlyingReadInternalCommunications = value }
    }
    public var underlyingReadInternalCommunications: (AnyPublisher<[String], Never>)!
    public var hideWelcomeMessage: AnyPublisher<Bool, Never> {
        get { return underlyingHideWelcomeMessage }
        set(value) { underlyingHideWelcomeMessage = value }
    }
    public var underlyingHideWelcomeMessage: (AnyPublisher<Bool, Never>)!
    public var hideEURedeemInstructions: AnyPublisher<Bool, Never> {
        get { return underlyingHideEURedeemInstructions }
        set(value) { underlyingHideEURedeemInstructions = value }
    }
    public var underlyingHideEURedeemInstructions: (AnyPublisher<Bool, Never>)!


    //MARK: - set

    public var setOnboardingDateDateVoidCallsCount = 0
    public var setOnboardingDateDateVoidCalled: Bool {
        return setOnboardingDateDateVoidCallsCount > 0
    }
    public var setOnboardingDateDateVoidReceivedOnboardingDate: (Date)?
    public var setOnboardingDateDateVoidReceivedInvocations: [(Date)?] = []
    public var setOnboardingDateDateVoidClosure: ((Date?) -> Void)?

    public func set(onboardingDate: Date?) {
        setOnboardingDateDateVoidCallsCount += 1
        setOnboardingDateDateVoidReceivedOnboardingDate = onboardingDate
        setOnboardingDateDateVoidReceivedInvocations.append(onboardingDate)
        setOnboardingDateDateVoidClosure?(onboardingDate)
    }

    //MARK: - set

    public var setHideOnboardingBoolVoidCallsCount = 0
    public var setHideOnboardingBoolVoidCalled: Bool {
        return setHideOnboardingBoolVoidCallsCount > 0
    }
    public var setHideOnboardingBoolVoidReceivedHideOnboarding: (Bool)?
    public var setHideOnboardingBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideOnboardingBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideOnboarding: Bool) {
        setHideOnboardingBoolVoidCallsCount += 1
        setHideOnboardingBoolVoidReceivedHideOnboarding = hideOnboarding
        setHideOnboardingBoolVoidReceivedInvocations.append(hideOnboarding)
        setHideOnboardingBoolVoidClosure?(hideOnboarding)
    }

    //MARK: - set

    public var setOnboardingVersionStringVoidCallsCount = 0
    public var setOnboardingVersionStringVoidCalled: Bool {
        return setOnboardingVersionStringVoidCallsCount > 0
    }
    public var setOnboardingVersionStringVoidReceivedOnboardingVersion: (String)?
    public var setOnboardingVersionStringVoidReceivedInvocations: [(String)?] = []
    public var setOnboardingVersionStringVoidClosure: ((String?) -> Void)?

    public func set(onboardingVersion: String?) {
        setOnboardingVersionStringVoidCallsCount += 1
        setOnboardingVersionStringVoidReceivedOnboardingVersion = onboardingVersion
        setOnboardingVersionStringVoidReceivedInvocations.append(onboardingVersion)
        setOnboardingVersionStringVoidClosure?(onboardingVersion)
    }

    //MARK: - set

    public var setHideCardWallIntroBoolVoidCallsCount = 0
    public var setHideCardWallIntroBoolVoidCalled: Bool {
        return setHideCardWallIntroBoolVoidCallsCount > 0
    }
    public var setHideCardWallIntroBoolVoidReceivedHideCardWallIntro: (Bool)?
    public var setHideCardWallIntroBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideCardWallIntroBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideCardWallIntro: Bool) {
        setHideCardWallIntroBoolVoidCallsCount += 1
        setHideCardWallIntroBoolVoidReceivedHideCardWallIntro = hideCardWallIntro
        setHideCardWallIntroBoolVoidReceivedInvocations.append(hideCardWallIntro)
        setHideCardWallIntroBoolVoidClosure?(hideCardWallIntro)
    }

    //MARK: - set

    public var setServerEnvironmentConfigurationStringVoidCallsCount = 0
    public var setServerEnvironmentConfigurationStringVoidCalled: Bool {
        return setServerEnvironmentConfigurationStringVoidCallsCount > 0
    }
    public var setServerEnvironmentConfigurationStringVoidReceivedServerEnvironmentConfiguration: (String)?
    public var setServerEnvironmentConfigurationStringVoidReceivedInvocations: [(String)?] = []
    public var setServerEnvironmentConfigurationStringVoidClosure: ((String?) -> Void)?

    public func set(serverEnvironmentConfiguration: String?) {
        setServerEnvironmentConfigurationStringVoidCallsCount += 1
        setServerEnvironmentConfigurationStringVoidReceivedServerEnvironmentConfiguration = serverEnvironmentConfiguration
        setServerEnvironmentConfigurationStringVoidReceivedInvocations.append(serverEnvironmentConfiguration)
        setServerEnvironmentConfigurationStringVoidClosure?(serverEnvironmentConfiguration)
    }

    //MARK: - set

    public var setAppSecurityOptionAppSecurityOptionVoidCallsCount = 0
    public var setAppSecurityOptionAppSecurityOptionVoidCalled: Bool {
        return setAppSecurityOptionAppSecurityOptionVoidCallsCount > 0
    }
    public var setAppSecurityOptionAppSecurityOptionVoidReceivedAppSecurityOption: (AppSecurityOption)?
    public var setAppSecurityOptionAppSecurityOptionVoidReceivedInvocations: [(AppSecurityOption)] = []
    public var setAppSecurityOptionAppSecurityOptionVoidClosure: ((AppSecurityOption) -> Void)?

    public func set(appSecurityOption: AppSecurityOption) {
        setAppSecurityOptionAppSecurityOptionVoidCallsCount += 1
        setAppSecurityOptionAppSecurityOptionVoidReceivedAppSecurityOption = appSecurityOption
        setAppSecurityOptionAppSecurityOptionVoidReceivedInvocations.append(appSecurityOption)
        setAppSecurityOptionAppSecurityOptionVoidClosure?(appSecurityOption)
    }

    //MARK: - set

    public var setFailedAppAuthenticationsIntVoidCallsCount = 0
    public var setFailedAppAuthenticationsIntVoidCalled: Bool {
        return setFailedAppAuthenticationsIntVoidCallsCount > 0
    }
    public var setFailedAppAuthenticationsIntVoidReceivedFailedAppAuthentications: (Int)?
    public var setFailedAppAuthenticationsIntVoidReceivedInvocations: [(Int)] = []
    public var setFailedAppAuthenticationsIntVoidClosure: ((Int) -> Void)?

    public func set(failedAppAuthentications: Int) {
        setFailedAppAuthenticationsIntVoidCallsCount += 1
        setFailedAppAuthenticationsIntVoidReceivedFailedAppAuthentications = failedAppAuthentications
        setFailedAppAuthenticationsIntVoidReceivedInvocations.append(failedAppAuthentications)
        setFailedAppAuthenticationsIntVoidClosure?(failedAppAuthentications)
    }

    //MARK: - set

    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount = 0
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount > 0
    }
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedIgnoreDeviceNotSecuredWarningPermanently: (Bool)?
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedInvocations: [(Bool)] = []
    public var setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidClosure: ((Bool) -> Void)?

    public func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidCallsCount += 1
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedIgnoreDeviceNotSecuredWarningPermanently = ignoreDeviceNotSecuredWarningPermanently
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidReceivedInvocations.append(ignoreDeviceNotSecuredWarningPermanently)
        setIgnoreDeviceNotSecuredWarningPermanentlyBoolVoidClosure?(ignoreDeviceNotSecuredWarningPermanently)
    }

    //MARK: - set

    public var setSelectedProfileIdUUIDVoidCallsCount = 0
    public var setSelectedProfileIdUUIDVoidCalled: Bool {
        return setSelectedProfileIdUUIDVoidCallsCount > 0
    }
    public var setSelectedProfileIdUUIDVoidReceivedSelectedProfileId: (UUID)?
    public var setSelectedProfileIdUUIDVoidReceivedInvocations: [(UUID)] = []
    public var setSelectedProfileIdUUIDVoidClosure: ((UUID) -> Void)?

    public func set(selectedProfileId: UUID) {
        setSelectedProfileIdUUIDVoidCallsCount += 1
        setSelectedProfileIdUUIDVoidReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdUUIDVoidReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdUUIDVoidClosure?(selectedProfileId)
    }

    //MARK: - wipeAll

    public var wipeAllVoidCallsCount = 0
    public var wipeAllVoidCalled: Bool {
        return wipeAllVoidCallsCount > 0
    }
    public var wipeAllVoidClosure: (() -> Void)?

    public func wipeAll() {
        wipeAllVoidCallsCount += 1
        wipeAllVoidClosure?()
    }

    //MARK: - markInternalCommunicationAsRead

    public var markInternalCommunicationAsReadMessageIdStringVoidCallsCount = 0
    public var markInternalCommunicationAsReadMessageIdStringVoidCalled: Bool {
        return markInternalCommunicationAsReadMessageIdStringVoidCallsCount > 0
    }
    public var markInternalCommunicationAsReadMessageIdStringVoidReceivedMessageId: (String)?
    public var markInternalCommunicationAsReadMessageIdStringVoidReceivedInvocations: [(String)] = []
    public var markInternalCommunicationAsReadMessageIdStringVoidClosure: ((String) -> Void)?

    public func markInternalCommunicationAsRead(messageId: String) {
        markInternalCommunicationAsReadMessageIdStringVoidCallsCount += 1
        markInternalCommunicationAsReadMessageIdStringVoidReceivedMessageId = messageId
        markInternalCommunicationAsReadMessageIdStringVoidReceivedInvocations.append(messageId)
        markInternalCommunicationAsReadMessageIdStringVoidClosure?(messageId)
    }

    //MARK: - set

    public var setHideWelcomeMessageBoolVoidCallsCount = 0
    public var setHideWelcomeMessageBoolVoidCalled: Bool {
        return setHideWelcomeMessageBoolVoidCallsCount > 0
    }
    public var setHideWelcomeMessageBoolVoidReceivedHideWelcomeMessage: (Bool)?
    public var setHideWelcomeMessageBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideWelcomeMessageBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideWelcomeMessage: Bool) {
        setHideWelcomeMessageBoolVoidCallsCount += 1
        setHideWelcomeMessageBoolVoidReceivedHideWelcomeMessage = hideWelcomeMessage
        setHideWelcomeMessageBoolVoidReceivedInvocations.append(hideWelcomeMessage)
        setHideWelcomeMessageBoolVoidClosure?(hideWelcomeMessage)
    }

    //MARK: - set

    public var setHideEURedeemInstructionsBoolVoidCallsCount = 0
    public var setHideEURedeemInstructionsBoolVoidCalled: Bool {
        return setHideEURedeemInstructionsBoolVoidCallsCount > 0
    }
    public var setHideEURedeemInstructionsBoolVoidReceivedHideEURedeemInstructions: (Bool)?
    public var setHideEURedeemInstructionsBoolVoidReceivedInvocations: [(Bool)] = []
    public var setHideEURedeemInstructionsBoolVoidClosure: ((Bool) -> Void)?

    public func set(hideEURedeemInstructions: Bool) {
        setHideEURedeemInstructionsBoolVoidCallsCount += 1
        setHideEURedeemInstructionsBoolVoidReceivedHideEURedeemInstructions = hideEURedeemInstructions
        setHideEURedeemInstructionsBoolVoidReceivedInvocations.append(hideEURedeemInstructions)
        setHideEURedeemInstructionsBoolVoidClosure?(hideEURedeemInstructions)
    }


}
class UserProfileServiceMock: UserProfileService {


    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: (AnyPublisher<UUID?, Never>)!


    //MARK: - set

    var setSelectedProfileIdUUIDVoidCallsCount = 0
    var setSelectedProfileIdUUIDVoidCalled: Bool {
        return setSelectedProfileIdUUIDVoidCallsCount > 0
    }
    var setSelectedProfileIdUUIDVoidReceivedSelectedProfileId: (UUID)?
    var setSelectedProfileIdUUIDVoidReceivedInvocations: [(UUID)] = []
    var setSelectedProfileIdUUIDVoidClosure: ((UUID) -> Void)?

    func set(selectedProfileId: UUID) {
        setSelectedProfileIdUUIDVoidCallsCount += 1
        setSelectedProfileIdUUIDVoidReceivedSelectedProfileId = selectedProfileId
        setSelectedProfileIdUUIDVoidReceivedInvocations.append(selectedProfileId)
        setSelectedProfileIdUUIDVoidClosure?(selectedProfileId)
    }

    //MARK: - userProfilesPublisher

    var userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount = 0
    var userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorCalled: Bool {
        return userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount > 0
    }
    var userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorReturnValue: AnyPublisher<[UserProfile], UserProfileServiceError>!
    var userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorClosure: (() -> AnyPublisher<[UserProfile], UserProfileServiceError>)?

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount += 1
        if let userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorClosure = userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorClosure {
            return userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorClosure()
        } else {
            return userProfilesPublisherAnyPublisherUserProfileUserProfileServiceErrorReturnValue
        }
    }

    //MARK: - activeUserProfilePublisher

    var activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount = 0
    var activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorCalled: Bool {
        return activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount > 0
    }
    var activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorReturnValue: AnyPublisher<UserProfile, UserProfileServiceError>!
    var activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorClosure: (() -> AnyPublisher<UserProfile, UserProfileServiceError>)?

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorCallsCount += 1
        if let activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorClosure = activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorClosure {
            return activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorClosure()
        } else {
            return activeUserProfilePublisherAnyPublisherUserProfileUserProfileServiceErrorReturnValue
        }
    }

    //MARK: - save

    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorCallsCount = 0
    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorCalled: Bool {
        return saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorCallsCount > 0
    }
    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReceivedProfiles: ([Profile])?
    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReceivedInvocations: [([Profile])] = []
    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReturnValue: AnyPublisher<Bool, UserProfileServiceError>!
    var saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorClosure: (([Profile]) -> AnyPublisher<Bool, UserProfileServiceError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorCallsCount += 1
        saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReceivedProfiles = profiles
        saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReceivedInvocations.append(profiles)
        if let saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorClosure = saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorClosure {
            return saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorClosure(profiles)
        } else {
            return saveProfilesProfileAnyPublisherBoolUserProfileServiceErrorReturnValue
        }
    }

    //MARK: - update

    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorCallsCount = 0
    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorCalled: Bool {
        return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorCallsCount > 0
    }
    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReturnValue: AnyPublisher<Bool, UserProfileServiceError>!
    var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError> {
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorCallsCount += 1
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReceivedInvocations.append((profileId: profileId, mutating: mutating))
        if let updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorClosure = updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorClosure {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorClosure(profileId, mutating)
        } else {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolUserProfileServiceErrorReturnValue
        }
    }


}
class UserSessionProviderMock: UserSessionProvider {




    //MARK: - userSession

    var userSessionForUuidUUIDUserSessionCallsCount = 0
    var userSessionForUuidUUIDUserSessionCalled: Bool {
        return userSessionForUuidUUIDUserSessionCallsCount > 0
    }
    var userSessionForUuidUUIDUserSessionReceivedUuid: (UUID)?
    var userSessionForUuidUUIDUserSessionReceivedInvocations: [(UUID)] = []
    var userSessionForUuidUUIDUserSessionReturnValue: UserSession!
    var userSessionForUuidUUIDUserSessionClosure: ((UUID) -> UserSession)?

    func userSession(for uuid: UUID) -> UserSession {
        userSessionForUuidUUIDUserSessionCallsCount += 1
        userSessionForUuidUUIDUserSessionReceivedUuid = uuid
        userSessionForUuidUUIDUserSessionReceivedInvocations.append(uuid)
        if let userSessionForUuidUUIDUserSessionClosure = userSessionForUuidUUIDUserSessionClosure {
            return userSessionForUuidUUIDUserSessionClosure(uuid)
        } else {
            return userSessionForUuidUUIDUserSessionReturnValue
        }
    }


}
class UsersSessionContainerMock: UsersSessionContainer {


    var userSession: UserSession {
        get { return underlyingUserSession }
        set(value) { underlyingUserSession = value }
    }
    var underlyingUserSession: (UserSession)!


    //MARK: - switchToDemoMode

    var switchToDemoModeVoidCallsCount = 0
    var switchToDemoModeVoidCalled: Bool {
        return switchToDemoModeVoidCallsCount > 0
    }
    var switchToDemoModeVoidClosure: (() -> Void)?

    func switchToDemoMode() {
        switchToDemoModeVoidCallsCount += 1
        switchToDemoModeVoidClosure?()
    }

    //MARK: - switchToStandardMode

    var switchToStandardModeVoidCallsCount = 0
    var switchToStandardModeVoidCalled: Bool {
        return switchToStandardModeVoidCallsCount > 0
    }
    var switchToStandardModeVoidClosure: (() -> Void)?

    func switchToStandardMode() {
        switchToStandardModeVoidCallsCount += 1
        switchToStandardModeVoidClosure?()
    }


}
