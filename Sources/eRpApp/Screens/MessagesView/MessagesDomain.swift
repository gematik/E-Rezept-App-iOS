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
import ComposableArchitecture
import eRpKit
import SwiftUI
import ZXingObjC

protocol ResourceHandler {
    func open(_ url: URL)

    func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: ResourceHandler {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}

enum MessagesDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case loadCommunications
    }

    struct State: Equatable {
        var messageDomainStates: IdentifiedArrayOf<MessageDomain.State>
    }

    enum Action: Equatable {
        case subscribeToCommunicationChanges
        case communicationChangeReceived([MessageDomain.State])
        case message(MessageDomain.State.ID, MessageDomain.Action)
        case didReceiveSave(Result<Bool, ErxTaskRepositoryError>)
        case removeSubscription
    }

    struct Environment {
        let schedulers: Schedulers
        let erxTaskRepository: ErxTaskRepositoryAccess
        let application: ResourceHandler
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .subscribeToCommunicationChanges:
            return environment.erxTaskRepository.loadLocalCommunications(for: .reply)
                .receive(on: environment.schedulers.main)
                .catch { _ in Just([ErxTask.Communication]()) }
                .map { taskCommunications in
                    let messageStates = taskCommunications.map { erxTaskCommunication -> MessageDomain.State in
                        MessageDomain.State(communication: erxTaskCommunication)
                    }
                    return MessagesDomain.Action.communicationChangeReceived(messageStates)
                }
                .eraseToEffect()
                .cancellable(id: Token.loadCommunications, cancelInFlight: true)
        case let .communicationChangeReceived(communications):
            state.messageDomainStates = IdentifiedArray(uniqueElements: communications)
            return .none
        case .removeSubscription:
            return cleanup()
        case let .message(messageID, .didSelect):
            guard var erxTaskCommunication = state.messageDomainStates.first(where: { $0.id == messageID })?
                .communication,
                !erxTaskCommunication.isRead else {
                return .none
            }

            erxTaskCommunication.isRead = true
            return environment.erxTaskRepository.saveLocal(communications: [erxTaskCommunication])
                .receive(on: environment.schedulers.main)
                .catchToEffect()
                .map(MessagesDomain.Action.didReceiveSave)

        case .didReceiveSave:
            return .none
        case .message:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        MessageDomain.reducer.forEach( // swiftlint:disable:this trailing_closure
            state: \.messageDomainStates,
            action: /MessagesDomain.Action.message,
            environment: {
                MessageDomain.Environment(
                    schedulers: $0.schedulers,
                    application: $0.application
                )
            }
        ),
        domainReducer
    )
}

extension MessagesDomain {
    enum Dummies {
        static let communicationOnPremise = MessageDomain.State(communication: ErxTask.Communication(
            identifier: "1",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
        ))

        static let communicationShipment = MessageDomain.State(communication: ErxTask.Communication(
            identifier: "2",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.das-e-rezept-fuer-deutschland.de\"}",
            // swiftlint:disable:previous line_length
            isRead: true
        ))

        static let communicationDelivery = MessageDomain.State(communication: ErxTask.Communication(
            identifier: "3",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-29T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
        ))

        static let demoSessionContainer = DummyUserSessionContainer()
        static let state =
            State(messageDomainStates: [communicationOnPremise, communicationShipment, communicationDelivery])
        static let environment = Environment(
            schedulers: Schedulers(),
            erxTaskRepository: demoSessionContainer.userSession.erxTaskRepository,
            application: UIApplication.shared
        )
        static let store = Store(initialState: state,
                                 reducer: domainReducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: MessagesDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
