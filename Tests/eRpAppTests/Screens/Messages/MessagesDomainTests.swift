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
        let expectedUrl =
            URL(
                string: "mailto:app-fehlermeldung@ti-support.de?subject=Error%20message%20from%20the%20e-prescription%20app&body=Dear%20Service%20Team,%20I%20received%20a%20message%20from%20a%20pharmacy.%20Unfortunately,%20however,%20I%20could%20not%20pass%20the%20message%20on%20to%20my%20user%20because%20I%20did%20not%20understand%20it.%20Please%20check%20what%20happened%20here%20and%20help%20us.%20Thank%20you%20very%20much!%20The%20e-prescription%20app%0A%0AYou%20are%20sending%20us%20this%20information%20for%20purposes%20of%20troubleshooting.%20Please%20note%20that%20your%20email%20address%20and%20any%20name%20you%20include%20will%20also%20be%20transferred.%20If%20you%20do%20not%20wish%20to%20transfer%20this%20information%20either%20in%20full%20or%20in%20part,%20please%20remove%20it%20from%20this%20email.%20%0A%0AAll%20data%20will%20only%20be%20stored%20or%20processed%20by%20gematik%20GmbH%20or%20its%20appointed%20companies%20in%20order%20to%20deal%20with%20this%20error%20message.%20Deletion%20takes%20place%20automatically%20a%20maximum%20of%20180%20days%20after%20the%20ticket%20has%20been%20processed.%20We%20will%20use%20your%20email%20address%20exclusively%20to%20contact%20you%20regarding%20this%20error%20message.%20If%20you%20have%20any%20questions,%20or%20require%20an%20earlier%20deletion,%20you%20can%20contact%20the%20data%20protection%20representative%20responsible%20for%20the%20e-prescription%20system.%20You%20can%20find%20further%20information%20in%20the%20menu%20below%20the%20entry%20for%20data%20protection%20in%20the%20e-prescription%20app.%0A%0Awrong%20payload%20format%0A%0AError%2040%2042%2067336%0ATestAppVersion%0A\(timestamp)%0AModel:%20\(deviceInfo.model),%0AOS:\(deviceInfo.systemName)%20\(deviceInfo.version)" // swiftlint:disable:this line_length
            )

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
