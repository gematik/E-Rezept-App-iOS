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
@testable import eRpApp
import eRpKit
import XCTest

final class AppStartDomainTests: XCTestCase {
    var mockUserDataStore = MockUserDataStore()

    typealias TestStore = ComposableArchitecture.TestStore<
        AppStartDomain.State,
        AppStartDomain.State,
        AppStartDomain.Action,
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
                userSessionContainer: MockUserSessionContainer(),
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
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true))
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
                    selectedTab: .main,
                    main: MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.State(trackingOptOut: DummyTracker().optOut)
                    ),
                    messages: MessagesDomain.State(messageDomainStates: []),
                    unreadMessagesCount: 0,
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
                    selectedTab: .main,
                    main: MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.State(trackingOptOut: DummyTracker().optOut)
                    ),
                    messages: MessagesDomain.State(messageDomainStates: []),
                    unreadMessagesCount: 0,
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
                    selectedTab: .main,
                    main: MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.State(trackingOptOut: DummyTracker().optOut)
                    ),
                    messages: MessagesDomain.State(messageDomainStates: []),
                    unreadMessagesCount: 0,
                    isDemoMode: false
                )
            )
        }
    }
}