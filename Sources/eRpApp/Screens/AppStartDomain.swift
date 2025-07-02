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
import eRpKit
import IDP
import SwiftUI

@Reducer
struct AppStartDomain {
    typealias Store = StoreOf<Self>

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case loading
        case onboarding(OnboardingDomain)
        case app(AppDomain)
    }

    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .loading
    }

    enum Action: Equatable {
        case refreshOnboardingState
        case refreshOnboardingStateReceived(version: OnboardingDomain.Version?)

        case destination(Destination.Action)
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

    var body: some Reducer<State, Action> {
        Scope(state: \.destination, action: \.destination) {
            Reduce(Destination.body)
        }

        Reduce { state, action in
            switch action {
            case .destination(.onboarding(.dismissOnboarding)):
                state.destination = .app(
                    AppDomain.State(
                        destination: .main,
                        main: .init(
                            prescriptionListState: PrescriptionListDomain.State(),
                            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                        ),
                        pharmacy: PharmacyContainerDomain.State(
                            pharmacySearch: .init(
                                selectedPrescriptions: Shared(value: []),
                                inRedeemProcess: false
                            )
                        ),
                        orders: OrdersDomain.State(),
                        settings: .init(
                            isDemoMode: userSession.isDemoMode
                        ),
                        unreadOrderMessageCount: 0,
                        unreadInternalCommunicationCount: 0,
                        isDemoMode: false
                    )
                )
                return .none
            case .refreshOnboardingState:
                return .publisher(
                    userDataStore.onboardingVersion
                        .first()
                        .receive(on: schedulers.main)
                        .map(OnboardingDomain.Version.init(rawVersion:))
                        .map(AppStartDomain.Action.refreshOnboardingStateReceived)
                        .eraseToAnyPublisher
                )

            case let .refreshOnboardingStateReceived(version):
                if let version {
                    state.destination = .onboarding(OnboardingDomain.State(version: version))
                    return .none
                }
                state.destination = .app(
                    AppDomain.State(
                        destination: .main,
                        main: .init(prescriptionListState: .init(),
                                    horizontalProfileSelectionState: .init()),
                        pharmacy: PharmacyContainerDomain.State(
                            pharmacySearch: .init(
                                selectedPrescriptions: Shared(value: []),
                                inRedeemProcess: false
                            )
                        ),
                        orders: OrdersDomain.State(),
                        settings: .init(isDemoMode: userSession.isDemoMode),
                        unreadOrderMessageCount: 0,
                        unreadInternalCommunicationCount: 0,
                        isDemoMode: false
                    )
                )
                return .none
            case .destination:
                return .none
            }
        }
    }

    static let router: (Endpoint) -> Effect<Action> = { route in
        switch route {
        case let .settings(endpoint):
            switch endpoint {
            case .unlockCard:
                return .run { send in
                    // reset destination of settings tab
                    await send(.destination(.app(.settings(action: .popToRootView))))
                    // wait for running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to the settings tab
                    await send(.destination(.app(.setNavigation(.settings))))
                    // set actual destination in settings tab
                    await send(
                        .destination(
                            .app(.settings(action: .tappedUnlockCard))
                        )
                    )
                }
            case let .editProfile(editProfile):
                switch editProfile {
                case let .chargeItemListFor(profileId):
                    return .run { send in
                        // reset destination of settings tab
                        await send(.destination(.app(.settings(action: .popToRootView))))
                        // wait for running effects to finish
                        @Dependency(\.schedulers) var schedulers
                        try await schedulers.main.sleep(for: 0.5)
                        // switch to settings tab
                        await send(.destination(.app(.setNavigation(.settings))))
                        // set actual destination in settings tab
                        await send(
                            .destination(
                                .app(.settings(action: .showChargeItemListFor(profileId: profileId)))
                            )
                        )
                    }
                }
            case .medicationSchedule:
                return .run { send in
                    // reset destination of settings tab
                    await send(.destination(.app(.settings(action: .popToRootView))))
                    // wait for running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to settings tab
                    await send(.destination(.app(.setNavigation(.settings))))
                    // set actual destination in settings tab
                    await send(
                        .destination(.app(.settings(action: .showMedicationReminderList)))
                    )
                }
            default:
                return .run { send in
                    await send(.destination(.app(.settings(action: .popToRootView))))
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.destination(.app(.setNavigation(.settings))))
                }
            }

        case .scanner:
            return .run { send in
                // reset destination of settings tab
                await send(.destination(.app(.main(action: .setNavigation(tag: .none)))))
                // wait for possible running effects to finish
                @Dependency(\.schedulers) var schedulers
                try await schedulers.main.sleep(for: 0.5)
                // switch to main tab
                await send(.destination(.app(.setNavigation(.main))))
                // set actual destination in main tab
                await send(.destination(.app(.main(action: .showScannerView))))
            }
        case .orders:
            return .run { send in
                // reset destination of orders tab
                await send(.destination(.app(.orders(action: .resetNavigation))))
                // wait for possible running effects to finish
                @Dependency(\.schedulers) var schedulers
                try await schedulers.main.sleep(for: 0.5)
                // switch to orders tab
                await send(.destination(.app(.setNavigation(.orders))))
            }
        case let .mainScreen(endpoint):
            switch endpoint {
            case let .medicationReminder(scheduleEntries):
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.main(action: .setNavigation(tag: nil)))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(
                        .destination(.app(.main(action: .showMedicationReminder(scheduleEntries))))
                    )
                }
            case .login:
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.main(action: .setNavigation(tag: nil)))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.main(action: .prescriptionList(action: .refresh)))))
                }
            default:
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.main(action: .setNavigation(tag: nil)))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                }
            }
        // [REQ:BSI-eRp-ePA:O.Source_1#6] External application calls via Universal Linking
        case let .universalLink(url):
            switch url.path {
            // [REQ:gemSpec_IDP_Frontend:A_22301-01#4] App2App gID will trigger this case
            case "/extauth":
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.main(action: .setNavigation(tag: nil)))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // // [REQ:gemSpec_IDP_Frontend:A_22301-01#5] set actual destination in main tab
                    await send(.destination(.app(.main(action: .externalLogin(url)))))
                }
            case "/pharmacies/index.html",
                 "/pharmacies":
                return .run { send in
                    // reset destination of pharmacy tab
                    await send(.destination(.app(.pharmacy(action: .pharmacySearch(.resetNavigation)))))
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.destination(.app(.setNavigation(.pharmacy))))
                    // set actual destination in pharmacy tab
                    await send(.destination(.app(.pharmacy(action: .pharmacySearch(.universalLink(url))))))
                }
            case "/prescription":
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.main(action: .setNavigation(tag: nil)))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.main(action: .importTaskByUrl(url)))))
                }
            default:
                return .none
            }
        }
    }
}
