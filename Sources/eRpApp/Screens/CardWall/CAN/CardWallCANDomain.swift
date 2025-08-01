//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import ComposableArchitecture
import Foundation
import IDP

@Reducer
struct CardWallCANDomain {
    @ObservableState
    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID

        var can: String
        var wrongCANEntered = false
        var scannedCAN: String?
        var isFlashOn = false
        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall_PIN
        case pin(CardWallPINDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        case egk(OrderHealthCardDomain)
        // sourcery: AnalyticsScreen = cardWall_scanCAN
        case scanner
    }

    enum Action: Equatable {
        case update(can: String)
        case advance
        case showScannerView
        case toggleFlashLight
        case flashLightOff
        case successfulScan

        case resetNavigation
        case egkButtonTapped
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
            case navigateToIntro
            case unlockCardClose
        }
    }

    @Dependency(\.profileBasedSessionProvider) var sessionProvider: ProfileBasedSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.feedbackReceiver) var feedbackReceiver

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .update(can: can):
            state.can = can
            return .none
        case .advance:
            guard state.can.lengthOfBytes(using: .utf8) == 6 else {
                return .none
            }
            sessionProvider.userDataStore(for: state.profileId).set(can: state.can)
            state
                .destination = .pin(CardWallPINDomain
                    .State(isDemoModus: state.isDemoModus, profileId: state.profileId, transition: .push))
            return .none
        case .egkButtonTapped:
            state.destination = .egk(.init())
            return .none
        case .toggleFlashLight:
            state.isFlashOn.toggle()
            return .none
        case .showScannerView:
            state.destination = .scanner
            return .none
        case .resetNavigation,
             .destination(.presented(.egk(.delegate(.close)))):
            state.destination = nil
            return .none
        case let .destination(.presented(.pin(.delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                return Effect.send(.delegate(.close))
            case .wrongCanClose:
                state.destination = nil
                return .none
            case .navigateToIntro:
                state.destination = nil
                return .run { send in
                    // Delay for the switch to CardWallExthView, Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 0.05)
                    await send(.delegate(.navigateToIntro))
                }
            case .unlockCardClose:
                return Effect.send(.delegate(.unlockCardClose))
            }
        case .delegate,
             .destination:
            return .none
        case .flashLightOff:
            state.isFlashOn = false
            return .none
        case .successfulScan:
            feedbackReceiver.hapticFeedbackSuccess()
            return .none
        }
    }
}

extension CardWallCANDomain {
    enum Dummies {
        static let state = State(isDemoModus: false, profileId: UUID(), can: "")

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<CardWallCANDomain> {
            Store(initialState: state) {
                CardWallCANDomain()
            }
        }
    }
}
