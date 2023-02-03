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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class AppStartDomainTests: XCTestCase {
    var mockUserDataStore = MockUserDataStore()

    typealias TestStore = ComposableArchitecture.TestStore<
        AppStartDomain.State,
        AppStartDomain.Action,
        AppStartDomain.State,
        AppStartDomain.Action,
        AppStartDomain.Environment
    >

    private func testStore(with state: AppStartDomain.State = .init()) -> TestStore {
        TestStore(
            initialState: state,
            reducer: AppStartDomain.reducer,
            environment: AppStartDomain.Environment(
                appVersion: AppVersion.current,
                router: MockRouting(),
                userSessionContainer: MockUsersSessionContainer(),
                userSession: MockUserSession(),
                userDataStore: mockUserDataStore,
                schedulers: Schedulers(
                    uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler()
                ),
                fhirDateFormatter: FHIRDateFormatter.shared,
                serviceLocator: ServiceLocator(),
                accessibilityAnnouncementReceiver: { _ in },
                tracker: DummyTracker(),
                signatureProvider: DummySecureEnclaveSignatureProvider(),
                appSecurityManager: MockAppSecurityManager(),
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true)),
                userSessionProvider: MockUserSessionProvider()
            )
        )
    }

    func testStartAppWithOnboardingState() {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(false).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just(nil).eraseToAnyPublisher()

        store.send(.refreshOnboardingState)
        // when receiving onboarding with composition
        store.receive(.refreshOnboardingStateReceived(OnboardingDomain.Composition.allPages)) {
            // onboarding should be presented
            $0 = .onboarding(OnboardingDomain.State(composition: OnboardingDomain.Composition.allPages))
        }
        // when onboarding was dismissed
        store.send(.onboarding(action: .dismissOnboarding)) {
            // than app should be presented
            $0 = .app(
                AppDomain.State(
                    route: .main,
                    main: MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    ),
                    pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                    orders: OrdersDomain.State(orders: []),
                    settingsState: SettingsDomain.State(isDemoMode: false,
                                                        appSecurityState: .init(
                                                            availableSecurityOptions: [.password],
                                                            selectedSecurityOption: nil,
                                                            errorToDisplay: nil
                                                        )),
                    profileSelection: .init(),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testStartAppWithOnlyLegacyOnboardingState() {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(true).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just(nil).eraseToAnyPublisher()

        let expectedComposition = OnboardingDomain.Composition(
            currentPageIndex: 0,
            pages: [OnboardingDomain.Page.altRegisterAuthentication],
            hideOnboardingLegacy: true
        )

        store.send(.refreshOnboardingState)
        // when receiving onboarding with composition
        store.receive(.refreshOnboardingStateReceived(expectedComposition)) {
            // onboarding should be presented
            $0 = .onboarding(OnboardingDomain.State(composition: expectedComposition))
        }
        // when onboarding was dismissed
        store.send(.onboarding(action: .dismissOnboarding)) {
            // than app should be presented
            $0 = .app(
                AppDomain.State(
                    route: .main,
                    main: MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    ),
                    pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                    orders: OrdersDomain.State(orders: []),
                    settingsState: .init(isDemoMode: false,
                                         appSecurityState: .init(
                                             availableSecurityOptions: [.password],
                                             selectedSecurityOption: nil,
                                             errorToDisplay: nil
                                         )),
                    profileSelection: .init(),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testStartAppWithAppState() {
        let store = testStore()
        mockUserDataStore.hideOnboarding = Just(true).eraseToAnyPublisher()
        mockUserDataStore.onboardingVersion = Just("version").eraseToAnyPublisher()

        store.send(.refreshOnboardingState)
        store.receive(.refreshOnboardingStateReceived(OnboardingDomain.Composition(hideOnboardingLegacy: true,
                                                                                   onboardingVersion: "version"))) {
            $0 = .app(
                AppDomain.State(
                    route: .main,
                    main: MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    ),
                    pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                    orders: OrdersDomain.State(orders: []),
                    settingsState: .init(isDemoMode: false,
                                         appSecurityState:
                                         .init(availableSecurityOptions: [.password],
                                               selectedSecurityOption: nil,
                                               errorToDisplay: nil)),
                    profileSelection: .init(),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
        }
    }

    func testRouterSharingDeepLinkRouting() {
        let sut = AppStartDomain.router

        let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/prescription#")!

        let expected = AppStartDomain.Action.app(action: .main(action: .importTaskByUrl(url)))

        var success = false

        sut(Endpoint.universalLink(url)).test(
            failure: { _ in
                // cannot happen, is never
            }, expectations: { action in
                expect(action).to(equal(expected))
                success = true
            }
        )

        expect(success).to(equal(true))
    }

    func testRouterSharingDeepExtAuth() {
        let sut = AppStartDomain.router

        let url = URL(string: "https://das-e-rezept-fuer-deutschland.de/extauth/")!

        let expected = AppStartDomain.Action.app(action: .main(action: .externalLogin(url)))

        var success = false

        sut(Endpoint.universalLink(url)).test(
            failure: { _ in
                // cannot happen, is never
            }, expectations: { action in
                expect(action).to(equal(expected))
                success = true
            }
        )

        expect(success).to(equal(true))
    }
}
