//
//  Copyright (c) 2022 gematik GmbH
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
@testable import eRpApp
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

    var isLoggedIn: Bool
    var profileId: UUID

    init(isAuthenticated: Bool = true, profileId: UUID = UUID()) {
        isLoggedIn = isAuthenticated
        self.profileId = profileId
    }

    var isDemoMode: Bool {
        false
    }

    lazy var idpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    lazy var extAuthRequestStorageMock = ExtAuthRequestStorageMock()

    var extAuthRequestStorage: ExtAuthRequestStorage {
        extAuthRequestStorageMock
    }

    var biometrieIdpSession: IDPSession = IDPSessionMock()

    lazy var vauStorage: VAUStorage = {
        DemoVAUStorage()
    }()

    lazy var secureUserStore: SecureUserDataStore = {
        MockSecureUserStore()
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

    lazy var hintEventsStore: EventsStore = {
        MockHintEventsStore()
    }()

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = Just(isLoggedIn)
        .setFailureType(to: UserSessionError.self).eraseToAnyPublisher()

    lazy var erxTaskRepository: ErxTaskRepository = {
        StreamWrappedErxTaskRepository(stream: Just(FakeErxTaskRepository()).eraseToAnyPublisher())
    }()

    lazy var mockProfileDataStore: MockProfileDataStore = {
        MockProfileDataStore()
    }()

    lazy var profileDataStore: ProfileDataStore = {
        mockProfileDataStore
    }()

    lazy var pharmacyRepository: PharmacyRepository = {
        MockPharmacyRepository()
    }()

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        NFCSignatureProviderMock()
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

    var profileSecureDataWiper: ProfileSecureDataWiper = MockProfileSecureDataWiper()

    lazy var avsSession: AVSSession = {
        MockAVSSession()
    }()
}

class MockHintEventsStore: EventsStore {
    var hintStatePublisher: AnyPublisher<HintState, Never> =
        Just(HintState()).eraseToAnyPublisher()

    var hintState = HintState()
}

class MockSecureUserStore: SecureUserDataStore {
    @Published var publishedKeyIdentifier: Data?
    var keyIdentifier: AnyPublisher<Data?, Never> {
        $publishedKeyIdentifier.eraseToAnyPublisher()
    }

    func set(keyIdentifier: Data?) {
        publishedKeyIdentifier = keyIdentifier
    }

    var tokenState: CurrentValueSubject<IDPToken?, Never> = CurrentValueSubject(nil)
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
}

extension MockSecureUserStore: IDPStorage {
    var token: AnyPublisher<IDPToken?, Never> {
        tokenState.eraseToAnyPublisher()
    }

    func set(token: IDPToken?) {
        tokenState.value = token
    }

    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        $discoveryState.eraseToAnyPublisher()
    }

    func set(discovery document: DiscoveryDocument?) {
        discoveryState = document
    }
}

class MockPharmacyRepository: PharmacyRepository {
    func searchPharmacies(searchTerm: String,
                          position: Position?,
                          filter _: [PharmacyRepositoryFilter])
        -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        let filteredResult = store.filter { pharmacy in
            if !searchTerm.isEmpty,
               let pharmName = pharmacy.name,
               let position = position {
                return pharmName.lowercased().contains(searchTerm.lowercased())
                    && pharmacy.position?.latitude?.doubleValue == position.latitude
                    && pharmacy.position?.longitude?.doubleValue == position.longitude
            } else if !searchTerm.isEmpty,
                      let pharmName = pharmacy.name {
                return pharmName.lowercased().contains(searchTerm.lowercased())
            } else if let position = position,
                      let aLat = pharmacy.position?.latitude?.doubleValue,
                      let aLon = pharmacy.position?.longitude?.doubleValue {
                return fabs(aLat - position.latitude) < 0.1 && fabs(aLon - position.longitude) < 0.1
            } else {
                return false
            }
        }
        return Just(filteredResult).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
    }

    var store: [PharmacyLocation] = PharmacyLocation.Dummies.pharmacies
}

class FakeErxTaskRepository: ErxTaskRepository {
    typealias ErrorType = ErxRepositoryError

    var store: [String: ErxTask]
    init(store: [String: ErxTask] = FakeErxTaskRepository.exampleStore) {
        self.store = store
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
            store[task.identifier] = task
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

    func countAllUnreadCommunications(for _: ErxTask.Communication
        .Profile)
        -> AnyPublisher<Int, ErxRepositoryError> {
        Just(0).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

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
                medication: ErxTask.Medication(
                    name: "Sumatriptan-1a Pharma 100 mg Tabletten",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Saflorblüten-Extrakt",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Yucca filamentosa",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Zimtöl",
                    amount: 20,
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
                medication: ErxTask.Medication(
                    name: "Iboprogenal 100+",
                    amount: 10,
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
                medication: ErxTask.Medication(
                    name: "Saflorblüten-Extrakt",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Med. A",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Med. A",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Meditonsin 1",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Meditonsin 2",
                    amount: 12,
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
                medication: ErxTask.Medication(
                    name: "Brausepulver 1",
                    amount: 1,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
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
                medication: ErxTask.Medication(
                    name: "Brausepulver 2",
                    amount: 1,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
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
                medication: ErxTask.Medication(
                    name: "Brausepulver 3",
                    amount: 11,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
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
                medication: ErxTask.Medication(
                    name: "Brausepulver 3",
                    amount: 11,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
                    lanr: "987654321",
                    name: "Dr. Black"
                ),
                medicationDispense: ErxTask.MedicationDispense(
                    taskId: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                    insuranceId: "ABC",
                    pzn: "X123456",
                    name: "Brausepulver 4",
                    dose: "",
                    dosageForm: "TAB",
                    dosageInstruction: "",
                    amount: 11,
                    telematikId: "1234567",
                    whenHandedOver: handedOverAWeekBefore!
                )
            ),
            "14": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                status: .completed,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnNinetyTwoDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxTask.Medication(
                    name: "Brausepulver 3",
                    amount: 11,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
                    lanr: "987654322"
                ),
                medicationDispense: ErxTask.MedicationDispense(
                    taskId: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                    insuranceId: "ABC",
                    pzn: "X123456",
                    name: "Brausepulver 3",
                    dose: "",
                    dosageForm: "TAB",
                    dosageInstruction: "",
                    amount: 11,
                    telematikId: "1234567",
                    whenHandedOver: handedOverAWeekBefore!
                )
            ),
        ]
    }()
}
