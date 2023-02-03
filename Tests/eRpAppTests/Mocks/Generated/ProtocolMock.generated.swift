// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
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




















final class MockAVSSession: AVSSession {


    //MARK: - redeem

    var redeemMessageEndpointRecipientsCallsCount = 0
    var redeemMessageEndpointRecipientsCalled: Bool {
        return redeemMessageEndpointRecipientsCallsCount > 0
    }
    var redeemMessageEndpointRecipientsReceivedArguments: (message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])?
    var redeemMessageEndpointRecipientsReceivedInvocations: [(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509])] = []
    var redeemMessageEndpointRecipientsReturnValue: AnyPublisher<AVSSessionResponse, AVSError>!
    var redeemMessageEndpointRecipientsClosure: ((AVSMessage, AVSEndpoint, [X509]) -> AnyPublisher<AVSSessionResponse, AVSError>)?

    func redeem(message: AVSMessage, endpoint: AVSEndpoint, recipients: [X509]) -> AnyPublisher<AVSSessionResponse, AVSError> {
        redeemMessageEndpointRecipientsCallsCount += 1
        redeemMessageEndpointRecipientsReceivedArguments = (message: message, endpoint: endpoint, recipients: recipients)
        redeemMessageEndpointRecipientsReceivedInvocations.append((message: message, endpoint: endpoint, recipients: recipients))
        if let redeemMessageEndpointRecipientsClosure = redeemMessageEndpointRecipientsClosure {
            return redeemMessageEndpointRecipientsClosure(message, endpoint, recipients)
        } else {
            return redeemMessageEndpointRecipientsReturnValue
        }
    }

}
final class MockAVSTransactionDataStore: AVSTransactionDataStore {


    //MARK: - fetchAVSTransaction

    var fetchAVSTransactionByCallsCount = 0
    var fetchAVSTransactionByCalled: Bool {
        return fetchAVSTransactionByCallsCount > 0
    }
    var fetchAVSTransactionByReceivedIdentifier: UUID?
    var fetchAVSTransactionByReceivedInvocations: [UUID] = []
    var fetchAVSTransactionByReturnValue: AnyPublisher<AVSTransaction?, LocalStoreError>!
    var fetchAVSTransactionByClosure: ((UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>)?

    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        fetchAVSTransactionByCallsCount += 1
        fetchAVSTransactionByReceivedIdentifier = identifier
        fetchAVSTransactionByReceivedInvocations.append(identifier)
        if let fetchAVSTransactionByClosure = fetchAVSTransactionByClosure {
            return fetchAVSTransactionByClosure(identifier)
        } else {
            return fetchAVSTransactionByReturnValue
        }
    }

    //MARK: - listAllAVSTransactions

    var listAllAVSTransactionsCallsCount = 0
    var listAllAVSTransactionsCalled: Bool {
        return listAllAVSTransactionsCallsCount > 0
    }
    var listAllAVSTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var listAllAVSTransactionsClosure: (() -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        listAllAVSTransactionsCallsCount += 1
        if let listAllAVSTransactionsClosure = listAllAVSTransactionsClosure {
            return listAllAVSTransactionsClosure()
        } else {
            return listAllAVSTransactionsReturnValue
        }
    }

    //MARK: - save

    var saveAvsTransactionsCallsCount = 0
    var saveAvsTransactionsCalled: Bool {
        return saveAvsTransactionsCallsCount > 0
    }
    var saveAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var saveAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var saveAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var saveAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        saveAvsTransactionsCallsCount += 1
        saveAvsTransactionsReceivedAvsTransactions = avsTransactions
        saveAvsTransactionsReceivedInvocations.append(avsTransactions)
        if let saveAvsTransactionsClosure = saveAvsTransactionsClosure {
            return saveAvsTransactionsClosure(avsTransactions)
        } else {
            return saveAvsTransactionsReturnValue
        }
    }

    //MARK: - delete

    var deleteAvsTransactionsCallsCount = 0
    var deleteAvsTransactionsCalled: Bool {
        return deleteAvsTransactionsCallsCount > 0
    }
    var deleteAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var deleteAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var deleteAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var deleteAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        deleteAvsTransactionsCallsCount += 1
        deleteAvsTransactionsReceivedAvsTransactions = avsTransactions
        deleteAvsTransactionsReceivedInvocations.append(avsTransactions)
        if let deleteAvsTransactionsClosure = deleteAvsTransactionsClosure {
            return deleteAvsTransactionsClosure(avsTransactions)
        } else {
            return deleteAvsTransactionsReturnValue
        }
    }

}
final class MockActivityIndicating: ActivityIndicating {

    var isActive: AnyPublisher<Bool, Never> {
        get { return underlyingIsActive }
        set(value) { underlyingIsActive = value }
    }
    var underlyingIsActive: AnyPublisher<Bool, Never>!

}
final class MockDeviceSecurityManagerSessionStorage: DeviceSecurityManagerSessionStorage {

    var ignoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningForSession }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningForSession = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningForSession: AnyPublisher<Bool?, Never>!
    var ignoreDeviceRootedWarningForSession: Bool {
        get { return underlyingIgnoreDeviceRootedWarningForSession }
        set(value) { underlyingIgnoreDeviceRootedWarningForSession = value }
    }
    var underlyingIgnoreDeviceRootedWarningForSession: Bool!

    //MARK: - set

    var setIgnoreDeviceNotSecuredWarningForSessionCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningForSessionCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningForSessionCallsCount > 0
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
final class MockERPDateFormatter: ERPDateFormatter {


    //MARK: - string

    var stringFromCallsCount = 0
    var stringFromCalled: Bool {
        return stringFromCallsCount > 0
    }
    var stringFromReceivedFrom: Date?
    var stringFromReceivedInvocations: [Date] = []
    var stringFromReturnValue: String!
    var stringFromClosure: ((Date) -> String)?

    func string(from: Date) -> String {
        stringFromCallsCount += 1
        stringFromReceivedFrom = from
        stringFromReceivedInvocations.append(from)
        if let stringFromClosure = stringFromClosure {
            return stringFromClosure(from)
        } else {
            return stringFromReturnValue
        }
    }

}
final class MockLoginHandler: LoginHandler {


    //MARK: - isAuthenticated

    var isAuthenticatedCallsCount = 0
    var isAuthenticatedCalled: Bool {
        return isAuthenticatedCallsCount > 0
    }
    var isAuthenticatedReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedCallsCount += 1
        if let isAuthenticatedClosure = isAuthenticatedClosure {
            return isAuthenticatedClosure()
        } else {
            return isAuthenticatedReturnValue
        }
    }

    //MARK: - isAuthenticatedOrAuthenticate

    var isAuthenticatedOrAuthenticateCallsCount = 0
    var isAuthenticatedOrAuthenticateCalled: Bool {
        return isAuthenticatedOrAuthenticateCallsCount > 0
    }
    var isAuthenticatedOrAuthenticateReturnValue: AnyPublisher<LoginResult, Never>!
    var isAuthenticatedOrAuthenticateClosure: (() -> AnyPublisher<LoginResult, Never>)?

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        isAuthenticatedOrAuthenticateCallsCount += 1
        if let isAuthenticatedOrAuthenticateClosure = isAuthenticatedOrAuthenticateClosure {
            return isAuthenticatedOrAuthenticateClosure()
        } else {
            return isAuthenticatedOrAuthenticateReturnValue
        }
    }

}
final class MockMatrixCodeGenerator: MatrixCodeGenerator {


    //MARK: - generateImage

    var generateImageForWidthHeightThrowableError: Error?
    var generateImageForWidthHeightCallsCount = 0
    var generateImageForWidthHeightCalled: Bool {
        return generateImageForWidthHeightCallsCount > 0
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
        if let generateImageForWidthHeightClosure = generateImageForWidthHeightClosure {
            return try generateImageForWidthHeightClosure(contents, width, height)
        } else {
            return generateImageForWidthHeightReturnValue
        }
    }

}
final class MockModelMigrating: ModelMigrating {


    //MARK: - startModelMigration

    var startModelMigrationFromCallsCount = 0
    var startModelMigrationFromCalled: Bool {
        return startModelMigrationFromCallsCount > 0
    }
    var startModelMigrationFromReceivedCurrentVersion: ModelVersion?
    var startModelMigrationFromReceivedInvocations: [ModelVersion] = []
    var startModelMigrationFromReturnValue: AnyPublisher<ModelVersion, MigrationError>!
    var startModelMigrationFromClosure: ((ModelVersion) -> AnyPublisher<ModelVersion, MigrationError>)?

    func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError> {
        startModelMigrationFromCallsCount += 1
        startModelMigrationFromReceivedCurrentVersion = currentVersion
        startModelMigrationFromReceivedInvocations.append(currentVersion)
        if let startModelMigrationFromClosure = startModelMigrationFromClosure {
            return startModelMigrationFromClosure(currentVersion)
        } else {
            return startModelMigrationFromReturnValue
        }
    }

}
final class MockNFCHealthCardPasswordController: NFCHealthCardPasswordController {


    //MARK: - resetEgkMrPinRetryCounter

    var resetEgkMrPinRetryCounterCanPukModeCallsCount = 0
    var resetEgkMrPinRetryCounterCanPukModeCalled: Bool {
        return resetEgkMrPinRetryCounterCanPukModeCallsCount > 0
    }
    var resetEgkMrPinRetryCounterCanPukModeReceivedArguments: (can: String, puk: String, mode: NFCResetRetryCounterMode)?
    var resetEgkMrPinRetryCounterCanPukModeReceivedInvocations: [(can: String, puk: String, mode: NFCResetRetryCounterMode)] = []
    var resetEgkMrPinRetryCounterCanPukModeReturnValue: AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var resetEgkMrPinRetryCounterCanPukModeClosure: ((String, String, NFCResetRetryCounterMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        resetEgkMrPinRetryCounterCanPukModeCallsCount += 1
        resetEgkMrPinRetryCounterCanPukModeReceivedArguments = (can: can, puk: puk, mode: mode)
        resetEgkMrPinRetryCounterCanPukModeReceivedInvocations.append((can: can, puk: puk, mode: mode))
        if let resetEgkMrPinRetryCounterCanPukModeClosure = resetEgkMrPinRetryCounterCanPukModeClosure {
            return resetEgkMrPinRetryCounterCanPukModeClosure(can, puk, mode)
        } else {
            return resetEgkMrPinRetryCounterCanPukModeReturnValue
        }
    }

    //MARK: - changeReferenceData

    var changeReferenceDataCanOldNewModeCallsCount = 0
    var changeReferenceDataCanOldNewModeCalled: Bool {
        return changeReferenceDataCanOldNewModeCallsCount > 0
    }
    var changeReferenceDataCanOldNewModeReceivedArguments: (can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)?
    var changeReferenceDataCanOldNewModeReceivedInvocations: [(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)] = []
    var changeReferenceDataCanOldNewModeReturnValue: AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>!
    var changeReferenceDataCanOldNewModeClosure: ((String, String, String, NFCChangeReferenceDataMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>)?

    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        changeReferenceDataCanOldNewModeCallsCount += 1
        changeReferenceDataCanOldNewModeReceivedArguments = (can: can, old: old, new: new, mode: mode)
        changeReferenceDataCanOldNewModeReceivedInvocations.append((can: can, old: old, new: new, mode: mode))
        if let changeReferenceDataCanOldNewModeClosure = changeReferenceDataCanOldNewModeClosure {
            return changeReferenceDataCanOldNewModeClosure(can, old, new, mode)
        } else {
            return changeReferenceDataCanOldNewModeReturnValue
        }
    }

}
final class MockNFCSignatureProvider: NFCSignatureProvider {


    //MARK: - openSecureSession

    var openSecureSessionCanPinCallsCount = 0
    var openSecureSessionCanPinCalled: Bool {
        return openSecureSessionCanPinCallsCount > 0
    }
    var openSecureSessionCanPinReceivedArguments: (can: String, pin: String)?
    var openSecureSessionCanPinReceivedInvocations: [(can: String, pin: String)] = []
    var openSecureSessionCanPinReturnValue: AnyPublisher<SignatureSession, NFCSignatureProviderError>!
    var openSecureSessionCanPinClosure: ((String, String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError>)?

    func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        openSecureSessionCanPinCallsCount += 1
        openSecureSessionCanPinReceivedArguments = (can: can, pin: pin)
        openSecureSessionCanPinReceivedInvocations.append((can: can, pin: pin))
        if let openSecureSessionCanPinClosure = openSecureSessionCanPinClosure {
            return openSecureSessionCanPinClosure(can, pin)
        } else {
            return openSecureSessionCanPinReturnValue
        }
    }

    //MARK: - sign

    var signCanPinChallengeCallsCount = 0
    var signCanPinChallengeCalled: Bool {
        return signCanPinChallengeCallsCount > 0
    }
    var signCanPinChallengeReceivedArguments: (can: String, pin: String, challenge: IDPChallengeSession)?
    var signCanPinChallengeReceivedInvocations: [(can: String, pin: String, challenge: IDPChallengeSession)] = []
    var signCanPinChallengeReturnValue: AnyPublisher<SignedChallenge, NFCSignatureProviderError>!
    var signCanPinChallengeClosure: ((String, String, IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError>)?

    func sign(can: String, pin: String, challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        signCanPinChallengeCallsCount += 1
        signCanPinChallengeReceivedArguments = (can: can, pin: pin, challenge: challenge)
        signCanPinChallengeReceivedInvocations.append((can: can, pin: pin, challenge: challenge))
        if let signCanPinChallengeClosure = signCanPinChallengeClosure {
            return signCanPinChallengeClosure(can, pin, challenge)
        } else {
            return signCanPinChallengeReturnValue
        }
    }

}
final class MockPrescriptionRepository: PrescriptionRepository {


    //MARK: - loadLocal

    var loadLocalCallsCount = 0
    var loadLocalCalled: Bool {
        return loadLocalCallsCount > 0
    }
    var loadLocalReturnValue: AnyPublisher<[Prescription], PrescriptionRepositoryError>!
    var loadLocalClosure: (() -> AnyPublisher<[Prescription], PrescriptionRepositoryError>)?

    func loadLocal() -> AnyPublisher<[Prescription], PrescriptionRepositoryError> {
        loadLocalCallsCount += 1
        if let loadLocalClosure = loadLocalClosure {
            return loadLocalClosure()
        } else {
            return loadLocalReturnValue
        }
    }

    //MARK: - forcedLoadRemote

    var forcedLoadRemoteForCallsCount = 0
    var forcedLoadRemoteForCalled: Bool {
        return forcedLoadRemoteForCallsCount > 0
    }
    var forcedLoadRemoteForReceivedLocale: String?
    var forcedLoadRemoteForReceivedInvocations: [String?] = []
    var forcedLoadRemoteForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var forcedLoadRemoteForClosure: ((String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func forcedLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        forcedLoadRemoteForCallsCount += 1
        forcedLoadRemoteForReceivedLocale = locale
        forcedLoadRemoteForReceivedInvocations.append(locale)
        if let forcedLoadRemoteForClosure = forcedLoadRemoteForClosure {
            return forcedLoadRemoteForClosure(locale)
        } else {
            return forcedLoadRemoteForReturnValue
        }
    }

    //MARK: - silentLoadRemote

    var silentLoadRemoteForCallsCount = 0
    var silentLoadRemoteForCalled: Bool {
        return silentLoadRemoteForCallsCount > 0
    }
    var silentLoadRemoteForReceivedLocale: String?
    var silentLoadRemoteForReceivedInvocations: [String?] = []
    var silentLoadRemoteForReturnValue: AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>!
    var silentLoadRemoteForClosure: ((String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError>)?

    func silentLoadRemote(for locale: String?) -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        silentLoadRemoteForCallsCount += 1
        silentLoadRemoteForReceivedLocale = locale
        silentLoadRemoteForReceivedInvocations.append(locale)
        if let silentLoadRemoteForClosure = silentLoadRemoteForClosure {
            return silentLoadRemoteForClosure(locale)
        } else {
            return silentLoadRemoteForReturnValue
        }
    }

}
final class MockProfileBasedSessionProvider: ProfileBasedSessionProvider {


    //MARK: - idpSession

    var idpSessionForCallsCount = 0
    var idpSessionForCalled: Bool {
        return idpSessionForCallsCount > 0
    }
    var idpSessionForReceivedProfileId: UUID?
    var idpSessionForReceivedInvocations: [UUID] = []
    var idpSessionForReturnValue: IDPSession!
    var idpSessionForClosure: ((UUID) -> IDPSession)?

    func idpSession(for profileId: UUID) -> IDPSession {
        idpSessionForCallsCount += 1
        idpSessionForReceivedProfileId = profileId
        idpSessionForReceivedInvocations.append(profileId)
        if let idpSessionForClosure = idpSessionForClosure {
            return idpSessionForClosure(profileId)
        } else {
            return idpSessionForReturnValue
        }
    }

    //MARK: - biometrieIdpSession

    var biometrieIdpSessionForCallsCount = 0
    var biometrieIdpSessionForCalled: Bool {
        return biometrieIdpSessionForCallsCount > 0
    }
    var biometrieIdpSessionForReceivedProfileId: UUID?
    var biometrieIdpSessionForReceivedInvocations: [UUID] = []
    var biometrieIdpSessionForReturnValue: IDPSession!
    var biometrieIdpSessionForClosure: ((UUID) -> IDPSession)?

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        biometrieIdpSessionForCallsCount += 1
        biometrieIdpSessionForReceivedProfileId = profileId
        biometrieIdpSessionForReceivedInvocations.append(profileId)
        if let biometrieIdpSessionForClosure = biometrieIdpSessionForClosure {
            return biometrieIdpSessionForClosure(profileId)
        } else {
            return biometrieIdpSessionForReturnValue
        }
    }

    //MARK: - userDataStore

    var userDataStoreForCallsCount = 0
    var userDataStoreForCalled: Bool {
        return userDataStoreForCallsCount > 0
    }
    var userDataStoreForReceivedProfileId: UUID?
    var userDataStoreForReceivedInvocations: [UUID] = []
    var userDataStoreForReturnValue: SecureUserDataStore!
    var userDataStoreForClosure: ((UUID) -> SecureUserDataStore)?

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userDataStoreForCallsCount += 1
        userDataStoreForReceivedProfileId = profileId
        userDataStoreForReceivedInvocations.append(profileId)
        if let userDataStoreForClosure = userDataStoreForClosure {
            return userDataStoreForClosure(profileId)
        } else {
            return userDataStoreForReturnValue
        }
    }

    //MARK: - idTokenValidator

    var idTokenValidatorForCallsCount = 0
    var idTokenValidatorForCalled: Bool {
        return idTokenValidatorForCallsCount > 0
    }
    var idTokenValidatorForReceivedProfileId: UUID?
    var idTokenValidatorForReceivedInvocations: [UUID] = []
    var idTokenValidatorForReturnValue: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var idTokenValidatorForClosure: ((UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>)?

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        idTokenValidatorForCallsCount += 1
        idTokenValidatorForReceivedProfileId = profileId
        idTokenValidatorForReceivedInvocations.append(profileId)
        if let idTokenValidatorForClosure = idTokenValidatorForClosure {
            return idTokenValidatorForClosure(profileId)
        } else {
            return idTokenValidatorForReturnValue
        }
    }

}
final class MockProfileDataStore: ProfileDataStore {


    //MARK: - fetchProfile

    var fetchProfileByCallsCount = 0
    var fetchProfileByCalled: Bool {
        return fetchProfileByCallsCount > 0
    }
    var fetchProfileByReceivedIdentifier: Profile.ID?
    var fetchProfileByReceivedInvocations: [Profile.ID] = []
    var fetchProfileByReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    var fetchProfileByClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByCallsCount += 1
        fetchProfileByReceivedIdentifier = identifier
        fetchProfileByReceivedInvocations.append(identifier)
        if let fetchProfileByClosure = fetchProfileByClosure {
            return fetchProfileByClosure(identifier)
        } else {
            return fetchProfileByReturnValue
        }
    }

    //MARK: - listAllProfiles

    var listAllProfilesCallsCount = 0
    var listAllProfilesCalled: Bool {
        return listAllProfilesCallsCount > 0
    }
    var listAllProfilesReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    var listAllProfilesClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesCallsCount += 1
        if let listAllProfilesClosure = listAllProfilesClosure {
            return listAllProfilesClosure()
        } else {
            return listAllProfilesReturnValue
        }
    }

    //MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        return saveProfilesCallsCount > 0
    }
    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        if let saveProfilesClosure = saveProfilesClosure {
            return saveProfilesClosure(profiles)
        } else {
            return saveProfilesReturnValue
        }
    }

    //MARK: - delete

    var deleteProfilesCallsCount = 0
    var deleteProfilesCalled: Bool {
        return deleteProfilesCallsCount > 0
    }
    var deleteProfilesReceivedProfiles: [Profile]?
    var deleteProfilesReceivedInvocations: [[Profile]] = []
    var deleteProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesCallsCount += 1
        deleteProfilesReceivedProfiles = profiles
        deleteProfilesReceivedInvocations.append(profiles)
        if let deleteProfilesClosure = deleteProfilesClosure {
            return deleteProfilesClosure(profiles)
        } else {
            return deleteProfilesReturnValue
        }
    }

    //MARK: - update

    var updateProfileIdMutatingCallsCount = 0
    var updateProfileIdMutatingCalled: Bool {
        return updateProfileIdMutatingCallsCount > 0
    }
    var updateProfileIdMutatingReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdMutatingReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdMutatingReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateProfileIdMutatingClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdMutatingCallsCount += 1
        updateProfileIdMutatingReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdMutatingReceivedInvocations.append((profileId: profileId, mutating: mutating))
        if let updateProfileIdMutatingClosure = updateProfileIdMutatingClosure {
            return updateProfileIdMutatingClosure(profileId, mutating)
        } else {
            return updateProfileIdMutatingReturnValue
        }
    }

    //MARK: - pagedAuditEventsController

    var pagedAuditEventsControllerForWithThrowableError: Error?
    var pagedAuditEventsControllerForWithCallsCount = 0
    var pagedAuditEventsControllerForWithCalled: Bool {
        return pagedAuditEventsControllerForWithCallsCount > 0
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
        if let pagedAuditEventsControllerForWithClosure = pagedAuditEventsControllerForWithClosure {
            return try pagedAuditEventsControllerForWithClosure(profileId, locale)
        } else {
            return pagedAuditEventsControllerForWithReturnValue
        }
    }

}
final class MockProfileOnlineChecker: ProfileOnlineChecker {


    //MARK: - token

    var tokenForCallsCount = 0
    var tokenForCalled: Bool {
        return tokenForCallsCount > 0
    }
    var tokenForReceivedProfile: Profile?
    var tokenForReceivedInvocations: [Profile] = []
    var tokenForReturnValue: AnyPublisher<IDPToken?, Never>!
    var tokenForClosure: ((Profile) -> AnyPublisher<IDPToken?, Never>)?

    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        tokenForCallsCount += 1
        tokenForReceivedProfile = profile
        tokenForReceivedInvocations.append(profile)
        if let tokenForClosure = tokenForClosure {
            return tokenForClosure(profile)
        } else {
            return tokenForReturnValue
        }
    }

}
final class MockProfileSecureDataWiper: ProfileSecureDataWiper {


    //MARK: - wipeSecureData

    var wipeSecureDataOfCallsCount = 0
    var wipeSecureDataOfCalled: Bool {
        return wipeSecureDataOfCallsCount > 0
    }
    var wipeSecureDataOfReceivedProfileId: UUID?
    var wipeSecureDataOfReceivedInvocations: [UUID] = []
    var wipeSecureDataOfReturnValue: AnyPublisher<Void, Never>!
    var wipeSecureDataOfClosure: ((UUID) -> AnyPublisher<Void, Never>)?

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        wipeSecureDataOfCallsCount += 1
        wipeSecureDataOfReceivedProfileId = profileId
        wipeSecureDataOfReceivedInvocations.append(profileId)
        if let wipeSecureDataOfClosure = wipeSecureDataOfClosure {
            return wipeSecureDataOfClosure(profileId)
        } else {
            return wipeSecureDataOfReturnValue
        }
    }

    //MARK: - logout

    var logoutProfileCallsCount = 0
    var logoutProfileCalled: Bool {
        return logoutProfileCallsCount > 0
    }
    var logoutProfileReceivedProfile: Profile?
    var logoutProfileReceivedInvocations: [Profile] = []
    var logoutProfileReturnValue: AnyPublisher<Void, Never>!
    var logoutProfileClosure: ((Profile) -> AnyPublisher<Void, Never>)?

    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        logoutProfileCallsCount += 1
        logoutProfileReceivedProfile = profile
        logoutProfileReceivedInvocations.append(profile)
        if let logoutProfileClosure = logoutProfileClosure {
            return logoutProfileClosure(profile)
        } else {
            return logoutProfileReturnValue
        }
    }

    //MARK: - secureStorage

    var secureStorageOfCallsCount = 0
    var secureStorageOfCalled: Bool {
        return secureStorageOfCallsCount > 0
    }
    var secureStorageOfReceivedProfileId: UUID?
    var secureStorageOfReceivedInvocations: [UUID] = []
    var secureStorageOfReturnValue: SecureUserDataStore!
    var secureStorageOfClosure: ((UUID) -> SecureUserDataStore)?

    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        secureStorageOfCallsCount += 1
        secureStorageOfReceivedProfileId = profileId
        secureStorageOfReceivedInvocations.append(profileId)
        if let secureStorageOfClosure = secureStorageOfClosure {
            return secureStorageOfClosure(profileId)
        } else {
            return secureStorageOfReturnValue
        }
    }

}
final class MockRedeemService: RedeemService {


    //MARK: - redeem

    var redeemCallsCount = 0
    var redeemCalled: Bool {
        return redeemCallsCount > 0
    }
    var redeemReceivedOrders: [Order]?
    var redeemReceivedInvocations: [[Order]] = []
    var redeemReturnValue: AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>!
    var redeemClosure: (([Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError>)?

    func redeem(_ orders: [Order]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        redeemCallsCount += 1
        redeemReceivedOrders = orders
        redeemReceivedInvocations.append(orders)
        if let redeemClosure = redeemClosure {
            return redeemClosure(orders)
        } else {
            return redeemReturnValue
        }
    }

}
final class MockRegisteredDevicesService: RegisteredDevicesService {


    //MARK: - registeredDevices

    var registeredDevicesForCallsCount = 0
    var registeredDevicesForCalled: Bool {
        return registeredDevicesForCallsCount > 0
    }
    var registeredDevicesForReceivedProfileId: UUID?
    var registeredDevicesForReceivedInvocations: [UUID] = []
    var registeredDevicesForReturnValue: AnyPublisher<PairingEntries, RegisteredDevicesServiceError>!
    var registeredDevicesForClosure: ((UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError>)?

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        registeredDevicesForCallsCount += 1
        registeredDevicesForReceivedProfileId = profileId
        registeredDevicesForReceivedInvocations.append(profileId)
        if let registeredDevicesForClosure = registeredDevicesForClosure {
            return registeredDevicesForClosure(profileId)
        } else {
            return registeredDevicesForReturnValue
        }
    }

    //MARK: - deviceId

    var deviceIdForCallsCount = 0
    var deviceIdForCalled: Bool {
        return deviceIdForCallsCount > 0
    }
    var deviceIdForReceivedProfileId: UUID?
    var deviceIdForReceivedInvocations: [UUID] = []
    var deviceIdForReturnValue: AnyPublisher<String?, Never>!
    var deviceIdForClosure: ((UUID) -> AnyPublisher<String?, Never>)?

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        deviceIdForCallsCount += 1
        deviceIdForReceivedProfileId = profileId
        deviceIdForReceivedInvocations.append(profileId)
        if let deviceIdForClosure = deviceIdForClosure {
            return deviceIdForClosure(profileId)
        } else {
            return deviceIdForReturnValue
        }
    }

    //MARK: - deleteDevice

    var deleteDeviceOfCallsCount = 0
    var deleteDeviceOfCalled: Bool {
        return deleteDeviceOfCallsCount > 0
    }
    var deleteDeviceOfReceivedArguments: (device: String, profileId: UUID)?
    var deleteDeviceOfReceivedInvocations: [(device: String, profileId: UUID)] = []
    var deleteDeviceOfReturnValue: AnyPublisher<Bool, RegisteredDevicesServiceError>!
    var deleteDeviceOfClosure: ((String, UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError>)?

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        deleteDeviceOfCallsCount += 1
        deleteDeviceOfReceivedArguments = (device: device, profileId: profileId)
        deleteDeviceOfReceivedInvocations.append((device: device, profileId: profileId))
        if let deleteDeviceOfClosure = deleteDeviceOfClosure {
            return deleteDeviceOfClosure(device, profileId)
        } else {
            return deleteDeviceOfReturnValue
        }
    }

    //MARK: - cardWall

    var cardWallForCallsCount = 0
    var cardWallForCalled: Bool {
        return cardWallForCallsCount > 0
    }
    var cardWallForReceivedProfileId: UUID?
    var cardWallForReceivedInvocations: [UUID] = []
    var cardWallForReturnValue: AnyPublisher<IDPCardWallDomain.State, Never>!
    var cardWallForClosure: ((UUID) -> AnyPublisher<IDPCardWallDomain.State, Never>)?

    func cardWall(for profileId: UUID) -> AnyPublisher<IDPCardWallDomain.State, Never> {
        cardWallForCallsCount += 1
        cardWallForReceivedProfileId = profileId
        cardWallForReceivedInvocations.append(profileId)
        if let cardWallForClosure = cardWallForClosure {
            return cardWallForClosure(profileId)
        } else {
            return cardWallForReturnValue
        }
    }

}
final class MockRouting: Routing {


    //MARK: - routeTo

    var routeToCallsCount = 0
    var routeToCalled: Bool {
        return routeToCallsCount > 0
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
final class MockSearchHistory: SearchHistory {


    //MARK: - addHistoryItem

    var addHistoryItemCallsCount = 0
    var addHistoryItemCalled: Bool {
        return addHistoryItemCallsCount > 0
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

    //MARK: - historyItems

    var historyItemsCallsCount = 0
    var historyItemsCalled: Bool {
        return historyItemsCallsCount > 0
    }
    var historyItemsReturnValue: [String]!
    var historyItemsClosure: (() -> [String])?

    func historyItems() -> [String] {
        historyItemsCallsCount += 1
        if let historyItemsClosure = historyItemsClosure {
            return historyItemsClosure()
        } else {
            return historyItemsReturnValue
        }
    }

}
final class MockSecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {

    var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        get { return underlyingIsBiometrieRegistered }
        set(value) { underlyingIsBiometrieRegistered = value }
    }
    var underlyingIsBiometrieRegistered: AnyPublisher<Bool, Never>!

    //MARK: - createPairingSession

    var createPairingSessionThrowableError: Error?
    var createPairingSessionCallsCount = 0
    var createPairingSessionCalled: Bool {
        return createPairingSessionCallsCount > 0
    }
    var createPairingSessionReturnValue: PairingSession!
    var createPairingSessionClosure: (() throws -> PairingSession)?

    func createPairingSession() throws -> PairingSession {
        if let error = createPairingSessionThrowableError {
            throw error
        }
        createPairingSessionCallsCount += 1
        if let createPairingSessionClosure = createPairingSessionClosure {
            return try createPairingSessionClosure()
        } else {
            return createPairingSessionReturnValue
        }
    }

    //MARK: - signPairingSession

    var signPairingSessionWithCertificateCallsCount = 0
    var signPairingSessionWithCertificateCalled: Bool {
        return signPairingSessionWithCertificateCallsCount > 0
    }
    var signPairingSessionWithCertificateReceivedArguments: (pairingSession: PairingSession, signer: JWTSigner, certificate: X509)?
    var signPairingSessionWithCertificateReceivedInvocations: [(pairingSession: PairingSession, signer: JWTSigner, certificate: X509)] = []
    var signPairingSessionWithCertificateReturnValue: AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>!
    var signPairingSessionWithCertificateClosure: ((PairingSession, JWTSigner, X509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>)?

    func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: X509) -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        signPairingSessionWithCertificateCallsCount += 1
        signPairingSessionWithCertificateReceivedArguments = (pairingSession: pairingSession, signer: signer, certificate: certificate)
        signPairingSessionWithCertificateReceivedInvocations.append((pairingSession: pairingSession, signer: signer, certificate: certificate))
        if let signPairingSessionWithCertificateClosure = signPairingSessionWithCertificateClosure {
            return signPairingSessionWithCertificateClosure(pairingSession, signer, certificate)
        } else {
            return signPairingSessionWithCertificateReturnValue
        }
    }

    //MARK: - abort

    var abortPairingSessionThrowableError: Error?
    var abortPairingSessionCallsCount = 0
    var abortPairingSessionCalled: Bool {
        return abortPairingSessionCallsCount > 0
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

    //MARK: - authenticationData

    var authenticationDataForCallsCount = 0
    var authenticationDataForCalled: Bool {
        return authenticationDataForCallsCount > 0
    }
    var authenticationDataForReceivedChallenge: IDPChallengeSession?
    var authenticationDataForReceivedInvocations: [IDPChallengeSession] = []
    var authenticationDataForReturnValue: AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>!
    var authenticationDataForClosure: ((IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>)?

    func authenticationData(for challenge: IDPChallengeSession) -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        authenticationDataForCallsCount += 1
        authenticationDataForReceivedChallenge = challenge
        authenticationDataForReceivedInvocations.append(challenge)
        if let authenticationDataForClosure = authenticationDataForClosure {
            return authenticationDataForClosure(challenge)
        } else {
            return authenticationDataForReturnValue
        }
    }

}
final class MockShipmentInfoDataStore: ShipmentInfoDataStore {

    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        get { return underlyingSelectedShipmentInfo }
        set(value) { underlyingSelectedShipmentInfo = value }
    }
    var underlyingSelectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError>!

    //MARK: - set

    var setSelectedShipmentInfoIdCallsCount = 0
    var setSelectedShipmentInfoIdCalled: Bool {
        return setSelectedShipmentInfoIdCallsCount > 0
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

    //MARK: - fetchShipmentInfo

    var fetchShipmentInfoByCallsCount = 0
    var fetchShipmentInfoByCalled: Bool {
        return fetchShipmentInfoByCallsCount > 0
    }
    var fetchShipmentInfoByReceivedIdentifier: UUID?
    var fetchShipmentInfoByReceivedInvocations: [UUID] = []
    var fetchShipmentInfoByReturnValue: AnyPublisher<ShipmentInfo?, LocalStoreError>!
    var fetchShipmentInfoByClosure: ((UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError>)?

    func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        fetchShipmentInfoByCallsCount += 1
        fetchShipmentInfoByReceivedIdentifier = identifier
        fetchShipmentInfoByReceivedInvocations.append(identifier)
        if let fetchShipmentInfoByClosure = fetchShipmentInfoByClosure {
            return fetchShipmentInfoByClosure(identifier)
        } else {
            return fetchShipmentInfoByReturnValue
        }
    }

    //MARK: - listAllShipmentInfos

    var listAllShipmentInfosCallsCount = 0
    var listAllShipmentInfosCalled: Bool {
        return listAllShipmentInfosCallsCount > 0
    }
    var listAllShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var listAllShipmentInfosClosure: (() -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        listAllShipmentInfosCallsCount += 1
        if let listAllShipmentInfosClosure = listAllShipmentInfosClosure {
            return listAllShipmentInfosClosure()
        } else {
            return listAllShipmentInfosReturnValue
        }
    }

    //MARK: - save

    var saveShipmentInfosCallsCount = 0
    var saveShipmentInfosCalled: Bool {
        return saveShipmentInfosCallsCount > 0
    }
    var saveShipmentInfosReceivedShipmentInfos: [ShipmentInfo]?
    var saveShipmentInfosReceivedInvocations: [[ShipmentInfo]] = []
    var saveShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var saveShipmentInfosClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        saveShipmentInfosCallsCount += 1
        saveShipmentInfosReceivedShipmentInfos = shipmentInfos
        saveShipmentInfosReceivedInvocations.append(shipmentInfos)
        if let saveShipmentInfosClosure = saveShipmentInfosClosure {
            return saveShipmentInfosClosure(shipmentInfos)
        } else {
            return saveShipmentInfosReturnValue
        }
    }

    //MARK: - delete

    var deleteShipmentInfosCallsCount = 0
    var deleteShipmentInfosCalled: Bool {
        return deleteShipmentInfosCallsCount > 0
    }
    var deleteShipmentInfosReceivedShipmentInfos: [ShipmentInfo]?
    var deleteShipmentInfosReceivedInvocations: [[ShipmentInfo]] = []
    var deleteShipmentInfosReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!
    var deleteShipmentInfosClosure: (([ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>)?

    func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        deleteShipmentInfosCallsCount += 1
        deleteShipmentInfosReceivedShipmentInfos = shipmentInfos
        deleteShipmentInfosReceivedInvocations.append(shipmentInfos)
        if let deleteShipmentInfosClosure = deleteShipmentInfosClosure {
            return deleteShipmentInfosClosure(shipmentInfos)
        } else {
            return deleteShipmentInfosReturnValue
        }
    }

    //MARK: - update

    var updateIdentifierMutatingCallsCount = 0
    var updateIdentifierMutatingCalled: Bool {
        return updateIdentifierMutatingCallsCount > 0
    }
    var updateIdentifierMutatingReceivedArguments: (identifier: UUID, mutating: (inout ShipmentInfo) -> Void)?
    var updateIdentifierMutatingReceivedInvocations: [(identifier: UUID, mutating: (inout ShipmentInfo) -> Void)] = []
    var updateIdentifierMutatingReturnValue: AnyPublisher<ShipmentInfo, LocalStoreError>!
    var updateIdentifierMutatingClosure: ((UUID, @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError>)?

    func update(identifier: UUID, mutating: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        updateIdentifierMutatingCallsCount += 1
        updateIdentifierMutatingReceivedArguments = (identifier: identifier, mutating: mutating)
        updateIdentifierMutatingReceivedInvocations.append((identifier: identifier, mutating: mutating))
        if let updateIdentifierMutatingClosure = updateIdentifierMutatingClosure {
            return updateIdentifierMutatingClosure(identifier, mutating)
        } else {
            return updateIdentifierMutatingReturnValue
        }
    }

}
final class MockTracker: Tracker {

    var optIn: Bool {
        get { return underlyingOptIn }
        set(value) { underlyingOptIn = value }
    }
    var underlyingOptIn: Bool!
    var optInPublisher: AnyPublisher<Bool, Never> {
        get { return underlyingOptInPublisher }
        set(value) { underlyingOptInPublisher = value }
    }
    var underlyingOptInPublisher: AnyPublisher<Bool, Never>!

    //MARK: - track

    var trackEventsCallsCount = 0
    var trackEventsCalled: Bool {
        return trackEventsCallsCount > 0
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

    //MARK: - track

    var trackScreensCallsCount = 0
    var trackScreensCalled: Bool {
        return trackScreensCallsCount > 0
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

    //MARK: - track

    var trackEventCallsCount = 0
    var trackEventCalled: Bool {
        return trackEventCallsCount > 0
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

    //MARK: - track

    var trackScreenCallsCount = 0
    var trackScreenCalled: Bool {
        return trackScreenCallsCount > 0
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

    //MARK: - stopTracking

    var stopTrackingCallsCount = 0
    var stopTrackingCalled: Bool {
        return stopTrackingCallsCount > 0
    }
    var stopTrackingClosure: (() -> Void)?

    func stopTracking() {
        stopTrackingCallsCount += 1
        stopTrackingClosure?()
    }

}
final class MockUserDataStore: UserDataStore {

    var hideOnboarding: AnyPublisher<Bool, Never> {
        get { return underlyingHideOnboarding }
        set(value) { underlyingHideOnboarding = value }
    }
    var underlyingHideOnboarding: AnyPublisher<Bool, Never>!
    var isOnboardingHidden: Bool {
        get { return underlyingIsOnboardingHidden }
        set(value) { underlyingIsOnboardingHidden = value }
    }
    var underlyingIsOnboardingHidden: Bool!
    var onboardingVersion: AnyPublisher<String?, Never> {
        get { return underlyingOnboardingVersion }
        set(value) { underlyingOnboardingVersion = value }
    }
    var underlyingOnboardingVersion: AnyPublisher<String?, Never>!
    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        get { return underlyingHideCardWallIntro }
        set(value) { underlyingHideCardWallIntro = value }
    }
    var underlyingHideCardWallIntro: AnyPublisher<Bool, Never>!
    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        get { return underlyingServerEnvironmentConfiguration }
        set(value) { underlyingServerEnvironmentConfiguration = value }
    }
    var underlyingServerEnvironmentConfiguration: AnyPublisher<String?, Never>!
    var serverEnvironmentName: String?
    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        get { return underlyingAppSecurityOption }
        set(value) { underlyingAppSecurityOption = value }
    }
    var underlyingAppSecurityOption: AnyPublisher<AppSecurityOption, Never>!
    var failedAppAuthentications: AnyPublisher<Int, Never> {
        get { return underlyingFailedAppAuthentications }
        set(value) { underlyingFailedAppAuthentications = value }
    }
    var underlyingFailedAppAuthentications: AnyPublisher<Int, Never>!
    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        get { return underlyingIgnoreDeviceNotSecuredWarningPermanently }
        set(value) { underlyingIgnoreDeviceNotSecuredWarningPermanently = value }
    }
    var underlyingIgnoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never>!
    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!
    var latestCompatibleModelVersion: ModelVersion {
        get { return underlyingLatestCompatibleModelVersion }
        set(value) { underlyingLatestCompatibleModelVersion = value }
    }
    var underlyingLatestCompatibleModelVersion: ModelVersion!
    var appStartCounter: Int {
        get { return underlyingAppStartCounter }
        set(value) { underlyingAppStartCounter = value }
    }
    var underlyingAppStartCounter: Int!
    var hideWelcomeDrawer: Bool {
        get { return underlyingHideWelcomeDrawer }
        set(value) { underlyingHideWelcomeDrawer = value }
    }
    var underlyingHideWelcomeDrawer: Bool!

    //MARK: - set

    var setHideOnboardingCallsCount = 0
    var setHideOnboardingCalled: Bool {
        return setHideOnboardingCallsCount > 0
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

    //MARK: - set

    var setOnboardingVersionCallsCount = 0
    var setOnboardingVersionCalled: Bool {
        return setOnboardingVersionCallsCount > 0
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

    //MARK: - set

    var setHideCardWallIntroCallsCount = 0
    var setHideCardWallIntroCalled: Bool {
        return setHideCardWallIntroCallsCount > 0
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

    //MARK: - set

    var setServerEnvironmentConfigurationCallsCount = 0
    var setServerEnvironmentConfigurationCalled: Bool {
        return setServerEnvironmentConfigurationCallsCount > 0
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

    //MARK: - set

    var setAppSecurityOptionCallsCount = 0
    var setAppSecurityOptionCalled: Bool {
        return setAppSecurityOptionCallsCount > 0
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

    //MARK: - set

    var setFailedAppAuthenticationsCallsCount = 0
    var setFailedAppAuthenticationsCalled: Bool {
        return setFailedAppAuthenticationsCallsCount > 0
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

    //MARK: - set

    var setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount = 0
    var setIgnoreDeviceNotSecuredWarningPermanentlyCalled: Bool {
        return setIgnoreDeviceNotSecuredWarningPermanentlyCallsCount > 0
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

    //MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        return setSelectedProfileIdCallsCount > 0
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

    //MARK: - wipeAll

    var wipeAllCallsCount = 0
    var wipeAllCalled: Bool {
        return wipeAllCallsCount > 0
    }
    var wipeAllClosure: (() -> Void)?

    func wipeAll() {
        wipeAllCallsCount += 1
        wipeAllClosure?()
    }

}
final class MockUserProfileService: UserProfileService {

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        get { return underlyingSelectedProfileId }
        set(value) { underlyingSelectedProfileId = value }
    }
    var underlyingSelectedProfileId: AnyPublisher<UUID?, Never>!

    //MARK: - set

    var setSelectedProfileIdCallsCount = 0
    var setSelectedProfileIdCalled: Bool {
        return setSelectedProfileIdCallsCount > 0
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

    //MARK: - userProfilesPublisher

    var userProfilesPublisherCallsCount = 0
    var userProfilesPublisherCalled: Bool {
        return userProfilesPublisherCallsCount > 0
    }
    var userProfilesPublisherReturnValue: AnyPublisher<[UserProfile], UserProfileServiceError>!
    var userProfilesPublisherClosure: (() -> AnyPublisher<[UserProfile], UserProfileServiceError>)?

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        userProfilesPublisherCallsCount += 1
        if let userProfilesPublisherClosure = userProfilesPublisherClosure {
            return userProfilesPublisherClosure()
        } else {
            return userProfilesPublisherReturnValue
        }
    }

    //MARK: - activeUserProfilePublisher

    var activeUserProfilePublisherCallsCount = 0
    var activeUserProfilePublisherCalled: Bool {
        return activeUserProfilePublisherCallsCount > 0
    }
    var activeUserProfilePublisherReturnValue: AnyPublisher<UserProfile, UserProfileServiceError>!
    var activeUserProfilePublisherClosure: (() -> AnyPublisher<UserProfile, UserProfileServiceError>)?

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        activeUserProfilePublisherCallsCount += 1
        if let activeUserProfilePublisherClosure = activeUserProfilePublisherClosure {
            return activeUserProfilePublisherClosure()
        } else {
            return activeUserProfilePublisherReturnValue
        }
    }

    //MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        return saveProfilesCallsCount > 0
    }
    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, UserProfileServiceError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, UserProfileServiceError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        if let saveProfilesClosure = saveProfilesClosure {
            return saveProfilesClosure(profiles)
        } else {
            return saveProfilesReturnValue
        }
    }

}
final class MockUserSessionProvider: UserSessionProvider {


    //MARK: - userSession

    var userSessionForCallsCount = 0
    var userSessionForCalled: Bool {
        return userSessionForCallsCount > 0
    }
    var userSessionForReceivedUuid: UUID?
    var userSessionForReceivedInvocations: [UUID] = []
    var userSessionForReturnValue: UserSession!
    var userSessionForClosure: ((UUID) -> UserSession)?

    func userSession(for uuid: UUID) -> UserSession {
        userSessionForCallsCount += 1
        userSessionForReceivedUuid = uuid
        userSessionForReceivedInvocations.append(uuid)
        if let userSessionForClosure = userSessionForClosure {
            return userSessionForClosure(uuid)
        } else {
            return userSessionForReturnValue
        }
    }

}
final class MockUsersSessionContainer: UsersSessionContainer {

    var userSession: UserSession {
        get { return underlyingUserSession }
        set(value) { underlyingUserSession = value }
    }
    var underlyingUserSession: UserSession!
    var isDemoMode: AnyPublisher<Bool, Never> {
        get { return underlyingIsDemoMode }
        set(value) { underlyingIsDemoMode = value }
    }
    var underlyingIsDemoMode: AnyPublisher<Bool, Never>!

    //MARK: - switchToDemoMode

    var switchToDemoModeCallsCount = 0
    var switchToDemoModeCalled: Bool {
        return switchToDemoModeCallsCount > 0
    }
    var switchToDemoModeClosure: (() -> Void)?

    func switchToDemoMode() {
        switchToDemoModeCallsCount += 1
        switchToDemoModeClosure?()
    }

    //MARK: - switchToStandardMode

    var switchToStandardModeCallsCount = 0
    var switchToStandardModeCalled: Bool {
        return switchToStandardModeCallsCount > 0
    }
    var switchToStandardModeClosure: (() -> Void)?

    func switchToStandardMode() {
        switchToStandardModeCallsCount += 1
        switchToStandardModeClosure?()
    }

}
