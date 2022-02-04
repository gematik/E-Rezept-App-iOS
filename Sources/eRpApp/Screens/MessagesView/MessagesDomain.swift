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

    enum Route: Equatable {
        case pickupCode(PickupCodeDomain.State)
        case alert(AlertState<Action>)

        enum Tag: Int {
            case pickupCode
            case alert
        }

        var tag: Tag {
            switch self {
            case .pickupCode:
                return .pickupCode
            case .alert:
                return .alert
            }
        }
    }

    struct State: Equatable {
        var communications: IdentifiedArrayOf<ErxTask.Communication>
        var route: Route?
    }

    enum Action: Equatable {
        case subscribeToCommunicationChanges
        case communicationChangeReceived([ErxTask.Communication])
        case didSelect(String)
        case setNavigation(tag: Route.Tag?)
        case removeSubscription

        case showPickupCode(dmcCode: String?, hrCode: String?)
        case pickupCode(action: PickupCodeDomain.Action)
        case openUrl(url: URL)
        case openMail(message: String)
    }

    struct Environment {
        internal init(schedulers: Schedulers,
                      erxTaskRepository: ErxTaskRepository,
                      application: ResourceHandler,
                      date: Date = Date(),
                      deviceInfo: MessagesDomain.DeviceInformations = DeviceInformations(),
                      version: String = AppVersion.current.description) {
            self.schedulers = schedulers
            self.erxTaskRepository = erxTaskRepository
            self.application = application
            self.date = date
            self.deviceInfo = deviceInfo
            self.version = version
        }

        let schedulers: Schedulers
        let erxTaskRepository: ErxTaskRepository
        let application: ResourceHandler
        let date: Date
        let deviceInfo: DeviceInformations
        let version: String

        func setReadState(for communication: ErxTask.Communication) -> Effect<Bool, ErxRepositoryError> {
            guard !communication.isRead else { return Effect.none }
            var communication = communication
            communication.isRead = true
            return erxTaskRepository.saveLocal(communications: [communication])
                .receive(on: schedulers.main)
                .eraseToEffect()
        }
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .subscribeToCommunicationChanges:
            return environment.erxTaskRepository.loadLocalCommunications(for: .reply)
                .catch { _ in Just([ErxTask.Communication]()) }
                .map(MessagesDomain.Action.communicationChangeReceived)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.loadCommunications, cancelInFlight: true)
        case let .communicationChangeReceived(communications):
            state.communications = IdentifiedArray(uniqueElements: communications)
            return .none
        case .removeSubscription:
            return cleanup()
        case let .didSelect(communicationId):
            guard let selectedCommunication = state.communications[id: communicationId] else {
                return .none
            }
            return Effect.concatenate(
                effect(for: selectedCommunication),
                environment.setReadState(for: selectedCommunication).fireAndForget()
            )
        case let .showPickupCode(dmcCode: dmcCode, hrCode: hrCode):
            state.route = .pickupCode(.init(pickupCodeHR: hrCode, pickupCodeDMC: dmcCode))
            return .none
        case .setNavigation(tag: .none), .pickupCode(action: .close):
            state.route = nil
            return .none
        case let .openUrl(url: url):
            if environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.route = .alert(openUrlAlertState(for: url))
            }
            return .none
        case let .openMail(message):
            state.route = nil
            if let url = createEmailUrl(
                to: L10n.msgsTxtEmailSupport.text,
                subject: L10n.msgsTxtMailSubject.text,
                body: eMailBody(
                    with: message,
                    date: environment.date,
                    deviceInfo: environment.deviceInfo,
                    version: environment.version
                )
            ), environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.route = .alert(openMailAlertState)
            }
            return .none
        case .setNavigation, .pickupCode:
            return .none
        }
    }

    private static func effect(for communication: ErxTask.Communication) -> Effect<Action, Never> {
        guard let payload = communication.payload else {
            let payloadJSON = communication.payloadJSON
            return Effect(value: MessagesDomain.Action.openMail(message: payloadJSON))
        }

        switch payload.supplyOptionsType {
        case .onPremise:
            if payload.pickUpCodeHR != nil || payload.pickUpCodeDMC != nil {
                return Effect(value: MessagesDomain.Action.showPickupCode(
                    dmcCode: payload.pickUpCodeDMC,
                    hrCode: payload.pickUpCodeHR
                ))
            }
            return .none
        case .delivery:
            return .none
        case .shipment:
            if let urlString = payload.url,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                return Effect(value: MessagesDomain.Action.openUrl(url: url))
            }
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pickupCodeReducer,
        domainReducer
    )

    private static let pickupCodeReducer: Reducer =
        PickupCodeDomain.reducer
            ._pullback(
                state: (\State.route).appending(path: /MessagesDomain.Route.pickupCode),
                action: /MessagesDomain.Action.pickupCode(action:)
            ) { messagesEnvironment in
                PickupCodeDomain.Environment(
                    schedulers: messagesEnvironment.schedulers,
                    matrixCodeGenerator: ZXDataMatrixWriter()
                )
            }

    struct DeviceInformations {
        let model: String
        let systemName: String
        let version: String

        init(model: String = UIDevice.current.model,
             systemName: String = UIDevice.current.systemName,
             version: String = UIDevice.current.systemVersion) {
            self.model = model
            self.systemName = systemName
            self.version = version
        }

        var description: String {
            """
            Model: \(model),
            OS:\(systemName) \(version)
            """
        }
    }

    private static func eMailBody(
        with message: String,
        date: Date,
        deviceInfo: DeviceInformations,
        version: String
    ) -> String {
        """
        \(L10n.msgsTxtMailBody1.text)

        \(L10n.msgsTxtMailBody2.text)

        \(message)

        \(L10n.msgsTxtMailError.text)
        \(version)
        \(date.fhirFormattedString(with: .yearMonthDayTime))
        \(deviceInfo.description)
        """
    }

    private static func createEmailUrl(to email: String, subject: String? = nil, body: String? = nil) -> URL? {
        var urlString = URLComponents(string: "mailto:\(email)")
        var queryItems = [URLQueryItem]()

        if let subject = subject {
            queryItems.append(URLQueryItem(name: "subject", value: subject))
        }

        if let body = body {
            queryItems.append(URLQueryItem(name: "body", value: body))
        }

        urlString?.queryItems = queryItems

        return urlString?.url
    }

    static var openMailAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.msgsTxtOpenMailErrorTitle),
            message: TextState(L10n.msgsTxtOpenMailErrorMessage),
            dismissButton: .cancel(TextState(L10n.alertBtnClose))
        )
    }()

    static func openUrlAlertState(for url: URL) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.msgsTxtFormatErrorTitle),
            message: TextState(L10n.msgsTxtFormatErrorMessage),
            primaryButton: .cancel(TextState(L10n.alertBtnClose)),
            secondaryButton: .default(
                TextState(L10n.msgsBtnFormatError),
                action: .send(Action.openMail(message: url.absoluteString))
            )
        )
    }
}

extension MessagesDomain {
    enum Dummies {
        static let communicationOnPremise = ErxTask.Communication(
            identifier: "1",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
        )

        static let communicationShipment = ErxTask.Communication(
            identifier: "2",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.das-e-rezept-fuer-deutschland.de\"}",
            // swiftlint:disable:previous line_length
            isRead: true
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

        static let demoSessionContainer = DummyUserSessionContainer()
        static let state =
            State(communications: [communicationOnPremise, communicationShipment, communicationDelivery])
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
