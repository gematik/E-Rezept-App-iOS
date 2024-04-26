//
//  Copyright (c) 2024 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import AVS
import Combine
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IDP
import OpenSSL
import Pharmacy
import TestUtils
import TrustStore
import VAUClient

class MockUserSession: UserSession {
    lazy var trustStoreSession: TrustStoreSession = DemoTrustStoreSession()
    var mockPrescriptionRepository: MockPrescriptionRepository
    var mockIDPSession: IDPSessionMock
    var profileSecureDataWiper: ProfileSecureDataWiper
    var secureUserStore: SecureUserDataStore
    var mockUpdateChecker: UpdateChecker

    var isLoggedIn: Bool
    var profileId: UUID

    init(
        isAuthenticated: Bool = true,
        profileId: UUID = UUID(),
        prescriptionRepository: MockPrescriptionRepository = MockPrescriptionRepository(),
        idpSession: IDPSessionMock = IDPSessionMock(),
        secureUserStore: SecureUserDataStore = MockSecureUserStore(),
        profileSecureDataWiper: ProfileSecureDataWiper = MockProfileSecureDataWiper(),
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

    var isDemoMode: Bool {
        false
    }

    lazy var idpSession: IDPSession = {
        mockIDPSession
    }()

    lazy var extAuthRequestStorageMock = ExtAuthRequestStorageMock()

    var extAuthRequestStorage: ExtAuthRequestStorage {
        extAuthRequestStorageMock
    }

    lazy var pairingIdpSession: IDPSession = {
        mockIDPSession
    }()

    lazy var vauStorage: VAUStorage = {
        DemoVAUStorage()
    }()

    lazy var mockUserDataStore: MockUserDataStore = {
        MockUserDataStore()
    }()

    lazy var shipmentInfoDataStore: ShipmentInfoDataStore = {
        MockShipmentInfoDataStore()
    }()

    var localUserStore: UserDataStore {
        mockUserDataStore
    }

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = Just(isLoggedIn)
        .setFailureType(to: UserSessionError.self).eraseToAnyPublisher()

    lazy var erxTaskRepository: ErxTaskRepository = {
        StreamWrappedErxTaskRepository(stream: Just(FakeErxTaskRepository()).eraseToAnyPublisher())
    }()

    lazy var entireErxTaskRepository: ErxTaskRepository = {
        StreamWrappedErxTaskRepository(stream: Just(FakeErxTaskRepository()).eraseToAnyPublisher())
    }()

    var ordersRepository: OrdersRepository {
        get { underlyingOrdersTaskRepository }
        set(value) { underlyingOrdersTaskRepository = value }
    }

    private var underlyingOrdersTaskRepository: OrdersRepository!

    lazy var mockProfileDataStore: MockProfileDataStore = {
        MockProfileDataStore()
    }()

    lazy var profileDataStore: ProfileDataStore = {
        mockProfileDataStore
    }()

    lazy var pharmacyRepository: PharmacyRepository = {
        MockPharmacyRepository()
    }()

    var updateChecker: UpdateChecker {
        mockUpdateChecker
    }

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        MockNFCSignatureProvider()
    }()

    lazy var nfcHealthCardPasswordController: NFCHealthCardPasswordController = {
        MockNFCHealthCardPasswordController()
    }()

    lazy var appSecurityManager: AppSecurityManager = {
        MockAppSecurityManager()
    }()

    private(set) lazy var deviceSecurityManager: DeviceSecurityManager = {
        MockDeviceSecurityManager()
    }()

    var profileReturnValue: AnyPublisher<Profile, LocalStoreError>!

    func profile() -> AnyPublisher<Profile, LocalStoreError> {
        profileReturnValue
    }

    lazy var avsSession: AVSSession = {
        MockAVSSession()
    }()

    lazy var avsTransactionDataStore: AVSTransactionDataStore = {
        MockAVSTransactionDataStore()
    }()

    lazy var activityIndicating: ActivityIndicating = {
        MockActivityIndicating()
    }()

    lazy var prescriptionRepository: PrescriptionRepository = {
        mockPrescriptionRepository
    }()

    lazy var idpSessionLoginHandler: LoginHandler = {
        MockLoginHandler()
    }()

    lazy var pairingIdpSessionLoginHandler: LoginHandler = {
        MockLoginHandler()
    }()

    lazy var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider = {
        MockSecureEnclaveSignatureProvider()
    }()
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

    var certificate: AnyPublisher<X509?, Never> = Just(nil).eraseToAnyPublisher()

    var setCertificateCalledCount = 0
    func set(certificate _: X509?) {
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

class FakeErxTaskRepository: ErxTaskRepository {
    typealias ErrorType = ErxRepositoryError

    var store: [String: ErxTask]
    var chargeItemStore: [String: ErxSparseChargeItem]

    init(
        store: [String: ErxTask] = FakeErxTaskRepository.exampleStore,
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
        erxTasks.forEach { task in
            store[task.identifier] = task
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        erxTasks.forEach { task in
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
        if let fetchConsentsClosure = fetchConsentsClosure {
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
        if let grantConsentClosure = grantConsentClosure {
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
        if let revokeConsentClosure = revokeConsentClosure {
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
        chargeItems.forEach { item in
            chargeItemStore.removeValue(forKey: item.identifier)
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    static let chargeItemsStore: [String: ErxSparseChargeItem] = {
        [
            "1": ErxSparseChargeItem(
                identifier: "1390f983-1e67-11b2-8555-63bf44001234",
                taskId: "task id",
                fhirData: "afasf".data(using: .utf8)!,
                enteredDate: "2022-11-22T14:07:47.809+00:00"
            ),
        ]

    }()

    static var exampleStore: [String: ErxTask] = {
        let authoredOnNinetyTwoDaysBefore = DemoDate.createDemoDate(.ninetyTwoDaysBefore)
        let authoredOnThirtyDaysBefore = DemoDate.createDemoDate(.thirtyDaysBefore)
        let authoredOnSixteenDaysBefore = DemoDate.createDemoDate(.sixteenDaysBefore)
        let authoredOnWeekBefore = DemoDate.createDemoDate(.weekBefore)
        let expiresIn12DaysString = DemoDate.createDemoDate(.twelveDaysAhead)
        let expiresYesterdayString = DemoDate.createDemoDate(.yesterday)
        let expiresIn31DaysString = DemoDate.createDemoDate(.twentyEightDaysAhead)
        let redeemedOnToday = DemoDate.createDemoDate(.today)
        let handedOverAWeekBefore = DemoDate.createDemoDate(.weekBefore)

        return [
            // Group 1 [0 - 2]
            "0390f983-1e67-11b2-8555-63bf44e44fb8": ErxTask(
                identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Sumatriptan-1a Pharma 100 mg Tabletten",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "1": ErxTask(
                identifier: "1390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Saflorblüten-Extrakt",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "2": ErxTask(
                identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Yucca filamentosa",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Group 2 [3]: archived because expired
            "3": ErxTask(
                identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresYesterdayString,
                author: "Dr. Abgelaufen",
                medication: ErxMedication(
                    name: "Zimtöl",
                    amount: .init(numerator: .init(value: "20")),
                    dosageForm: "AEO"
                )
            ),
            // Group 3 [4 -7]: other authored on date same author
            "4": ErxTask(
                identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Iboprogenal 100+",
                    amount: .init(numerator: .init(value: "10")),
                    dosageForm: "TAB"
                )
            ),
            "5": ErxTask(
                identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Saflorblüten-Extrakt",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "6": ErxTask(
                identifier: "6390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Med. A",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // expired but not jet acceptDate passed
            "7": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresYesterdayString,
                acceptedUntil: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Med. A",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Gruppe 4 [8 - 9]: Redeemed by hand (scanned tasks)
            "8": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f1c",
                status: .completed,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnToday,
                author: nil,
                source: .scanner,
                medication: ErxMedication(
                    name: "Meditonsin 1",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "9": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f2c",
                status: .completed,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnToday,
                author: nil,
                source: .scanner,
                medication: ErxMedication(
                    name: "Meditonsin 2",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Gruppe 5 [10 - 12] other author
            "10": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f3c",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 1",
                    amount: .init(numerator: .init(value: "1")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            "11": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f4c",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 2",
                    amount: .init(numerator: .init(value: "1")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            "12": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f5c",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            // Group 6 [13 -14]: Redeemed by server with medication dispenses
            "13": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                status: .completed,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnNinetyTwoDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "987654321",
                    name: "Dr. Black"
                ),
                medicationDispenses: [ErxMedicationDispense(
                    identifier: "3456789987654",
                    taskId: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                    insuranceId: "ABC",
                    dosageInstruction: "",
                    telematikId: "1234567",
                    whenHandedOver: handedOverAWeekBefore!,
                    medication: ErxMedication(
                        name: "Brausepulver 3",
                        amount: .init(numerator: .init(value: "11")),
                        dosageForm: "TAB"
                    )
                )]
            ),
            "14": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                status: .completed,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnNinetyTwoDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "987654322"
                ),
                medicationDispenses: [
                    ErxMedicationDispense(
                        identifier: "098767825647892",
                        taskId: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                        insuranceId: "ABC",
                        dosageInstruction: "",
                        telematikId: "A12345678",
                        whenHandedOver: handedOverAWeekBefore!,
                        medication: ErxMedication(
                            name: "Brausepulver 3",
                            amount: .init(numerator: .init(value: "6")),
                            dosageForm: "TAB"
                        )
                    ),
                    ErxMedicationDispense(
                        identifier: "098767825647892-2",
                        taskId: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                        insuranceId: "ABC",
                        dosageInstruction: "",
                        telematikId: "A12345678",
                        whenHandedOver: handedOverAWeekBefore!,
                        medication: ErxMedication(
                            name: "Brausepulver 3",
                            amount: .init(numerator: .init(value: "5")),
                            dosageForm: "TAB"
                        )
                    ),
                ]
            ),
        ]
    }()
}
