//
//  Copyright (c) 2023 gematik GmbH
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

final class OrderDetailDomainTests: XCTestCase {
    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    let mockRepository = MockErxTaskRepository(
        find: Just(ErxTask.Demo.erxTask1).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher(),
        saveCommunications: Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    )
    let mockApplication = MockResourceHandler()
    typealias TestStore = ComposableArchitecture.TestStore<
        OrderDetailDomain.State,
        OrderDetailDomain.Action,
        OrderDetailDomain.State,
        OrderDetailDomain.Action,
        Void
    >

    private func testStore(
        for repository: MockErxTaskRepository
    ) -> TestStore {
        TestStore(
            initialState: OrderDetailDomain.State(order: .init(orderId: "765432", communications: [])),
            reducer: OrderDetailDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = DummySessionContainer()
            dependencies.erxTaskRepository = repository
            dependencies.resourceHandler = UnimplementedResourceHandler()
        }
    }

    private func testStore(
        for order: OrderCommunications,
        resourceHandler: ResourceHandler = UnimplementedResourceHandler()
    ) -> TestStore {
        TestStore(
            initialState: OrderDetailDomain.State(order: order),
            reducer: OrderDetailDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = DummySessionContainer()
            dependencies.erxTaskRepository = mockRepository
            dependencies.resourceHandler = resourceHandler
        }
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

    func testMarkCommunicationsRead() {
        let orderId = "12343-1236-432"
        let input = [OrderDetailDomainTests.communicationShipmentUnread]
        let store = testStore(
            for: .init(orderId: orderId, communications: input),
            resourceHandler: mockApplication
        )

        store.send(.didReadCommunications)
        expect(self.mockRepository.saveCommunicationsCallsCount) == 1
    }

    func testLoadTasks() {
        let orderId = "12343-1236-432"
        let input = [OrderDetailDomainTests.communicationShipment]
        let tasks = [ErxTask.Demo.erxTask1]
        let store = testStore(
            for: .init(orderId: orderId, communications: input),
            resourceHandler: mockApplication
        )

        store.send(.loadTasks)
        store.receive(.tasksReceived(tasks)) {
            $0.erxTasks = IdentifiedArrayOf(uniqueElements: tasks)
        }
    }

    func testOpenPhoneApp() {
        let pharmacy = PharmacyLocation.Dummies.pharmacy
        let store = testStore(
            for: .init(
                orderId: "123",
                communications: [],
                pharmacy: pharmacy
            ),
            resourceHandler: mockApplication
        )

        store.send(.openPhoneApp)
        expect(self.mockApplication.openCallsCount) == 1
        guard let phone = pharmacy.telecom?.phone else {
            XCTFail("phone number is not present")
            return
        }
        expect(self.mockApplication.openReceivedUrl) == URL(phoneNumber: phone)
    }

    func testOpenMailApp() {
        let pharmacy = PharmacyLocation.Dummies.pharmacy
        let store = testStore(
            for: .init(
                orderId: "123",
                communications: [],
                pharmacy: pharmacy
            ),
            resourceHandler: mockApplication
        )

        store.send(.openMailApp)
        expect(self.mockApplication.openCallsCount) == 1
        guard let email = pharmacy.telecom?.email else {
            XCTFail("email address is not present")
            return
        }
        expect(self.mockApplication.openReceivedUrl) == URL(string: "mailto:\(email)?")
    }

    func testSelectingMedication() {
        let input = ErxTask.Demo.erxTask1
        let store = testStore(for: .init(orderId: "123", communications: []))

        store.send(.didSelectMedication(input)) { state in
            state.destination = .prescriptionDetail(
                .init(
                    prescription: Prescription(erxTask: input),
                    isArchived: false
                )
            )
        }
    }

    func testSelectingPickupCode() {
        let input = OrderCommunications(
            orderId: "123",
            communications: [OrderDetailDomainTests.communicationOnPremise]
        )
        let store = testStore(for: input)

        store.send(.showPickupCode(dmcCode: "DMC-4711-and-more", hrCode: "4711")) {
            $0.order = input
            $0.destination = .pickupCode(
                .init(
                    pickupCodeHR: "4711",
                    pickupCodeDMC: "DMC-4711-and-more",
                    dmcImage: nil
                )
            )
        }
        store.send(.setNavigation(tag: .none)) {
            $0.order = input
            $0.destination = nil
        }
    }

    func testSelectingValidUrl() {
        let orderId = "12343-1236-432"
        let input = [OrderDetailDomainTests.communicationShipment]
        let store = testStore(
            for: .init(orderId: orderId, communications: input),
            resourceHandler: mockApplication
        )

        let expectedUrl = URL(string: "https://www.das-e-rezept-fuer-deutschland.de")!
        store.send(.showOpenUrlSheet(url: expectedUrl)) { state in
            state.openUrlSheetUrl = expectedUrl
        }
        mockApplication.canOpenURLReturnValue = true

        store.send(.openUrl(url: expectedUrl))
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openReceivedUrl) == expectedUrl
    }

    func testSelectingInvalidUrl() {
        let orderId = "12343-1236-432"
        let expectedUrl = URL(string: "www.invalid-url.de")!
        let input = [OrderDetailDomainTests.communicationShipmentInvalidUrl]
        mockApplication.canOpenURLReturnValue = false
        let store = testStore(
            for: .init(orderId: orderId, communications: input),
            resourceHandler: mockApplication
        )

        store.send(.showOpenUrlSheet(url: expectedUrl)) { state in
            state.openUrlSheetUrl = expectedUrl
        }
        store.send(.openUrl(url: expectedUrl)) { state in
            state.destination = .alert(OrderDetailDomain.openUrlAlertState(for: expectedUrl))
        }
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 0
        expect(self.mockApplication.openReceivedUrl).to(beNil())
    }

    func testCommunicationWithWrongPayloadFormat() {
        let date = Date()
        let timestamp = date.fhirFormattedString(with: .yearMonthDayTime)
        let deviceInfo = OrderDetailDomain.DeviceInformations(
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

        let orderId = "12343-1236-432"
        let input = [OrderDetailDomainTests.communicationWithWrongPayload]
        let store = TestStore(
            initialState: OrderDetailDomain.State(order: .init(orderId: orderId, communications: input)),
            reducer: OrderDetailDomain(deviceInfo: deviceInfo)
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = DummySessionContainer()
            dependencies.erxTaskRepository = mockRepository
            dependencies.resourceHandler = mockApplication
            dependencies.dateProvider = { date }
            dependencies.currentAppVersion = AppVersion(
                productVersion: "TestAppVersion",
                buildNumber: "",
                buildHash: ""
            )
        }
        mockApplication.canOpenURLReturnValue = true
        store.send(.openMail(message: "wrong payload format"))
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openReceivedUrl) == expectedUrl
    }
}

extension OrderDetailDomainTests {
    static let communicationOnPremise = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\",\"pickUpCodeHR\":\"4711\",\"pickUpCodeDMC\":\"DMC-4711-and-more\" }" // swiftlint:disable:this line_length
    )

    static let communicationShipment = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}"
        // swiftlint:disable:previous line_length
    )

    static let communicationDelivery = ErxTask.Communication(
        identifier: "3",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-29T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
    )

    static let communicationWithWrongPayload = ErxTask.Communication(
        identifier: "4",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-30T10:59:37.098245933+00:00",
        payloadJSON: "wrong payload format"
    )

    static let communicationShipmentInvalidUrl = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.invalid-url.de\"}"
        // swiftlint:disable:previous line_length
    )

    static let communicationShipmentUnread = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}",
        // swiftlint:disable:previous line_length
        isRead: false
    )
}
