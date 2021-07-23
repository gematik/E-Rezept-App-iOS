//
//  Copyright (c) 2021 gematik GmbH
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

import Combine
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IDP
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient

class MockUserSession: UserSession {
    lazy var trustStoreSession: TrustStoreSession = DemoTrustStoreSession()

    private var isLoggedIn: Bool

    init(isAuthenticated: Bool = true) {
        isLoggedIn = isAuthenticated
    }

    var isDemoMode: Bool {
        false
    }

    lazy var idpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    lazy var biometrieIdpSession: IDPSession = {
        DemoIDPSession(storage: secureUserStore)
    }()

    lazy var vauStorage: VAUStorage = {
        DemoVAUStorage()
    }()

    lazy var secureUserStore: SecureUserDataStore = {
        MockSecureUserStore()
    }()

    lazy var localUserStore: UserDataStore = {
        MockUserDataStore()
    }()

    lazy var hintEventsStore: EventsStore = {
        MockHintEventsStore()
    }()

    lazy var isAuthenticated: AnyPublisher<Bool, UserSessionError> = Just(isLoggedIn)
            .setFailureType(to: UserSessionError.self).eraseToAnyPublisher()

    lazy var erxTaskRepository: ErxTaskRepositoryAccess = {
        AnyErxTaskRepository(Just(MockErxTaskRepository()).eraseToAnyPublisher())
    }()

    lazy var pharmacyRepository: PharmacyRepository = {
        MockPharmacyRepository()
    }()

    lazy var nfcSessionProvider: NFCSignatureProvider = {
        NFCSignatureProviderMock()
    }()
}

class MockHintEventsStore: EventsStore {
    var hintStatePublisher: AnyPublisher<HintState, Never> =
            Just(HintState()).eraseToAnyPublisher()

    var hintState = HintState()
}

class MockUserDataStore: UserDataStore {
    var hideOnboarding: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func set(hideOnboarding _: Bool) {
        // Do nothing
    }

    var hideCardWallIntro: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func set(hideCardWallIntro _: Bool) {
        // Do nothing
    }

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> = Just(nil).eraseToAnyPublisher()
    func set(serverEnvironmentConfiguration _: String?) {
        // Do nothing
    }

    var appSecurityOption: AnyPublisher<Int, Never> = Just(0).eraseToAnyPublisher()
    /// The app security option
    func set(appSecurityOption _: Int) {
        // Do nothing
    }
}

// TODO: Maybe MockSecureUserStore can be removed? swiftlint:disable:this todo
// It has been removed from DemoIDPSession. Check if it is used otherwise
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
    func searchPharmacies(searchTerm: String, position: Position?)
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

class MockErxTaskRepository: ErxTaskRepository {
    typealias ErrorType = ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType>

    func loadRemote(
        by id: ErxTask.ID, // swiftlint:disable:this identifier_name
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

    func loadLocal(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
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

    func redeem(orders _: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType> {
        Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
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
        -> AnyPublisher<Int, ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType>> {
        Just(0).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    var store: [String: ErxTask] = {
        let authoredOnFirstBlock = "2020-09-20T14:34:29+00:00"
        let authoredOnYesterdayBlock = "2021-01-19T14:34:29+00:00"
        let authoredOnTodayBlock = "2021-01-20T14:34:29+00:00"
        let expiresIn12DaysString = "2020-10-02T14:34:29+00:00"
        let expiresYesterdayString = "2021-01-19T14:34:29+00:00"
        let expiresIn31DaysString = "2021-02-20T14:34:29+00:00"
        let redeemedOnTodayBlock = "2021-01-20T14:34:29+00:00"

        return [
            "0390f983-1e67-11b2-8555-63bf44e44fb8": ErxTask(
                identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnFirstBlock,
                expiresOn: expiresIn12DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Sumatriptan-1a Pharma 100 mg Tabletten",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "1": ErxTask(
                identifier: "1390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnFirstBlock,
                expiresOn: expiresIn31DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Saflorblüten-Extrakt",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "2": ErxTask(
                identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnTodayBlock,
                expiresOn: expiresIn12DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Yucca filamentosa",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "3": ErxTask(
                identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnFirstBlock,
                expiresOn: expiresYesterdayString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Zimtöl",
                    amount: 20,
                    dosageForm: "AEO"
                )
            ),
            "4": ErxTask(
                identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: "Praxis Dr. med. Karin Hasenbein",
                medication: ErxTask.Medication(
                    name: "Iboprogenal 100+",
                    amount: 10,
                    dosageForm: "TAB"
                )
            ),
            "5": ErxTask(
                identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnTodayBlock,
                expiresOn: expiresIn31DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Saflorblüten-Extrakt",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "6": ErxTask(
                identifier: "6390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnFirstBlock,
                expiresOn: expiresIn31DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: nil,
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "7": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44fb8",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnFirstBlock,
                expiresOn: expiresIn12DaysString,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: nil,
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "8": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f1c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnTodayBlock,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Meditonsin 1",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "9": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f2d",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnTodayBlock,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: ErxTask.Medication(
                    name: "Meditonsin 2",
                    amount: 12,
                    dosageForm: "TAB"
                )
            ),
            "10": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f3c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: nil,
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
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f3c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: nil,
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
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f4c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: nil,
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
            "13": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f5c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: nil,
                medication: ErxTask.Medication(
                    name: "Brausepulver 3",
                    amount: 11,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
                    lanr: "987654321",
                    name: "Dr. Black"
                )
            ),
            "14": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnYesterdayBlock,
                expiresOn: expiresIn12DaysString,
                author: nil,
                medication: ErxTask.Medication(
                    name: "Brausepulver 3",
                    amount: 11,
                    dosageForm: "TAB"
                ),
                practitioner: ErxTask.Practitioner(
                    lanr: "987654322"
                )
            ),
        ]
    }()
}
