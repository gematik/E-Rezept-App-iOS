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
    typealias TestStore = ComposableArchitecture.TestStore<
        MessagesDomain.State,
        MessagesDomain.State,
        MessagesDomain.Action,
        MessagesDomain.Action,
        MessagesDomain.Environment
    >

    private func testStore(
        for repository: MockErxTaskRepositoryAccess
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())

        return TestStore(
            initialState: MessagesDomain.State(messageDomainStates: []),
            reducer: MessagesDomain.domainReducer,
            environment: MessagesDomain.Environment(
                schedulers: schedulers,
                erxTaskRepository: repository,
                application: FailingUIApplication()
            )
        )
    }

    private func repository(with communications: [ErxTask.Communication]) -> MockErxTaskRepositoryAccess {
        let communicationPublisher = Just<[ErxTask.Communication]>(communications)
            .setFailureType(to: ErxTaskRepositoryError.self)
            .eraseToAnyPublisher()
        let savePublisher = Just(true)
            .setFailureType(to: ErxTaskRepositoryError.self)
            .eraseToAnyPublisher()
        return MockErxTaskRepositoryAccess(listCommunications: communicationPublisher,
                                           saveCommunications: savePublisher)
    }

    func testMessagesDomainWithoutMessages() {
        let mockRepositoryAccess = repository(with: [])
        let store = testStore(for: mockRepositoryAccess)

        store.send(.subscribeToCommunicationChanges) {
            $0.messageDomainStates = []
        }
        store.receive(.communicationChangeReceived([])) {
            $0.messageDomainStates = []
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
        }
    }

    func testSelectingAnUnreadOnPremiseCommunication() {
        let input = [unreadOnPremiseCommunication]
        let expected = [MessageDomain.State(communication: unreadOnPremiseCommunication)]

        let mockRepositoryAccess = repository(with: input)
        let store = testStore(for: mockRepositoryAccess)

        store.send(.subscribeToCommunicationChanges) {
            $0.messageDomainStates = []
        }
        store.receive(.communicationChangeReceived(expected)) { state in
            state.messageDomainStates = IdentifiedArray(expected)
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
            expect(mockRepositoryAccess.saveCommunicationsCallsCount) == 0
        }
        store.send(.message(unreadOnPremiseCommunication.id, .didSelect)) {
            $0.messageDomainStates = IdentifiedArray(expected)
        }
        store.receive(.didReceiveSave(.success(true))) {
            $0.messageDomainStates = IdentifiedArray(expected)
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
            expect(mockRepositoryAccess.saveCommunicationsCallsCount) == 1
        }
    }

    func testSelectingAnUnreadCommunication() {
        let input = [readShipmentCommunication]
        let expected = [MessageDomain.State(communication: readShipmentCommunication)]

        let mockRepositoryAccess = repository(with: input)
        let store = testStore(for: mockRepositoryAccess)

        store.send(.subscribeToCommunicationChanges) {
            $0.messageDomainStates = []
        }
        store.receive(.communicationChangeReceived(expected)) { state in
            state.messageDomainStates = IdentifiedArray(expected)
            expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
            expect(mockRepositoryAccess.saveCommunicationsCallsCount) == 0
        }

        store.send(.message(readShipmentCommunication.id, .didSelect)) {
            $0.messageDomainStates = IdentifiedArray(expected)
        }
        expect(mockRepositoryAccess.listCommunicationsCallsCount) == 1
        expect(mockRepositoryAccess.saveCommunicationsCallsCount) == 0
    }

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

    let readShipmentCommunication = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}",
        // swiftlint:disable:previous line_length
        isRead: true
    )
}
