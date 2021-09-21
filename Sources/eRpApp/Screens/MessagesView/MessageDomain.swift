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
import ComposableArchitecture
import eRpKit
import SwiftUI
import ZXingObjC

enum MessageDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable, Identifiable {
        var communication: ErxTask.Communication
        var pickupCodeViewState: PickupCodeDomain.State?
        var alertState: AlertState<Action>?
        var id: ErxTask.Communication.ID { // swiftlint:disable:this identifier_name
            communication.identifier
        }
    }

    enum Action: Equatable {
        case didSelect
        case showPickupCode(dmcCode: String?, hrCode: String?)
        case pickupCode(action: PickupCodeDomain.Action)
        case dismissPickupCodeView
        case openUrl(url: URL)
        case openMail(message: String)
        case alertDismissButtonTapped
    }

    struct Environment {
        internal init(schedulers: Schedulers,
                      application: ResourceHandler,
                      date: Date = Date(),
                      deviceInfo: MessageDomain.DeviceInformations = DeviceInformations(),
                      version: String = AppVersion.current.description) {
            self.schedulers = schedulers
            self.application = application
            self.date = date
            self.deviceInfo = deviceInfo
            self.version = version
        }

        let schedulers: Schedulers
        let application: ResourceHandler
        let date: Date
        let deviceInfo: DeviceInformations
        let version: String
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .didSelect:
            guard let payload = state.communication.payload else {
                let payloadJSON = state.communication.payloadJSON
                return Effect(value: MessageDomain.Action.openMail(message: payloadJSON))
            }
            return effect(for: payload)
        case let .showPickupCode(dmcCode: dmcCode, hrCode: hrCode):
            state.pickupCodeViewState = PickupCodeDomain.State(
                pickupCodeHR: hrCode,
                pickupCodeDMC: dmcCode
            )
            return .none
        case .dismissPickupCodeView, .pickupCode(action: .close):
            state.pickupCodeViewState = nil
            return .none
        case .pickupCode:
            return .none
        case let .openUrl(url):
            if environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.alertState = openUrlAlertState(for: url)
            }
            return .none
        case let .openMail(message):
            state.alertState = nil
            if let url = createEmailUrl(
                to: NSLocalizedString("msgs_txt_email_support", comment: ""),
                subject: NSLocalizedString("msgs_txt_mail_subject", comment: ""),
                body: eMailBody(
                    with: message,
                    date: environment.date,
                    deviceInfo: environment.deviceInfo,
                    version: environment.version
                )
            ), environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.alertState = openMailAlertState
            }
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pickupCodeReducer,
        domainReducer
    )

    private static let pickupCodeReducer: Reducer =
        PickupCodeDomain.reducer.optional()
            .pullback(
                state: \.pickupCodeViewState,
                action: /MessageDomain.Action.pickupCode(action:)
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
        \(NSLocalizedString("msgs_txt_mail_body1", comment: ""))

        \(NSLocalizedString("msgs_txt_mail_body2", comment: ""))

        \(message)

        \(NSLocalizedString("msgs_txt_mail_error", comment: ""))
        \(version)
        \(date.fhirFormattedString(with: .yearMonthDayTime))
        \(deviceInfo.description)
        """
    }

    private static func effect(for payload: ErxTask.Communication.Payload) -> Effect<Action, Never> {
        switch payload.supplyOptionsType {
        case .onPremise:
            if payload.pickUpCodeHR != nil || payload.pickUpCodeDMC != nil {
                return Effect(value: MessageDomain.Action.showPickupCode(
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
                return Effect(value: MessageDomain.Action.openUrl(url: url))
            }
            return .none
        }
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
            dismissButton: .cancel()
        )
    }()

    static func openUrlAlertState(for url: URL) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.msgsTxtFormatErrorTitle),
            message: TextState(L10n.msgsTxtFormatErrorMessage),
            primaryButton: .cancel(),
            secondaryButton: .default(
                TextState(L10n.msgsBtnFormatError),
                send: Action.openMail(message: url.absoluteString)
            )
        )
    }
}
