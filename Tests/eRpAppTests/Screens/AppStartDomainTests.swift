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
@_spi(Internals)
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

@MainActor
final class AppStartDomainTests: XCTestCase {
    var mockUserDataStore: MockUserDataStore!

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
        }
    }

    func testStartAppWithOnboardingState() async {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(false).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just(nil).eraseToAnyPublisher()

        store.dependencies.userDataStore = mockUserDataStore
        store.dependencies.currentAppVersion = .previewValue

        await store.send(.refreshOnboardingState)
        // when receiving onboarding with composition
        await store.receive(.refreshOnboardingStateReceived(OnboardingDomain.Composition.allPages)) {
            // onboarding should be presented
            $0 = .onboarding(OnboardingDomain.State(composition: OnboardingDomain.Composition.allPages))
        }

        // when onboarding was dismissed
        await store.send(.onboarding(action: .dismissOnboarding)) {
            // than app should be presented
            $0 = .app(
                AppDomain.State(
                    destination: .main,
                    subdomains: .init(
                        main: MainDomain.State(
                            prescriptionListState: PrescriptionListDomain.State(),
                            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                        ),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settingsState: SettingsDomain.State(isDemoMode: false)
                    ),
                    unreadOrderMessageCount: 0,
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
            OnboardingDomain.Composition()
        )) {
            $0 = .app(
                AppDomain.State(
                    destination: .main,
                    subdomains: .init(
                        main: MainDomain.State(
                            prescriptionListState: PrescriptionListDomain.State(),
                            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                        ),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settingsState: .init(isDemoMode: false)
                    ),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testRouterSharingDeepLinkRouting() async {
        let sut = AppStartDomain.router

        let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/prescription#")!

        let expected = AppStartDomain.Action.app(action: .subdomains(.main(action: .importTaskByUrl(url))))
        let expectedActions = [expected]

        var receivedActions: [AppStartDomain.Action] = []
        for await action in sut(Endpoint.universalLink(url)).actions {
            receivedActions.append(action)
        }

        // then
        let sortComparator = AppStartDomainActionComparator.forward
        expect(receivedActions.sorted(using: sortComparator)).to(equal(expectedActions.sorted(using: sortComparator)))
    }

    func testRouterSharingDeepExtAuth() async {
        let sut = AppStartDomain.router

        let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/extauth/")!

        let expected = AppStartDomain.Action.app(action: .subdomains(.main(action: .externalLogin(url))))
        let expectedActions = [expected]

        var receivedActions: [AppStartDomain.Action] = []
        for await action in sut(Endpoint.universalLink(url)).actions {
            receivedActions.append(action)
        }

        let sortComparator = AppStartDomainActionComparator.forward
        expect(receivedActions.sorted(using: sortComparator)).to(equal(expectedActions.sorted(using: sortComparator)))
    }

    func testRouterRouteToMainScreenLogin() async {
        // given
        let sut = AppStartDomain.router

        let expected1 = AppStartDomain.Action.app(action: .setNavigation(.main))
        let expected2 = AppStartDomain.Action
            .app(action: .subdomains(.main(action: .prescriptionList(action: .refresh))))
        let expectedActions = [expected1, expected2]

        // when
        var receivedActions: [AppStartDomain.Action] = []
        for await action in sut(Endpoint.mainScreen(.login)).actions {
            receivedActions.append(action)
        }

        // then
        let sortComparator = AppStartDomainActionComparator.forward
        expect(receivedActions.sorted(using: sortComparator)).to(equal(expectedActions.sorted(using: sortComparator)))
    }
}

struct AppStartDomainActionComparator: SortComparator {
    typealias Compared = AppStartDomain.Action

    func compare(_ lhs: eRpApp.AppStartDomain.Action, _ rhs: eRpApp.AppStartDomain.Action) -> ComparisonResult {
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
