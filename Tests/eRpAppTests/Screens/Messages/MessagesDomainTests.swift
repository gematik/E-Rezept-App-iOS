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

import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class MessagesDomainTests: XCTestCase {
    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    let mockRepository = MockErxTaskRepository(
        saveCommunications: Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    )
    let mockApplication = MockUIApplication()
    typealias TestStore = ComposableArchitecture.TestStore<
        MessagesDomain.State,
        MessagesDomain.State,
        MessagesDomain.Action,
        MessagesDomain.Action,
        MessagesDomain.Environment
    >

    private func testStore(
        for repository: MockErxTaskRepository
    ) -> TestStore {
        TestStore(
            initialState: MessagesDomain.State(communications: []),
            reducer: MessagesDomain.domainReducer,
            environment: MessagesDomain.Environment(
                schedulers: schedulers,
                erxTaskRepository: repository,
                application: FailingUIApplication()
            )
        )
    }

    private func testStore(
        for communications: IdentifiedArrayOf<ErxTask.Communication>,
        resourceHandler: ResourceHandler = FailingUIApplication()
    ) -> TestStore {
        TestStore(
            initialState: MessagesDomain.State(communications: communications),
            reducer: MessagesDomain.domainReducer,
            environment: MessagesDomain.Environment(
                schedulers: schedulers,
                erxTaskRepository: mockRepository,
                application: resourceHandler
            )
        )
    }

    private func repository(with communications: [ErxTask.Communication]) -> MockErxTaskRepository {
        let communicationPublisher = Just<[ErxTask.Communication]>(communications)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        let savePublisher = Just(true)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        return MockErxTaskRepository(listCommunications: communicationPublisher,
                                     saveCommunications: savePublisher)
    }

    func testMessagesDomainSubscriptionWithoutMessages() {
        let mockRepositoryAccess = repository(with: [])
        let store = testStore(for: mockRepositoryAccess)

        store.send(.subscribeToCommunicationChanges)
        store.receive(.communicationChangeReceived([])) {
            $0.communications = []
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
        }
    }

    func testMessagesDomainSubscriptionWithMessages() {
        let expected = [unreadOnPremiseCommunication]

        let mockRepositoryAccess = repository(with: expected)
        let store = testStore(for: mockRepositoryAccess)

        store.send(.subscribeToCommunicationChanges)
        store.receive(.communicationChangeReceived(expected)) { state in
            state.communications = IdentifiedArray(uniqueElements: expected)
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
            expect(mockRepositoryAccess.saveCommunicationsCallsCount) == 0
        }
    }

    func testSelectingUnreadOnPremiseCommunicationMessage() {
        let input = IdentifiedArrayOf(uniqueElements: [communicationOnPremise])
        let store = testStore(for: input)

        store.send(.didSelect(communicationOnPremise.id))
        store.receive(.showPickupCode(dmcCode: "DMC-4711-and-more", hrCode: "4711")) {
            $0.communications = input
            $0.route = .pickupCode(
                .init(
                    pickupCodeHR: "4711",
                    pickupCodeDMC: "DMC-4711-and-more",
                    dmcImage: nil
                )
            )
        }
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
        store.send(.setNavigation(tag: .none)) {
            $0.communications = IdentifiedArrayOf(uniqueElements: input)
            $0.route = nil
        }
    }

    func testSelectingReadOnPremiseCommunicationMessage() {
        var communication = communicationOnPremise
        communication.isRead = true
        let store = testStore(for: [communication])

        store.send(.didSelect(communicationOnPremise.id))
        store.receive(.showPickupCode(dmcCode: "DMC-4711-and-more", hrCode: "4711")) {
            $0.communications = [communication]
            $0.route = .pickupCode(
                .init(
                    pickupCodeHR: "4711",
                    pickupCodeDMC: "DMC-4711-and-more",
                    dmcImage: nil
                )
            )
        }
        expect(self.mockRepository.saveCommunicationsCallsCount) == 0
    }

    func testSelectingUnreadMessageWithShipmentCommunication() {
        let input = IdentifiedArrayOf(uniqueElements: [communicationShipment])
        let store = testStore(for: input, resourceHandler: mockApplication)

        store.send(.didSelect(communicationShipment.id))
        let expectedUrl = URL(string: "https://www.das-e-rezept-fuer-deutschland.de")!
        store.receive(.openUrl(url: expectedUrl))
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openUrlParameter) == expectedUrl
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
    }

    func testSelectingReadMessageWithShipmentCommunication() {
        var communication = communicationShipment
        communication.isRead = true
        let input = IdentifiedArrayOf(uniqueElements: [communication])
        let store = testStore(for: input, resourceHandler: mockApplication)

        store.send(.didSelect(communication.id))
        let expectedUrl = URL(string: "https://www.das-e-rezept-fuer-deutschland.de")!
        store.receive(.openUrl(url: expectedUrl))
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openUrlParameter) == expectedUrl
        expect(self.mockRepository.saveCommunicationsCallsCount) == 0
    }

    func testSelectingShipmentCommunicationWithWrongUrl() {
        let expectedUrl = URL(string: "www.invalid-url.de")!
        let input = IdentifiedArrayOf(uniqueElements: [communicationShipmentInvalidUrl])
        mockApplication.canOpenURLReturnValue = false
        let store = testStore(for: input, resourceHandler: mockApplication)

        store.send(.didSelect(communicationShipmentInvalidUrl.id))
        store.receive(.openUrl(url: expectedUrl)) { state in
            state.route = .alert(MessagesDomain.openUrlAlertState(for: expectedUrl))
        }
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 0
        expect(self.mockApplication.openUrlParameter).to(beNil())
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
    }

    func testSelectingUnreadMessagesWithDeliveryCommunication() {
        let input = IdentifiedArrayOf(uniqueElements: [communicationDelivery])
        let store = testStore(for: input)

        store.send(.didSelect(communicationDelivery.id))
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
    }

    func testSelectingReadMessagesWithDeliveryCommunication() {
        var communication = communicationDelivery
        communication.isRead = true
        let input = IdentifiedArrayOf(uniqueElements: [communication])
        let store = testStore(for: input)

        store.send(.didSelect(communication.id))
        expect(self.mockRepository.saveCommunicationsCallsCount) == 0
    }

    func testMessageWithWrongPayloadFormat() {
        let date = Date()
        let timestamp = date.fhirFormattedString(with: .yearMonthDayTime)
        let deviceInfo = MessagesDomain.DeviceInformations(
            model: "TestModel",
            systemName: "TestSystem",
            version: "TestOSVersion"
        )
        // swiftlint:disable line_length
        let expectedUrl = URL(
            string:
            "mailto:app-fehlermeldung@ti-support.de?subject=Fehlermeldung%20aus%20der%20E-Rezept%20App&body=Liebes%20Service-Team,%20ich%20habe%20eine%20Nachricht%20von%20einer%20Apotheke%20erhalten.%20Leider%20konnte%20ich%20meinem%20Nutzer%20die%20Nachricht%20aber%20nicht%20mitteilen,%20da%20ich%20sie%20nicht%20verstanden%20habe.%20Bitte%20pr%C3%BCft,%20was%20hier%20passiert%20ist,%20und%20helft%20uns.%20Vielen%20Dank!%20Die%20E-Rezept%20App%0A%0ASie%20senden%20uns%20diese%20Informationen%20zum%20Zwecke%20der%20Fehlersuche.%20Bitte%20beachten%20Sie,%20dass%20auch%20Ihre%20Mailadresse%20sowie%20ggf.%20Ihr%20darin%20enthaltener%20Name%20%C3%BCbertragen%20wird.%20Wenn%20Sie%20diese%20Informationen%20ganz%20oder%20teilweise%20nicht%20%C3%BCbermitteln%20m%C3%B6chten,%20l%C3%B6schen%20Sie%20diese%20bitte%20aus%20dieser%20Mail.%20%0A%0AAlle%20Daten%20werden%20von%20der%20gematik%20GmbH%20oder%20deren%20beauftragten%20Unternehmen%20nur%20zur%20Bearbeitung%20dieser%20Fehlermeldung%20gespeichert%20und%20verarbeitet.%20Die%20L%C3%B6schung%20erfolgt%20automatisiert,%20sp%C3%A4testens%20180%20Tage%20nach%20Bearbeitung%20des%20Tickets.%20Ihre%20Mailadresse%20nutzen%20wir%20ausschlie%C3%9Flich,%20um%20mit%20Ihnen%20Kontakt%20in%20Bezug%20auf%20diese%20Fehlermeldung%20aufzunehmen.%20F%C3%BCr%20Fragen%20oder%20eine%20vorzeitige%20L%C3%B6schung%20k%C3%B6nnen%20Sie%20sich%20jederzeit%20an%20den%20Datenschutzverantwortlichen%20des%20E-Rezept%20Systems%20wenden.%20Sie%20finden%20weitere%20Informationen%20in%20der%20E-Rezept%20App%20im%20Men%C3%BC%20unter%20dem%20Datenschutz-Eintrag.%0A%0Awrong%20payload%20format%0A%0AFehler%2040%2042%2067336%0ATestAppVersion%0A\(timestamp)%0AModel:%20\(deviceInfo.model),%0AOS:\(deviceInfo.systemName)%20\(deviceInfo.version)"
        )
        // swiftlint:enable line_length

        let input = IdentifiedArrayOf(uniqueElements: [communicationWithWrongPayload])
        let store = TestStore(
            initialState: MessagesDomain.State(communications: input),
            reducer: MessagesDomain.domainReducer,
            environment: MessagesDomain.Environment(
                schedulers: schedulers,
                erxTaskRepository: mockRepository,
                application: mockApplication,
                date: date,
                deviceInfo: deviceInfo,
                version: "TestAppVersion"
            )
        )

        store.send(.didSelect(communicationWithWrongPayload.id))
        store.receive(.openMail(message: "wrong payload format"))
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openUrlParameter) == expectedUrl
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
    }

    let communicationOnPremise = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\",\"pickUpCodeHR\":\"4711\",\"pickUpCodeDMC\":\"DMC-4711-and-more\" }" // swiftlint:disable:this line_length
    )

    let communicationShipment = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}"
        // swiftlint:disable:previous line_length
    )

    let communicationDelivery = ErxTask.Communication(
        identifier: "3",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-29T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
    )

    let communicationWithWrongPayload = ErxTask.Communication(
        identifier: "4",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-30T10:59:37.098245933+00:00",
        payloadJSON: "wrong payload format"
    )

    let communicationShipmentInvalidUrl = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.invalid-url.de\"}"
        // swiftlint:disable:previous line_length
    )

    let unreadOnPremiseCommunication = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\",\"pickUpCodeHR\":\"4711\",\"pickUpCodeDMC\":\"DMC-4711-and-more\" }",
        // swiftlint:disable:previous line_length
        isRead: false
    )
}
