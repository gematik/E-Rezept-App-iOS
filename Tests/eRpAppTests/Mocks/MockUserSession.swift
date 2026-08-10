//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import BfArM
import Combine
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FeatureCardWall
import Foundation
import IDP
import Pharmacy
import TestUtils
import TrustStore
import VAUClient

class MockUserSession: UserSession {
    lazy var trustStoreSession: TrustStoreSession = DemoTrustStoreSession()
    var mockPrescriptionRepository: PrescriptionRepositoryMock
    var mockIDPSession: IDPSessionMock
    var profileSecureDataWiper: ProfileSecureDataWiper
    var secureUserStore: SecureUserDataStore
    var mockUpdateChecker: UpdateChecker

    var isLoggedIn: Bool
    var profileId: UUID

    init(
        isAuthenticated: Bool = true,
        profileId: UUID = UUID(),
        prescriptionRepository: PrescriptionRepositoryMock = PrescriptionRepositoryMock(),
        idpSession: IDPSessionMock = IDPSessionMock(),
        secureUserStore: SecureUserDataStore = MockSecureUserStore(),
        profileSecureDataWiper: ProfileSecureDataWiper = ProfileSecureDataWiperMock(),
        mockUpdateChecker: UpdateChecker = UpdateChecker { false }
    ) {
        isLoggedIn = isAuthenticated
        self.profileId = profileId
        mockPrescriptionRepository = prescriptionRepository
        mockIDPSession = idpSession
        self.profileSecureDataWiper = profileSecureDataWiper
        self.secureUserStore = secureUserStore
        self.mockUpdateChecker = mockUpdateChecker
    }

    lazy var idpSession: IDPSession = mockIDPSession

    lazy var extAuthRequestStorageMock = ExtAuthRequestStorageMock()

    var extAuthRequestStorage: ExtAuthRequestStorage {
        extAuthRequestStorageMock
    }

    lazy var pairingIdpSession: IDPSession = mockIDPSession

    lazy var vauStorage: VAUStorage = DemoVAUStorage()

    lazy var mockUserDataStore: UserDataStoreMock = .init()

    lazy var shipmentInfoDataStore: ShipmentInfoDataStore = ShipmentInfoDataStoreMock()

    var localUserStore: UserDataStore {
        mockUserDataStore
    }

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = Just(isLoggedIn)
        .setFailureType(to: UserSessionError.self).eraseToAnyPublisher()

    var ordersRepository: OrdersRepository {
        get { underlyingOrdersTaskRepository }
        set(value) { underlyingOrdersTaskRepository = value }
    }

    private var underlyingOrdersTaskRepository: OrdersRepository!

    lazy var mockProfileDataStore: ProfileDataStoreMock = .init()

    lazy var profileDataStore: ProfileDataStore = mockProfileDataStore

    var updateChecker: UpdateChecker {
        mockUpdateChecker
    }

    lazy var nfcHealthCardPasswordController: NFCHealthCardPasswordController = NFCHealthCardPasswordControllerMock()

    lazy var appSecurityManager: AppSecurityManager = AppSecurityManagerMock()

    private(set) lazy var deviceSecurityManager: DeviceSecurityManager = MockDeviceSecurityManager()

    var profileReturnValue: AnyPublisher<Profile, LocalStoreError>!

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        profileReturnValue
    }

    lazy var avsTransactionDataStore: AVSTransactionDataStore = AVSTransactionDataStoreMock()

    lazy var activityIndicating: ActivityIndicating = ActivityIndicatingMock()

    lazy var prescriptionRepository: PrescriptionRepository = mockPrescriptionRepository

    lazy var idpSessionLoginHandler: LoginHandler = LoginHandlerMock()

    lazy var pairingIdpSessionLoginHandler: LoginHandler = LoginHandlerMock()

    var bfarmSession: BfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
}

class MockSecureUserStore: SecureUserDataStore {
    var underlyingKeyIdentifier: AnyPublisher<Data?, Never>!
    var keyIdentifier: AnyPublisher<Data?, Never> {
        underlyingKeyIdentifier.eraseToAnyPublisher()
    }

    var setKeyIdentifierCallsCount = 0
    var setKeyIdentifierCalled: Bool {
        setKeyIdentifierCallsCount > 0
    }

    var setKeyIdentifierReceivedKeyIdentifier: Data?
    var setKeyIdentifierReceivedInvocations: [Data?] = []
    var setKeyIdentifierClosure: ((Data?) -> Void)?

    func set(keyIdentifier: Data?) {
        setKeyIdentifierReceivedKeyIdentifier = keyIdentifier
        setKeyIdentifierCallsCount += 1
        setKeyIdentifierReceivedInvocations.append(keyIdentifier)
        setKeyIdentifierClosure?(keyIdentifier)
    }

    var tokenState: AnyPublisher<IDPToken?, Never>!
    @Published var discoveryState: DiscoveryDocument?
    var can: AnyPublisher<String?, Never> = Just("123123").eraseToAnyPublisher()

    var setCANCalled: Bool {
        setCANCalledCount > 0
    }

    var setCANCalledCount = 0
    func set(can _: String?) {
        setCANCalledCount += 1
    }

    @Published var publishedAccessToken: String? = "123"
    var accessToken: Published<String?>.Publisher {
        $publishedAccessToken
    }

    var setAccessTockenCalled: Bool {
        setAccessTokenCalledCount > 0
    }

    var setAccessTokenCalledCount = 0
    func set(accessToken _: String?) {
        setAccessTokenCalledCount += 1
    }

    var certificate: AnyPublisher<IDPX509?, Never> = Just(nil).eraseToAnyPublisher()

    var setCertificateCalledCount = 0
    func set(certificate _: IDPX509?) {
        setCertificateCalledCount += 1
    }

    var wipeCalledCount = 0
    func wipe() {
        wipeCalledCount += 1
    }

    var setTokenCallsCount = 0
    var setTokenCalled: Bool {
        setKeyIdentifierCallsCount > 0
    }

    var setTokenReceivedSetToken: IDPToken?
    var setTokenReceivedInvocations: [IDPToken?] = []
    var setTokenClosure: ((IDPToken?) -> Void)?
}

extension MockSecureUserStore: IDPStorage {
    var token: AnyPublisher<IDPToken?, Never> {
        tokenState.eraseToAnyPublisher()
    }

    func set(token: IDPToken?) {
        setTokenReceivedSetToken = token
        setTokenCallsCount += 1
        setTokenReceivedInvocations.append(token)
        setTokenClosure?(token)
    }

    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        $discoveryState.eraseToAnyPublisher()
    }

    func set(discovery document: DiscoveryDocument?) {
        discoveryState = document
    }
}

class FakeErxTaskRepository {
    typealias ErrorType = ErxRepositoryError

    var store: [String: ErxTask]
    var chargeItemStore: [String: ErxSparseChargeItem]

    init(
        store: [String: ErxTask] = [:],
        chargeItemStore: [String: ErxSparseChargeItem] = FakeErxTaskRepository.chargeItemsStore
    ) {
        self.store = store
        self.chargeItemStore = chargeItemStore
    }

    func loadRemote(
        by id: ErxTask.ID,
        accessCode _: String?
    ) -> AnyPublisher<ErxTask?, ErrorType> {
        if let result = store[id] {
            return Just(result).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        } else {
            return Empty().setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        }
    }

    func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType> {
        let erxTasks = store.values.compactMap { $0 }
        return Just(erxTasks).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func loadLocal(by id: ErxTask.ID,
                   accessCode _: String?) -> AnyPublisher<ErxTask?, ErrorType> {
        let erxTask = store[id]
        return Just(erxTask).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErrorType> {
        let erxTasks = store.values.compactMap { $0 }
        return Just(erxTasks).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        for task in erxTasks {
            store[task.identifier] = task
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        for task in erxTasks {
            store.removeValue(forKey: task.identifier)
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErrorType> {
        Just(order).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func loadLocalCommunications(for _: ErxTask.Communication
        .Profile)
        -> AnyPublisher<[ErxTask.Communication], ErrorType> {
        Just([]).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func saveLocal(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType> {
        Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func countAllUnreadCommunicationsAndChargeItems(for _: ErxTask.Communication
        .Profile)
        -> AnyPublisher<Int, ErxRepositoryError> {
        Just(0).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    // MARK: - AuditEvents

    func loadRemoteLatestAuditEvents(for _: String?)
        -> AnyPublisher<eRpKit.PagedContent<[eRpKit.ErxAuditEvent]>, eRpKit.ErxRepositoryError> {
        Just(PagedContent(content: [], next: nil)).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func loadRemoteAuditEventsPage(from _: URL,
                                   locale _: String?) -> AnyPublisher<
        eRpKit.PagedContent<[eRpKit.ErxAuditEvent]>,
        eRpKit.ErxRepositoryError
    > {
        Just(PagedContent(content: [], next: nil)).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    // MARK: - ChargeItem

    func loadRemoteChargeItems() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        Just([]).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    // MARK: - fetchConsents

    var fetchConsentsCallsCount = 0
    var fetchConsentsCalled: Bool {
        fetchConsentsCallsCount > 0
    }

    var fetchConsentsReturnValue: AnyPublisher<[ErxConsent], ErxRepositoryError>!
    var fetchConsentsClosure: (() -> AnyPublisher<[ErxConsent], ErxRepositoryError>)?

    func fetchConsents() -> AnyPublisher<[ErxConsent], ErxRepositoryError> {
        fetchConsentsCallsCount += 1
        if let fetchConsentsClosure {
            return fetchConsentsClosure()
        } else {
            return fetchConsentsReturnValue
        }
    }

    // MARK: - grantConsent

    var grantConsentCallsCount = 0
    var grantConsentCalled: Bool {
        grantConsentCallsCount > 0
    }

    var grantConsentReceivedConsent: ErxConsent?
    var grantConsentReceivedInvocations: [ErxConsent] = []
    var grantConsentReturnValue: AnyPublisher<ErxConsent?, ErxRepositoryError>!
    var grantConsentClosure: ((ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError>)?

    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError> {
        grantConsentCallsCount += 1
        grantConsentReceivedConsent = consent
        grantConsentReceivedInvocations.append(consent)
        if let grantConsentClosure {
            return grantConsentClosure(consent)
        } else {
            return grantConsentReturnValue
        }
    }

    // MARK: - revokeConsent

    var revokeConsentCallsCount = 0
    var revokeConsentCalled: Bool {
        revokeConsentCallsCount > 0
    }

    var revokeConsentReceivedCategory: ErxConsent.Category?
    var revokeConsentReceivedInvocations: [ErxConsent.Category] = []
    var revokeConsentReturnValue: AnyPublisher<Bool, ErxRepositoryError>!
    var revokeConsentClosure: ((ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError>)?

    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError> {
        revokeConsentCallsCount += 1
        revokeConsentReceivedCategory = category
        revokeConsentReceivedInvocations.append(category)
        if let revokeConsentClosure {
            return revokeConsentClosure(category)
        } else {
            return revokeConsentReturnValue
        }
    }

    // MARK: - load chargeItems

    func loadLocal(by id: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, eRpKit.ErxRepositoryError> {
        if let result = chargeItemStore[id] {
            return Just(result).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        } else {
            return Empty().setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        }
    }

    func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        let chargeItems = chargeItemStore.values.compactMap { $0 }
        return Just(chargeItems).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func save(chargeItems _: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        for item in chargeItems {
            chargeItemStore.removeValue(forKey: item.identifier)
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func deleteLocal(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        for item in chargeItems {
            chargeItemStore.removeValue(forKey: item.identifier)
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    static let chargeItemsStore: [String: ErxSparseChargeItem] = [
        "1": ErxSparseChargeItem(
            identifier: "1390f983-1e67-11b2-8555-63bf44001234",
            taskId: "task id",
            fhirData: Data("afasf".utf8),
            enteredDate: "2022-11-22T14:07:47.809+00:00"
        ),
    ]

    // MARK: - ErxDeviceRequest.DiGaInfo

    func updateLocal(diGaInfo _: eRpKit.DiGaInfo) -> AnyPublisher<Bool, eRpKit.ErxRepositoryError> {
        Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }
}
