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
@_spi(Internals)
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class AppStartDomainTests: XCTestCase {
    var mockUserDataStore: MockUserDataStore!
    static let now = Date()

    typealias TestStore = TestStoreOf<AppStartDomain>

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
    }

    private func testStore(with state: AppStartDomain.State = .init()) -> TestStore {
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        return TestStore(initialState: state) {
            AppStartDomain()
        } withDependencies: { dependencies in
            dependencies.userSession = MockUserSession()
            dependencies.userDataStore = mockUserDataStore
            dependencies.schedulers = Schedulers(
                uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler()
            )
            dependencies.appSecurityManager = MockAppSecurityManager()
            dependencies.router = MockRouting()
            dependencies.date = DateGenerator.constant(Self.now)
        }
    }

    func testStartAppWithOnboardingState() async {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(false).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just(nil).eraseToAnyPublisher()

        store.dependencies.userDataStore = mockUserDataStore
        store.dependencies.currentAppVersion = .previewValue

        await store.send(.refreshOnboardingState)
        // when receiving onboarding with version
        await store.receive(.refreshOnboardingStateReceived(version: OnboardingDomain.Version.none)) {
            // onboarding should be presented
            $0.destination = .onboarding(OnboardingDomain.State(version: OnboardingDomain.Version.none))
        }

        // when onboarding was dismissed
        await store.send(.destination(.onboarding(.dismissOnboarding))) {
            // than app should be presented
            $0.destination = .app(
                AppDomain.State(
                    destination: .main,
                    main: MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    ),
                    pharmacy: PharmacyContainerDomain.State(
                        pharmacySearch: PharmacySearchDomain.State(
                            selectedPrescriptions: Shared(value: []),
                            inRedeemProcess: false,
                            pharmacyFilterOptions: Shared(value: [])
                        )
                    ),
                    orders: OrdersDomain.State(communicationMessage: []),
                    settings: SettingsDomain.State(isDemoMode: false),
                    unreadOrderMessageCount: 0,
                    unreadInternalCommunicationCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testStartAppWithAppState() async {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(true).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just("version").eraseToAnyPublisher()

        await store.send(.refreshOnboardingState)
        await store.receive(.refreshOnboardingStateReceived(
            version: OnboardingDomain.Version(rawVersion: "3.10.0")
        )) {
            $0.destination = .app(
                AppDomain.State(
                    destination: .main,
                    main: MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    ),
                    pharmacy: PharmacyContainerDomain.State(
                        pharmacySearch: PharmacySearchDomain.State(
                            selectedPrescriptions: Shared(value: []),
                            inRedeemProcess: false,
                            pharmacyFilterOptions: Shared(value: [])
                        )
                    ),
                    orders: OrdersDomain.State(communicationMessage: []),
                    settings: .init(isDemoMode: false),
                    unreadOrderMessageCount: 0,
                    unreadInternalCommunicationCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testRouterSharingDeepLinkRouting() async {
        await withDependencies { dependencies in
            dependencies.schedulers = .immediate
        } operation: {
            let sut = AppStartDomain.router

            let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/prescription#")!

            let expected1 = AppStartDomain.Action
                .destination(.app(.main(action: .setNavigation(tag: nil))))
            let expected2 = AppStartDomain.Action.destination(.app(.setNavigation(.main)))
            let expected3 = AppStartDomain.Action.destination(.app(.main(action: .importTaskByUrl(url))))
            let expectedActions = [expected1, expected2, expected3]

            var receivedActions: [AppStartDomain.Action] = []
            for await action in sut(Endpoint.universalLink(url)).actions {
                receivedActions.append(action)
            }

            // then
            expect(receivedActions).to(equal(expectedActions))
        }
    }

    func testRouterSharingDeepExtAuth() async {
        await withDependencies { dependencies in
            dependencies.schedulers = .immediate
        } operation: {
            let sut = AppStartDomain.router

            let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/extauth/")!

            let expected1 = AppStartDomain.Action
                .destination(.app(.main(action: .setNavigation(tag: nil))))
            let expected2 = AppStartDomain.Action.destination(.app(.setNavigation(.main)))
            let expected3 = AppStartDomain.Action.destination(.app(.main(action: .externalLogin(url))))
            let expectedActions = [expected1, expected2, expected3]

            var receivedActions: [AppStartDomain.Action] = []
            for await action in sut(Endpoint.universalLink(url)).actions {
                receivedActions.append(action)
            }

            expect(receivedActions).to(equal(expectedActions))
        }
    }

    func testRouterRouteToMainScreenLogin() async {
        await withDependencies { dependencies in
            dependencies.schedulers = .immediate
        } operation: {
            // given
            let sut = AppStartDomain.router

            let expected1 = AppStartDomain.Action
                .destination(.app(.main(action: .setNavigation(tag: nil))))
            let expected2 = AppStartDomain.Action.destination(.app(.setNavigation(.main)))
            let expected3 = AppStartDomain.Action
                .destination(.app(.main(action: .prescriptionList(action: .refresh))))
            let expectedActions = [expected1, expected2, expected3]

            // when
            var receivedActions: [AppStartDomain.Action] = []
            for await action in sut(Endpoint.mainScreen(.login)).actions {
                receivedActions.append(action)
            }

            // then
            expect(receivedActions).to(equal(expectedActions))
        }
    }

    func testRouterRouteToSettingsUnlockCard() async {
        await withDependencies { dependencies in
            dependencies.schedulers = .immediate
        } operation: {
            // given
            let sut = AppStartDomain.router

            let expected1 = AppStartDomain.Action.destination(.app(.settings(action: .popToRootView)))
            let expected2 = AppStartDomain.Action.destination(.app(.setNavigation(.settings)))
            let expected3 = AppStartDomain.Action.destination(.app(
                .settings(action: .tappedUnlockCard)
            ))
            let expectedActions = [expected1, expected2, expected3]

            // when
            var receivedActions: [AppStartDomain.Action] = []
            for await action in sut(Endpoint.settings(.unlockCard)).actions {
                receivedActions.append(action)
            }

            // then
            expect(receivedActions).to(equal(expectedActions))
        }
    }
}

struct AppStartDomainActionComparator: SortComparator {
    typealias Compared = AppStartDomain.Action

    func compare(_ lhs: AppStartDomain.Action, _ rhs: AppStartDomain.Action) -> ComparisonResult {
        if String(describing: lhs) < String(describing: rhs) {
            return .orderedAscending
        } else if String(describing: lhs) > String(describing: rhs) {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }

    var order: SortOrder
    static let forward = Self(order: .forward)
}
