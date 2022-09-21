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
import IDP

enum CardWallCANDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case pin(CardWallPINDomain.State)
        case egk
        case scanner

        enum Tag: Int {
            case pin
            case egk
            case scanner
        }

        var tag: Tag {
            switch self {
            case .pin:
                return .pin
            case .egk:
                return .egk
            case .scanner:
                return .scanner
            }
        }
    }

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID

        var can: String
        var wrongCANEntered = false
        var scannedCAN: String?
        var isFlashOn = false
        var route: Route?
    }

    indirect enum Action: Equatable {
        case update(can: String)
        case advance
        case showEGKOrderInfoView
        case close
        case showScannerView
        case toggleFlashLight
        case pinAction(action: CardWallPINDomain.Action)
        case setNavigation(tag: Route.Tag?)
        case navigateToIntro
    }

    struct Environment {
        var sessionProvider: ProfileBasedSessionProvider
        let signatureProvider: SecureEnclaveSignatureProvider
        var userSession: UserSession
        let accessibilityAnnouncementReceiver: (String) -> Void
        var schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .update(can: can):
            state.can = can
            return .none
        case .advance:
            guard state.can.lengthOfBytes(using: .utf8) == 6 else {
                return .none
            }
            environment.sessionProvider.userDataStore(for: state.profileId).set(can: state.can)
            state.route = .pin(CardWallPINDomain.State(isDemoModus: state.isDemoModus))
            return .none
        case .close:
            return .none
        case .showEGKOrderInfoView:
            state.route = .egk
            return .none
        case .toggleFlashLight:
            state.isFlashOn.toggle()
            return .none
        case .showScannerView:
            state.route = .scanner
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .pinAction(.wrongCanClose):
            state.route = nil
            return .none
        case .pinAction(.close):
            return Effect(value: .close)
        case .pinAction(.navigateToIntro):
            state.route = nil
            return Effect(value: .navigateToIntro)
                // Delay for the switch to CardWallExthView, Workaround for TCA pullback problem
                .delay(for: 0.01, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation,
             .navigateToIntro,
             .pinAction:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        pinPullbackReducer,
        domainReducer
    )

    static let pinPullbackReducer: Reducer =
        CardWallPINDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.pin),
            action: /Action.pinAction(action:)
        ) { environment in
            CardWallPINDomain.Environment(
                userSession: environment.userSession,
                schedulers: environment.schedulers,
                sessionProvider: environment.sessionProvider,
                signatureProvider: environment.signatureProvider,
                accessibilityAnnouncementReceiver: environment.accessibilityAnnouncementReceiver
            )
        }
}

extension CardWallCANDomain {
    enum Dummies {
        static let state = State(isDemoModus: true, profileId: UUID(), can: "")
        static let environment = Environment(sessionProvider: DummyProfileBasedSessionProvider(),
                                             signatureProvider: DummySecureEnclaveSignatureProvider(),
                                             userSession: DemoSessionContainer(schedulers: Schedulers()),
                                             accessibilityAnnouncementReceiver: { _ in },
                                             schedulers: Schedulers())

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
